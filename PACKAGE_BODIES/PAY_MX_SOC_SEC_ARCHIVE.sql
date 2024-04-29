--------------------------------------------------------
--  DDL for Package Body PAY_MX_SOC_SEC_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_SOC_SEC_ARCHIVE" AS
/* $Header: paymxsocsecarch.pkb 120.65.12010000.18 2009/11/19 11:10:39 sjawid ship $ */
/*
 +=======================================================================+
 |                Copyright (c) 2003 Oracle Corporation                  |
 |                   Redwood Shores, California, USA                     |
 |                        All rights reserved.                           |
 +=======================================================================+
 Package Header Name : pay_mx_soc_sec_archive
 Package File Name   : paymxsocsecarch.pkb

 Description : Used for Social Security Archiver.

 Change List:
 ------------

 Name          Date        Version Bug     Text
 ------------- ----------- ------- ------- ---------------------------------
 vpandya       28-Apr-2005 115.0           Initial Version
 vpandya       02-Jun-2005 115.1   4409303 Changed get_start_date function
                                           and required procedures
                                           for SUA functionality.
 vmehta        14-Jun-2005 115.2   4431932 corrected the parameters in the
                                           call to pay_mx_ff_udfs.get_idw
 vmehta        17-Jun-2005 115.3   4435714 Initialized gn_implementation to
                                           zero so that person data is
                                           re-archived upon retry
 vmehta        19-Jun-2005 115.4           Moved get_idw in the arch_hire_sep
                                           procedure so that it is called for
                                           the hire transaction with the hire
                                           date.
 vmehta        22-Jun-2005 115.5           Procedure get_start_date:
                                           Modified to get default
                                           implementation date when the
                                           implementation date at LE is null

                                           Modified arch_other_transactions
                                           look for Fixed IDW based on
                                           element extra info, Variable IDW
                                           based on secondary classification
                                           and absence/disability based on
                                           element entry creator type
                                           Only archive those absence
                                           transactions that are marked as
                                           'Report to Social Security' on
                                           Further Absence type DDF.
 vmehta       27-Jun-2005 115.6   4455393  Changed range_cursor and the
                                           action creation cursor so that
                                           assignments terminated or rehired
                                           at a previous date are also picked
                                           up
 vmehta      27-Jun-2005  115.7   4458243  Modified the way hire and
                                           separation transactions are
                                           processed in
                                           archive_hire_sep_transactions
 vmehta      27-Jun-2005  115.8            Fixed GSCC error
 vpandya     11-Jul-2005  115.11           Added logic for INFONAVIT Info.
 vpandya     18-Jul-2005  115.12           Added logic for variable IDW.
                                           Changed following procedures:
                                           - range_cursor
                                           - action_creation
                                           - archinit
                                           - arch_other_transaction
 vpandya     21-Jul-2005  115.13  4450685  Added logic to create only one
                                           record for Hire/Separation if it
                                           follows by the same record.
 vpandya     27-Jul-2005  115.14           Changed logic in range cursor and
                                           action creation cursors. Archiver
                                           can be run with bimonthly option
                                           more than one time for the same
                                           period and pick only those asg
                                           that are not picked before for
                                           the same period for bimonthly.
 vpandya     28-Jul-2005  115.15           Changed logic in range cursor and
                                           action_creation. Now variable
                                           gv_periodic_end_date is used for
                                           getting assingments for variable
                                           salary change.
 vpandya     05-Aug-2005  115.16           Ignore transaction if eff date of
                                           event is 31-Dec-4712 as per VM.
 vpandya     17-Aug-2005  115.17  4558178  Passing lv_transmitter_gre_id to
                                           c_get_org_information cursor
                                           instead of lv_transmitter.
 vpandya     18-Aug-2005  115.18  4561824  Added a condition in cursor
                                           c_minimum_wage_zonea to get the
                                           correct minimum wage based on
                                           the effective_date.
 vpandya     31-Oct-2005  115.19  4710619  Changed range_cursor procedure.
                                           Stamping 31-Dec-4712 in eff date
                                           in pay_payroll_actions table
                                           to view terminated and
                                           rehired employees transactions.
 sdahiya     28-Dec-2005  115.20           Support for salary change
                                           transaction caused due to
                                           seniority changes and IDW factor
                                           table updates.
 sdahiya     28-Jan-2006  115.21  5002283  Modified cursor c_IDW_events to
                                           fetch element entry updates done
                                           in "Update" mode in addition to
                                           "Correction" mode.
 sdahiya     01-Feb-2006  115.22           Modified cursor c_IDW_events to
                                           use events' effective date
                                           (instead of creation date) for IDW
                                           calculation.
 sdahiya     01-Feb-2006  115.23  5002283  Modified cursor c_IDW_events to
                                           use events' effective date
                                           (instead of creation date) to
                                           date effectively identify element
                                           entries and element types.
 sdahiya     02-Feb-2006  115.24           Modified action_creation and
                                           archinit to stamp appropriate date
                                           in pay_recorded_requests when
                                           archiver is run in retry mode.
 sdahiya     10-Apr-2006  115.25  5146225  Modified function get_idw to call
                                           pay_mx_ff_udfs.get_idw in
                                           BIMONTH_REPORT mode only if
                                           gv_variable_idw is 'Y'.
 sdahiya     17-Apr-2006  115.26  5005254  Archiver should archive
                                           termination date instead of a day
                                           prior to the date stamped in
                                           pay_process_events.
 sdahiya     19-Apr-2006  115.27           Calculate IDW on
                                           LEAST(assignment's end date,
                                                            process end date)
 sdahiya     11-May-2006  115.28  5033056  Modified cursor c_person_detail
                                           to select future dated hires for
                                           archival.
 vpandya     18-May-2006  115.29  5234584  Modified cursor c_person_detail
                                           to select future dated hires and
                                           for any UPDATE or CORRECTION in
                                           employee name.
 sdahiya     19-Jun-2006  115.30           SUA 2006 changes.
 vpandya     22-Jun-2006  115.31  5353025  Changed c_abs_info cursor.
                                           Now passing eff start and end date
                                           of element entry instead of the
                                           archiver.
 sdahiya     27-Jun-2006  115.32  5354858  Modified all references involving
                                           INFONAVIT element entries to
                                           consider INFONAVIT transactions
                                           occuring in future with respect to
                                           archiver's end date.
 sdahiya     28-Jun-2006  115.33  5355325  Removed undesired join with
                                           pay_element_entry_values_f in
                                           cursor c_abs_info.
 vpandya     25-Aug-2006  115.34           Initializing gn_implementation to
                                           zero when there is no payroll
                                           action before the current one so
                                           that if retry is run  for the
                                           very first SS Archiver process
                                           after running SS Archiver multiple
                                           times, it should archive Person
                                           Information.
                                           Also Changed value for rww.
                                           Added logic for separation.
 sdahiya     20-Sep-2006  115.35  5552692  'S' should be archived if
                                           Reduction Table Applies input
                                           value is 'Y'.
 sdahiya     23-Sep-2006  115.36  5558838  INFONAVIT transactions effective in
                                           past with respect to archiver
                                           start date should be considered
                                           for transactions 18, 19 and 20.
 vmehta      26-Sep-2006  115.37  5568202  modified load_infonavit_trans to
                                           call load_infonavit_info with
                                           effective_start_date + 1
                                           and effective_end_date + 1
                                           This to ensure that we load the
                                           structure with current values and
                                           not old values.
 sdahiya     24-Jan-2007  115.38           Modified the archiver so that
                                           transaction date is now archived
                                           in action_information2 and employer
                                           SS identifier in action_information5.
                                           Data upgrade will be carried out
                                           using the generic upgrade mechanism.
                                           Function arch_exists_without_upgrade
                                           created to restrict running of
                                           archiver without upgrading existing
                                           archived data.
 sdahiya     13-Feb-2007  115.39  5875096  Fixed get_person_information so that
                                           it uses correct dates to fetch person
                                           data for future dated events.
 sdahiya     06-Mar-2007  115.40  5908010  Only those assignments which belong
                                           to the current GRE should be
                                           considered to fetch person data.
 sdahiya     13-Mar-2007  115.41  5921945, Each event should be checked for its
                                  5899264, existence under GRE for which
                                  5922046  archiver is run.
 sdahiya     14-Mar-2007  115.42  5888285  Events for EFFECTIVE_END_DATE should
                                           be ignored if future asg records
                                           exist.
 vpandya     20-Mar-2007  115.43  5944540  Leapfrog ver 115.37 to resolve R12
                                           Branch Line issue.
 vpandya     20-Mar-2007  115.44           This is the same as 115.42.
 sdahiya     21-Mar-2007  115.45           Modified seniority_changed to check
                                           seniority on MAX(hire date, previous
                                           archiver run date).
 sdahiya     22-Mar-2007  115.46  5885473  Modified chk_person_rec_chng to
                                           identify changes in IMSS medical
                                           center (PER_INFORMATION4).
 sdahiya     20-Apr-2007  115.47  6005922  Fixed seniority calculation for
                                           future-dated hires.
 sdahiya     22-Apr-2007  115.48           08 and 02 transactions should not be
                                           archived if person-GRE relation
                                           exists due to assignments other than
                                           the current one.
 sdahiya     24-Apr-2007  115.49  6013218  Employee social security number
                                           should be fetched from person
                                           record effective on transaction
                                           date.
 sdahiya     25-Apr-2007  115.50  6005853  Terminations due to SCL changes
                                           should be checked for qualification
                                           under current GRE.
 sdahiya     25-Apr-2007  115.51           Modified cursor csr_per_gre so that
                                           it checks for person-GRE association
                                           for the current assignment in
                                           addition to others.
 sdahiya     26-Apr-2007  115.52  6019466  Modified cursor csr_per_gre to ensure
                                           that only active assignments are
                                           checked to establish person's
                                           relation with GRE.
 sdahiya     27-Apr-2007  115.53  6020160  Added NVL check in
                                           chk_person_rec_chng procedure.
 vpandya     10-May-2007  115.54  6019849  Changed cursor c_person_detail:
                                           removing trailing blank if second
                                           name is not entered.(rtrim)
 sdahiya     15-May-2007  115.55  6021768  Modified arch_other_transactions
                                           so that 07 is archived only if
                                           person is not a new hire.
 sdahiya     16-May-2007  115.56           07 transactions effective on a date
                                           different from the hire date should
                                           be archived. Modified cache_idw_date
                                           for this.
 sdahiya     18-May-2007  115.57  6060052  Run through transactions only if
                                           transactions' cache is not empty.
 nragavar    12-Jul-2007  115.58  6198089  modified to log absences correctly.
 vpandya     16-Jul-2007  115.59  6238481  Changed: arch_other_transactions
                                           Added end if for event_qualified
                                           for INFONAVIT.
 vpandya     18-Jul-2007  115.60  6198089  Changed: range_cursor and removed
                                  6130744  condition for ppe.effective_date.
                                           For bimonthly period, the date
                                           for 07 trans would be first day
                                           of next bimonthly period.
 vpandya     20-Jul-2007  115.62  6264202  Changed: archive_data
                                           Filter transaction if trn date is
                                           4712/12/31. Call an API if pl/sql
                                           table count is greater than 0.
 vpandya     20-Jul-2007  115.63           Changed: archive_data
 vpandya     20-Aug-2007  115.64           Changed: get_idw, truncating
                                           effective_date while calling get_idw
                                           of udfs.
 vpandya     21-Aug-2007  115.65  6353167  Changed: get_idw, using mode to
                                           REPORT now on as bimonthly IDW gets
                                           when first day of next bimonth period
                                           .
 prechand   21-Feb-2008   115.66  6820541  Start date is replaced by effective_
                                           start_date in the get person information
                                           query for getting the latest hire date
 sivanara   07-Mar-2008   115.67  6862116  Added cursor c_check_active_employee
                                           to archive_data cursor, so that
					   archive data is only for "Employee"
 sivanara   25-Apr-2008   115.68  6960481  Added new parameter to event_qualified
                                           to filter out applicant event.
 sivanara   17-Jun-2008   115.70  7185703  Removed fnd_date function from the cursor
                                           csr_get_asg_end_date and csr_per_gre.
 sivanara   20-Aug-2008   115.71  7341327  For the cursor csr_per_gre added condition
                                           for applicant.
 swamukhi   01-Oct-2008   115.72  6451017  For the cursor csr_per_gre added a condition
                                           to check the effective_start_date.
 vvijayku   07-Nov-2008   115.73  6451017  Added a new cursor c_get_report_term_rehire
                                           to retrieve the value of the reporting option
					   and later archiving it.
 vvijayku   10-Nov-2008   115.74  7342321  Added a new cursor c_first_sal_date which retrieves
				           the date on which the first salary was attached to
					   the assignment.
 vvijayku   21-Nov-2008   115.75  7342321  The complete fix did not go into the earlier version
                                           115.74. This version has the complete fix.
 vvijayku   21-Nov-2008   115.76  7342321  Had to remove some compilation errors,which was arcsed
                                           in by mistake.
 sjawid     30-Jul-2009   115.77  6933682  Added extra parameters p_payroll_action_id,
                                           p_execute_old_idw_code to
                                           function call pay_mx_ff_udfs.get_idw.
					   Added new cursor c_salary_type in
					   procedure arch_hire_separation
					   to correct the salary_type for newhire employees.
 sjawid     30-Jul-2009   115.78  6933682  Corrected pay_mx_ff_udfs.get_idw function call
 vvijayku   20-Nov-2009   115.79  8988585  Corrected the to_char idw conversion to the correct
                                           format.
 sjawid     09-Nov-2009   115.80  8912736  Modified cursor c_disabilities_info, added decode function
                                           to disability_control to get the correct codes as per
					   statutory requirement.
 sjawid     19-Nov-2009   115.81  9128410  Changed the get_idw function call for the person info .
                                           Passing assignment_start_date to get_idw function
					   when the person is processing first time.
 ============================================================================*/

--
-- Global Variables
--
   TYPE gre_rec_type IS RECORD(
    assignment_id           NUMBER,
    effective_start_date    DATE,
    effective_end_date      DATE,
    gre_id                  NUMBER);

   TYPE gre_tab_type IS TABLE OF gre_rec_type INDEX BY BINARY_INTEGER;

   gt_gre_cache            gre_tab_type;
   gv_package              VARCHAR2(240);
   gv_debug                BOOLEAN;
   gn_implementation       NUMBER;
   gn_person_rec_chng      NUMBER;
   gn_gre_found            NUMBER;
   gn_idw                  NUMBER;
   gv_credit_no            VARCHAR2(240);
   gv_credit_start_date    VARCHAR2(240);
   gv_crdt_grant_dt        VARCHAR2(240);
   gv_discount_type        VARCHAR2(240);
   gv_discount_value       VARCHAR2(240);
   gv_variable_idw         VARCHAR2(10);
   gv_IDW_calc_method      hr_organization_information.org_information10%type;

  PROCEDURE hr_utility_trace (p_data    IN VARCHAR2) IS
  BEGIN
    IF gv_debug THEN
        hr_utility.trace (p_data);
    END IF;
  END;

  FUNCTION event_qualified(p_person_id      NUMBER,
                           p_assignment_id  NUMBER,
                           p_effective_date DATE,
                           p_gre_id         NUMBER) RETURN BOOLEAN IS
        CURSOR csr_asg IS
            SELECT assignment_id,
                   effective_start_date,
                   effective_end_date,
                   per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                   location_id,
                                   business_group_id,
                                   soft_coding_keyflex_id,
                                   effective_end_date) gre_id
              FROM per_assignments_f
             WHERE assignment_id = p_assignment_id;

  /*Added to check for the applicant type */
    CURSOR c_check_per_status (p_person_id IN VARCHAR2 ,
                                  p_effective_date IN VARCHAR2) IS

       SELECT  per.current_applicant_flag
       FROM  per_all_people_f per
       WHERE per.person_id = p_person_id
       AND  fnd_date.canonical_to_date(p_effective_date)
            BETWEEN per.effective_start_date AND per.effective_end_date;


        l_return    BOOLEAN;
        ln_cntr     NUMBER;
        l_proc_name varchar2(100);
	lv_chk_emp_status  VARCHAR2(1);

  BEGIN
        l_proc_name := gv_package || 'event_qualified';
        hr_utility_trace ('Entering '||l_proc_name);
        hr_utility_trace ('p_assignment_id = '||p_assignment_id);
        hr_utility_trace ('p_effective_date = '||
                                fnd_date.date_to_canonical(p_effective_date));
        hr_utility_trace ('p_gre_id = '||p_gre_id);

        l_return := FALSE;
        -- Check if assignment is cached.
        IF gt_gre_cache.count() > 0 THEN
        FOR ln_cntr IN gt_gre_cache.first()..gt_gre_cache.last() LOOP
            IF p_assignment_id = gt_gre_cache(ln_cntr).assignment_id THEN
                hr_utility_trace('Assignment '||p_assignment_id||
                                    ' found in cache.');
                l_return := TRUE;
                EXIT;
            END IF;
        END LOOP;
        END IF;

        IF l_return THEN
        -- Assignment is cached. Check if event is qualified.
        l_return := FALSE;
        FOR ln_cntr IN gt_gre_cache.first()..gt_gre_cache.last() LOOP
            IF p_assignment_id = gt_gre_cache(ln_cntr).assignment_id AND
               p_gre_id = gt_gre_cache(ln_cntr).gre_id AND
               p_effective_date BETWEEN gt_gre_cache(ln_cntr).effective_start_date
                                    AND gt_gre_cache(ln_cntr).effective_end_date
                                                                           THEN
                l_return := TRUE;
                EXIT;
            END IF;
        END LOOP;
        ELSE
            -- Assignment is not cached. Load cache. Check if event is qualified.
            hr_utility_trace('Assignment '||p_assignment_id||
                                ' not found in cache. Hitting database now.');
            l_return := FALSE;
            FOR csr_asg_rec IN csr_asg LOOP
                ln_cntr := gt_gre_cache.count();
                gt_gre_cache(ln_cntr).assignment_id := csr_asg_rec.assignment_id;
                gt_gre_cache(ln_cntr).effective_start_date :=
                                               csr_asg_rec.effective_start_date;
                gt_gre_cache(ln_cntr).effective_end_date :=
                                                 csr_asg_rec.effective_end_date;
                gt_gre_cache(ln_cntr).gre_id := csr_asg_rec.gre_id;

                IF p_assignment_id = gt_gre_cache(ln_cntr).assignment_id AND
                   p_gre_id = gt_gre_cache(ln_cntr).gre_id AND
                   p_effective_date BETWEEN gt_gre_cache(ln_cntr).effective_start_date
                                        AND gt_gre_cache(ln_cntr).effective_end_date
                                                                            THEN
                    l_return := TRUE;
                END IF;
            END LOOP;
        END IF;
         hr_utility_trace('Checking for applicant record');
	 OPEN c_check_per_status(p_person_id, fnd_date.date_to_canonical(p_effective_date));
           FETCH  c_check_per_status INTO lv_chk_emp_status;
         CLOSE c_check_per_status;

	   IF lv_chk_emp_status = 'Y' THEN
            l_return := FALSE;
	   END IF;


        IF l_return THEN
            hr_utility_trace ('Event qualified.');
        ELSE
            hr_utility_trace ('Event not qualified.');
        END IF;
        hr_utility_trace ('Leaving '||l_proc_name);
        RETURN (l_return);
  END event_qualified;

  FUNCTION get_start_date( p_gre_id       IN VARCHAR2 )
  RETURN   VARCHAR2 IS

   CURSOR c_get_bus_grp_id(cp_organization_id IN NUMBER) IS
     SELECT business_group_id
     FROM   hr_all_organization_units
     WHERE  organization_id = cp_organization_id;

   CURSOR c_get_start_date(cp_tax_unit_id IN NUMBER) IS
     SELECT pay_mx_utility.get_legi_param_val('END_DATE',LEGISLATIVE_PARAMETERS)
     FROM   pay_payroll_actions ppa
     WHERE  ppa.report_type      = 'SS_ARCHIVE'
     AND    ppa.report_qualifier = 'SS_ARCHIVE'
     AND    ppa.report_category  = 'RT'
     AND    pay_mx_utility.get_legi_param_val('GRE',LEGISLATIVE_PARAMETERS) =
                           cp_tax_unit_id
     ORDER BY ppa.payroll_action_id desc ;


   CURSOR c_get_imp_date(cp_organization_id IN NUMBER) IS
     SELECT fnd_date.canonical_to_date(org_information6)
     FROM   hr_organization_information
     WHERE  org_information_context = 'MX_TAX_REGISTRATION'
     AND    organization_id         = cp_organization_id ;

     ld_report_imp_date   date;
     ld_start_date        date;
     lv_start_date        varchar2(50);
     ln_tax_unit_id       NUMBER;
     ln_legal_employer_id NUMBER;
     ln_bus_grp_id        NUMBER;
     ln_count             NUMBER;

  BEGIN

    hr_utility_trace('p_gre_id '||nvl( p_gre_id, -999));

    pay_recorded_requests_pkg.get_recorded_date_no_ins(
                 p_process       => 'MX_SOC_SEC_ARCH',
                 p_recorded_date => ld_start_date,
                 p_attribute1    => p_gre_id,
                 p_attribute2    => NULL,
                 p_attribute3    => NULL,
                 p_attribute4    => NULL,
                 p_attribute5    => NULL,
                 p_attribute6    => NULL,
                 p_attribute7    => NULL,
                 p_attribute8    => NULL,
                 p_attribute9    => NULL,
                 p_attribute10   => NULL,
                 p_attribute11   => NULL,
                 p_attribute12   => NULL,
                 p_attribute13   => NULL,
                 p_attribute14   => NULL,
                 p_attribute15   => NULL,
                 p_attribute16   => NULL,
                 p_attribute17   => NULL,
                 p_attribute18   => NULL,
                 p_attribute19   => NULL,
                 p_attribute20   => NULL);

    /* Above procedure returns hr_api.g_sot if no records are found in
       pay_recorded_requests. So, use the implementation date if date
       fetched above is equal to hr_api.g_sot */

    IF NVL( ld_start_date, hr_api.g_sot ) <> hr_api.g_sot THEN

       lv_start_date := fnd_date.date_to_canonical( ld_start_date );

    ELSE

       IF p_gre_id IS NOT NULL THEN

         -- GET LEGAL EMPLOYER ID FROM GRE ID

         OPEN  c_get_bus_grp_id(p_gre_id);
         FETCH c_get_bus_grp_id INTO ln_bus_grp_id;
         CLOSE c_get_bus_grp_id;

         hr_utility_trace('ln_bus_grp_id '||ln_bus_grp_id);

         SELECT count(*)
           INTO ln_count
           FROM fnd_sessions
          WHERE session_id =  USERENV('sessionid');

         hr_utility_trace('ln_count '||ln_count);

         ln_legal_employer_id :=
                  hr_mx_utility.get_legal_employer(ln_bus_grp_id, p_gre_id);

         hr_utility_trace('ln_legal_employer_id '||ln_legal_employer_id);

         -- get the report Implementation Date from p_legal_emp_id

         OPEN  c_get_imp_date(ln_legal_employer_id);
         FETCH c_get_imp_date INTO ld_report_imp_date ;

         IF c_get_imp_date%NOTFOUND OR ld_report_imp_date is NULL THEN

            -- defaulting to Report Implementation Date from
            -- mx pay legislation info table
            ld_report_imp_date := fnd_date.canonical_to_date(
                                      pay_mx_utility.get_default_imp_date) ;

         END IF;

         CLOSE c_get_imp_date;

         hr_utility_trace('ld_report_imp_date '||ld_report_imp_date);

         ln_tax_unit_id := to_number(p_gre_id) ;

         OPEN  c_get_start_date(ln_tax_unit_id);
         FETCH c_get_start_date INTO lv_start_date ;

         IF c_get_start_date%NOTFOUND THEN

            -- assign the ld_start_date from rep imp date
            lv_start_date    := fnd_date.date_to_canonical(ld_report_imp_date);

         END IF;

         CLOSE c_get_start_date;

         hr_utility_trace('lv_start_date '||lv_start_date);

         ld_start_date := fnd_date.canonical_to_date(lv_start_date) ;

         hr_utility_trace('ld_start_date '||ld_start_date);

       ELSE

         SELECT fnd_date.date_to_canonical(sysdate)
           INTO lv_start_date
           FROM DUAL;

       END IF; -- p_gre_id IS NOT NULL

    END IF; -- ld_start_date <> hr_api.g_sot

    hr_utility_trace('lv_start_date '||lv_start_date);

    RETURN lv_start_date ;

  END get_start_date;

  FUNCTION get_dates_for_valueset(p_date IN VARCHAR2)
  RETURN VARCHAR2 IS

    lv_dates VARCHAR2(240);

  BEGIN

    lv_dates := NULL;

    SELECT fnd_date.date_to_displaydate( ADD_MONTHS (
               fnd_date.canonical_to_date( p_date ), -1 ) ) || '  -  ' ||
           fnd_date.date_to_displaydate( ADD_MONTHS (
               fnd_date.canonical_to_date( p_date ), 1 ) -1 )
      INTO lv_dates
      FROM dual;

    RETURN lv_dates;

  END get_dates_for_valueset;

  /*****************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for Tax Filing (FLS)/Payslip Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of Archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
               p_gre_id            - GRE ID (Organization ID of the GRE)
  *****************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     IN  NUMBER
                                   ,p_end_date              OUT NOCOPY VARCHAR2
                                   ,p_start_date            OUT NOCOPY VARCHAR2
                                   ,p_business_group_id     OUT NOCOPY NUMBER
                                   ,p_gre_id                OUT NOCOPY NUMBER
                                   )
  IS
    CURSOR c_payroll_Action_info (cp_payroll_action_id IN NUMBER) IS
      SELECT business_group_id
            ,pay_mx_utility.get_legi_param_val('START_DATE',
                                LEGISLATIVE_PARAMETERS) start_date
            ,pay_mx_utility.get_legi_param_val('END_DATE',
                                LEGISLATIVE_PARAMETERS) end_date
            ,pay_mx_utility.get_legi_param_val('GRE',LEGISLATIVE_PARAMETERS) GRE
            ,pay_mx_utility.get_legi_param_val('MODE',
                                LEGISLATIVE_PARAMETERS) REPORT_MODE
            ,pay_mx_utility.get_legi_param_val('PERIOD_ENDING_DATE',
                                LEGISLATIVE_PARAMETERS) PERIOD_ENDING_DATE
        FROM pay_payroll_actions
       WHERE payroll_action_id = cp_payroll_action_id;

    lv_end_date          VARCHAR2(50);
    lv_start_date        VARCHAR2(50);
    ln_business_group_id NUMBER;
    ln_gre_id            NUMBER;
    lv_mode              VARCHAR2(50);
    lv_periodic_end_date VARCHAR2(50);

    lv_procedure_name    VARCHAR2(100);
    lv_error_message     VARCHAR2(2000);
    ln_step              NUMBER;

   BEGIN

       lv_procedure_name := 'get_payroll_action_info';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;

       OPEN  c_payroll_action_info(p_payroll_action_id);
       FETCH c_payroll_action_info INTO ln_business_group_id
                                       ,lv_start_date
                                       ,lv_end_date
                                       ,ln_gre_id
                                       ,lv_mode
                                       ,lv_periodic_end_date;
       CLOSE c_payroll_action_info;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);

       IF lv_periodic_end_date IS NOT NULL THEN

          IF TRUNC(fnd_date.canonical_to_date(lv_end_date)) -
             TRUNC(fnd_date.canonical_to_date(lv_periodic_end_date)) >= 1 THEN

             gv_periodic_end_date :=
                        to_char(fnd_date.canonical_to_date(lv_periodic_end_date)
                                , 'YYYY/MM/DD') ||' 23:59:59';

          ELSE

             gv_periodic_end_date :=
                        to_char(fnd_date.canonical_to_date(lv_periodic_end_date)
                                , 'YYYY/MM/DD') ||' '||
                        to_char(fnd_date.canonical_to_date(lv_end_date)
                                , 'HH24:MI:SS');

          END IF;

       ELSE

          gv_periodic_end_date := lv_end_date;

       END IF;

       p_end_date          := lv_end_date;
       p_start_date        := lv_start_date;
       p_business_group_id := ln_business_group_id;
       p_gre_id            := ln_gre_id;
       gv_mode             := lv_mode;

       hr_utility.set_location(gv_package || lv_procedure_name, 50);
       ln_step := 2;

       IF gv_mode = 'P' THEN

          gv_periodic_start_date :=
             fnd_date.date_to_canonical(
             TRUNC(add_months(fnd_date.canonical_to_date(
                                       lv_periodic_end_date),-2)+1));

       ELSE

          gv_periodic_start_date := lv_start_date;

       END IF;

       hr_utility_trace('gv_periodic_start_date :' || gv_periodic_start_date);

  END get_payroll_action_info;

  /********************************************************************
   Name      : get_rww_ind
   Purpose   : This function returns the reduced working week indicator
  ********************************************************************/

  PROCEDURE get_rww_ind(p_business_group_id IN         NUMBER
                       ,p_workschedule      IN         VARCHAR2
                       ,p_rww_ind           OUT NOCOPY VARCHAR2) IS

    CURSOR c_rww ( cp_business_group_id IN NUMBER
                  ,cp_workschedule      IN VARCHAR2 )  IS
      SELECT  sum(decode(to_number(puci.value),0,0,1)) total_days
             ,sum(to_number(puci.value)) total_hours
        FROM  pay_user_column_instances_f puci,
              pay_user_columns puc
       WHERE  puc.user_column_name = cp_workschedule
         AND  ( puc.legislation_code = 'MX' OR
                puc.business_group_id = cp_business_group_id )
         AND  puc.user_column_id   = puci.user_column_id;

    ln_rww             NUMBER;
    ln_total_hours     NUMBER;
    ln_calculated_days NUMBER;

  BEGIN

    IF p_workschedule IS NOT NULL THEN

       OPEN  c_rww(p_business_group_id, p_workschedule) ;
       FETCH c_rww INTO ln_rww
                       ,ln_total_hours;
       CLOSE c_rww ;

       /******************************************************************
          What would be Reduced Working Week Indicator's value ?
          Sum up number of hours from Work Schedule, Divide it by 8,
          which gives number of days. If no of days are 6 or more then
          the value would be zero otherwise it is no of days.

          Examples:

          +-------------------------------------------------------------+
          | Work Schedule    |Total Hours| Calculate Days| Value        |
          |                  |           | Total Hours/8 |              |
          |-------------------------------------------------------------|
          |8-0-0-0-0-0-0     |    8      |  8/8 = 1      |   1          |
          |8-4-0-0-0-0-0     |   12      | 12/8 = 1.5    |   2          |
          |8-2-0-0-0-0-0     |   10      | 10/8 = 1.25   |   2          |
          |10-11-10-9-0-0-0  |   40      | 40/8 = 5      |   5          |
          |8-8-8-8-8-8-8     |   56      | 56/8 = 7      |   0          |
          |96-96-96-96-96-0-0|   48      | 48/8 = 6      |   0          |
          +-------------------------------------------------------------+
       ******************************************************************/

       ln_calculated_days := CEIL ( ln_total_hours / 8 );

       IF ln_calculated_days >= 6  THEN

          -- If work schedule is 6 or more, it is considered as Normal Week
          -- in this case, the reduced working week indicator should be zero
          -- as per VM

          ln_calculated_days := 0 ;

       END IF;

       p_rww_ind := to_char(ln_calculated_days) ;

    ELSE

       p_rww_ind := null ;

    END IF;

  END get_rww_ind;

  FUNCTION get_idw( p_assignment_id  IN NUMBER
                   ,p_tax_unit_id    IN NUMBER
                   ,p_effective_date IN DATE
                   ,p_fixed_idw      OUT NOCOPY NUMBER
                   ,p_variable_idw   OUT NOCOPY NUMBER )
  RETURN   NUMBER IS

    CURSOR c_minimum_wage_zonea( cp_effective_date DATE ) IS
      SELECT fnd_number.canonical_to_number(legislation_info2)
        FROM pay_mx_legislation_info_f
       WHERE legislation_info_type = 'MX Minimum Wage Information'
         AND legislation_info1     = 'MWA'
         AND cp_effective_date BETWEEN effective_start_date
                                   AND effective_end_date;

    ln_min_wage     NUMBER;
    ln_idw          NUMBER;
    ln_fixed_idw    NUMBER;
    ln_variable_idw NUMBER;

    lv_procedure_name    VARCHAR2(100);
    lv_error_message     VARCHAR2(2000);
    ln_step              NUMBER;
    lv_mode              VARCHAR2(15);

  BEGIN

    lv_procedure_name := 'get_idw';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_step := 1;

    ln_min_wage     := 0;
    ln_idw          := 0;
    ln_fixed_idw    := 0;
    ln_variable_idw := 0;

    hr_utility.set_location(gv_package || lv_procedure_name, 20);

    -- get the minimum wage for Zone A ( Mexico City )

    OPEN  c_minimum_wage_zonea(p_effective_date);
    FETCH c_minimum_wage_zonea INTO ln_min_wage;
    CLOSE c_minimum_wage_zonea;

    hr_utility.set_location(gv_package || lv_procedure_name, 30);


    BEGIN

      hr_utility.set_location(gv_package || lv_procedure_name, 40);

      ln_step := 2;

      lv_mode := 'REPORT';

      ln_idw := pay_mx_ff_udfs.get_idw( p_assignment_id  => p_assignment_id
                                       ,p_tax_unit_id    => p_tax_unit_id
                                       ,p_effective_date =>
                                                      TRUNC(p_effective_date)
				       ,p_payroll_action_id => NULL
                                       ,p_mode           => lv_mode
                                       ,p_fixed_idw      => ln_fixed_idw
                                       ,p_variable_idw   => ln_variable_idw
				       ,p_execute_old_idw_code => 'Y'
                                      );

      hr_utility.trace('SS_ARCH get_idw ln_idw: '|| ln_idw);
      hr_utility.trace('SS_ARCH get_idw ln_fixed_idw: '|| ln_fixed_idw);
      hr_utility.trace('SS_ARCH get_idw ln_variable_idw: '|| ln_variable_idw);

      hr_utility.set_location(gv_package || lv_procedure_name, 50);

      EXCEPTION WHEN others THEN
        hr_utility.set_location(gv_package || lv_procedure_name, 60);
        NULL;

    END;

    ln_step := 3;

    -- check the IDW with 25 times of zone A minimum wage
    -- if idw is greater than 25 times of zone A minimum wage then
    --    idw = 25 times of zone A minimum wage
    -- else
    --    idw = calculated one
    -- end if

    IF ln_idw > ( 25 * ln_min_wage ) THEN
       ln_idw := 25 * ln_min_wage;
       hr_utility.trace('SS_ARCH get_idw ln_idw > 25 * ln_min_wage');
       hr_utility.trace('25 times of zone A minimum wage');
    END IF;

    hr_utility.set_location(gv_package || lv_procedure_name, 70);

    -- round to 2 decimal and archive

    p_fixed_idw      := ROUND(LEAST(ln_fixed_idw, 25 * ln_min_wage), 2);
    p_variable_idw   := ROUND(LEAST(ln_variable_idw, 25 * ln_min_wage), 2);

    hr_utility.trace('SS_ARCH get_idw p_fixed_idw: '|| p_fixed_idw);
    hr_utility.trace('SS_ARCH get_idw p_variable_idw: '|| p_variable_idw);

    ln_idw := round(ln_idw,2);

    hr_utility.trace('SS_ARCH get_idw ln_idw: '|| ln_idw);

    RETURN ln_idw;

    EXCEPTION
    WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_idw;

  PROCEDURE arch_pay_action_level_data(
                               p_payroll_action_id IN NUMBER
                              ,p_assignment_id     IN NUMBER
                              ,p_effective_Date    IN DATE
                              ,p_tax_unit_id       IN NUMBER
                              ) IS

    CURSOR c_get_org_information ( cp_organization_id IN NUMBER) IS
      SELECT replace(org_information1,'-','') Social_Security_ID
            ,org_information3 Transmitter_Yes_No
            ,org_information5 WayBill_Number
            ,org_information6 Transmitter_GRE_ID
        FROM hr_organization_information
       WHERE org_information_context = 'MX_SOC_SEC_DETAILS'
         AND organization_id         = cp_organization_id ;

    CURSOR c_org_name ( cp_organization_id IN NUMBER) IS
      SELECT name
        FROM hr_organization_units
       WHERE organization_id = cp_organization_id;

    CURSOR c_waybill_of_trnsmtr ( cp_organization_id IN NUMBER) IS
      SELECT org_information5 WayBill_Number
        FROM hr_organization_information
       WHERE org_information_context = 'MX_SOC_SEC_DETAILS'
         AND organization_id         = cp_organization_id ;

    lv_soc_sec_id            VARCHAR2(240);
    lv_transmitter           VARCHAR2(240);
    lv_waybill_no            VARCHAR2(240);
    lv_transmitter_gre_id    VARCHAR2(240);

    lv_gre_name              VARCHAR2(240);
    lv_transmitter_gre_name  VARCHAR2(240);

    ln_index           NUMBER;

    lv_procedure_name      VARCHAR2(100);
    lv_error_message       VARCHAR2(2000);
    ln_step                NUMBER;

  BEGIN

    lv_procedure_name := 'arch_pay_action_level_data';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_step := 1;

    OPEN  c_get_org_information(p_tax_unit_id);
    FETCH c_get_org_information INTO lv_soc_sec_id
                                    ,lv_transmitter
                                    ,lv_waybill_no
                                    ,lv_transmitter_gre_id;
    CLOSE c_get_org_information;

    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 2;

    OPEN  c_org_name(p_tax_unit_id);
    FETCH c_org_name INTO lv_gre_name;
    CLOSE c_org_name;

    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    ln_step := 3;

    IF lv_transmitter = 'Y' THEN

       lv_transmitter_gre_id    := p_tax_unit_id;
       lv_transmitter_gre_name  := lv_gre_name;

    ELSE

       IF lv_transmitter IS NOT NULL THEN

          hr_utility.set_location(gv_package || lv_procedure_name, 40);
          ln_step := 4;

          OPEN  c_org_name(lv_transmitter_gre_id);
          FETCH c_org_name INTO lv_transmitter_gre_name;
          CLOSE c_org_name;

          hr_utility.set_location(gv_package || lv_procedure_name, 50);
          ln_step := 5;

          OPEN  c_waybill_of_trnsmtr(lv_transmitter_gre_id);
          FETCH c_waybill_of_trnsmtr INTO lv_waybill_no;
          CLOSE c_waybill_of_trnsmtr;

       END IF; -- lv_transmitter

    END IF;

    hr_utility.set_location(gv_package || lv_procedure_name, 60);
    ln_step := 6;

    ln_index := pay_mx_soc_sec_archive.lrr_act_tab.COUNT;

    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).action_info_category
                           := 'MX SS GRE INFORMATION';
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).jurisdiction_code := NULL;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info1 := lv_soc_sec_id;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info2 := lv_gre_name;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info3
                           := lv_transmitter_gre_id;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info4
                           := lv_transmitter_gre_name;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info5 := lv_waybill_no;

    pay_emp_action_arch.insert_rows_thro_api_process(
                     p_action_context_id   =>  p_payroll_action_id
                    ,p_action_context_type => 'PA'
                    ,p_assignment_id       => null
                    ,p_tax_unit_id         => p_tax_unit_id
                    ,p_curr_pymt_eff_date  => p_effective_date
                    ,p_tab_rec_data        => pay_mx_soc_sec_archive.lrr_act_tab
                    );

    pay_mx_soc_sec_archive.lrr_act_tab.DELETE;

    EXCEPTION
    WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END arch_pay_action_level_data;

  PROCEDURE chk_person_rec_chng (
                p_per_events IN pay_interpreter_pkg.t_detailed_output_table_type
                ) IS

    lv_old_value           VARCHAR2(150);
    lv_new_value           VARCHAR2(150);
    lv_change_values       VARCHAR2(150);

    lv_procedure_name      VARCHAR2(100);
    lv_error_message       VARCHAR2(2000);
    ln_step                NUMBER;

  BEGIN

    lv_procedure_name := 'chk_person_rec_chng';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_step := 1;


    FOR i IN p_per_events.FIRST..p_per_events.LAST LOOP

        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        ln_step := 2;

        lv_change_values := p_per_events(i).change_values ;

        lv_old_value := ltrim(rtrim(SUBSTR(lv_change_values,1,
                                 INSTR(lv_change_values,'->')-1)));

        lv_new_value := ltrim(rtrim(SUBSTR(lv_change_values,
                                    INSTR(lv_change_values,'->')+3)));

        hr_utility_trace('lv_change_values : '||lv_change_values);
        hr_utility_trace('lv_old_value     : '||lv_old_value);
        hr_utility_trace('lv_new_value     : '||lv_new_value);
        hr_utility_trace('column_name      : '||p_per_events(i).column_name);

        IF p_per_events(i).column_name in ( 'LAST_NAME', 'FIRST_NAME',
                                            'MIDDLE_NAMES', 'PER_INFORMATION1',
                                            'PER_INFORMATION4') -- Bug 5885473
        THEN

           IF NVL(lv_old_value,-1) <> NVL(lv_new_value,-1) THEN -- Bug 6020160

              gn_person_rec_chng := 1;
              EXIT;

           END IF;

        END IF;

    END LOOP;

    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    ln_step := 3;

    EXCEPTION
    WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END chk_person_rec_chng;

  PROCEDURE arch_other_transactions (
                 p_payroll_action_id IN NUMBER
                ,p_asg_action_id     IN NUMBER
                ,p_effective_date    IN DATE
                ,p_assignment_id     IN NUMBER
                ,p_person_id         IN NUMBER
                ,p_chunk_number      IN NUMBER
                ,p_start_date        IN DATE
                ,p_end_date          IN DATE
                ,p_business_group_id IN NUMBER
                ,p_gre_id            IN NUMBER
                ,p_eff_start_date    IN DATE
                ,p_eff_end_date      IN DATE ) IS

    CURSOR c_IDW_events IS
      SELECT ppe.effective_date
        FROM pay_process_events ppe
            ,pay_event_updates peu
            ,pay_dated_tables pdt
            ,pay_element_entry_values_f peev
            ,pay_input_values_f piv
            ,pay_element_types_f pet
       WHERE ppe.business_group_id = p_business_group_id
         AND ppe.assignment_id     = p_assignment_id
         AND ppe.change_type       = 'DATE_EARNED'
         AND ppe.creation_date  BETWEEN p_start_date
                                    AND p_end_date
         AND peu.event_update_id   = ppe.event_update_id
         AND pdt.dated_table_id    = peu.dated_table_id
         AND pdt.table_name        = 'PAY_ELEMENT_ENTRY_VALUES_F'
         AND ppe.surrogate_key     = peev.element_entry_value_id
         AND peev.input_value_id   = piv.input_value_id
         AND piv.element_type_id   = pet.element_type_id
         AND pet.element_name      = 'Integrated Daily Wage'
         AND piv.name              = 'IDW Factor Table'
         AND pet.legislation_code  = 'MX'
         AND ppe.effective_date BETWEEN peev.effective_start_date
                                    AND peev.effective_end_date
         AND ppe.effective_date BETWEEN piv.effective_start_date
                                    AND piv.effective_end_date
         AND ppe.effective_date BETWEEN pet.effective_start_date
                                    AND pet.effective_end_date
      UNION
      -- Bug 5002283
      SELECT ppe.effective_date
        FROM pay_process_events ppe
            ,pay_event_updates peu
            ,pay_dated_tables pdt
            ,pay_element_entries_f pee
            ,pay_element_types_f pet
       WHERE ppe.business_group_id = p_business_group_id
         AND ppe.assignment_id     = p_assignment_id
         AND ppe.change_type       = 'DATE_EARNED'
         AND ppe.creation_date  BETWEEN p_start_date
                                    AND p_end_date
         AND peu.event_update_id   = ppe.event_update_id
         AND pdt.dated_table_id    = peu.dated_table_id
         AND pdt.table_name        = 'PAY_ELEMENT_ENTRIES_F'
         AND ppe.surrogate_key     = pee.element_entry_id
         AND pee.element_type_id   = pet.element_type_id
         AND pet.element_name      = 'Integrated Daily Wage'
         AND pet.legislation_code  = 'MX'
         AND ppe.effective_date BETWEEN pee.effective_start_date
                                    AND pee.effective_end_date
         AND ppe.effective_date BETWEEN pet.effective_start_date
                                    AND pet.effective_end_date;

    CURSOR c_all_ele_entries (cp_effective_date IN DATE) IS
        SELECT element_entry_id
          FROM pay_element_entries_f
         WHERE assignment_id = p_assignment_id
           AND cp_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

    CURSOR c_ele_entries ( cp_business_group_id  IN NUMBER
                         , cp_assignment_id      IN NUMBER
                         , cp_start_date         IN DATE
                         , cp_end_date           IN DATE ) IS
      SELECT DISTINCT ppe.effective_date
            ,ppe.description      change_values
            ,ppe.surrogate_key    element_entry_id
            ,ppe.calculation_date
            ,peu.event_type
        FROM pay_process_events ppe
            ,pay_event_updates peu
            ,pay_dated_tables pdt
       WHERE ppe.business_group_id = cp_business_group_id
         AND ppe.assignment_id     = cp_assignment_id
         AND ppe.change_type       = 'DATE_EARNED'
         AND ppe.creation_date  BETWEEN cp_start_date
                                    AND cp_end_date
         AND peu.event_update_id   = ppe.event_update_id
         AND pdt.dated_table_id    = peu.dated_table_id
         AND pdt.table_name        = 'PAY_ELEMENT_ENTRIES_F'
       ORDER BY ppe.effective_date;

    CURSOR c_ele_type_id ( cp_element_entry_id   IN NUMBER
                         , cp_effective_date     IN DATE ) IS
      SELECT element_type_id
            ,creator_type
            ,effective_start_date
            ,effective_end_date
        FROM pay_element_entries_f
       WHERE element_entry_id = cp_element_entry_id
         AND cp_effective_date BETWEEN effective_start_date
                                   AND effective_end_date;

    CURSOR c_ele_extra_info ( cp_element_type_id    IN NUMBER
                             ,cp_effective_date DATE ) IS
      SELECT 'MX_IDWF' eei_information1
        FROM pay_element_type_extra_info
       WHERE element_type_id          = cp_element_type_id
         AND information_type         = 'PQP_UK_RATE_TYPE'
         AND eei_information_category = 'PQP_UK_RATE_TYPE'
         AND ((eei_information1 = 'MX_BASE' AND gv_IDW_calc_method = 'B')
              OR (eei_information1 = 'MX_IDWF' AND gv_IDW_calc_method <> 'B'))
      UNION ALL
      SELECT 'MX_IDWV'
        FROM pay_element_types_f pet
            ,pay_element_classifications pec
            ,pay_sub_classification_rules_f psr
       WHERE pet.element_type_id   = cp_element_type_id
         AND cp_effective_date BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date
         AND psr.element_type_id = pet.element_type_id
         AND cp_effective_date BETWEEN psr.effective_start_date
                                   AND psr.effective_end_date
         AND pec.classification_id = psr.classification_id
         AND psr.legislation_code  = 'MX'
         AND INSTR(pec.classification_name,
              'Eligible Compensation for IDW (Variable Basis)') > 0;

    CURSOR c_get_org_information ( cp_organization_id IN NUMBER) IS
      SELECT replace(org_information1,'-','') Social_Security_ID
        FROM hr_organization_information
       WHERE org_information_context = 'MX_SOC_SEC_DETAILS'
         AND organization_id         = cp_organization_id ;

    CURSOR c_person_detail (cp_person_id      IN NUMBER
                           ,cp_effective_date IN DATE) IS
      SELECT replace(ppf.per_information3,'-','')        emp_ssnumber
        FROM per_all_people_f ppf
       WHERE ppf.person_id = cp_person_id
         -- Bug 6013218
         AND cp_effective_date BETWEEN ppf.effective_start_date AND
                                       ppf.effective_end_date;
         /*AND ppf.effective_start_date =
                ( SELECT max(ppf_in.effective_start_date)
                    FROM per_all_people_f ppf_in
                   WHERE ppf_in.person_id      =  ppf.person_id
                     AND trunc(cp_end_date)   >= ppf_in.effective_start_date
                     AND trunc(cp_start_date) <= ppf_in.effective_end_date);*/

    CURSOR c_abs_info ( cp_business_group_id  NUMBER
                       ,cp_assignment_id      NUMBER
                       ,cp_element_entry_id   NUMBER
                       ,cp_element_type_id    NUMBER
                       ,cp_person_id          NUMBER
                       ,cp_start_date         DATE
                       ,cp_end_date           DATE ) IS
      SELECT paat.absence_attendance_type_id
            ,paa.absence_attendance_id
            ,paa.absence_days
            ,paa.date_start
            ,paa.date_end
            ,paa.abs_information_category
            --,paa.abs_information1 disability_type
            ,paa.abs_information2 disability_id
        FROM per_absence_attendance_types paat
            ,pay_input_values_f piv
            ,pay_element_entries_f pee
            --,pay_element_entry_values_f peev  (Bug 5355325)
            ,per_absence_attendances paa
       WHERE paat.business_group_id     = cp_business_group_id
         AND NVL(paat.information1, 'N')= 'Y'
             /*
                information1 for MX specifies if absence should be
                reported to Social Security
             */
         AND piv.input_value_id         = paat.input_value_id
         AND piv.effective_start_date  <= cp_end_date
         AND piv.effective_end_date    >= cp_start_date
         AND piv.element_type_id        = cp_element_type_id
         AND pee.element_entry_id       = cp_element_entry_id
         AND pee.assignment_id          = cp_assignment_id
         AND pee.element_type_id        = piv.element_type_id
         AND pee.effective_start_date  <= cp_end_date
         AND pee.effective_end_date    >= cp_start_date
         --AND peev.element_entry_id      = pee.element_entry_id
         --AND peev.effective_start_date <= cp_end_date
         --AND peev.effective_end_date   >= cp_start_date
         AND paa.absence_attendance_id  = pee.creator_id
         AND paa.person_id                  = cp_person_id
         AND paa.absence_attendance_type_id = paat.absence_attendance_type_id
         AND paa.date_start       BETWEEN cp_start_date
                                      AND cp_end_date;

    CURSOR c_get_infonavit  ( cp_element_type_id    IN NUMBER ) IS
      SELECT eei_information1
        FROM pay_element_type_extra_info
       WHERE element_type_id          = cp_element_type_id
         AND information_type         = 'MX_DEDUCTION_PROCESSING'
         AND eei_information_category = 'MX_DEDUCTION_PROCESSING'
         AND eei_information1         = 'INFONAVIT';

    CURSOR c_infonavit_info ( cp_assignment_id      NUMBER
                             ,cp_element_entry_id   NUMBER
                             ,cp_element_type_id    NUMBER
                             ,cp_start_date         DATE
                             ,cp_end_date           DATE ) IS
      SELECT piv.name
            ,piv.input_value_id
            ,pee.element_entry_id
            ,pee.assignment_id
            ,peev.screen_entry_value
            ,pee.effective_start_date
            ,pee.effective_end_date
        FROM pay_input_values_f piv
            ,pay_element_entries_f pee
            ,pay_element_entry_values_f peev
       WHERE piv.effective_start_date  <= cp_end_date
         AND piv.effective_end_date    >= cp_start_date
         AND piv.element_type_id        = cp_element_type_id
         AND pee.element_entry_id       = cp_element_entry_id
         AND pee.assignment_id          = cp_assignment_id
         AND pee.element_type_id        = piv.element_type_id
         AND pee.effective_start_date  <= cp_end_date
         AND pee.effective_end_date    >= cp_start_date
         AND peev.element_entry_id      = pee.element_entry_id
         AND peev.effective_start_date <= cp_end_date
         AND peev.effective_end_date   >= cp_start_date
         AND pee.effective_start_date   = peev.effective_start_date
         AND pee.effective_end_date     = peev.effective_end_date
         AND peev.input_value_id        = piv.input_value_id
    ORDER BY piv.display_sequence;

    CURSOR csr_infonavit_tran_16 (cp_element_type_id NUMBER,
                                  cp_start_date      DATE,
                                  cp_end_date        DATE) IS
        SELECT element_entry_id
          FROM pay_element_entries_f
         WHERE assignment_id        = p_assignment_id
           AND element_type_id      = cp_element_type_id
           AND effective_start_date BETWEEN cp_start_date AND cp_end_date;

    CURSOR c_disabilities_info (cp_registration_id VARCHAR2) IS  /*bug 8912736*/
        SELECT pdf.degree,
               pdf.dis_information2 subsidized_days,
               pdf.dis_information3 disability_type,
               pdf.dis_information4 consequence,
               DECODE(pdf.dis_information5,'6','7','7','8','8','9',pdf.dis_information5) disability_control,
               pdf.incident_id
          FROM per_disabilities_f pdf
         WHERE pdf.person_id = p_person_id
           AND pdf.registration_id = cp_registration_id
           AND p_effective_date BETWEEN pdf.effective_start_date
                                    AND pdf.effective_end_date;

    CURSOR c_work_incident_info (cp_incident_id NUMBER) IS
        SELECT pwi.inc_information1 risk_type
          FROM per_work_incidents pwi
         WHERE pwi.person_id = p_person_id
           AND pwi.incident_id = cp_incident_id;

    ld_effective_date      DATE;
    lv_change_values       VARCHAR2(240);
    ln_element_entry_id    NUMBER;
    ld_calculation_date    DATE;
    lv_event_type          VARCHAR2(100);

    ln_element_type_id     NUMBER;
    ln_classification_id   NUMBER;
    lv_classification_name VARCHAR2(240);
    ln_incident_id         NUMBER;

    fix_var_idw            fixed_variable_idw;
    fix_var_idw_uniq       fixed_variable_idw;
    trn                    transaction;

    lv_fix_var_idw_found   VARCHAR2(1);
    ln_count               NUMBER;
    ln_trn_cnt             NUMBER;
    ln_index               NUMBER;

    ln_idw                 NUMBER;
    ln_fixed_idw           NUMBER;
    ln_variable_idw        NUMBER;
    lv_employee_ssn        VARCHAR2(100);
    lv_employer_ss_id      VARCHAR2(100);
    prev_eff_date          DATE;

    ln_abs_attend_type_id  NUMBER;
    ln_abs_attendance_id   NUMBER;
    ln_absence_days        NUMBER;
    ld_date_start          DATE;
    ld_date_end            DATE;
    lv_abs_info_category   VARCHAR2(240);
    --lv_disability_type     VARCHAR2(240);
    lv_disability_id       VARCHAR2(240);
    lv_idw_type            VARCHAR2(20);
    lv_creator_type        VARCHAR2(5);
    ld_ee_eff_start_date   DATE;
    ld_ee_eff_end_date     DATE;

    lv_infonavit           VARCHAR2(240);

    lv_procedure_name      VARCHAR2(100);
    lv_error_message       VARCHAR2(2000);
    ln_step                NUMBER;
    ld_anniversary_date    DATE;
    ld_hire_anniversary    DATE;
    lb_tran_16_found       BOOLEAN;

    ln_next_element_entry_id  NUMBER;


    /* This procedure loads a cache of dates, which will be later used as
       effective dates for IDW calculation. These dates will archived as
       "transaction dates" for transaction type 07. */
    PROCEDURE cache_IDW_date (p_idw_type        VARCHAR2,
                              p_effective_date  DATE) IS
        ln_count               NUMBER;
        lb_new_hire            BOOLEAN;
	ld_effective_date      DATE;
        ln_fix_idw             NUMBER;
        ln_var_idw             NUMBER;

        /*The Cursor c_first_sal_date gets the date on which the first
        salary was attached to the employee. This is done to prevent
        the reporting of the new salary as a salary change if it is
        attached to the assignments on a date after the hire date of
        the employee. Refer Bug 7342321 */

	CURSOR c_first_sal_date IS

      SELECT max(ppe.effective_date)
        FROM pay_process_events ppe ,
             pay_event_updates peu  ,
             pay_dated_tables pdt
       WHERE ppe.business_group_id = p_business_group_id
         AND ppe.assignment_id     = p_assignment_id
         AND ppe.change_type       = 'DATE_EARNED'
         AND peu.event_update_id   = ppe.event_update_id
         AND pdt.dated_table_id    = peu.dated_table_id
         AND ((pdt.table_name      = 'PAY_ELEMENT_ENTRIES_F')
          OR (pdt.table_name       = 'PAY_ELEMENT_ENTRY_VALUES_F'))
         AND peu.event_type        = 'INSERT';
    BEGIN
        IF event_qualified (p_person_id,
	                    p_assignment_id,
                            p_effective_date,
                            p_gre_id) THEN
            -- Archive a 07 only if current person is not a new hire
            -- (Bug 6021768)
            lb_new_hire := FALSE;
	     hr_utility_trace('Checking for hire ');
	     hr_utility_trace('Archived SS transaxtions ' ||pay_mx_soc_sec_archive.lrr_act_tab.COUNT());
             hr_utility_trace('p_effective_date ' || p_effective_date);

	     OPEN c_first_sal_date;
             FETCH c_first_sal_date into ld_effective_date;
             CLOSE c_first_sal_date;

            IF pay_mx_soc_sec_archive.lrr_act_tab.COUNT() > 0 THEN --Bug 6060052
                FOR cntr IN pay_mx_soc_sec_archive.lrr_act_tab.FIRST()..
                    pay_mx_soc_sec_archive.lrr_act_tab.LAST() LOOP
                    hr_utility_trace('pay_mx_soc_sec_archive.lrr_act_tab(cntr).action_info_category ' ||
		    pay_mx_soc_sec_archive.lrr_act_tab(cntr).action_info_category);
                    hr_utility_trace('pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info2) ' ||
		    pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info2);
                    hr_utility_trace('pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info4 ' ||
		    pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info4);

                    IF pay_mx_soc_sec_archive.lrr_act_tab(cntr).action_info_category
                                                      = 'MX SS TRANSACTIONS' AND
                       fnd_date.canonical_to_date(
                        pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info2) =
                                                            p_effective_date AND
                       pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info4 = '08'
                                                                            THEN
                        lb_new_hire := TRUE;
                        EXIT;
		    ELSIF
		          p_effective_date = ld_effective_date AND            --BUG 7342321
                          pay_mx_soc_sec_archive.lrr_act_tab(cntr).action_info_category
                                                      = 'MX SS TRANSACTIONS' AND
                          pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info4 = '08'
                                                                            THEN
                          lb_new_hire := TRUE;
                          hr_utility_trace('Going to run the get_idw to get the correct IDW for the first salary.');
                          ln_idw := get_idw( p_assignment_id  => p_assignment_id
                                            ,p_tax_unit_id    => p_gre_id
                                            ,p_effective_date => ld_effective_date
                                            ,p_fixed_idw      => ln_fix_idw
                                            ,p_variable_idw   => ln_var_idw );
                          pay_mx_soc_sec_archive.lrr_act_tab(cntr).act_info8:= ln_idw;
                          hr_utility_trace('Exiting the ELSIF part to prevent 07 transaction');
                          EXIT;
                    END IF;
                END LOOP;
            END IF;
            IF NOT lb_new_hire THEN
                IF p_idw_type = 'MX_IDWF' THEN
                 ln_count := fix_var_idw.COUNT;
                 fix_var_idw(ln_count).idw_type := 'FIXED';
                 fix_var_idw(ln_count).idw_date := p_effective_date;
                ELSIF p_idw_type = 'MX_IDWV' THEN
                  ln_count := fix_var_idw.COUNT;
                  fix_var_idw(ln_count).idw_type := 'VARIABLE';
                  fix_var_idw(ln_count).idw_date := p_effective_date;
                END IF;
            ELSE
                hr_utility_trace('Current person is a new hire. 07 effective '||
                             'on '||fnd_date.date_to_canonical(p_effective_date)
                                                    ||' will not be archived.');
            END IF;
        END IF;
    END cache_IDW_date;


    /* This procedure goes through all element entries of current assignemnt
       and prepares transaction dates for salary change transaction. */
    PROCEDURE parse_all_ele_entries (p_effective_date   DATE) IS
        ln_element_entry_id NUMBER;
        ln_element_type_id  NUMBER;
        lv_idw_type         VARCHAR2(40);
        lv_creator_type     pay_element_types_f.creator_type%type;
    BEGIN
            OPEN c_all_ele_entries (p_effective_date);
                LOOP
                    FETCH c_all_ele_entries INTO ln_element_entry_id;
                    EXIT WHEN c_all_ele_entries%NOTFOUND;
                    hr_utility_trace('Element Entry ID = '||
                                                        ln_element_entry_id);

                    OPEN c_ele_type_id (ln_element_entry_id,
                                        p_effective_date);
                        FETCH c_ele_type_id INTO ln_element_type_id,
                                                 lv_creator_type,
                                                 ld_ee_eff_start_date,
                                                 ld_ee_eff_end_date;
                    CLOSE c_ele_type_id;

                    lv_idw_type := NULL;
                    OPEN c_ele_extra_info (ln_element_type_id,
                                           p_effective_date);
                        FETCH c_ele_extra_info INTO lv_idw_type;
                    CLOSE c_ele_extra_info;

                    IF lv_idw_type IS NOT NULL THEN
                        hr_utility_trace('element entry id '||
                            ln_element_entry_id||' has following IDW info: -');
                        hr_utility_trace('IDW type = '||lv_idw_type);
                        hr_utility_trace('IDW effective date = '||
                                fnd_date.date_to_canonical(p_effective_date));
                    ELSE
                        hr_utility_trace('element entry id '||
                              ln_element_entry_id||' has no IDW information.');
                    END IF;
                    cache_IDW_date (lv_idw_type,
                                    p_effective_date);

                    /* Stop processing element entries as soon as we run into
                       first element entry with IDW information. This is
                       because a change in IDW table or seniority is applicable
                       to all element entries. Though we remove duplicate dates
                       from cache later down the line, this action should save
                       some processing. */
                    EXIT WHEN lv_idw_type IS NOT NULL;
                END LOOP;
            CLOSE c_all_ele_entries;
    END parse_all_ele_entries;


    PROCEDURE load_infonavit_info (p_assignment_id      NUMBER
                                  ,p_element_entry_id   NUMBER
                                  ,p_element_type_id    NUMBER
                                  ,p_start_date         DATE
                                  ,p_end_date           DATE
                                  ,p_index              NUMBER) IS

      CURSOR c_infonavit_info IS
          SELECT piv.name
                ,piv.input_value_id
                ,pee.element_entry_id
                ,pee.assignment_id
                ,peev.screen_entry_value
                ,pee.effective_start_date
                ,pee.effective_end_date
            FROM pay_input_values_f piv
                ,pay_element_entries_f pee
                ,pay_element_entry_values_f peev
           WHERE piv.effective_start_date  <= p_end_date
             AND piv.effective_end_date    >= p_start_date
             AND piv.element_type_id        = p_element_type_id
             AND pee.element_entry_id       = p_element_entry_id
             AND pee.assignment_id          = p_assignment_id
             AND pee.element_type_id        = piv.element_type_id
             AND pee.effective_start_date  <= p_end_date
             AND pee.effective_end_date    >= p_start_date
             AND peev.element_entry_id      = pee.element_entry_id
             AND peev.effective_start_date <= p_end_date
             AND peev.effective_end_date   >= p_start_date
             AND pee.effective_start_date   = peev.effective_start_date
             AND pee.effective_end_date     = peev.effective_end_date
             AND peev.input_value_id        = piv.input_value_id
        ORDER BY piv.display_sequence;
    BEGIN

        FOR c_infonavit_info_rec IN c_infonavit_info LOOP
            IF c_infonavit_info_rec.name = 'Credit Number' THEN
                trn(p_index).credit_number :=
                                      c_infonavit_info_rec.screen_entry_value;
            ELSIF c_infonavit_info_rec.name = 'Discount Type' THEN
                trn(p_index).discount_type :=
                                      c_infonavit_info_rec.screen_entry_value;
            ELSIF c_infonavit_info_rec.name = 'Discount Value' THEN
                trn(p_index).discount_value :=
                                      c_infonavit_info_rec.screen_entry_value;
            ELSIF c_infonavit_info_rec.name = 'Reduction Table Applies' THEN
                -- Bug 5552692
                SELECT DECODE (c_infonavit_info_rec.screen_entry_value,
                               'Y', 'S',
                               'N') INTO trn(p_index).redxn_table_applies
                  FROM DUAL;
            END IF;
        END LOOP;
    END load_infonavit_info;

    /* This procedure loads transaction cache with data corresponding to
       INFONAVIT transactions 18, 19 and 20. */
    PROCEDURE load_infonavit_trans (
      p_element_entry_id     NUMBER,
      p_element_type_id      NUMBER,
      p_iv_name              pay_input_values_f.name%type,
      p_effective_start_date DATE,
      p_effective_end_date   DATE,
      p_screen_entry_value   pay_element_entry_values_f.screen_entry_value%type,
      p_tran_type            VARCHAR2) IS

        CURSOR c_infonavit_info ( cp_assignment_id      NUMBER
                                 ,cp_element_entry_id   NUMBER
                                 ,cp_element_type_id    NUMBER
                                 ,cp_start_date         DATE
                                 ,cp_end_date           DATE ) IS
          SELECT piv.name
                ,piv.input_value_id
                ,pee.element_entry_id
                ,pee.assignment_id
                ,peev.screen_entry_value
                ,pee.effective_start_date
                ,pee.effective_end_date
            FROM pay_input_values_f piv
                ,pay_element_entries_f pee
                ,pay_element_entry_values_f peev
           WHERE piv.effective_start_date  <= cp_end_date
             AND piv.effective_end_date    >= cp_start_date
             AND piv.element_type_id        = cp_element_type_id
             AND pee.element_entry_id       = cp_element_entry_id
             AND pee.assignment_id          = cp_assignment_id
             AND pee.element_type_id        = piv.element_type_id
             AND pee.effective_start_date  <= cp_end_date
             AND pee.effective_end_date    >= cp_start_date
             AND peev.element_entry_id      = pee.element_entry_id
             AND peev.effective_start_date <= cp_end_date
             AND peev.effective_end_date   >= cp_start_date
             AND pee.effective_start_date   = peev.effective_start_date
             AND pee.effective_end_date     = peev.effective_end_date
             AND peev.input_value_id        = piv.input_value_id
        ORDER BY piv.display_sequence;

        ln_trn_cnt    NUMBER;
        lb_tran_found BOOLEAN;
    BEGIN
        ln_trn_cnt := trn.count();
        lb_tran_found := FALSE;
        FOR c_infonavit_info_rec IN c_infonavit_info ( p_assignment_id
                                                      ,p_element_entry_id
                                                      ,p_element_type_id
                                                      ,p_effective_start_date
                                                      ,p_effective_end_date)
        LOOP
            IF p_iv_name = c_infonavit_info_rec.name AND
               p_screen_entry_value <> c_infonavit_info_rec.screen_entry_value
                                                                            THEN
                trn(ln_trn_cnt).type := p_tran_type;
                trn(ln_trn_cnt).date := fnd_date.date_to_canonical(
                                                      p_effective_end_date + 1);
                hr_utility_trace('Transaction '|| p_tran_type ||' found.');
                lb_tran_found := TRUE;
                EXIT;
            END IF;
        END LOOP;

        IF lb_tran_found THEN
          load_infonavit_info (p_assignment_id
                              ,p_element_entry_id
                              ,p_element_type_id
                              ,p_effective_start_date + 1 --bug 5568202
                              ,p_effective_end_date + 1 --bug 5568202
                              ,ln_trn_cnt);
          /*FOR c_infonavit_info_rec IN c_infonavit_info ( p_assignment_id
                                                        ,p_element_entry_id
                                                        ,p_element_type_id
                                                        ,p_effective_start_date
                                                        ,p_effective_end_date)
          LOOP
              IF c_infonavit_info_rec.name = 'Credit Number' THEN
                  trn(ln_trn_cnt).credit_number :=
                                        c_infonavit_info_rec.screen_entry_value;
              ELSIF c_infonavit_info_rec.name = 'Discount Type' THEN
                  trn(ln_trn_cnt).discount_type :=
                                        c_infonavit_info_rec.screen_entry_value;
              ELSIF c_infonavit_info_rec.name = 'Discount Value' THEN
                  trn(ln_trn_cnt).discount_value :=
                                        c_infonavit_info_rec.screen_entry_value;
              END IF;
          END LOOP;*/
        END IF;
    END load_infonavit_trans;

  BEGIN -- Main

    lv_procedure_name := 'arch_other_transactions';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_step := 1;

    fix_var_idw.DELETE;
    fix_var_idw_uniq.DELETE;
    prev_eff_date := fnd_date.canonical_to_date('0001/01/01');

    hr_utility.set_location(gv_package || lv_procedure_name, 910);
    ln_step := 91;

    OPEN  c_get_org_information(p_gre_id);
    FETCH c_get_org_information INTO lv_employer_ss_id;
    CLOSE c_get_org_information;

    hr_utility.set_location(gv_package || lv_procedure_name, 920);
    ln_step := 92;

    hr_utility.set_location(gv_package || lv_procedure_name, 930);
    ln_step := 93;

    IF gv_IDW_calc_method = 'B' THEN
        /*-- IDW factor table support --*/
        OPEN c_IDW_events;
            LOOP
                FETCH c_IDW_events INTO ld_effective_date;
                EXIT WHEN c_IDW_events%NOTFOUND;
                hr_utility_trace('Timestamp of IDW table update event = '||
                                 fnd_date.date_to_canonical(ld_effective_date));
                parse_all_ele_entries (ld_effective_date);
            END LOOP;
        CLOSE c_IDW_events;

        /*-- Support for change in seniority --*/
        IF pay_mx_soc_sec_archive.seniority_changed (p_person_id,
                                                     p_end_date,
                                                     p_start_date) = 'Y' THEN
            hr_utility_trace ('Seniority of person '||p_person_id||
                              ' has changed since last archiver run. IDW will'||
                              ' be recomputed for this person.');
            -- Get hire anniversary date
            ld_hire_anniversary := hr_mx_utility.get_hire_anniversary(
                                                                    p_person_id,
                                                                    p_end_date);
            hr_utility_trace ('Hire anniversary date of person '||p_person_id||
                        ' = '||fnd_date.date_to_canonical(ld_hire_anniversary));

            -- Calculate anniversary date in current year
            SELECT ADD_MONTHS (TRUNC (p_end_date, 'Y'),
                               MONTHS_BETWEEN (ld_hire_anniversary,
                                               TRUNC (ld_hire_anniversary, 'Y'))
                               ) +
                  (ld_hire_anniversary - TRUNC (ld_hire_anniversary, 'MM'))
              INTO ld_anniversary_date
              FROM dual;

            hr_utility_trace ('Anniversary date of person '||p_person_id||
                        ' in the year of archiver run = '||
                              fnd_date.date_to_canonical(ld_anniversary_date));

            parse_all_ele_entries (ld_anniversary_date);
        END IF; -- seniority_changed?
    END IF; -- gv_IDW_calc_method = 'B'

    OPEN  c_ele_entries( p_business_group_id
                        ,p_assignment_id
                        ,p_start_date
                        ,p_end_date );

    LOOP

      FETCH c_ele_entries INTO ld_effective_date
                              ,lv_change_values
                              ,ln_element_entry_id
                              ,ld_calculation_date
                              ,lv_event_type;

      EXIT WHEN c_ele_entries%NOTFOUND;
      /* Adding event qualification mechanism so that only those events that
         belong to current GRE are picked for archival. (Bug 5921945)*/

      hr_utility.set_location(gv_package || lv_procedure_name, 20);
      ln_step := 2;

      hr_utility_trace('ld_effective_date   :' || ld_effective_date);
      hr_utility_trace('lv_change_values    :' || lv_change_values);
      hr_utility_trace('ln_element_entry_id :' || ln_element_entry_id);
      hr_utility_trace('ld_calculation_date :' || ld_calculation_date);
      hr_utility_trace('lv_event_type       :' || lv_event_type);

      OPEN  c_ele_type_id ( ln_element_entry_id
                           ,ld_effective_date );
      FETCH c_ele_type_id INTO ln_element_type_id
                              ,lv_creator_type
                              ,ld_ee_eff_start_date
                              ,ld_ee_eff_end_date;
      CLOSE c_ele_type_id;

      hr_utility.set_location(gv_package || lv_procedure_name, 30);
      ln_step := 3;

      hr_utility_trace('ln_element_type_id   :' || ln_element_type_id);

      hr_utility.set_location(gv_package || lv_procedure_name, 40);
      ln_step := 4;

      lv_idw_type := NULL;
      OPEN c_ele_extra_info (ln_element_type_id, ld_effective_date);

      FETCH c_ele_extra_info
      INTO lv_idw_type;

      CLOSE c_ele_extra_info;

      hr_utility.set_location(gv_package || lv_procedure_name, 50);
      ln_step := 5;

      hr_utility_trace('IDW_TYPE   :' || lv_idw_type);

      IF lv_idw_type IS NOT NULL THEN
         cache_IDW_date (lv_idw_type,
                         ld_effective_date);
      END IF;

      IF lv_creator_type  = 'A' THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 60);
         ln_step := 6;

         ln_abs_attend_type_id := 0;

         OPEN  c_abs_info ( p_business_group_id
                           ,p_assignment_id
                           ,ln_element_entry_id
                           ,ln_element_type_id
                           ,p_person_id
                           ,ld_ee_eff_start_date
                           ,ld_ee_eff_end_date );
                           --,p_start_date
                           --,p_end_date );

         hr_utility.set_location(gv_package || lv_procedure_name, 70);
         ln_step := 7;

         LOOP

           FETCH c_abs_info INTO ln_abs_attend_type_id
                                ,ln_abs_attendance_id
                                ,ln_absence_days
                                ,ld_date_start
                                ,ld_date_end
                                ,lv_abs_info_category
                                --,lv_disability_type
                                ,lv_disability_id;

           EXIT WHEN c_abs_info%NOTFOUND;

           hr_utility_trace('ln_abs_attend_type_id : '||ln_abs_attend_type_id);
           hr_utility_trace('ln_abs_attendance_id : '||ln_abs_attendance_id);
           hr_utility_trace('ln_absence_days : '|| ln_absence_days);
           hr_utility_trace('ld_date_start : '|| ld_date_start);
           hr_utility_trace('ld_date_end : '|| ld_date_end);
           hr_utility_trace('lv_abs_info_category: '|| lv_abs_info_category);
           --hr_utility_trace('lv_disability_type : '|| lv_disability_type);
           hr_utility_trace('lv_disability_id : '|| lv_disability_id);

           IF event_qualified (p_person_id,
	                       p_assignment_id,
                               ld_date_start,
                               p_gre_id) THEN

	      ln_trn_cnt := trn.COUNT;

              IF lv_disability_id IS NOT NULL THEN

                 trn(ln_trn_cnt).type           := '12';
                 --trn(ln_trn_cnt).dis_insurance_type := lv_disability_type;
                 trn(ln_trn_cnt).dis_num        := lv_disability_id;
                 trn(ln_trn_cnt).abs_start_date := fnd_date.date_to_canonical(
                                                            ld_date_start);
                 trn(ln_trn_cnt).abs_end_date   := fnd_date.date_to_canonical(
                                                            ld_date_end);

                 OPEN  c_disabilities_info (lv_disability_id);
                 FETCH c_disabilities_info
                              INTO trn(ln_trn_cnt).disability_percent,
                                   trn(ln_trn_cnt).subsidized_days,
                                   trn(ln_trn_cnt).dis_insurance_type,
                                   trn(ln_trn_cnt).consequence,
                                   trn(ln_trn_cnt).disability_control,
                                                  ln_incident_id;
                 CLOSE c_disabilities_info;

                 OPEN  c_work_incident_info (ln_incident_id);
                 FETCH c_work_incident_info INTO trn(ln_trn_cnt).risk_type;
                 CLOSE c_work_incident_info;

              ELSE

                 trn(ln_trn_cnt).type     := '11';
                 trn(ln_trn_cnt).dis_num  := NULL;

              END IF;

              trn(ln_trn_cnt).date := fnd_date.date_to_canonical(ld_date_start);

              trn(ln_trn_cnt).abs_days      := ln_absence_days;
              trn(ln_trn_cnt).idw_vol_contr := NULL;
              trn(ln_trn_cnt).salary_type   := NULL;

           END IF; -- event_qualified for Absence

         END LOOP;

         CLOSE c_abs_info;

      END IF; -- lv_creator_type  = 'A'


      IF event_qualified (p_person_id,
                          p_assignment_id,
                          ld_effective_date,
                          p_gre_id) THEN

         lv_infonavit := NULL;

         OPEN  c_get_infonavit(ln_element_type_id);
         FETCH c_get_infonavit INTO lv_infonavit;
         CLOSE c_get_infonavit;

         hr_utility_trace('lv_infonavit : '|| nvl(lv_infonavit, 'NULL'));

         IF lv_infonavit = 'INFONAVIT' THEN

           lb_tran_16_found := FALSE;
            FOR infonavit IN c_infonavit_info ( p_assignment_id
                                               ,ln_element_entry_id
                                               ,ln_element_type_id
                                               ,ld_ee_eff_start_date
                                               ,ld_ee_eff_end_date)
            LOOP

              hr_utility_trace('----------------------');
              hr_utility_trace('name : '|| infonavit.name);
              hr_utility_trace('screen_entry_value : '||
                                    infonavit.screen_entry_value);
              hr_utility_trace('input_value_id : '|| infonavit.input_value_id);
              hr_utility_trace('element_entry_id:'||infonavit.element_entry_id);
              hr_utility_trace('assignment_id : '|| infonavit.assignment_id);
              hr_utility_trace('effective_start_date : '||
                                                infonavit.effective_start_date);
              hr_utility_trace('effective_end_date : '||
                                                infonavit.effective_end_date);

              IF infonavit.name = 'Credit Number' THEN

                 gv_credit_no         := infonavit.screen_entry_value;
                  -- transaction 20
                 load_infonavit_trans (ln_element_entry_id,
                                       ln_element_type_id,
                                       infonavit.name,
                                       ld_ee_eff_start_date - 1,
                                       infonavit.effective_start_date - 1,
                                       infonavit.screen_entry_value,
                                       '20');

              ELSIF infonavit.name IN ('Credit Start Date',
                                       'Discount Start Date') THEN

                 gv_credit_start_date := infonavit.screen_entry_value;

              ELSIF infonavit.name = 'Credit Grant Date' THEN

                 gv_crdt_grant_dt := infonavit.screen_entry_value;

              ELSIF infonavit.name = 'Discount Type' THEN

                 gv_discount_type     := infonavit.screen_entry_value;
                  -- transaction 18
                 load_infonavit_trans (ln_element_entry_id,
                                       ln_element_type_id,
                                       infonavit.name,
                                       ld_ee_eff_start_date - 1,
                                       infonavit.effective_start_date - 1,
                                       infonavit.screen_entry_value,
                                       '18');

              ELSIF infonavit.name = 'Discount Value' THEN

                 gv_discount_value    := infonavit.screen_entry_value;
                  -- transaction 19
                 load_infonavit_trans (ln_element_entry_id,
                                       ln_element_type_id,
                                       infonavit.name,
                                       ld_ee_eff_start_date - 1,
                                       infonavit.effective_start_date - 1,
                                       infonavit.screen_entry_value,
                                       '19');

              /*-- Identify INFONAVIT transaction - Suspension of Discount --*/
              ELSIF infonavit.effective_end_date < hr_general.end_of_time AND
                NOT lb_tran_16_found THEN

                  ln_next_element_entry_id := -1;

                  OPEN csr_infonavit_tran_16 (ln_element_type_id,
                                              infonavit.effective_end_date + 1,
                                              p_end_date);
                  FETCH csr_infonavit_tran_16 INTO ln_next_element_entry_id;
                  CLOSE csr_infonavit_tran_16;

                  IF ln_next_element_entry_id = -1 THEN

                     ln_trn_cnt := trn.count();
                     trn (ln_trn_cnt).type := '16';
                     trn (ln_trn_cnt).date := fnd_date.date_to_canonical (
                                                  infonavit.effective_end_date);

                     load_infonavit_info (p_assignment_id
                                         ,ln_element_entry_id
                                         ,ln_element_type_id
                                         ,ld_ee_eff_start_date
                                         ,ld_ee_eff_end_date
                                         ,ln_trn_cnt);
                     lb_tran_16_found := TRUE;
                     hr_utility_trace ('Transaction 16 found.');

                  END IF;

              ELSIF infonavit.name = 'Transaction Type' AND
                 infonavit.screen_entry_value IS NOT NULL AND
                 NOT lb_tran_16_found THEN

                 ln_trn_cnt := trn.count();

                 IF infonavit.screen_entry_value = 'CREDIT_BEGIN' THEN

                    trn(ln_trn_cnt).type := '15';
                    hr_utility_trace ('Transaction 15 found.');

                 ELSIF infonavit.screen_entry_value = 'DISC_RESUME' THEN

                    trn(ln_trn_cnt).type := '17';
                    hr_utility_trace ('Transaction 17 found.');

                 END IF;

                 -- gv_credit_start_date is already in canonical date format.

                 trn(ln_trn_cnt).date := nvl(gv_credit_start_date,
                                             fnd_date.date_to_canonical(
                                              infonavit.effective_start_date));

                 load_infonavit_info (p_assignment_id
                                     ,ln_element_entry_id
                                     ,ln_element_type_id
                                     ,ld_ee_eff_start_date
                                     ,ld_ee_eff_end_date
                                     ,ln_trn_cnt);

              END IF;

            END LOOP; -- infonavit

            IF gv_credit_no IS NOT NULL THEN
               gn_person_rec_chng := 1;
            END IF;

         END IF; -- lv_infonavit = 'INFONAVIT'

      END IF; -- event_qualified for 'INFONAVIT'

    END LOOP; -- c_ele_entries

    CLOSE c_ele_entries;

    IF fix_var_idw.COUNT > 0 THEN

       fix_var_idw_uniq.DELETE;

       FOR i in fix_var_idw.FIRST..fix_var_idw.LAST
       LOOP

           lv_fix_var_idw_found := 'N';
           hr_utility_trace('fix_var_idw(i).idw_type '||i||': '||
                             fix_var_idw(i).idw_type );
           hr_utility_trace('fix_var_idw(i).idw_date '||i||': '||
                             fix_var_idw(i).idw_date );
           hr_utility_trace('---------------------------------------');

           IF fix_var_idw_uniq.COUNT > 0 THEN

              FOR j in fix_var_idw_uniq.FIRST..fix_var_idw_uniq.LAST
              LOOP
                  hr_utility_trace('fix_var_idw_uniq(j).idw_type '||j||': '||
                                    fix_var_idw_uniq(j).idw_type );
                  hr_utility_trace('fix_var_idw_uniq(j).idw_date '||j||': '||
                                    fix_var_idw_uniq(j).idw_date );

                  IF fix_var_idw(i).idw_type = fix_var_idw_uniq(j).idw_type AND
                     fix_var_idw(i).idw_date = fix_var_idw_uniq(j).idw_date THEN

                     lv_fix_var_idw_found := 'Y';
                     hr_utility_trace('FOUND');

                  END IF;

              END LOOP;

           END IF;

           hr_utility_trace('---------------------------------------');

           IF lv_fix_var_idw_found = 'N' AND
              fix_var_idw(i).idw_type = 'FIXED' THEN

              hr_utility_trace('NOT FOUND');
              hr_utility_trace(' ');
              ln_count := fix_var_idw_uniq.COUNT;
              fix_var_idw_uniq(ln_count).idw_type := fix_var_idw(i).idw_type;
              fix_var_idw_uniq(ln_count).idw_date := fix_var_idw(i).idw_date;

           END IF;

       END LOOP;

       fix_var_idw.DELETE;
       fix_var_idw := fix_var_idw_uniq;
       fix_var_idw_uniq.DELETE;

       FOR i IN fix_var_idw.FIRST..fix_var_idw.LAST
       LOOP

         IF prev_eff_date <> fix_var_idw(i).idw_date THEN

            ln_idw          := 0;
            ln_fixed_idw    := 0;
            ln_variable_idw := 0;

            ln_idw := get_idw( p_assignment_id  => p_assignment_id
                              ,p_tax_unit_id    => p_gre_id
                              ,p_effective_date => fix_var_idw(i).idw_date
                              ,p_fixed_idw      => ln_fixed_idw
                              ,p_variable_idw   => ln_variable_idw );

            hr_utility.trace('SS_ARCH other TRN ln_idw: '||ln_idw);
            hr_utility.trace('SS_ARCH other TRN ln_fixed_idw: '||ln_fixed_idw);
            hr_utility.trace('SS_ARCH other TRN ln_variable_idw: '||
                                                              ln_variable_idw);

            hr_utility.set_location(gv_package || lv_procedure_name, 2030);
            ln_step := 203;

         END IF;

         prev_eff_date := fix_var_idw(i).idw_date;

         ln_trn_cnt := trn.COUNT;

         trn(ln_trn_cnt).type := '07';
         trn(ln_trn_cnt).date :=
                    fnd_date.date_to_canonical(fix_var_idw(i).idw_date);
         trn(ln_trn_cnt).dis_num       := NULL;
         trn(ln_trn_cnt).abs_days      := NULL;

         IF fix_var_idw(i).idw_type = 'FIXED' THEN
            trn(ln_trn_cnt).idw_vol_contr := ln_idw; --ln_fixed_idw;
         ELSE
            trn(ln_trn_cnt).idw_vol_contr := ln_idw; --ln_variable_idw;
         END IF;

         trn(ln_trn_cnt).salary_type := fix_var_idw(i).idw_type;

       END LOOP;

    END IF; -- fix_var_idw.COUNT > 0 THEN

    IF gv_variable_idw = 'Y' THEN

       ln_idw          := 0;
       ln_fixed_idw    := 0;
       ln_variable_idw := 0;

       ln_idw := get_idw( p_assignment_id  => p_assignment_id
                         ,p_tax_unit_id    => p_gre_id
                         ,p_effective_date =>
                            fnd_date.canonical_to_date(gv_periodic_end_date) + 1
                         ,p_fixed_idw      => ln_fixed_idw
                         ,p_variable_idw   => ln_variable_idw );

       hr_utility.trace('SS_ARCH other TRN VARIABLE ln_idw: '||ln_idw);
       hr_utility.trace('SS_ARCH other TRN VARIABLE ln_fixed_idw: '||
                                                             ln_fixed_idw);
       hr_utility.trace('SS_ARCH other TRN VARIABLE ln_variable_idw: '||
                                                             ln_variable_idw);

       hr_utility.set_location(gv_package || lv_procedure_name, 2040);
       ln_step := 204;

       ln_trn_cnt := trn.COUNT;

       trn(ln_trn_cnt).type          := '07';
       trn(ln_trn_cnt).date          :=
           fnd_date.date_to_canonical(
           trunc(fnd_date.canonical_to_date(gv_periodic_end_date)) + 1);
       trn(ln_trn_cnt).dis_num       := NULL;
       trn(ln_trn_cnt).abs_days      := NULL;
       trn(ln_trn_cnt).idw_vol_contr := ln_idw;
       trn(ln_trn_cnt).salary_type   := 'VARIABLE';

       hr_utility.set_location(gv_package || lv_procedure_name, 2050);

    END IF; -- gv_variable_idw = 'Y'

    IF trn.COUNT > 0 THEN

       FOR i IN trn.FIRST..trn.LAST LOOP

         OPEN  c_person_detail (p_person_id
                               ,fnd_date.canonical_to_date(trn(i).date));
         FETCH c_person_detail INTO lv_employee_ssn;
         CLOSE c_person_detail;

         ln_index := pay_mx_soc_sec_archive.lrr_act_tab.COUNT;

         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).action_info_category
                                := 'MX SS TRANSACTIONS';
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).jurisdiction_code
                                := NULL;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info1
                                := p_person_id;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info2
                                := trn(i).date;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info3
                                := lv_employee_ssn;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info4
                                := trn(i).type;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info5
                                := lv_employer_ss_id;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info6
                                := trn(i).dis_num;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info7
                                := trn(i).abs_days;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info8
                                := to_char(trn(i).idw_vol_contr,'99999.99');
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info9
                                := NULL;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info10
                                := NULL;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info11
                                := trn(i).salary_type;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info12
                                := trn(i).credit_number;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info13
                                := trn(i).discount_type;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info14
                                := trn(i).discount_value;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info15
                                := trn(i).redxn_table_applies;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info16
                                := trn(i).abs_start_date;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info17
                                := trn(i).subsidized_days;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info18
                                := trn(i).disability_percent;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info19
                                := trn(i).dis_insurance_type;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info20
                                := trn(i).risk_type;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info21
                                := trn(i).consequence;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info22
                                := trn(i).disability_control;
         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info23
                                := trn(i).abs_end_date;

       END LOOP;

    END IF; -- trn.COUNT > 0

    EXCEPTION
    WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END arch_other_transactions;

  PROCEDURE arch_hire_separation (
                 p_payroll_action_id IN NUMBER
                ,p_asg_action_id     IN NUMBER
                ,p_effective_date    IN DATE
                ,p_assignment_id     IN NUMBER
                ,p_person_id         IN NUMBER
                ,p_chunk_number      IN NUMBER
                ,p_start_date        IN DATE
                ,p_end_date          IN DATE
                ,p_business_group_id IN NUMBER
                ,p_gre_id            IN NUMBER
                ,p_eff_start_date    IN DATE
                ,p_eff_end_date      IN DATE
                ,p_asg_events        IN
                             pay_interpreter_pkg.t_detailed_output_table_type
                ) IS

    CURSOR c_get_report_term_rehire (cp_asg_id    IN NUMBER) IS
      SELECT segment10
        FROM per_all_assignments_f  paf
             ,hr_soft_coding_keyflex hck
       WHERE paf.assignment_id = cp_asg_id
         AND paf.soft_coding_keyflex_id = hck.soft_coding_keyflex_id;

    CURSOR c_get_asg_scl (cp_asg_id         IN NUMBER
                         ,cp_effective_date IN DATE) IS
      SELECT segment1
            ,assignment_number
        FROM per_all_assignments_f  paf
            ,hr_soft_coding_keyflex hck
       WHERE paf.assignment_id = cp_asg_id
         AND cp_effective_date BETWEEN paf.effective_start_date
                                   AND paf.effective_end_date
         AND paf.soft_coding_keyflex_id = hck.soft_coding_keyflex_id;

    CURSOR c_get_asg_loc (cp_asg_id         IN NUMBER
                         ,cp_effective_date IN DATE) IS
      SELECT location_id
            ,assignment_number
        FROM per_all_assignments_f
       WHERE assignment_id = cp_asg_id
         AND cp_effective_date BETWEEN effective_start_date
                                   AND effective_end_date;


    CURSOR c_get_org_information ( cp_organization_id IN NUMBER) IS
      SELECT replace(org_information1,'-','') Social_Security_ID
        FROM hr_organization_information
       WHERE org_information_context = 'MX_SOC_SEC_DETAILS'
         AND organization_id         = cp_organization_id ;

    CURSOR c_person_detail (cp_person_id      IN NUMBER
                           ,cp_effective_date IN DATE) IS
      SELECT replace(ppf.per_information3,'-','')        emp_ssnumber
        FROM per_all_people_f ppf
       WHERE ppf.person_id = cp_person_id
         -- Bug 6013218
         AND cp_effective_date BETWEEN ppf.effective_start_date AND
                                       ppf.effective_end_date;
         /*AND ppf.effective_start_date =
                ( SELECT max(ppf_in.effective_start_date)
                    FROM per_all_people_f ppf_in
                   WHERE ppf_in.person_id      =  ppf.person_id
                     AND trunc(cp_end_date)   >= ppf_in.effective_start_date
                     AND trunc(cp_start_date) <= ppf_in.effective_end_date);*/

    CURSOR c_get_leaving_reason ( cp_assignment_id  IN NUMBER
                                 ,cp_effective_date IN DATE
                                 ,cp_gre_id         IN NUMBER ) IS
      SELECT aei_information3
        FROM per_assignment_extra_info pae
       WHERE pae.assignment_id = cp_assignment_id
         AND information_type  = 'MX_SS_EMP_TRANS_REASON'
         AND fnd_date.canonical_to_date(aei_information1) = cp_effective_date
         AND aei_information2  = cp_gre_id ;

    CURSOR c_get_pos_leaving_reason ( cp_assignment_id  IN NUMBER
                                     ,cp_effective_date IN DATE ) IS
      SELECT pds_information1
            ,actual_termination_date
        FROM per_periods_of_service ppos,
             per_all_assignments_f paf
       WHERE paf.assignment_id = cp_assignment_id
         AND paf.person_id = ppos.person_id
         AND cp_effective_date BETWEEN paf.effective_start_date
                                   AND paf.effective_end_date
         AND pds_information_category='MX';

   CURSOR c_asg_status_type ( cp_asg_status_type_id IN NUMBER) IS
     SELECT per_system_status
       FROM per_assignment_status_types
      WHERE assignment_status_type_id = cp_asg_status_type_id;

    CURSOR csr_asg_exists (cp_effective_date DATE) IS
        SELECT 'X'
          FROM per_assignments_f paf
         WHERE paf.assignment_id = p_assignment_id
           AND cp_effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
           AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                            paf.location_id
                                           ,paf.business_group_id
                                           ,paf.soft_coding_keyflex_id
                                           ,cp_effective_date) = p_gre_id;


    CURSOR csr_per_gre (cp_effective_date DATE,
                        cp_tran_type      VARCHAR2) IS
        SELECT 'Y'
          FROM per_assignments_f paf,
               per_assignment_status_types pst
         WHERE paf.person_id = p_person_id
           --AND paf.assignment_id <> p_assignment_id
           AND paf.assignment_status_type_id = pst.assignment_status_type_id
           AND ((cp_effective_date < paf.effective_end_date AND
                 cp_tran_type = '02' AND
                 -- Bug 6019466
                 pst.per_system_status = 'ACTIVE_ASSIGN') OR
                (cp_effective_date > paf.effective_start_date AND
                 cp_tran_type = '08'))
           AND paf.assignment_type = 'E'
           AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                            paf.location_id
                                           ,paf.business_group_id
                                           ,paf.soft_coding_keyflex_id
                                           ,cp_effective_date) = p_gre_id
 	   AND EXISTS (SELECT 1
	               FROM per_all_people_f per
		       WHERE per.person_id = paf.person_id
        	       AND  cp_effective_date
                            BETWEEN per.effective_start_date AND per.effective_end_date
			AND NVL(per.current_applicant_flag,'N') <> 'Y'
			AND paf.effective_start_date BETWEEN per.effective_start_date AND per.effective_end_date);

   /*Added to check for the applicant type */
    CURSOR c_check_per_status (p_person_id IN VARCHAR2 ,
                                  p_effective_date IN VARCHAR2) IS

       SELECT  per.current_applicant_flag
       FROM  per_all_people_f per
       WHERE per.person_id = p_person_id
       AND  fnd_date.canonical_to_date(p_effective_date)
            BETWEEN per.effective_start_date AND per.effective_end_date;

   /*bug 6933682*/
    CURSOR c_salary_type ( cp_assignment_id  IN NUMBER
                           ,cp_effective_date IN DATE) IS
      SELECT hck.segment6
        FROM per_all_assignments_f  paf
             ,hr_soft_coding_keyflex hck
       WHERE paf.assignment_id = cp_assignment_id
         AND paf.soft_coding_keyflex_id = hck.soft_coding_keyflex_id
         AND cp_effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date ;


    lv_hire       VARCHAR2(1);
    lv_separation VARCHAR2(1);

    lv_transaction_type    VARCHAR2(50);
    lv_employer_ss_id      VARCHAR2(50);
    lv_employee_ssn        VARCHAR2(50);
    lv_transaction_date    VARCHAR2(50);
    lv_leaving_reason      VARCHAR2(50);
    lv_relation_exists     VARCHAR2(1);
    lv_report_yes_no       VARCHAR2(4);

    ld_sep_date            DATE;
    ld_eff_date            DATE;
    ln_min_wage            NUMBER;

    ln_index               NUMBER;

    hire_sep               hire_separation;
    hire_sep_uniq          hire_separation;

    ln_soft_cod_kflx_found NUMBER;
    lv_table_name          VARCHAR2(150);
    lv_old_value           VARCHAR2(150);
    lv_new_value           VARCHAR2(150);
    lv_change_values       VARCHAR2(150);
    lv_msg_txt             VARCHAR2(250);
    lv_asg_number          VARCHAR2(150);
    ln_first_time          NUMBER;
    ln_asg_scl_old         NUMBER;
    ln_asg_scl_new         NUMBER;
    ln_asg_loc_old         NUMBER;
    ln_asg_loc_new         NUMBER;
    ln_count               NUMBER;
    ln_old_gre_id          NUMBER;
    ln_new_gre_id          NUMBER;
    lv_hire_sep_found      VARCHAR2(15);
    lv_sep_already_in      VARCHAR2(15);
    lv_hire_already_in     VARCHAR2(15);
    lv_old_asg_status      VARCHAR2(100);
    lv_new_asg_status      VARCHAR2(100);
    ln_asg_count           NUMBER;


    ln_idw                 NUMBER;
    ln_fixed_idw           NUMBER;
    ln_variable_idw        NUMBER;
    lv_idw                 VARCHAR2(100);

    lv_procedure_name      VARCHAR2(100);
    lv_error_message       VARCHAR2(2000);
    ln_step                NUMBER;

    lv_check_applicant       varchar2(1);
    ln_salary_type        VARCHAR2(10);

  BEGIN

    lv_procedure_name := 'arch_hire_separation';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_step := 1;

    lv_leaving_reason      := NULL;
    lv_idw                 := NULL;
    ld_eff_date            := p_eff_end_date;
    ln_soft_cod_kflx_found := 0;
    ln_idw                 := 0;
    ln_fixed_idw           := 0;
    ln_variable_idw        := 0;
    lv_hire                := 'N';

    hire_sep.DELETE;

    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 2;

    FOR i IN 1..p_asg_events.COUNT
    LOOP

      lv_table_name :=
               dated_tbls(p_asg_events(i).dated_table_id).table_name;

      hr_utility_trace('-----------------------------------------------');
      hr_utility_trace('Result row       :' ||to_char(i));
      hr_utility_trace('lv_table_name    :' ||lv_table_name );
      hr_utility_trace('Datetracked_event: '||
                             p_asg_events(i).datetracked_event );
      hr_utility_trace('Change_mode      : '||
                             p_asg_events(i).change_mode );
      hr_utility_trace('Effective_date   : '||
                 to_char(p_asg_events(i).effective_date,'DD-MON-YYYY'));
      hr_utility_trace('dated_table_id   : '||
                             TO_CHAR(p_asg_events(i).dated_table_id));
      hr_utility_trace('column_name      : '||
                             p_asg_events(i).column_name );
      hr_utility_trace('Update_type      : '||
                             p_asg_events(i).update_type );
      hr_utility_trace('old_value        : '||
                             p_asg_events(i).old_value );
      hr_utility_trace('new_value        : '||
                             p_asg_events(i).new_value );
      hr_utility_trace('change_values    : '||
                             p_asg_events(i).change_values );
      hr_utility_trace('-----------------------------------------------');

      ln_old_gre_id := -9;
      ln_new_gre_id := -9;

      lv_change_values := p_asg_events(i).change_values ;

      lv_old_value := ltrim(rtrim(SUBSTR(lv_change_values,1,
                           INSTR(lv_change_values,'->')-1)));

      lv_new_value := ltrim(rtrim(SUBSTR(lv_change_values,
                              INSTR(lv_change_values,'->')+3)));

      IF lv_old_value = '<null>' THEN
         lv_old_value := NULL;
      END IF;

      IF lv_new_value = '<null>' THEN
         lv_new_value := NULL;
      END IF;

      IF p_asg_events(i).update_type = 'I' THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 30);
         ln_step := 3;

         lv_hire  := 'Y';
         ln_count := hire_sep.COUNT;
         hire_sep(ln_count).trn_type := 'HIRE';
         hire_sep(ln_count).trn_date := p_asg_events(i).effective_date;

      ELSE

         hr_utility.set_location(gv_package || lv_procedure_name, 40);
         ln_step := 4;
         hr_utility_trace ('column_name = PER_ALL_ASSIGNMENTS_F.'||
                                                p_asg_events(i).column_name);
         IF p_asg_events(i).column_name = 'LOCATION_ID' THEN

            hr_utility.set_location(gv_package || lv_procedure_name, 50);

            /*
             * Retrieve the gre off the soft coding keyflex (scl). If a GRE has
             * been specified at the scl, location changes are moot.
             */
            OPEN c_get_asg_scl(p_assignment_id
                                     ,p_asg_events(i).effective_date - 1);

            FETCH c_get_asg_scl
             INTO ln_asg_scl_old
                 ,lv_asg_number;

            CLOSE c_get_asg_scl;

            OPEN c_get_asg_scl(p_assignment_id
                                     ,p_asg_events(i).effective_date);

            FETCH c_get_asg_scl
             INTO ln_asg_scl_new
                 ,lv_asg_number;

            CLOSE c_get_asg_scl;

            hr_utility.set_location(gv_package || lv_procedure_name, 60);
            ln_step := 6;

            ln_old_gre_id :=
               per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                     lv_old_value
                                     ,p_business_group_id
                                     ,ln_asg_scl_old
                                     ,p_asg_events(i).effective_date - 1);

            hr_utility.set_location(gv_package || lv_procedure_name, 70);

            IF ln_old_gre_id < 0 THEN
               lv_msg_txt := 'Unable to determine GRE: Assignment Number ['||
                             lv_asg_number ||'], Effective Date ['||
                             TO_CHAR(p_asg_events(i).effective_date - 1)||']';

               pay_core_utils.push_message(p_applid   => 800
                                          ,p_msg_name => NULL
                                          ,p_msg_txt  => lv_msg_txt
                                          ,p_level    => 'I');
            END IF;

           hr_utility_trace('Checking wherther the person is applicant');
           OPEN c_check_per_status(p_person_id, fnd_date.date_to_canonical(p_asg_events(i).effective_date - 1));
           FETCH  c_check_per_status INTO lv_check_applicant;

           CLOSE c_check_per_status;

	   IF lv_check_applicant = 'Y' THEN
            hr_utility_trace('The person is applicant on effective_date ' || fnd_date.date_to_canonical(p_asg_events(i).effective_date - 1));
            hr_utility_trace('making -9 for the gre that got by location');
            ln_old_gre_id := -9;
	   END IF;

            ln_step := 7;

            ln_new_gre_id :=
               per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                     lv_new_value
                                     ,p_business_group_id
                                     ,ln_asg_scl_new
                                     ,p_asg_events(i).effective_date);

            IF ln_new_gre_id < 0 THEN
               lv_msg_txt := 'Unable to determine GRE: Assignment Number ['||
                             lv_asg_number ||'], Effective Date ['||
                             TO_CHAR(p_asg_events(i).effective_date)||']';

               pay_core_utils.push_message(p_applid   => 800
                                          ,p_msg_name => NULL
                                          ,p_msg_txt  => lv_msg_txt
                                          ,p_level    => 'I');
            END IF;

            /*IF ( p_asg_events(1).update_type <> 'I' AND
                 p_asg_events(i).update_type <> 'I' )  THEN*/

               IF ln_old_gre_id = p_gre_id AND ln_new_gre_id <> p_gre_id
               THEN

                  hr_utility.set_location(gv_package||lv_procedure_name,100);
                  ln_step := 10;

                  ln_count := hire_sep.COUNT;
                  hire_sep(ln_count).trn_type := 'SEPARATION';
                  hire_sep(ln_count).trn_date :=
                                     p_asg_events(i).effective_date - 1;

               END IF;

               IF ln_old_gre_id <> p_gre_id AND ln_new_gre_id = p_gre_id
               THEN

                  hr_utility.set_location(gv_package||lv_procedure_name,110);
                  ln_step := 11;

                  ln_count := hire_sep.COUNT;
                  hire_sep(ln_count).trn_type := 'HIRE';
                  hire_sep(ln_count).trn_date :=
                                     p_asg_events(i).effective_date;

               END IF;

            --END IF; -- update_type <> 'I'


         ELSIF p_asg_events(i).column_name = 'SOFT_CODING_KEYFLEX_ID' THEN

            hr_utility.set_location(gv_package||lv_procedure_name,120);
            ln_step := 12;
            hr_utility_trace('Inside get_transaction and sof_coding  :');
            hr_utility_trace('p_assignment_id :' || p_assignment_id);
            hr_utility_trace('p_asg_events(i).effective_date - 1 :' || fnd_date.date_to_canonical(p_asg_events(i).effective_date - 1));
            OPEN c_get_asg_loc(p_assignment_id
                              ,p_asg_events(i).effective_date - 1);

            FETCH c_get_asg_loc
             INTO ln_asg_loc_old
                 ,lv_asg_number;

            CLOSE c_get_asg_loc;
            hr_utility_trace('Value from the cursor c_get_asg_loc');
            hr_utility_trace('ln_asg_loc_old '||ln_asg_loc_old);
            hr_utility_trace('lv_asg_number '||lv_asg_number);
            hr_utility.set_location(gv_package||lv_procedure_name,130);
            ln_step := 13;

            ln_old_gre_id := NVL(
                         per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                       ln_asg_loc_old
                                      ,p_business_group_id
                                      ,lv_old_value
                                      ,p_asg_events(i).effective_date - 1), -9);
           hr_utility_trace('Checking wherther the person is applicant');
           OPEN c_check_per_status(p_person_id, fnd_date.date_to_canonical(p_asg_events(i).effective_date - 1));
           FETCH  c_check_per_status INTO lv_check_applicant;

           CLOSE c_check_per_status;

	   IF lv_check_applicant = 'Y' THEN
            hr_utility_trace('The person is applicant on effective_date ' || fnd_date.date_to_canonical(p_asg_events(i).effective_date - 1));
            hr_utility_trace('making -9 for the gre that got by location');
            ln_old_gre_id := -9;
	   END IF;

            hr_utility.set_location(gv_package||lv_procedure_name,135);
            hr_utility_trace('ln_old_gre_id '||ln_old_gre_id);

            IF ln_old_gre_id < 0 THEN
            hr_utility_trace('ln_old_gre_id <0');
               lv_msg_txt := 'Unable to determine GRE: Assignment Number ['||
                             lv_asg_number ||'], Effective Date ['||
                             TO_CHAR(p_asg_events(i).effective_date - 1)||']';

               pay_core_utils.push_message(p_applid   => 800
                                          ,p_msg_name => NULL
                                          ,p_msg_txt  => lv_msg_txt
                                          ,p_level    => 'I');
            END IF;

            hr_utility.set_location(gv_package||lv_procedure_name,140);
            ln_step := 14;
            hr_utility_trace('p_assignment_id :' || p_assignment_id);
            hr_utility_trace('p_asg_events(i).effective_date :' || fnd_date.date_to_canonical(p_asg_events(i).effective_date ));
            OPEN c_get_asg_loc(p_assignment_id
                              ,p_asg_events(i).effective_date);

            FETCH c_get_asg_loc
             INTO ln_asg_loc_new
                 ,lv_asg_number;

            CLOSE c_get_asg_loc;
           hr_utility_trace('Value from the cursor c_get_asg_loc for new loc');
            hr_utility_trace('ln_asg_loc_new '||ln_asg_loc_new);
            hr_utility_trace('lv_asg_number '||lv_asg_number);
            ln_new_gre_id := NVL(
                         per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                        ln_asg_loc_new
                                       ,p_business_group_id
                                       ,lv_new_value
                                       ,p_asg_events(i).effective_date), -9);

            IF ln_new_gre_id < 0 THEN
             hr_utility_trace('ln_old_gre_id <0');
               lv_msg_txt := 'Unable to determine GRE: Assignment Number ['||
                             lv_asg_number ||'], Effective Date ['||
                             TO_CHAR(p_asg_events(i).effective_date - 1)||']';

               pay_core_utils.push_message(p_applid   => 800
                                          ,p_msg_name => NULL
                                          ,p_msg_txt  => lv_msg_txt
                                          ,p_level    => 'I');
            END IF;
             hr_utility_trace('p_gre_id '||p_gre_id);
             hr_utility_trace('ln_old_gre_id '||ln_old_gre_id);
             hr_utility_trace('ln_new_gre_id '||ln_new_gre_id);
            IF ln_old_gre_id = p_gre_id AND ln_new_gre_id <> p_gre_id
            THEN
              hr_utility_trace('ln_old_gre_id = p_gre_id AND ln_new_gre_id <> p_gre_id');
               hr_utility.set_location(gv_package||lv_procedure_name,100);
               ln_step := 10;

               ln_count := hire_sep.COUNT;
               hire_sep(ln_count).trn_type := 'SEPARATION';
               hire_sep(ln_count).trn_date :=
                                  p_asg_events(i).effective_date - 1;
             hr_utility_trace('Separation');
            END IF;

            IF ln_old_gre_id <> p_gre_id AND ln_new_gre_id = p_gre_id
            THEN
                hr_utility_trace('ln_old_gre_id <> p_gre_id AND ln_new_gre_id = p_gre_id');
               hr_utility.set_location(gv_package||lv_procedure_name,110);
               ln_step := 11;

               ln_count := hire_sep.COUNT;
               hire_sep(ln_count).trn_type := 'HIRE';
               hire_sep(ln_count).trn_date :=
                                  p_asg_events(i).effective_date;
            hr_utility_trace('Hire');
            END IF;

         ELSIF p_asg_events(i).column_name = 'ASSIGNMENT_STATUS_TYPE_ID' THEN

            -- ACTIVE_ASSIGN to TERM_ASSIGN   ok
            -- TERM_ASSIGN TO ACTIVE_ASSIGN
            -- ( This is a reverse termination. We need to record this as a HIRE
            --  Transaction. If the termination was reported to Social Security
            --  SUA and the Rehire needs to reported.)

            IF lv_old_value is NOT NULL  THEN
               OPEN  c_asg_status_type(TO_NUMBER(lv_old_value)) ;
               FETCH c_asg_status_type INTO lv_old_asg_status ;
               CLOSE c_asg_status_type ;
            END IF;

            IF lv_new_value IS NOT NULL THEN
               OPEN  c_asg_status_type(TO_NUMBER(lv_new_value)) ;
               FETCH c_asg_status_type INTO lv_new_asg_status ;
               CLOSE c_asg_status_type ;
            END IF;

            hr_utility_trace( 'old assignment status :'||lv_old_asg_status );
            hr_utility_trace( 'new assignment status :'||lv_new_asg_status );

            IF lv_old_asg_status = 'ACTIVE_ASSIGN' AND
               lv_new_asg_status = 'TERM_ASSIGN' THEN

               ln_count := hire_sep.COUNT;
               hire_sep(ln_count).trn_type := 'SEPARATION';

               SELECT COUNT(*)
                 INTO ln_asg_count
                 FROM per_all_assignments_f
                WHERE assignment_id        = p_assignment_id
                  AND effective_start_date = p_asg_events(i).effective_date;

               IF ln_asg_count > 0 THEN

                  hire_sep(ln_count).trn_date :=
                           p_asg_events(i).effective_date - 1;

               ELSE

                  hire_sep(ln_count).trn_date := p_asg_events(i).effective_date;

               END IF;


            ELSE
               ln_count := hire_sep.COUNT;
               hire_sep(ln_count).trn_type := 'HIRE';
               hire_sep(ln_count).trn_date := p_asg_events(i).effective_date;

            END IF;

         ELSIF p_asg_events(i).column_name = 'EMPLOYMENT_CATEGORY' THEN

            IF NVL(lv_old_value, 'NULL') <> NVL(lv_new_value, 'NULL') THEN

               IF gn_person_rec_chng = 0 THEN
                  gn_person_rec_chng := 1;
               END IF;

            END IF;

         ELSIF p_asg_events(i).column_name = 'EFFECTIVE_END_DATE'  THEN

               /**********************************************************
               ** IGNORE THE TRANSACTION IF EFFECTIVE_DATE is 31-Dec-4712,
               ** AS PER VM.
               **********************************************************/

               /* PEM returns a change in EFFECTIVE_END_DATE for *every*
                  date-tracked update to the asg record. We need to ignore
                  EFFECTIVE_END_DATE events if assignment is not terminated.
                  (Bug 5888285)*/
               lv_old_asg_status := NULL;
               OPEN csr_asg_exists(p_asg_events(i).effective_date + 1);
                    FETCH csr_asg_exists INTO lv_old_asg_status;
               CLOSE csr_asg_exists;

               /*IF p_asg_events(i).effective_date <>
                               to_date('4712/12/31', 'yyyy/mm/dd') THEN*/
               IF lv_old_asg_status IS NULL THEN
                  ln_count := hire_sep.COUNT;
                  hire_sep(ln_count).trn_type := 'SEPARATION';
                  hire_sep(ln_count).trn_date := p_asg_events(i).effective_date;
               END IF;

         END IF;

      END IF;

      hr_utility_trace('---------------------------------------');
      hr_utility_trace('Row in Location  :' ||i);
      hr_utility_trace('lv_change_values :' ||lv_change_values);
      hr_utility_trace('lv_old_value     :' ||lv_old_value    );
      hr_utility_trace('lv_new_value     :' ||lv_new_value    );
      hr_utility_trace('ln_old_gre_id    :' ||ln_old_gre_id       );
      hr_utility_trace('ln_new_gre_id    :' ||ln_new_gre_id       );
      hr_utility_trace('p_gre_id         :' ||p_gre_id       );

      IF hire_sep.COUNT > 0 THEN

         hr_utility_trace('ln_count         :' ||ln_count);
         hr_utility_trace('TRN_TYPE         :' ||hire_sep(ln_count).trn_type);
         hr_utility_trace('TRN_DATE         :' ||hire_sep(ln_count).trn_date);

      ELSE

         hr_utility_trace('NO RECORD FOUND in hire_sep table');
      END IF;

      hr_utility_trace('---------------------------------------');

    END LOOP;

    IF hire_sep.COUNT > 0 THEN

       hire_sep_uniq.DELETE;

       lv_sep_already_in  := 'N';
       lv_hire_already_in := 'N';

       FOR i in hire_sep.FIRST..hire_sep.LAST
       LOOP

           lv_hire_sep_found := 'N';

           hr_utility_trace('hire_sep(i).trn_type '||i||': '||
                             hire_sep(i).trn_type );
           hr_utility_trace('hire_sep(i).trn_date '||i||': '||
                             hire_sep(i).trn_date );
           hr_utility_trace('---------------------------------------');

           IF hire_sep_uniq.COUNT > 0 THEN

              FOR j in hire_sep_uniq.FIRST..hire_sep_uniq.LAST
              LOOP
                  hr_utility_trace('hire_sep_uniq(j).trn_type '||j||': '||
                                    hire_sep_uniq(j).trn_type );
                  hr_utility_trace('hire_sep_uniq(j).trn_date '||j||': '||
                                    hire_sep_uniq(j).trn_date );

                  IF hire_sep(i).trn_type = hire_sep_uniq(j).trn_type AND
                     hire_sep(i).trn_date = hire_sep_uniq(j).trn_date THEN

                     lv_hire_sep_found := 'Y';
                     hr_utility_trace('FOUND');

                  END IF;

              END LOOP;

           END IF;

           hr_utility_trace('---------------------------------------');

           /**************************************************************
           ** There should not be a hire/separation record followed by
           ** another hire/separation record.
           ** That means, there should be an hire/sepatation record
           ** between two separation/hire records.
           ** lv_sep_already_in and lv_hire_already_in flags are used to
           ** fulfill above requirement.
           ***************************************************************/

           IF lv_hire_sep_found = 'N' THEN

              IF hire_sep(i).trn_type = 'HIRE' THEN

                 IF lv_hire_already_in = 'N' THEN

                    lv_hire_already_in := 'Y';
                    lv_sep_already_in  := 'N';

                    hr_utility_trace('NOT FOUND'||hire_sep(i).trn_type);
                    hr_utility_trace(' ');
                    ln_count := hire_sep_uniq.COUNT;
                    hire_sep_uniq(ln_count).trn_type := hire_sep(i).trn_type;
                    hire_sep_uniq(ln_count).trn_date := hire_sep(i).trn_date;

                 END IF; -- lv_hire_already_in = 'N'

              ELSIF hire_sep(i).trn_type = 'SEPARATION' THEN

                 IF lv_sep_already_in = 'N' THEN

                    lv_hire_already_in := 'N';
                    lv_sep_already_in  := 'Y';

                    hr_utility_trace('NOT FOUND'||hire_sep(i).trn_type);
                    hr_utility_trace(' ');

                    ln_count := hire_sep_uniq.COUNT;
                    hire_sep_uniq(ln_count).trn_type := hire_sep(i).trn_type;
                    -- Bug 5005254
                    hire_sep_uniq(ln_count).trn_date := hire_sep(i).trn_date;

                 END IF; -- lv_sep_already_in = 'N'

              END IF; -- hire_sep(i).trn_type

           END IF; -- lv_hire_sep_found = 'N'

       END LOOP;

       hire_sep.DELETE;
       hire_sep := hire_sep_uniq;
       hire_sep_uniq.DELETE;

       hr_utility.set_location(gv_package || lv_procedure_name, 210);
       ln_step := 21;

       OPEN  c_get_org_information(p_gre_id);
       FETCH c_get_org_information INTO lv_employer_ss_id;
       CLOSE c_get_org_information;

       hr_utility.set_location(gv_package || lv_procedure_name, 220);
       ln_step := 22;

       FOR i in hire_sep.FIRST..hire_sep.LAST
       LOOP

       hr_utility.trace('Count hire_sep array :'|| i);
       lv_relation_exists := 'N';
          IF hire_sep(i).trn_type = 'HIRE' THEN

             hr_utility.set_location(gv_package || lv_procedure_name, 240);
             ln_step := 24;

             lv_transaction_type := '08';
             lv_transaction_date :=
                    fnd_date.date_to_canonical(hire_sep(i).trn_date);
             lv_leaving_reason   := NULL;
             hr_utility.trace('lv_transaction_date is: '||lv_transaction_date);
             /* Do not archive this transaction if person-GRE relation
                already exists prior to transaction date. */
             OPEN csr_per_gre(hire_sep(i).trn_date,
                              lv_transaction_type);
                FETCH csr_per_gre INTO lv_relation_exists;
             CLOSE csr_per_gre;
             hr_utility.trace('lv_relation_exists is: '||lv_relation_exists);
             hr_utility.set_location(gv_package || lv_procedure_name, 230);
             ln_step := 23;

             ln_idw := get_idw( p_assignment_id  => p_assignment_id
                               ,p_tax_unit_id    => p_gre_id
                               ,p_effective_date => hire_sep(i).trn_date
                               ,p_fixed_idw      => ln_fixed_idw
                               ,p_variable_idw   => ln_variable_idw );

             hr_utility.trace('SS_ARCH hire_sep ln_idw: '||ln_idw);
             hr_utility.trace('SS_ARCH hire_sep ln_fixed_idw: '||ln_fixed_idw);
             hr_utility.trace('SS_ARCH hire_sep ln_variable_idw: '||
                                                            ln_variable_idw);

             hr_utility.set_location(gv_package || lv_procedure_name, 2030);
             ln_step := 203;

             lv_idw              := to_char(ln_idw, '99999.99'); --Bug 8988585

             hr_utility.trace('SS_ARCH hire_sep lv_idw: '||lv_idw);

             IF gn_person_rec_chng = 0 THEN
                gn_person_rec_chng := 1;
             END IF;

          ELSIF hire_sep(i).trn_type = 'SEPARATION' THEN

             hr_utility.set_location(gv_package || lv_procedure_name, 250);
             ln_step := 25;

             lv_transaction_type := '02';
             lv_transaction_date :=
                    fnd_date.date_to_canonical(hire_sep(i).trn_date);

             ld_eff_date         := hire_sep(i).trn_date;
             lv_idw              := NULL;

             /* Do not archive this transaction if person-GRE relation
                already exists after transaction date. */
             OPEN csr_per_gre(hire_sep(i).trn_date,
                              lv_transaction_type);
                FETCH csr_per_gre INTO lv_relation_exists;
             CLOSE csr_per_gre;
              hr_utility.trace('lv_relation_exists is: '||lv_relation_exists);

             hr_utility.set_location(gv_package || lv_procedure_name, 260);
             ln_step := 26;

             OPEN c_get_leaving_reason( p_assignment_id
                                       ,ld_eff_date
                                       ,p_gre_id
                                      );
             FETCH c_get_leaving_reason INTO lv_leaving_reason ;
             CLOSE c_get_leaving_reason;

             IF lv_leaving_reason IS NULL THEN

                hr_utility.set_location(gv_package || lv_procedure_name, 270);
                ln_step := 27;

                -- get it from periods of service
                -- also the effective date passed is not correct
                -- so need to get the actual termination date

                OPEN  c_get_pos_leaving_reason( p_assignment_id
                                               ,ld_eff_date );
                FETCH c_get_pos_leaving_reason INTO lv_leaving_reason
                                                   ,ld_sep_date;
                CLOSE c_get_pos_leaving_reason;

             END IF;

          END IF;

          IF lv_relation_exists = 'N' THEN
              hr_utility.set_location(gv_package || lv_procedure_name, 280);
              ln_step := 28;
               hr_utility_trace('lv_transaction_date :'|| lv_transaction_date);
              OPEN  c_person_detail (p_person_id
                                    ,fnd_date.canonical_to_date
                                                        (lv_transaction_date));
              FETCH c_person_detail INTO lv_employee_ssn;
              CLOSE c_person_detail;

	      OPEN c_get_report_term_rehire (p_assignment_id);
             FETCH c_get_report_term_rehire INTO lv_report_yes_no;
             CLOSE c_get_report_term_rehire;

             IF lv_report_yes_no = 'N' THEN
                lv_report_yes_no := 'No';
           ELSE lv_report_yes_no := 'Yes';
           END IF;

              /*6933682*/
	      OPEN  c_salary_type(  p_assignment_id
	                           ,hire_sep(i).trn_date);
   	      FETCH c_salary_type INTO ln_salary_type;
   	       CLOSE c_salary_type;
   	          hr_utility.set_location(gv_package || lv_procedure_name, 300);
                  ln_step := 28;
               IF ln_salary_type ='1' THEN
                  ln_salary_type :='VARIABLE';
               ELSIF ln_salary_type ='2' THEN
                     ln_salary_type :='MIXED';
               ELSIF ln_salary_type = '0' THEN
                     ln_salary_type :='FIXED';
               END IF;

              ln_index := pay_mx_soc_sec_archive.lrr_act_tab.COUNT;

              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).action_info_category
                                     := 'MX SS TRANSACTIONS';
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).jurisdiction_code
                                     := NULL;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info1
                                     := p_person_id;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info2
                                     := lv_transaction_date;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info3
                                     := lv_employee_ssn;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info4
                                     := lv_transaction_type;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info5
                                     := lv_employer_ss_id;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info6
                                     := NULL;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info7
                                     := NULL;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info8
                                     := lv_idw;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info9
                                     := lv_leaving_reason;
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info10
                                     := NULL;
              IF pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info11 IS NULL THEN
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info11
                                     := ln_salary_type;
              END IF; /*6933682*/
              pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info24
                                     := lv_report_yes_no;
              hr_utility_trace('Archived MX SS Transaction for hire');
              hr_utility_trace('-----------------------------------');
	      hr_utility_trace('index ' || ln_index);
              hr_utility_trace('pay_mx_soc_sec_archive.lrr_act_tab(ln_index).action_info_category ' ||
	                        pay_mx_soc_sec_archive.lrr_act_tab(ln_index).action_info_category);
              hr_utility_trace(' pay_mx_soc_sec_archive.lrr_act_tab(ln_index).jurisdiction_code ' ||
	                         pay_mx_soc_sec_archive.lrr_act_tab(ln_index).jurisdiction_code);
              hr_utility_trace('Person ID ' ||
	                        pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info1);
              hr_utility_trace('Transaction date ' ||
	                        pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info2);
              hr_utility_trace('transaction type ' ||
	                        pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info4);
              hr_utility_trace('-----------------------------------');


          ELSE
              hr_utility_trace('Person-GRE association exits. Transaction '||
                               lv_transaction_type||' ('||lv_transaction_date||
                                                     ') will not be archived.');
          END IF;
       END LOOP;

    END IF;


    EXCEPTION
    WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END arch_hire_separation;

  PROCEDURE get_transactions( p_payroll_action_id IN NUMBER
                             ,p_asg_action_id     IN NUMBER
                             ,p_effective_date    IN DATE
                             ,p_assignment_id     IN NUMBER
                             ,p_person_id         IN NUMBER
                             ,p_chunk_number      IN NUMBER
                             ,p_start_date        IN DATE
                             ,p_end_date          IN DATE
                             ,p_business_group_id IN NUMBER
                             ,p_gre_id            IN NUMBER ) IS

    CURSOR c_get_event_group (cp_event_group_name IN VARCHAR2) IS
      SELECT event_group_id
        FROM pay_event_groups
       WHERE event_group_name = cp_event_group_name;

    CURSOR c_assignments ( cp_assignment_id          IN NUMBER
                          ,cp_start_date             IN DATE
                          ,cp_end_date               IN DATE
                          ,cp_gre_id                 IN NUMBER ) IS
      SELECT paf.assignment_id
            ,paf.location_id
            ,paf.soft_coding_keyflex_id
            ,paf.effective_start_date
            ,paf.effective_end_date
        FROM per_all_assignments_f paf
       WHERE paf.assignment_id     = cp_assignment_id
         AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                            paf.location_id
                                           ,paf.business_group_id
                                           ,paf.soft_coding_keyflex_id
                                           ,trunc(cp_end_date)) = cp_gre_id
       ORDER BY paf.assignment_id
               ,paf.effective_start_date desc
               ,paf.effective_end_date desc;

    CURSOR csr_get_asg_end_date (cp_effective_date DATE) IS
        SELECT effective_end_date
          FROM per_assignments_f pa
         WHERE pa.assignment_id = p_assignment_id
           AND pa.effective_end_date = cp_effective_date
           AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                            location_id
                                           ,business_group_id
                                           ,soft_coding_keyflex_id
                                           ,cp_effective_date) = p_gre_id
	   AND EXISTS (SELECT 1
	               FROM per_all_people_f per
		       WHERE per.person_id = pa.person_id
        	       AND  cp_effective_date
                            BETWEEN per.effective_start_date AND per.effective_end_date
			AND NVL(per.current_applicant_flag,'N') <> 'Y');


    ln_assignment_id     NUMBER;
    ln_location_id       NUMBER;
    ln_soft_cod_kflx_id  NUMBER;
    ld_eff_start_date    DATE;
    ld_eff_end_date      DATE;
    ld_effective_date    DATE;

    ln_gre_id            NUMBER;
    ln_event_group_id    NUMBER;

    int_pkg_events       pay_interpreter_pkg.t_detailed_output_table_type;
    --asg_events_table     t_int_asg_event_table;
    l_proration_dates    pay_interpreter_pkg.t_proration_dates_table_type;
    l_proration_changes  pay_interpreter_pkg.t_proration_type_table_type;
    l_pro_type_tab       pay_interpreter_pkg.t_proration_type_table_type;
    l_global_env         pay_interpreter_pkg.t_global_env_rec;
    l_dynamic_sql        pay_interpreter_pkg.t_dynamic_sql_tab;


    asg_events           pay_interpreter_pkg.t_detailed_output_table_type;
    per_events           pay_interpreter_pkg.t_detailed_output_table_type;
    ele_events           pay_interpreter_pkg.t_detailed_output_table_type;
    eev_events           pay_interpreter_pkg.t_detailed_output_table_type;
    asg_count            NUMBER;
    per_count            NUMBER;
    ele_count            NUMBER;
    eev_count            NUMBER;

    lv_table_name        VARCHAR2(150);

    lv_procedure_name    VARCHAR2(100);
    lv_error_message     VARCHAR2(2000);
    ln_step              NUMBER;

  BEGIN

    lv_procedure_name := 'get_transactions';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_step := 1;

    ld_eff_start_date      := p_start_date;
    ld_eff_end_date        := p_end_date;
    asg_count              := 0;
    per_count              := 0;
    ele_count              := 0;
    eev_count              := 0;

    asg_events.DELETE;
    per_events.DELETE;
    ele_events.DELETE;
    eev_events.DELETE;

    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 2;

    OPEN  c_get_event_group ('Mexico Social Security Reports');
    FETCH c_get_event_group INTO ln_event_group_id;
    CLOSE c_get_event_group;

    hr_utility_trace('p_person_id : ' || p_person_id);
    hr_utility_trace('p_start_date : ' || p_start_date);
    hr_utility_trace('p_end_date : ' || p_end_date);
    hr_utility_trace('p_gre_id : ' || p_gre_id);

    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    ln_step := 3;

    OPEN  c_assignments ( p_assignment_id
                         ,p_start_date
                         ,p_end_date
                         ,p_gre_id);
    FETCH c_assignments INTO ln_assignment_id
                            ,ln_location_id
                            ,ln_soft_cod_kflx_id
                            ,ld_eff_start_date
                            ,ld_eff_end_date;
    CLOSE c_assignments;

    hr_utility.set_location(gv_package || lv_procedure_name, 40);
    ln_step := 4;

    pay_interpreter_pkg.entry_affected(
          p_element_entry_id      => NULL
         ,p_assignment_action_id  => NULL
         ,p_assignment_id         => p_assignment_id
         ,p_mode                  => NULL
         ,p_process               => NULL
         ,p_event_group_id        => ln_event_group_id
         ,p_process_mode          => 'ENTRY_CREATION_DATE'
         ,p_start_date            => p_start_date
         ,p_end_date              => p_end_date
         ,p_unique_sort           => 'N' --tells intrprtr not to do unique sort
         ,p_business_group_id     => NULL
         ,t_detailed_output       => int_pkg_events   --OUTPUT OF RESULTS
         ,t_proration_dates       => l_proration_dates
         ,t_proration_change_type => l_proration_changes
         ,t_proration_type        => l_pro_type_tab);

    hr_utility.set_location(gv_package || lv_procedure_name, 50);
    ln_step := 5;
    hr_utility_trace('pay_interpreter_pkg.entry_affected Returned Rows');

    IF int_pkg_events.COUNT > 0 THEN

       FOR i IN 1..int_pkg_events.COUNT
       LOOP
            /*IF lv_table_name = 'PER_ALL_ASSIGNMENTS_F' THEN
                IF int_pkg_events(i).column_name = 'LOCATION_ID' THEN
                    int_pkg_events(i).effective_date :=
                                          int_pkg_events(i).effective_date - 1;
                END IF;
            END IF;*/

          /* Adding event qualification mechanism so that only those events that
             belong to current GRE are picked for archival. (Bug 5921945)*/
	     hr_utility.set_location(gv_package || lv_procedure_name, 60);
            ld_effective_date := int_pkg_events(i).effective_date;
           hr_utility_trace('ld_effective_date :' ||ld_effective_date);
            -- Bug 6005853
            IF int_pkg_events(i).column_name IN ('LOCATION_ID',
                                                 'SOFT_CODING_KEYFLEX_ID') THEN
            hr_utility_trace('Inside the event on location or soft key flex');
                OPEN csr_get_asg_end_date (int_pkg_events(i).effective_date-1);
                    FETCH csr_get_asg_end_date INTO ld_effective_date;
                CLOSE csr_get_asg_end_date;
            hr_utility_trace('ld_effective_date :' ||ld_effective_date);
            END IF;
            hr_utility_trace('final ld_effective_date :' || ld_effective_date);
            IF event_qualified(p_person_id,
	                       p_assignment_id,
                               ld_effective_date,
                               p_gre_id) THEN
             lv_table_name :=
                        dated_tbls(int_pkg_events(i).dated_table_id).table_name;

            hr_utility_trace('-----------------------------------------------');
            hr_utility_trace('lv_table_name    :' ||lv_table_name );


             IF lv_table_name = 'PER_ALL_ASSIGNMENTS_F' THEN

                asg_count             := asg_count + 1;
                asg_events(asg_count) := int_pkg_events(i);

             ELSIF lv_table_name = 'PER_ALL_PEOPLE_F' THEN

                per_count             := per_count + 1;
                per_events(per_count) := int_pkg_events(i);

             ELSIF lv_table_name = 'PAY_ELEMENT_ENTRIES_F' THEN

                ele_count             := ele_count + 1;
                ele_events(ele_count) := int_pkg_events(i);

             ELSIF lv_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' THEN

                eev_count             := eev_count + 1;
                eev_events(eev_count) := int_pkg_events(i);

             END IF;
           END IF;
       END LOOP;

    END IF;

    IF asg_events.COUNT > 0 THEN

       hr_utility.set_location(gv_package || lv_procedure_name, 60);
       ln_step := 6;

       arch_hire_separation ( p_payroll_action_id => p_payroll_action_id
                             ,p_asg_action_id     => p_asg_action_id
                             ,p_effective_Date    => p_effective_Date
                             ,p_assignment_id     => p_assignment_id
                             ,p_person_id         => p_person_id
                             ,p_chunk_number      => p_chunk_number
                             ,p_start_date        => p_start_date
                             ,p_end_date          => p_end_date
                             ,p_business_group_id => p_business_group_id
                             ,p_gre_id            => p_gre_id
                             ,p_eff_start_date    => ld_eff_start_date
                             ,p_eff_end_date      => ld_eff_end_date
                             ,p_asg_events        => asg_events
                            );

    END IF;

    IF gn_person_rec_chng = 0 AND per_events.COUNT > 0 THEN

       hr_utility.set_location(gv_package || lv_procedure_name, 70);
       ln_step := 7;

       chk_person_rec_chng( p_per_events => per_events );

    END IF;

    hr_utility.set_location(gv_package || lv_procedure_name, 80);
    ln_step := 8;

    arch_other_transactions ( p_payroll_action_id => p_payroll_action_id
                             ,p_asg_action_id     => p_asg_action_id
                             ,p_effective_Date    => p_effective_Date
                             ,p_assignment_id     => p_assignment_id
                             ,p_person_id         => p_person_id
                             ,p_chunk_number      => p_chunk_number
                             ,p_start_date        => p_start_date
                             ,p_end_date          => p_end_date
                             ,p_business_group_id => p_business_group_id
                             ,p_gre_id            => p_gre_id
                             ,p_eff_start_date    => ld_eff_start_date
                             ,p_eff_end_date      => ld_eff_end_date
                            );

    hr_utility.set_location(gv_package || lv_procedure_name, 90);
    ln_step := 9;

    EXCEPTION
    WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_transactions;

  PROCEDURE get_person_information( p_payroll_action_id IN NUMBER
                                   ,p_asg_action_id     IN NUMBER
                                   ,p_effective_date    IN DATE
                                   ,p_assignment_id     IN NUMBER
                                   ,p_person_id         IN NUMBER
                                   ,p_chunk_number      IN NUMBER
                                   ,p_start_date        IN DATE
                                   ,p_end_date          IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_gre_id            IN NUMBER ) IS

    CURSOR c_person_detail (cp_person_id      IN NUMBER
                          , cp_effective_date IN DATE ) IS
      SELECT ppf.person_id                               person_id
            ,replace(ppf.per_information3,'-','')        emp_ssnumber
            ,ppf.last_name                               paternal_last_name
            ,ppf.per_information1                        maternal_last_name
            ,rtrim(ppf.first_name || ' ' || ppf.middle_names)   emp_name
            ,ppf.per_information4                        medical_center
            ,ppf.employee_number                         worker_id
            ,ppf.national_identifier                     curp
            ,ppf.per_information2                        tax_rfc_id
            ,fnd_date.date_to_canonical(ppf.effective_start_date)  hire_date
       FROM per_all_people_f ppf
      WHERE ppf.person_id = cp_person_id
        AND ppf.effective_start_date =
                ( SELECT max(ppf_in.effective_start_date)
                    FROM per_all_people_f ppf_in
                   WHERE ppf_in.person_id             = ppf.person_id
                     AND ppf_in.effective_start_date <= cp_effective_date);

    CURSOR c_asg_detail ( cp_assignment_id  IN NUMBER
                        , cp_effective_date IN DATE/*
                        , cp_start_date     IN DATE
                        , cp_end_date       IN DATE*/ ) IS
      SELECT paf.location_id
            ,paf.soft_coding_keyflex_id
            ,substr(paf.employment_category,3,1) worker_type
       FROM per_all_assignments_f paf
      WHERE paf.assignment_id = cp_assignment_id
        AND cp_effective_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date;
        /*AND paf.effective_start_date =
                ( SELECT max(paf_in.effective_start_date)
                    FROM per_all_assignments_f paf_in
                   WHERE paf_in.assignment_id  = paf.assignment_id
                     AND trunc(cp_end_date)   >= paf_in.effective_start_date
                     AND trunc(cp_start_date) <= paf_in.effective_end_date);*/

    CURSOR c_work_schdl ( cp_soft_cod_kflx_id  IN NUMBER ) IS
      SELECT  hsc.segment6             salary_type
             ,puc.user_column_name     work_schedule
        FROM hr_soft_coding_keyflex hsc,
             pay_user_columns puc
       WHERE hsc.soft_coding_keyflex_id  = cp_soft_cod_kflx_id
         AND hsc.segment4 = puc.user_column_id(+);

    CURSOR c_location ( cp_location_id  IN NUMBER ) IS
      SELECT  location_code
        FROM  hr_locations_all
       WHERE  location_id = cp_location_id;

    CURSOR csr_asg_dates IS
        SELECT paf.effective_start_date,
               paf.effective_end_date
          FROM per_assignments_f paf
         WHERE paf.assignment_id = p_assignment_id
           AND paf.effective_start_date = (SELECT max(paf_in.effective_start_date)
                                             FROM per_assignments_f paf_in
                                            WHERE paf_in.assignment_id =
                                                         paf.assignment_id
                           -- Bug 5908010
                           AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                      paf_in.location_id,
                                      paf_in.business_group_id,
                                      paf_in.soft_coding_keyflex_id,
                                      paf_in.effective_start_date) = p_gre_id);

    CURSOR c_ee_for_infonavit( cp_person_id      NUMBER
                              ,cp_effective_date DATE ) IS
      SELECT pee.element_entry_id
            ,pee.element_type_id
        FROM pay_element_entries_f pee
            ,per_all_assignments_f paf
       WHERE paf.person_id     = cp_person_id
         AND cp_effective_date BETWEEN paf.effective_start_date
                                   AND paf.effective_end_date
         AND pee.assignment_id = paf.assignment_id + 0
         AND cp_effective_date BETWEEN pee.effective_start_date
                                   AND pee.effective_end_date
         AND EXISTS ( SELECT 1
                        FROM pay_element_type_extra_info petei
                       WHERE petei.information_type = 'MX_DEDUCTION_PROCESSING'
                         AND petei.eei_information_category =
                                                      'MX_DEDUCTION_PROCESSING'
                         AND petei.eei_information1 = 'INFONAVIT'
                         AND petei.element_type_id = pee.element_type_id )
        ORDER BY pee.effective_start_date desc;

    CURSOR c_infonavit( cp_element_type_id    NUMBER
                       ,cp_element_entry_id   NUMBER
                       ,cp_effective_date     DATE ) IS
      SELECT piv.name, peev.screen_entry_value
        FROM pay_element_entry_values_f peev
            ,pay_input_values_f piv
       WHERE piv.element_type_id   = cp_element_type_id
         AND peev.element_entry_id = cp_element_entry_id
         AND piv.input_value_id    = peev.input_value_id
         AND cp_effective_date BETWEEN piv.effective_start_date
                                   AND piv.effective_end_date;

    ln_person_id           NUMBER;
    lv_end_date            VARCHAR2(30);
    lv_start_date          VARCHAR2(30);
    ln_bus_grp_id          NUMBER;
    ln_gre_id              NUMBER;
    lv_emp_ssn             VARCHAR2(240);
    lv_tax_rfc_id          VARCHAR2(240);
    lv_curp                VARCHAR2(240);
    lv_paternal_last_name  VARCHAR2(240);
    lv_maternal_last_name  VARCHAR2(240);
    lv_emp_name            VARCHAR2(240);
    lv_worker_type         VARCHAR2(240);
    lv_red_work_week_ind   VARCHAR2(240);
    lv_hire_date           VARCHAR2(240);
    lv_location_code       VARCHAR2(240);
    ln_infonavit_crdt_no   NUMBER;
    ln_infonavit_strt_dt   DATE;
    ld_asg_start_date      DATE;
    ld_asg_end_date        DATE;
    ld_effective_date      DATE;
    ln_infonavit_disc_type VARCHAR2(240);
    ln_infonavit_disc_val  NUMBER;
    lv_daily_base_wage     VARCHAR2(240);
    lv_salary_type         VARCHAR2(240);
    lv_medical_center      VARCHAR2(240);
    lv_worker_id           VARCHAR2(240);

    ln_location_id         NUMBER;
    ln_soft_cod_kflx_id    NUMBER;
    lv_work_schedule       VARCHAR2(240);

    ln_min_wage            NUMBER;

    ln_index               NUMBER;
    ln_idw                 NUMBER;
    ln_fixed_idw           NUMBER;
    ln_variable_idw        NUMBER;

    ln_element_entry_id    NUMBER;
    ln_element_type_id     NUMBER;

    lv_procedure_name    VARCHAR2(100);
    lv_error_message     VARCHAR2(2000);
    ln_step              NUMBER;
    ln_check_person_info_exist NUMBER;

  BEGIN

    lv_procedure_name := 'get_person_information';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_step := 1;

    hr_utility_trace('p_asg_action_id : ' ||p_asg_action_id);
    hr_utility_trace('p_assignment_id : ' ||p_assignment_id);
    hr_utility_trace('p_person_id     : ' ||p_person_id    );

    OPEN csr_asg_dates;
        FETCH csr_asg_dates INTO ld_asg_start_date,
                                 ld_asg_end_date;
    CLOSE csr_asg_dates;

    -- Bug 5875096
    IF ld_asg_start_date <= p_end_date THEN
        ld_effective_date := LEAST (ld_asg_end_date, p_end_date);
    ELSE
        ld_effective_date := ld_asg_start_date;
    END IF;
    /*ld_effective_date := max (ld_effective_date, p_end_date);
    hr_utility_trace('p_end_date = '||
                            fnd_date.date_to_canonical(p_end_date));*/
    hr_utility_trace('ld_asg_start_date = '||
                            fnd_date.date_to_canonical(ld_asg_start_date));
    hr_utility_trace('ld_asg_end_date = '||
                            fnd_date.date_to_canonical(ld_asg_end_date));
    hr_utility_trace('p_end_date = '||
                            fnd_date.date_to_canonical(p_end_date));
    hr_utility_trace('ld_effective_date = '||
                            fnd_date.date_to_canonical(ld_effective_date));

    OPEN  c_person_detail (p_person_id
                          ,ld_effective_date);
                          --,p_effective_date);

    FETCH c_person_detail INTO ln_person_id
                              ,lv_emp_ssn
                              ,lv_paternal_last_name
                              ,lv_maternal_last_name
                              ,lv_emp_name
                              ,lv_medical_center
                              ,lv_worker_id
                              ,lv_curp
                              ,lv_tax_rfc_id
                              ,lv_hire_date;
    CLOSE c_person_detail;

    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 2;

    OPEN  c_asg_detail( p_assignment_id
                       ,ld_effective_date/*
                       ,p_start_date
                       ,p_end_date */);
    FETCH c_asg_detail INTO ln_location_id
                           ,ln_soft_cod_kflx_id
                           ,lv_worker_type;
    CLOSE c_asg_detail;

    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    ln_step := 3;

    OPEN  c_work_schdl( ln_soft_cod_kflx_id );
    FETCH c_work_schdl INTO lv_salary_type
                           ,lv_work_schedule;
    CLOSE c_work_schdl;

    hr_utility.set_location(gv_package || lv_procedure_name, 40);
    ln_step := 4;

    OPEN  c_location (ln_location_id);
    FETCH c_location INTO lv_location_code;
    CLOSE c_location;

    hr_utility.set_location(gv_package || lv_procedure_name, 50);
    ln_step := 5;

    -- derive Reduced Working-week indicator from workschedule

    IF lv_work_schedule IS NOT NULL THEN

       get_rww_ind( p_business_group_id
                   ,lv_work_schedule
                   ,lv_red_work_week_ind );

    ELSE

       lv_red_work_week_ind := NULL ;

    END IF;

    hr_utility.set_location(gv_package || lv_procedure_name, 60);
    ln_step := 6;

    -- Bug 5146225
    get_payroll_action_info (p_payroll_action_id,
                             lv_end_date,
                             lv_start_date,
                             ln_bus_grp_id,
                             ln_gre_id);

    -- Calculate IDW on LEAST(assignment's end date, process end date)
    /*OPEN csr_asg_end_date;
        FETCH csr_asg_end_date INTO ld_asg_end_date;
    CLOSE csr_asg_end_date;

    lv_end_date := fnd_date.date_to_canonical(
                                 LEAST(ld_asg_end_date,
                                      fnd_date.canonical_to_date(lv_end_date)));*/

     SELECT count(*) into ln_check_person_info_exist
      FROM pay_action_information
      WHERE action_context_type='AAP'
      AND assignment_id = p_assignment_id
      AND tax_unit_id = p_gre_id
      AND action_information_category = 'MX SS PERSON INFORMATION'
      AND ld_asg_start_date >=fnd_date.canonical_to_date(action_information10);

 hr_utility.trace('ln_check_person_info_exist '|| ln_check_person_info_exist);
        IF ln_check_person_info_exist > 0 THEN

/*bug9128410: If the person is processing first time along with new hire(08) transaction
  then the effective date for the idw calculation is assignment start date otherwise it
  should be the effective date of current process. This change has done to make the
  person info idw sinc with new hire transaction*/

    ln_idw := get_idw( p_assignment_id  => p_assignment_id  /*bug9128410*/
                      ,p_tax_unit_id    => p_gre_id
                      ,p_effective_date => ld_effective_date
                      ,p_fixed_idw      => ln_fixed_idw
                      ,p_variable_idw   => ln_variable_idw );
       ELSE
    ln_idw := get_idw( p_assignment_id  => p_assignment_id  /*bug9128410*/
                      ,p_tax_unit_id    => p_gre_id
                      ,p_effective_date => ld_asg_start_date
                      ,p_fixed_idw      => ln_fixed_idw
                      ,p_variable_idw   => ln_variable_idw );
       END IF;

    hr_utility.trace('SS_ARCH PERSON_INFO ln_idw: '|| ln_idw);
    hr_utility.trace('SS_ARCH PERSON_INFO get_idw ln_fixed_idw: '||
                                                           ln_fixed_idw);
    hr_utility.trace('SS_ARCH PERSON_INFO get_idw ln_variable_idw: '||
                                                           ln_variable_idw);

    hr_utility.set_location(gv_package || lv_procedure_name, 70);
    ln_step := 7;

    IF ( gv_credit_no IS NULL AND gv_credit_start_date IS NULL ) THEN

       ln_element_entry_id := NULL;
       ln_element_type_id  := NULL;

       OPEN  c_ee_for_infonavit( p_person_id
                                ,p_end_date );
       FETCH c_ee_for_infonavit INTO ln_element_entry_id
                                    ,ln_element_type_id;
       CLOSE c_ee_for_infonavit;

       IF ln_element_entry_id IS NOT NULL THEN

          FOR infonavit IN c_infonavit (ln_element_type_id
                                       ,ln_element_entry_id
                                       ,p_end_date)
          LOOP

            hr_utility_trace('name : '|| infonavit.name);
            hr_utility_trace('screen_entry_value : '||
                                  infonavit.screen_entry_value);

            IF infonavit.name = 'Credit Number' THEN

               gv_credit_no         := infonavit.screen_entry_value;

            ELSIF infonavit.name = 'Credit Start Date' THEN

               gv_credit_start_date := infonavit.screen_entry_value;

            ELSIF infonavit.name = 'Discount Type' THEN

               gv_discount_type     := infonavit.screen_entry_value;

            ELSIF infonavit.name = 'Discount Value' THEN

               gv_discount_value    := infonavit.screen_entry_value;

            END IF;

          END LOOP; -- infonavit

       END IF;

    END IF;

    hr_utility.set_location(gv_package || lv_procedure_name, 80);
    ln_step := 8;

    ln_index := pay_mx_soc_sec_archive.lrr_act_tab.COUNT;

    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).action_info_category
                           := 'MX SS PERSON INFORMATION';
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).jurisdiction_code := NULL;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info1  := ln_person_id;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info2  := lv_emp_ssn;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info3  := lv_tax_rfc_id;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info4  := lv_curp;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info5
                           := lv_paternal_last_name;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info6
                           := lv_maternal_last_name;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info7  := lv_emp_name;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info8  := lv_worker_type;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info9
                           := lv_red_work_week_ind;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info10 := lv_hire_date;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info11
                           := to_char(ln_idw,'99999.99');
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info12 := lv_location_code;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info13 := gv_credit_no;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info14
                           := gv_credit_start_date;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info15 := gv_discount_type;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info16
                           := gv_discount_value;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info17 := NULL;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info18 := lv_salary_type;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info19
                           := lv_medical_center;
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info20 := lv_worker_id;
    -- Segment 21 is the 'Do Not Report on Magtape' flag
    pay_mx_soc_sec_archive.lrr_act_tab(ln_index).act_info22 := gv_crdt_grant_dt;

    hr_utility.set_location(gv_package || lv_procedure_name, 90);

    EXCEPTION
    WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_person_information;


  /*****************************************************************************
   Name      : get_IDW_calc_method
   Purpose   : This returns the IDW calculation method captured at GRE EIT.
  *****************************************************************************/
  FUNCTION get_IDW_calc_method(p_org_id         IN NUMBER
                              ,p_effective_date IN DATE) RETURN VARCHAR2 IS
  CURSOR c_get_idw_calc_method IS
    SELECT hoi.org_information10
      FROM hr_organization_units hou,
           hr_organization_information hoi
     WHERE hou.organization_id = p_org_id
       AND hoi.org_information_context ='MX_SOC_SEC_DETAILS'
       AND hou.organization_id = hoi.organization_id
       AND p_effective_date BETWEEN hou.date_from
                                AND nvl(hou.date_to,p_effective_date);

    lv_idw_calc_method hr_organization_information.org_information10%type;
BEGIN
    OPEN c_get_idw_calc_method;
        FETCH c_get_idw_calc_method INTO lv_idw_calc_method;
    CLOSE c_get_idw_calc_method;

    hr_utility_trace ('IDW calculation method = '||lv_idw_calc_method);
    RETURN (lv_idw_calc_method);
END get_IDW_calc_method;

  /*****************************************************************************
   Name      : seniority_changed
   Purpose   : This returns 'Y' if passed person crossed anniversary date since
               last archiver run.
  *****************************************************************************/
  FUNCTION seniority_changed(p_person_id    IN NUMBER
                            ,p_curr_date    IN DATE
                            ,p_prev_date    IN DATE) RETURN VARCHAR2 IS
    ld_hire_anniversary DATE;
  BEGIN
    ld_hire_anniversary := hr_mx_utility.get_hire_anniversary(p_person_id,
                                                              p_curr_date);
    -- Bug 6005922
    IF CEIL((GREATEST(p_prev_date,ld_hire_anniversary+1)-ld_hire_anniversary)/365) =
       CEIL((GREATEST(p_curr_date,ld_hire_anniversary+1)-ld_hire_anniversary)/365) THEN
        RETURN ('N');
    ELSE
        RETURN ('Y');
    END IF;
  END seniority_changed;

  PROCEDURE range_cursor( p_payroll_action_id IN  NUMBER
                         ,p_sqlstr            OUT NOCOPY VARCHAR2) IS


    lv_procedure_name      VARCHAR2(200);
    lv_end_date            VARCHAR2(19);
    lv_start_date          VARCHAR2(19);
    ln_business_group_id   hr_organization_units.organization_id%TYPE;
    ln_gre_id              hr_organization_units.organization_id%TYPE;
    ln_pactid              NUMBER;

  BEGIN

    lv_procedure_name := 'range_cursor';

    hr_utility.set_location('Entering: '||gv_package || lv_procedure_name, 10);

    hr_utility_trace('Starting range_cursor ');
    hr_utility_trace('ln_gre_id : ' || ln_gre_id );
    hr_utility_trace('p_payroll_action_id : '||p_payroll_action_id );
    hr_utility_trace('ln_gre_id : ' || ln_gre_id );


    get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                           ,p_end_date          => lv_end_date
                           ,p_start_date        => lv_start_date
                           ,p_business_group_id => ln_business_group_id
                           ,p_gre_id            => ln_gre_id
                           );

    hr_utility_trace('lv_start_date :' || lv_start_date);
    hr_utility_trace('lv_end_date :' || lv_end_date);
    hr_utility_trace('ln_business_group_id :' || ln_business_group_id);

    IF pay_mx_soc_sec_archive.arch_exists_without_upgrade(ln_business_group_id)
                                                                    = 'B' THEN
        pay_generic_upgrade.new_business_group (
                              p_bus_grp_id => ln_business_group_id,
                              p_leg_code   => NULL);
    END IF;

    gv_IDW_calc_method := get_IDW_calc_method (
                                    ln_gre_id,
                                    fnd_date.canonical_to_date (lv_end_date));

    hr_utility_trace('--> gv_IDW_calc_method : ' || gv_IDW_calc_method );
/*
    IF gv_mode = 'P' THEN

       gv_periodic_start_date :=
          fnd_date.date_to_canonical(
          TRUNC(add_months(fnd_date.canonical_to_date(lv_end_date),-2)+1));
                -- ||' 00:00:00';

    ELSE

       gv_periodic_start_date := lv_start_date;

    END IF;

    hr_utility_trace('gv_periodic_start_date :' || gv_periodic_start_date);
    hr_utility_trace('gv_periodic_end_date :' || gv_periodic_end_date);
*/

    ln_pactid := p_payroll_action_id;

    SELECT COUNT(*)
      INTO gn_implementation
      FROM pay_payroll_actions
     WHERE report_type      = 'SS_ARCHIVE'
       AND report_qualifier = 'SS_ARCHIVE'
       AND report_category  = 'RT'
       AND pay_mx_utility.get_legi_param_val('GRE', legislative_parameters )
                                  = ln_gre_id
       AND payroll_action_id + 0 < p_payroll_action_id;

    /****************************************************************
    ** gn_implementation is used to check whether archiver
    ** has already been run before or not.
    ** IF not (gn_implementation = 0) then it should archive person
    ** information for all employees and transaction it there is any.
    ** IF yes (gn_implementation > 0), it should arrchive only
    ** transaction if there is any event occured.
    **************************************************************/
    hr_utility_trace('--> gn_implementation : ' || gn_implementation );

    IF gn_implementation = 0 THEN

       p_sqlstr :=
        'SELECT  DISTINCT paf.person_id
         FROM    per_assignments_f      paf,
                 pay_payroll_actions    ppa
         WHERE   ppa.payroll_action_id    = :p_payroll_action_id
         AND     paf.business_group_id    = ppa.business_group_id
         AND     per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                   paf.location_id
                                  ,paf.business_group_id
                                  ,paf.soft_coding_keyflex_id
                                  ,ppa.effective_date) = '||ln_gre_id|| ' '||
        'AND    ppa.effective_date BETWEEN paf.effective_start_date
                                    AND paf.effective_end_date
         ORDER BY paf.person_id';

    ELSE

       p_sqlstr :=
        'SELECT  DISTINCT person_id FROM ( '||
        'SELECT  paf.person_id
         FROM    per_assignments_f      paf
                ,pay_payroll_actions    ppa
         WHERE   ppa.payroll_action_id    = :p_payroll_action_id
         AND     paf.business_group_id    = ppa.business_group_id
         AND     per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                    paf.location_id
                                   ,paf.business_group_id
                                   ,paf.soft_coding_keyflex_id
                                   ,ppa.effective_date) = '||ln_gre_id|| ' '||
        'AND     (EXISTS ( '||
                'SELECT 1 FROM pay_process_events     ppe '||
                'WHERE    ppe.assignment_id = paf.assignment_id '||
                'AND      ppe.creation_date BETWEEN '||
                '    fnd_date.canonical_to_date(''' ||lv_start_date||''') AND'||
                '    fnd_date.canonical_to_date('''||lv_end_date||''') )';

        IF gv_IDW_calc_method = 'B' THEN
            p_sqlstr := p_sqlstr ||
            'OR pay_mx_soc_sec_archive.seniority_changed (paf.person_id,'||
            'fnd_date.canonical_to_date('''||lv_end_date||'''),'||
            'fnd_date.canonical_to_date('''||lv_start_date||''')) = ''Y''';
        END IF;

        p_sqlstr := p_sqlstr ||
        ') UNION ALL '||
        'SELECT  paf.person_id
         FROM    per_assignments_f      paf
                ,pay_payroll_actions    ppa
                ,pay_element_entries_f pee
                ,pay_sub_classification_rules_f psc
                ,pay_element_classifications pec
                ,pay_assignment_actions paa
                ,pay_payroll_actions ppa2
         WHERE   ppa.payroll_action_id    = '|| ln_pactid ||' '||
        'AND     paf.business_group_id    = ppa.business_group_id
         AND     per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                    paf.location_id
                                   ,paf.business_group_id
                                   ,paf.soft_coding_keyflex_id
                                   ,ppa.effective_date) = '||ln_gre_id|| ' '||
        'AND pee.assignment_id = paf.assignment_id '||
        'AND pee.effective_start_date <= '||
             'fnd_date.canonical_to_date('''||gv_periodic_end_date||''') '||
        'AND pee.effective_end_date >= '||
             'fnd_date.canonical_to_date(''' ||gv_periodic_start_date||''') '||
        'AND psc.business_group_id = ppa.business_group_id '||
        'AND psc.element_type_id = pee.element_type_id '||
        'AND psc.effective_start_date <=  '||
             'fnd_date.canonical_to_date('''||gv_periodic_end_date||''') '||
        'AND psc.effective_end_date >=  '||
             'fnd_date.canonical_to_date(''' ||gv_periodic_start_date||''') '||
        'AND pec.classification_id = psc.classification_id '||
        'AND pec.classification_name LIKE
                      ''%Eligible Compensation for IDW (Variable Basis)'' '||
        'AND paa.assignment_id = paf.assignment_id '||
        'AND ppa2.payroll_action_id = paa.payroll_action_id '||
        'AND ppa2.effective_date BETWEEN  '||
             'fnd_date.canonical_to_date(''' ||gv_periodic_start_date||''') '||
             'AND fnd_date.canonical_to_date('''||gv_periodic_end_date||''') '||
        'AND ppa2.action_type in ( ''R'', ''Q'', ''B'', ''V'' ) '||
        'AND EXISTS ( SELECT 1 FROM pay_run_results prr
             WHERE prr.assignment_action_id = paa.assignment_action_id
               AND prr.element_type_id = pee.element_type_id ) '||
        'AND NOT EXISTS (
                 SELECT 1
                   FROM pay_payroll_actions ppa_prev
                       ,pay_assignment_actions paa_prev
                  WHERE ppa_prev.report_type      = ''SS_ARCHIVE''
                    AND ppa_prev.report_qualifier = ''SS_ARCHIVE''
                    AND ppa_prev.report_category  = ''RT''
                    AND pay_mx_utility.get_legi_param_val(''GRE'',
                           ppa_prev.legislative_parameters) = '||
                                                          ln_gre_id|| ' '||
                   'AND TRUNC( fnd_date.canonical_to_date (
                        pay_mx_utility.get_legi_param_val(
                                                   ''PERIOD_ENDING_DATE'',
                                ppa_prev.legislative_parameters) ) ) = ' ||
                        'TRUNC(fnd_date.canonical_to_date('''||
                                            gv_periodic_end_date|| ''') ) '||
                   'AND paa_prev.payroll_action_id = ppa_prev.payroll_action_id
                    AND paa_prev.assignment_id     = paf.assignment_id
                    AND pay_mx_utility.get_legi_param_val(''MX_IDWV'',
                    paa_prev.serial_number) =   ''Y'' ) ' ||
        'AND    '''|| gv_mode || ''' = ''P'' ) ' ||
        'ORDER BY person_id';

    END IF; -- gn_implementation = 0
    hr_utility.set_location(gv_package || lv_procedure_name, 20);

    hr_utility_trace('--> Query formed p_sqlstr : ' || p_sqlstr );

    update  pay_payroll_actions
    set     effective_date = fnd_date.canonical_to_date('4712/12/31')
    where   payroll_action_id = p_payroll_action_id;

    hr_utility.set_location(gv_package || lv_procedure_name, 30);

  END range_cursor;

  PROCEDURE action_creation( p_payroll_action_id   IN NUMBER
                            ,p_start_person_id     IN NUMBER
                            ,p_end_person_id       IN NUMBER
                            ,p_chunk               IN NUMBER) IS

   CURSOR c_get_emp( cp_payroll_action_id   IN NUMBER
                    ,cp_start_person_id     IN NUMBER
                    ,cp_end_person_id       IN NUMBER
                    ,cp_business_group_id   IN NUMBER
                    ,cp_gre_id              IN NUMBER
                    ,cp_start_date          IN DATE
                    ,cp_end_date            IN DATE
                    ,cp_periodic_start_date IN DATE
                    ,cp_periodic_end_date   IN DATE) IS
     SELECT paf.person_id
           ,decode(paf.primary_flag, 'Y', 'Y', 'Z')
           ,paf.assignment_id
           ,'N' variable_idw
       FROM pay_payroll_actions ppa
           ,per_assignments_f paf
      WHERE ppa.payroll_action_id  = cp_payroll_action_id
        AND ppa.business_group_id  = cp_business_group_id
        AND paf.business_group_id  = ppa.business_group_id
        AND paf.person_id BETWEEN cp_start_person_id
                              AND cp_end_person_id
        AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                            paf.location_id
                                           ,paf.business_group_id
                                           ,paf.soft_coding_keyflex_id
                                           ,ppa.effective_date) = cp_gre_id
      UNION ALL
     SELECT paf.person_id
           ,decode(paf.primary_flag, 'Y', 'Y', 'Z')
           ,paf.assignment_id
           ,'Y' variable_idw
       FROM per_assignments_f      paf
           ,pay_payroll_actions    ppa
           ,pay_element_entries_f pee
           ,pay_sub_classification_rules_f psc
           ,pay_element_classifications pec
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa2
      WHERE ppa.payroll_action_id    =  cp_payroll_action_id
        AND paf.business_group_id    = ppa.business_group_id
        AND paf.person_id BETWEEN cp_start_person_id
                              AND cp_end_person_id
        AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                    paf.location_id
                                   ,paf.business_group_id
                                   ,paf.soft_coding_keyflex_id
                                   ,ppa.effective_date) = cp_gre_id
        AND pee.assignment_id = paf.assignment_id
        AND pee.effective_start_date <= cp_periodic_end_date
        AND pee.effective_end_date   >= cp_periodic_start_date
        AND psc.business_group_id     = ppa.business_group_id
        AND psc.element_type_id       = pee.element_type_id
        AND psc.effective_start_date <= cp_periodic_end_date
        AND psc.effective_end_date   >= cp_periodic_start_date
        AND pec.classification_id     = psc.classification_id
        AND pec.classification_name LIKE
                      '%Eligible Compensation for IDW (Variable Basis)'
        AND paa.assignment_id         = paf.assignment_id
        AND ppa2.payroll_action_id    = paa.payroll_action_id
        AND ppa2.effective_date BETWEEN cp_periodic_start_date
                                    AND cp_periodic_end_date
        AND ppa2.action_type in ( 'R', 'Q', 'B', 'V' )
        AND EXISTS (SELECT 1 FROM pay_run_results prr
                     WHERE prr.assignment_action_id = paa.assignment_action_id
                       AND prr.element_type_id = pee.element_type_id )
        AND NOT EXISTS (
                 SELECT 1
                   FROM pay_payroll_actions ppa_prev
                       ,pay_assignment_actions paa_prev
                  WHERE ppa_prev.report_type      = 'SS_ARCHIVE'
                    AND ppa_prev.report_qualifier = 'SS_ARCHIVE'
                    AND ppa_prev.report_category  = 'RT'
                    AND pay_mx_utility.get_legi_param_val('GRE',
                           ppa_prev.legislative_parameters) = cp_gre_id
                    AND TRUNC( fnd_date.canonical_to_date (
                        pay_mx_utility.get_legi_param_val( 'PERIOD_ENDING_DATE',
                                ppa_prev.legislative_parameters) ) ) =
                        TRUNC(fnd_date.canonical_to_date(cp_periodic_end_date))
                    AND paa_prev.payroll_action_id = ppa_prev.payroll_action_id
                    AND paa_prev.assignment_id     = paf.assignment_id
                    AND pay_mx_utility.get_legi_param_val('MX_IDWV',
                        paa_prev.serial_number) =   'Y' )
        AND gv_mode  = 'P'
      ORDER BY 1, 2, 3, 4 desc;

   CURSOR c_get_range_emp(
                         cp_payroll_action_id   IN NUMBER
                        ,cp_chunk_number        IN NUMBER
                        ,cp_business_group_id   IN NUMBER
                        ,cp_gre_id              IN NUMBER
                        ,cp_start_date          IN DATE
                        ,cp_end_date            IN DATE
                        ,cp_periodic_start_date IN DATE
                        ,cp_periodic_end_date   IN DATE) IS
     SELECT paf.person_id
           ,decode(paf.primary_flag, 'Y', 'Y', 'Z')
           ,paf.assignment_id
           ,'N' variable_idw
       FROM pay_payroll_actions ppa
           ,per_assignments_f paf
           ,pay_population_ranges ppr
      WHERE ppa.payroll_action_id = cp_payroll_action_id
        AND ppr.payroll_action_id = ppa.payroll_action_id
        AND ppr.chunk_number      = cp_chunk_number
        AND paf.person_id         = ppr.person_id
        AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                            paf.location_id
                                           ,paf.business_group_id
                                           ,paf.soft_coding_keyflex_id
                                           ,ppa.effective_date) = cp_gre_id
      UNION ALL
     SELECT paf.person_id
           ,decode(paf.primary_flag, 'Y', 'Y', 'Z')
           ,paf.assignment_id
           ,'Y' variable_idw
       FROM pay_payroll_actions ppa
           ,per_assignments_f paf
           ,pay_population_ranges ppr
           ,pay_element_entries_f pee
           ,pay_sub_classification_rules_f psc
           ,pay_element_classifications pec
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa2
      WHERE ppa.payroll_action_id = cp_payroll_action_id
        AND ppr.payroll_action_id = ppa.payroll_action_id
        AND ppr.chunk_number      = cp_chunk_number
        AND paf.person_id         = ppr.person_id
        AND per_mx_ssaffl_archive.derive_gre_from_loc_scl(
                                            paf.location_id
                                           ,paf.business_group_id
                                           ,paf.soft_coding_keyflex_id
                                           ,ppa.effective_date) = cp_gre_id
        AND pee.assignment_id = paf.assignment_id
        AND pee.effective_start_date <= cp_periodic_end_date
        AND pee.effective_end_date   >= cp_periodic_start_date
        AND psc.business_group_id     = ppa.business_group_id
        AND psc.element_type_id       = pee.element_type_id
        AND psc.effective_start_date <= cp_periodic_end_date
        AND psc.effective_end_date   >= cp_periodic_start_date
        AND pec.classification_id     = psc.classification_id
        AND pec.classification_name LIKE
                      '%Eligible Compensation for IDW (Variable Basis)'
        AND paa.assignment_id         = paf.assignment_id
        AND ppa2.payroll_action_id    = paa.payroll_action_id
        AND ppa2.effective_date BETWEEN cp_periodic_start_date
                                    AND cp_periodic_end_date
        AND ppa2.action_type in ( 'R', 'Q', 'B', 'V' )
        AND EXISTS (SELECT 1 FROM pay_run_results prr
                     WHERE prr.assignment_action_id = paa.assignment_action_id
                       AND prr.element_type_id = pee.element_type_id )
        AND NOT EXISTS (
                 SELECT 1
                   FROM pay_payroll_actions ppa_prev
                       ,pay_assignment_actions paa_prev
                  WHERE ppa_prev.report_type      = 'SS_ARCHIVE'
                    AND ppa_prev.report_qualifier = 'SS_ARCHIVE'
                    AND ppa_prev.report_category  = 'RT'
                    AND pay_mx_utility.get_legi_param_val('GRE',
                           ppa_prev.legislative_parameters) = cp_gre_id
                    AND TRUNC( fnd_date.canonical_to_date (
                        pay_mx_utility.get_legi_param_val( 'PERIOD_ENDING_DATE',
                                ppa_prev.legislative_parameters) ) ) =
                        TRUNC(fnd_date.canonical_to_date(cp_periodic_end_date))
                    AND paa_prev.payroll_action_id = ppa_prev.payroll_action_id
                    AND paa_prev.assignment_id     = paf.assignment_id
                    AND pay_mx_utility.get_legi_param_val('MX_IDWV',
                        paa_prev.serial_number) =   'Y' )
        AND gv_mode  = 'P'
      ORDER BY 1, 2, 3, 4 desc;

    ln_person_id            NUMBER;
    ln_assignment_id        NUMBER;
    ln_person_id_prev       NUMBER;
    ln_assignment_id_prev   NUMBER;
    ln_primary_flag         VARCHAR2(100);
    lv_report_mode          VARCHAR2(10);

    lv_end_date             VARCHAR2(50);
    lv_start_date           VARCHAR2(50);
    ln_business_group_id    NUMBER;
    ln_gre_id               NUMBER;

    ln_asg_act_id           NUMBER;
    ln_events_found         NUMBER;
    lb_range_person         BOOLEAN;

    lv_procedure_name       VARCHAR2(100);
    lv_error_message        VARCHAR2(2000);
    ln_step                 NUMBER;

  BEGIN

     lv_procedure_name  := 'action_creation';

     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);


     hr_utility_trace('--> Entering Action Creation ');

     get_payroll_action_info(
                             p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => lv_start_date
                            ,p_end_date          => lv_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_gre_id            => ln_gre_id);

     hr_utility_trace('lv_start_date ' || lv_start_date);
     hr_utility_trace('lv_end_date ' || lv_end_date);
     hr_utility_trace('ln_business_group_id ' || ln_business_group_id);
     hr_utility_trace('ln_gre_id ' || ln_gre_id);

     IF gv_IDW_calc_method IS NULL THEN
        gv_IDW_calc_method := get_IDW_calc_method (
                                     ln_gre_id,
                                     fnd_date.canonical_to_date (lv_end_date));
     END IF;

     hr_utility_trace('--> gv_IDW_calc_method ' || gv_IDW_calc_method);

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;

     lb_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'SS_ARCHIVE'
                          ,p_report_format    => 'SS_ARCHIVE'
                          ,p_report_qualifier => 'SS_ARCHIVE'
                          ,p_report_category  => 'RT');

     hr_utility_trace('--> Step ' || ln_step);
     IF lb_range_person THEN
        OPEN c_get_range_emp(p_payroll_action_id
                            ,p_chunk
                            ,ln_business_group_id
                            ,ln_gre_id
                            ,fnd_date.canonical_to_date(lv_start_date)
                            ,fnd_date.canonical_to_date(lv_end_date)
                            ,fnd_date.canonical_to_date(gv_periodic_start_date)
                            ,fnd_date.canonical_to_date(gv_periodic_end_date)
                            );

        hr_utility_trace('c_get_range_emp');

     ELSE
        OPEN c_get_emp( p_payroll_action_id
                      , p_start_person_id
                      , p_end_person_id
                      , ln_business_group_id
                      , ln_gre_id
                      , fnd_date.canonical_to_date(lv_start_date)
                      , fnd_date.canonical_to_date(lv_end_date)
                      , fnd_date.canonical_to_date(gv_periodic_start_date)
                      , fnd_date.canonical_to_date(gv_periodic_end_date) );

        hr_utility_trace('c_get_emp');

     END IF;

     --Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);

     ln_person_id_prev     := 0;
     ln_assignment_id_prev := 0;

     LOOP

        IF lb_range_person THEN

           hr_utility.set_location(gv_package || lv_procedure_name, 30);
           ln_step := 3;
           hr_utility_trace('--> Fetching from c_get_range_emp ' );
           FETCH c_get_range_emp INTO ln_person_id
                                     ,ln_primary_flag
                                     ,ln_assignment_id
                                     ,lv_report_mode;

           EXIT WHEN c_get_range_emp%NOTFOUND;

        ELSE

           hr_utility.set_location(gv_package || lv_procedure_name, 40);
           ln_step := 4;
           hr_utility_trace('--> Fetching from c_get_emp ' );
           FETCH c_get_emp INTO ln_person_id
                               ,ln_primary_flag
                               ,ln_assignment_id
                               ,lv_report_mode;

           EXIT WHEN c_get_emp%NOTFOUND;

        END IF;

        hr_utility.set_location(gv_package || lv_procedure_name, 50);
        ln_step := 5;

        hr_utility_trace('ln_person_id = ' || ln_person_id);
        hr_utility_trace('ln_assignment_id = ' || ln_assignment_id);
        hr_utility_trace('ln_primary_flag = ' || ln_primary_flag);
        hr_utility_trace('lv_report_mode = ' || lv_report_mode);

        IF (ln_person_id <> ln_person_id_prev OR
            ln_assignment_id <> ln_assignment_id_prev) THEN

           IF gn_implementation = 0 THEN


              ln_step := 6;
      	      hr_utility_trace('--> Step  6' );
              hr_utility_trace('IMPLEMENTATION TRUE');

              SELECT pay_assignment_actions_s.nextval
                INTO ln_asg_act_id
                FROM dual;

      	      hr_utility_trace('--> Inserting into pay_assignment_actions' );
       	      hr_utility_trace('--> ln_asg_act_id' || ln_asg_act_id );
              -- insert into pay_assignment_actions.
              hr_nonrun_asact.insact(ln_asg_act_id,
                                     ln_assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     ln_gre_id,
                                     null,
                                     'U',
                                     null);

              hr_utility.set_location(gv_package || lv_procedure_name, 70);
              hr_utility_trace('ln_asg_act_id = ' || ln_asg_act_id);
              hr_utility_trace('p_payroll_action_id= ' || p_payroll_action_id);
              hr_utility_trace('ln_tax_unit_id = '   || ln_gre_id);

              hr_utility.set_location(gv_package || lv_procedure_name, 80);

      	      hr_utility_trace('--> Updating into pay_assignment_actions' );
       	      hr_utility_trace('--> ln_asg_act_id' || ln_asg_act_id );
	      UPDATE pay_assignment_actions
                 SET serial_number = to_char(ln_person_id) || '|' ||
                                     'MX_IDWV=' || lv_report_mode || '|'
               WHERE assignment_action_id = ln_asg_act_id;

           ELSE

              ln_step := 7;

		hr_utility_trace('--> In STep 7');

              IF ( pay_mx_soc_sec_archive.per_asg.EXISTS(ln_person_id) = FALSE )
              THEN
			hr_utility_trace('--> Adding in pay_mx_soc_sec_archive.per_asg ');
                 pay_mx_soc_sec_archive.per_asg(ln_person_id).person_id :=
                                                              ln_person_id;
                 pay_mx_soc_sec_archive.per_asg(ln_person_id).assignment_id :=
                                                              ln_assignment_id;
              END IF;

 	      hr_utility_trace('--> lv_report_mode '||lv_report_mode);
              IF lv_report_mode = 'Y' THEN

                 ln_events_found := 1;

              ELSE

                 SELECT count(*)
                   INTO ln_events_found
                   FROM pay_process_events
                  WHERE assignment_id = ln_assignment_id
                    AND last_update_date
                               BETWEEN fnd_date.canonical_to_date(lv_start_date)
                                   AND fnd_date.canonical_to_date(lv_end_date);
              END IF;

              ln_step := 8;
		hr_utility_trace('--> In Step 8 ');
		hr_utility_trace('--> ln_events_found ' || ln_events_found);

              IF ln_events_found > 0
              OR (gv_IDW_calc_method = 'B' AND
                  seniority_changed (
                         ln_person_id,
                         fnd_date.canonical_to_date(lv_end_date),
                         fnd_date.canonical_to_date(lv_start_date)) = 'Y') THEN
 		hr_utility_trace('--> Inside If ' );
                 SELECT pay_assignment_actions_s.nextval
                   INTO ln_asg_act_id
                   FROM dual;

		hr_utility_trace('--> insert into pay_assignment_actions.' );
                 -- insert into pay_assignment_actions.
                 hr_nonrun_asact.insact(ln_asg_act_id,
                                        ln_assignment_id,
                                        p_payroll_action_id,
                                        p_chunk,
                                        ln_gre_id,
                                        null,
                                        'U',
                                        null);

                 hr_utility.set_location(gv_package || lv_procedure_name, 90);
                 hr_utility_trace('ln_asg_act_id = ' || ln_asg_act_id);
                 hr_utility_trace('ln_tax_unit_id = '   || ln_gre_id);

                 hr_utility.set_location(gv_package || lv_procedure_name, 100);

                 UPDATE pay_assignment_actions
                    SET serial_number = to_char(ln_person_id) || '|' ||
                                        'MX_IDWV=' || lv_report_mode || '|'
                  WHERE assignment_action_id = ln_asg_act_id;


                 pay_mx_soc_sec_archive.per_asg.delete;

              END IF; -- ln_events_found

           END IF; -- gn_implementation

        END IF; -- prev_person

        ln_person_id_prev     := ln_person_id;
        ln_assignment_id_prev := ln_assignment_id;

     END LOOP;

     IF lb_range_person THEN

        CLOSE c_get_range_emp;

     ELSE

        CLOSE c_get_emp;

     END IF;

     ln_step := 9;

     hr_utility_trace('--> Step 9 ' );
     hr_utility_trace(' p_payroll_action_id : '|| p_payroll_action_id );
     hr_utility_trace(' p_chunk : '|| p_chunk );

     hr_utility.set_location('Leaving: '||gv_package || lv_procedure_name, 100);

     EXCEPTION
     WHEN others THEN
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;



  END action_creation;

  PROCEDURE archive_data(p_asg_action_id  IN NUMBER,
                         p_effective_date IN DATE) IS

    CURSOR c_asgact_info (cp_assignment_action IN NUMBER) IS
      SELECT paa.payroll_action_id
            ,paa.assignment_id
            ,paa.tax_unit_id
            ,paa.chunk_number
            ,paa.serial_number
        FROM pay_assignment_actions paa
       WHERE paa.assignment_action_id = cp_assignment_action;


    CURSOR c_check_pay_action( cp_payroll_action_id IN NUMBER) IS
      SELECT count(*)
        FROM pay_action_information
       WHERE action_context_id   = cp_payroll_action_id
         AND action_context_type = 'PA';

  CURSOR c_check_active_employee (p_person_id IN VARCHAR2 ,
                                  p_effective_date IN VARCHAR2) IS

       SELECT  'Y'
       FROM  per_all_people_f per
       WHERE per.person_id = p_person_id
       AND  fnd_date.canonical_to_date(p_effective_date)
            BETWEEN per.effective_start_date AND per.effective_end_date
       AND   per.current_employee_flag = 'Y';


    lv_end_date             VARCHAR2(50);
    lv_start_date           VARCHAR2(50);
    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_gre_id               NUMBER;

    ln_payroll_action_id    NUMBER;
    ln_assignment_id        NUMBER;
    ln_tax_unit_id          NUMBER;
    ln_chunk_number         NUMBER;
    lv_serial_number        VARCHAR2(240);
    ln_person_id            VARCHAR2(24);

    ln_pay_action_count     NUMBER;

    lv_procedure_name       VARCHAR2(100);
    lv_error_message        VARCHAR2(2000);
    ln_step                 NUMBER;

    l_act_tab               pay_emp_action_arch.action_info_table;
    j                       NUMBER;
    lv_is_employee          VARCHAR2(2) := 'N';

  BEGIN

     hr_utility_trace('--> Archive_data' );
     hr_utility_trace('--> p_asg_action_id '  || p_asg_action_id );
     hr_utility_trace('--> p_effective_date'  || p_effective_date );

     pay_mx_soc_sec_archive.lrr_act_tab.DELETE;

     lv_procedure_name    := 'archive_data';
     gn_person_rec_chng   := 0;
     gn_gre_found         := 0;
     gv_credit_no         := NULL;
     gv_credit_start_date := NULL;
     gv_crdt_grant_dt     := NULL;
     gv_discount_type     := NULL;
     gv_discount_value    := NULL;



     IF gn_implementation = 0 THEN
        gn_person_rec_chng := 1;
     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     OPEN  c_asgact_info(p_asg_action_id);
     FETCH c_asgact_info INTO  ln_payroll_action_id
                              ,ln_assignment_id
                              ,ln_tax_unit_id
                              ,ln_chunk_number
                              ,lv_serial_number;
     CLOSE c_asgact_info;

     ln_person_id := SUBSTR( lv_serial_number, 1,
                                       NVL(INSTR(lv_serial_number,'|'),50) -1);

     hr_utility_trace('--> ln_person_id'|| ln_person_id);
     /***********************************************************
     ** gv_variable_idw is used to get information about whether
     ** whether this assignment has variable IDW or not.
     ***********************************************************/

     gv_variable_idw :=
        NVL(pay_mx_utility.get_legi_param_val('MX_IDWV',lv_serial_number), 'N');
     hr_utility_trace('--> gv_variable_idw' || gv_variable_idw );

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;

     get_payroll_action_info(
                             p_payroll_action_id => ln_payroll_action_id
                            ,p_start_date        => lv_start_date
                            ,p_end_date          => lv_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_gre_id            => ln_gre_id);

      hr_utility.set_location(gv_package || lv_procedure_name, 30);
      ln_step := 3;

      ld_start_date := fnd_date.canonical_to_date(lv_start_date);
      ld_end_date   := fnd_date.canonical_to_date(lv_end_date);

     hr_utility_trace('--> lv_start_date' || lv_start_date );
     hr_utility_trace('--> lv_end_date' || lv_end_date );
     hr_utility_trace('--> ln_business_group_id' || ln_business_group_id );
     hr_utility_trace('--> ln_gre_id' || ln_gre_id );


      IF gv_IDW_calc_method IS NULL THEN
         gv_IDW_calc_method := get_IDW_calc_method (
                                    ln_gre_id,
                                    fnd_date.canonical_to_date (lv_end_date));
      END IF;
     hr_utility_trace('--> gv_IDW_calc_method' || gv_IDW_calc_method );
     /****************************************************************
     ** Archive all the payroll action level data once only when
     ** chunk number is 1. Also check if this has not been archived
     ** earlier
     *****************************************************************/

     hr_utility.set_location(gv_package || lv_procedure_name, 40);
     ln_step := 4;

     OPEN  c_check_pay_action(ln_payroll_action_id);
     FETCH c_check_pay_action INTO ln_pay_action_count;
     CLOSE c_check_pay_action;

     hr_utility_trace('--> ln_pay_action_count' || ln_pay_action_count );
     IF ln_pay_action_count = 0 THEN

        hr_utility.set_location(gv_package || lv_procedure_name, 50);
        ln_step := 5;

        IF ln_chunk_number = 1 THEN

           ln_step := 25;

           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           ln_step := 6;
           hr_utility_trace('--> arch_pay_action_level_data' );
           arch_pay_action_level_data(
                               p_payroll_action_id => ln_payroll_action_id
                              ,p_assignment_id     => ln_assignment_id
                              ,p_effective_Date    => ld_end_date
                              ,p_tax_unit_id       => ln_gre_id
                              );
       END IF;

     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 70);
     ln_step := 7;

     hr_utility_trace('--> get_transactions' );
     get_transactions( p_payroll_action_id => ln_payroll_action_id
                      ,p_asg_action_id     => p_asg_action_id
                      ,p_effective_Date    => p_effective_Date
                      ,p_assignment_id     => ln_assignment_id
                      ,p_person_id         => ln_person_id
                      ,p_chunk_number      => ln_chunk_number
                      ,p_start_date        => ld_start_date
                      ,p_end_date          => ld_end_date
                      ,p_business_group_id => ln_business_group_id
                      ,p_gre_id            => ln_gre_id
                     );

     IF ( gn_person_rec_chng = 1 ) THEN

        hr_utility.set_location(gv_package || lv_procedure_name, 80);
        ln_step := 8;
        hr_utility_trace('-->    8     get_person_information' );
        get_person_information(
                   p_payroll_action_id => ln_payroll_action_id
                  ,p_asg_action_id     => p_asg_action_id
                  ,p_effective_Date    => p_effective_Date
                  ,p_assignment_id     => ln_assignment_id
                  ,p_person_id         => ln_person_id
                  ,p_chunk_number      => ln_chunk_number
                  ,p_start_date        => ld_start_date
                  ,p_end_date          => ld_end_date
                  ,p_business_group_id => ln_business_group_id
                  ,p_gre_id            => ln_gre_id
                  );

     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 90);
     ln_step := 9;

     l_act_tab.DELETE;
     j := 0;


     IF pay_mx_soc_sec_archive.lrr_act_tab.COUNT > 0 THEN
        FOR i IN pay_mx_soc_sec_archive.lrr_act_tab.FIRST..
                 pay_mx_soc_sec_archive.lrr_act_tab.LAST
        LOOP

          IF pay_mx_soc_sec_archive.lrr_act_tab(i).action_info_category
                                                    = 'MX SS TRANSACTIONS' THEN
            /*Added code for bug 6862116*/
	     hr_utility_trace('Checking for active employe ..for MX SS TRANSACTIONS' );
	     OPEN c_check_active_employee(pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO1,
                            pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO2);
             FETCH c_check_active_employee INTO lv_is_employee;
	     CLOSE c_check_active_employee;

	      hr_utility_trace('Person ID for MX SS Transcations .. ' ||  pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO1);
              hr_utility_trace('Transaction Date for MX SS Transcations .. ' ||  pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO2);
      	      hr_utility_trace('IS Employee active .. ' ||  lv_is_employee);

              IF   (TRUNC(fnd_date.canonical_to_date(
                      pay_mx_soc_sec_archive.lrr_act_tab(i).act_info2)) =
                           TRUNC(fnd_date.canonical_to_date('4712/12/31'))) OR lv_is_employee = 'N' THEN

                  NULL;
                   hr_utility_trace('-->   NULL' );
              ELSE
               l_act_tab(j) := pay_mx_soc_sec_archive.lrr_act_tab(i);

	       j := j + 1;

	     END if;

       ELSIF  pay_mx_soc_sec_archive.lrr_act_tab(i).action_info_category
                                                    = 'MX SS PERSON INFORMATION' THEN
       	     hr_utility_trace('Checking for active employe ..for MX SS PERSON Information' );
    	     OPEN c_check_active_employee (pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO1,
                            pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO10);
             FETCH c_check_active_employee INTO lv_is_employee;
	     CLOSE c_check_active_employee;

              hr_utility_trace('Person ID for MX SS Transcations .. ' ||  pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO1);
              hr_utility_trace('Transaction Date for MX SS Transcations .. ' ||  pay_mx_soc_sec_archive.lrr_act_tab(i).ACT_INFO10);

	      hr_utility_trace('IS Employee active .. ' ||  lv_is_employee);


	     IF lv_is_employee = 'N' THEN

	       NULL ;

             ELSE
               l_act_tab(j) := pay_mx_soc_sec_archive.lrr_act_tab(i);

	       j := j + 1;

	      END IF ;

        ELSE
             l_act_tab(j) := pay_mx_soc_sec_archive.lrr_act_tab(i);

             j := j + 1;

        END IF;

        END LOOP;

        pay_mx_soc_sec_archive.lrr_act_tab.DELETE;

        IF l_act_tab.COUNT > 0 THEN
           pay_mx_soc_sec_archive.lrr_act_tab := l_act_tab;
        END IF;

        l_act_tab.DELETE;

     END IF;

     IF pay_mx_soc_sec_archive.lrr_act_tab.COUNT > 0 THEN

        hr_utility_trace('-->    pay_mx_soc_sec_archive.lrr_act_tab.COUNT '  || pay_mx_soc_sec_archive.lrr_act_tab.COUNT);
        pay_emp_action_arch.insert_rows_thro_api_process(
                     p_action_context_id   => p_asg_action_id
                    ,p_action_context_type => 'AAP'
                    ,p_assignment_id       => ln_assignment_id
                    ,p_tax_unit_id         => ln_gre_id
                    ,p_curr_pymt_eff_date  => ld_end_date
                    ,p_tab_rec_data        => pay_mx_soc_sec_archive.lrr_act_tab
                    );

     END IF;

    pay_mx_soc_sec_archive.lrr_act_tab.DELETE;

    hr_utility.set_location(gv_package || lv_procedure_name, 100);
    ln_step := 10;

    EXCEPTION
    WHEN others THEN
            hr_utility_trace('-->    Exception in Archive_data ' );
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility_trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END archive_data;

  PROCEDURE archinit(p_payroll_action_id in number) IS

    CURSOR c_dated_tables IS
      SELECT dated_table_id
            ,table_name
        FROM pay_dated_tables;

    CURSOR c_payroll_Action_info (cp_payroll_action_id IN NUMBER) IS
      SELECT pay_mx_utility.get_legi_param_val('GRE',
                                               LEGISLATIVE_PARAMETERS) GRE,
             fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val(
                                              'END_DATE',
                                              LEGISLATIVE_PARAMETERS)) END_DATE
        FROM pay_payroll_actions
       WHERE payroll_action_id = cp_payroll_action_id;

    ln_gre_id               NUMBER;
    ld_start_date           DATE;
    ld_end_date             DATE;
    ld_old_recorded_date    DATE;

  BEGIN

    FOR pdt IN  c_dated_tables
    LOOP

      dated_tbls(pdt.dated_table_id).table_name := pdt.table_name;

    END LOOP;

    OPEN  c_payroll_action_info(p_payroll_action_id);
    FETCH c_payroll_action_info INTO ln_gre_id,
                                     ld_end_date;
    CLOSE c_payroll_action_info;

    SELECT COUNT(*)
      INTO gn_implementation
      FROM pay_payroll_actions
     WHERE report_type      = 'SS_ARCHIVE'
       AND report_qualifier = 'SS_ARCHIVE'
       AND report_category  = 'RT'
       AND pay_mx_utility.get_legi_param_val('GRE', legislative_parameters )
                                  = ln_gre_id
       AND payroll_action_id + 0 < p_payroll_action_id;

    pay_recorded_requests_pkg.get_recorded_date_no_ins(
                 p_process       => 'MX_SOC_SEC_ARCH',
                 p_recorded_date => ld_start_date,
                 p_attribute1    => ln_gre_id,
                 p_attribute2    => NULL,
                 p_attribute3    => NULL,
                 p_attribute4    => NULL,
                 p_attribute5    => NULL,
                 p_attribute6    => NULL,
                 p_attribute7    => NULL,
                 p_attribute8    => NULL,
                 p_attribute9    => NULL,
                 p_attribute10   => NULL,
                 p_attribute11   => NULL,
                 p_attribute12   => NULL,
                 p_attribute13   => NULL,
                 p_attribute14   => NULL,
                 p_attribute15   => NULL,
                 p_attribute16   => NULL,
                 p_attribute17   => NULL,
                 p_attribute18   => NULL,
                 p_attribute19   => NULL,
                 p_attribute20   => NULL);

    hr_utility_trace ('end_date in legislative_parameters = '||
                        fnd_date.date_to_canonical(ld_end_date));
    hr_utility_trace ('Date stamped in pay_recorded_requests = '||
                        fnd_date.date_to_canonical(ld_start_date));

      /* We need to stamp the end date in pay_recorded_requests only if
         existing date is less than end date stamped on payroll action. This
         is done to prevent invalid stamping of date in pay_recorded_requests
         when archiver is run in retry mode.

         In other words, date stamped in pay_recorded_requests can only be
         advanced further; it cannot be updated by a potential retry attempt. */
      IF ld_end_date > ld_start_date THEN
          hr_utility_trace ('Advancing date in pay_recorded_requests to '||
                                      fnd_date.date_to_canonical(ld_end_date));
          pay_recorded_requests_pkg.set_recorded_date(
                     p_process       => 'MX_SOC_SEC_ARCH',
                     p_recorded_date => ld_end_date,
                     p_recorded_date_o => ld_old_recorded_date,
                     p_attribute1    => ln_gre_id,
                     p_attribute2    => NULL,
                     p_attribute3    => NULL,
                     p_attribute4    => NULL,
                     p_attribute5    => NULL,
                     p_attribute6    => NULL,
                     p_attribute7    => NULL,
                     p_attribute8    => NULL,
                     p_attribute9    => NULL,
                     p_attribute10   => NULL,
                     p_attribute11   => NULL,
                     p_attribute12   => NULL,
                     p_attribute13   => NULL,
                     p_attribute14   => NULL,
                     p_attribute15   => NULL,
                     p_attribute16   => NULL,
                     p_attribute17   => NULL,
                     p_attribute18   => NULL,
                     p_attribute19   => NULL,
                     p_attribute20   => NULL);
    ELSE
        hr_utility_trace ('pay_recorded_requests not updated.');
    END IF;

    gt_gre_cache.delete();

  END archinit;

FUNCTION arch_exists_without_upgrade
(
    p_business_group_id NUMBER
) RETURN VARCHAR2 AS

    CURSOR csr_upgrade_exists IS
        SELECT 'Y'
          FROM pay_upgrade_status pus,
               pay_upgrade_definitions pud
         WHERE pud.upgrade_definition_id = pus.upgrade_definition_id
           AND pus.business_group_id = p_business_group_id
           AND pud.short_name = 'MX_SS_ARCH_TRAN_DATE'
           AND pus.status = 'C';

    CURSOR csr_arch_exists IS
        SELECT 'Y'
          FROM pay_payroll_actions ppa
         WHERE ppa.report_type = 'SS_ARCHIVE'
           AND ppa.report_qualifier = 'SS_ARCHIVE'
           AND ppa.report_category = 'RT'
           AND ppa.business_group_id = p_business_group_id;

    l_proc_name varchar2(100);
    lv_exists   varchar2(1);
BEGIN
/*
    This function returns following values: -
    B - Current BG is brand new. No SS archiver runs exist in the past.
    C - Completed upgrade process exists for BG passed as parameter.
    E - Error. Archiver runs exist without successful upgrade runs.
*/

    l_proc_name := gv_package || 'arch_exists_without_upgrade';
    hr_utility_trace ('Entering '||l_proc_name);
    lv_exists := 'N';

    OPEN csr_upgrade_exists;
        FETCH csr_upgrade_exists INTO lv_exists;
    CLOSE csr_upgrade_exists;

    IF lv_exists = 'Y' THEN
        hr_utility_trace ('Completed upgrade process exists.');
        hr_utility_trace ('Leaving '||l_proc_name);
        RETURN ('C');
    END IF;

    OPEN csr_arch_exists;
        FETCH csr_arch_exists INTO lv_exists;
    CLOSE csr_arch_exists;

    IF lv_exists = 'N' THEN
        hr_utility_trace ('Brand new business group.');
        hr_utility_trace ('Leaving '||l_proc_name);
        RETURN ('B');
    ELSE
        hr_utility_trace ('Archiver runs exist without successful upgrade.');
        hr_utility_trace ('Leaving '||l_proc_name);
        RETURN ('E');
    END IF;

END arch_exists_without_upgrade;

BEGIN

  --hr_utility.trace_on(null,'SUA');
  gv_package        := 'pay_mx_soc_sec_archive.';
  gv_debug          := hr_utility.debug_enabled;

END PAY_MX_SOC_SEC_ARCHIVE;

/
