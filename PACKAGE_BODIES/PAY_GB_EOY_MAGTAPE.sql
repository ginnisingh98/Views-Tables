--------------------------------------------------------
--  DDL for Package Body PAY_GB_EOY_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_EOY_MAGTAPE" AS
/* $Header: pygbemag.pkb 120.20.12010000.14 2010/03/02 09:09:21 npannamp ship $ */
/*
 Change List
  -----------
   Date        Name          Vers     Bug No   Description
   +-----------+-------------+--------+-------+-----------------------+
   11-Dec-1995  P.Driver                       (Original)
   22-Nov-1999  A.Mills      40.0              Used original as start point,
                                               cursors re-written to use
                                               archive views or functions:
                                               header_cur, emps_cur,
                                               emp_values, econ_chk.
                                               New functionality and
                                               procedures added, package
                                               renamed to above. See LLD.
   14-Dec-1999  A.Parkes     40.1              Fire econ_chk cursor for
                                               every type one record.
   18-Jan-2000  A.Parkes     40.2              Allow >= 5 type 2 errors.
   24-Jan-2000  A.Mills      110.0 = 40.3      Added P60 Type functionality.
   11-Feb-2000  A.Parkes     110.1     1178972 Changed select of gross_pay
                                               in emps_cur cursor.
   29-Feb-2000  A.Mills      115.0             forward ported.
   22-Mar-2000  A.Mills      115.1     1232417 Expanded error message size
                                               for bug fix of eoy process.
                                               Using DBI for error message.
   31-Mar-2000  A.Parkes     115.2     1232417 Allow length(tax_code) <= 7
                                               and smp <= 99999999
   17-Apr-2000  A.Mills      115.3     1265531 Changed emps_cur to ensure
                                               Middle name is 7 chars
                                               in the Magtape.
   12-Jun-2000  A.Blinko     115.4     1268568 Now processes assignments with
                                               >5 NI categories correctly.
   13-Jul-2000  A.Mills      115.5     1364509 Add EET, Student Loans,
                            =110.6             Tax Credits and Ees Rebate
                                               to outputs to MAG_RECORD2 and 4.
                                               Altered validation of name fields
                                               removed SCON checking in main
                                               procedure, now validated in the
                                               formula using call to new
                                               generic validate function.
  02-Aug-2000  A.Mills       115.6             Fixed minor conversion error
                                               found in unit testing.
  07-Sep-2000  A.Parkes      115.7             Fixed magtape validation so
                                               + is disallowed.
                                               Added EDI validation checks.
  19-Oct-2000  A.Mills       115.8             Performance tune for emps_cur.
                                               NB more substr etc formatting
                                               inline with 10.7 code, this
                                               speeds up code due to reduced
                                               sort key.
  16-Feb-2001  A.Parkes      115.9             Allow = in EDI charset
  13-Mar-2001  A.Parkes      115.10    1682586 Changed header_cur subquery
                                               to filter on char payroll_ids
                                               Also removed 'Dan Tow Decode'.
  18-Sep-2001  A.Mills       115.11    1778139 Added Assignment Message for
                                               asgs that have been updated
                                               during the run (warnings).
  20-Sep-2001  R. Makhija    115.12    1585510 Removed references to EET
                                       1802363 balance values, changed emps_cur
                                               to select full assignment_number,
                                               increased length of number
                                               variabes.
  19-Oct-2001  K.Thampan     115.13            Put blank into tax code field of
                                               mag record row two
  17-DEC-2001  R.Makhija     115.14            Increased length of student
                                               loan variables
  18-Nov-2001  R.Makhija     115.15            Added P14 EDI functionality
  09-JAN-2002  R.Makhija     115.16            Added Checkfile commands
  29-JAN-2002  R.Makhija     115.17            Added 'SET VARIFY OFF' at the
                                               beginning to fix GSCC warning.
  11-FEB-2002  R.Makhija     115.18            Added 2 more parameters for
                                               EDI EMP HEADER formula to
                                               pass middle name and
                                               and title of an employee.
  08-MAY-2002  A.Mills       115.19            Aggregated PAYE changes. Skip
                                               the employee type 2 record if
                                               all balances are zero, must be
                                               aggregated.
  19-jul-2002 Vimal          115.21            Fixes bug 2392279. The chanegs added
                                               to version 20 does not work as the pkg
                                               fails to compile on UTF8 database.
                                               So the fix was to chaneg the variable
                                               declaration of the address line
                                               to size greater than 27. Some other
                                               variable were also changed so that
                                               the process does not fail bcos of this
                                               error again.
  05-DEC-2002 V.Vinod        115.22  2696015   P14 EDI Enhancement for Year 2003
  13-SEP-2003 npershad       115.25  3133921   P14 EDI/P35 MT Functional Changes
                                               for End of Year 2003/2004
  24-MAR-2004 A.Mills        115.26  3527428   Fixed header_cur to ensure that
                                               Tax District Ref is 3 characters,
                                               issue found in P14EDI with short
                                               Tax Dist Ref No.
  10-MAY-2004 npershad       115.27  3614251   Added nvl call in cursor emps_cur,
                                               for field X_SUPERANNUATION_PAID.
  21-OCT-2004 rmakhija       115.28  3962706   Changed cursor emps_cur to suppress
  21-OCT-2004 rmakhija       115.28  3962706   Changed cursor emps_cur to suppress
  21-OCT-2004 rmakhija       115.28  3962706   Changed cursor emps_cur to suppress
                                               secondary aggregated asssignments.
  15-NOV-2004 rmakhija       115.29  4011263   P14 EDI Changes for 2004-2005.
  07-DEC-2004 rmakhija       115.30  4011263   Added coomit and exit at the end
  21-JAN-2005 rmakhija       115.31  4108896   Added new validations for First, Last
					       and Middle name in validate_input
					       function. Also changed emp_values
                                               cursor to select only non-zero
                                               NI records.
  01-MAR-2005 rmakhija       115.32  4216135   Changed emp_values to make sure
                                                atleast NI Cat X is reported
                                               when there is not enough earning
                                               therefore NI balances are 0
  11-MAR-2005 rmakhija       115.33  4234348   Changed emp_values to make sure
                                               Ni Cats with 0 lel/et/uel are
                                               processed first so that contribs
                                               in these NI Cats can be rolled up
                                               into another NI Cat
  19-MAY-2005 rmakhija       115.34  4362883   Change submit_reports to set
                                               printer and copies oprions
                                               as entered by the user on EOY
                                               request before submitting the
                                               reports.
  09-JUN-2005 rmakhija       115.35            Added nvl,ltrim and rtrim around
                                               first_name, middle_names, title
                                               and country to handle spaces in
                                               these fields as null values.
  16-JUN-2005 rmakhija       115.36            Increased length of some number
                                               variables in this package so
                                               pl/sql error is not raised by
                                               this package when value is too
                                               large but a user friendly error
                                               message will be raised by the EOY
                                               formula
  14-Nov-2005 rmakhija       115.37            Changed for EOY 2005-06
  01-Dec-205  mgera          115.38            Added extra validation for SCON check.
					       in validate_input function
  02-Dec-2005 rmakhija       115.39            Further changes for EOY 2005-06
  10-JAN-2005 rmakhija       115.40            Further changes for EOY 2005-06
  08-FEB-2006 kthampan       115.41            Added validation for P11D_EDI
  08-DEC-2006 rmakhija       115.42            EOY 2006-07 changes
  21-JAN-2007 rmakhija       115.43            Excluded NI Cat C from aggregated
                                               validations. Also added sum of
                                               total contributions as a
                                               parameter to the P14 emp trailer
                                               formula.
  25-Nov-2007 A.Ganguly     115.44             Added validate_tax_code_1
  29-Oct-2007 pbalu         115.45   6281170   Added a new parameter for Formula
                                               PAY_GB_EDI_P14_EMP_TRAILER
  29-Oct-2007 rlingama      115.46   5671777   BUG 5671777-5 Changed Start date of the EOY process
                                               to reflect start of the tax year.so no need to add
                                               12 months to the start date
   2-Nov-2007 parusia       115.47   6345375   Included 2 additional validation modes for
                                               in validate_input function for validating Last_name
					                           and First_name in P45(3) and P46 PENNOT
   13-Nov-2007 A.Ganguly    115.48   6345375   Added function get_payroll_version
                                               for the EOY Apr 08 Changes
   26-Nov-2007 parusia      115.49   6345375   Added validation modes in validate_input()
                                               for PostalCode and Title.
                                               Added code to remove leading minus
                                               sign from NUMBER_1 validate_mode.
   28-Nov-2007 parusia      115.50  6345375    Remove hardcoded 'apps' from csr_get_version
                                               as it was failing in GSCC checks.
   30-Nov-2007 parusia      115.51  6345375    Removed numbers from valid character set for
					       P45_46_FIRST_NAME, P45_46_LAST_NAME, P45_46_TITLE
   30-NOV-2007 pbalu        115.52  6281170    To change the condition for contribution
                                               rollup and LEL rollup as part of EOY 07/08
   20-Nov-2008 namgoyal     115.55  7540858    Allowed space as a valid character in P45_46_FIRST_NAME
   19-DEC-2009 vijranga     115.56  7043405    LEL Rollup condition (added for EOY 07/08) reverted back.
   17-Mar-2009 rlingama     115.57  8338575    Removed the first character validation for address lines
   22-Apr-2009 dwkrishn     115.58  8439388    Last Name should not have '.' Full stop in the char set
   18-Jun-2009 pbalu     115.59/60  8357870    Created new formula based on PAY_GB_EDI_P14_NI_DETAILS to
   					       enable users to run EOY for reconciliation.
   25-Jun-2009 pbalu   	    115.61  8357870    To pass NI UAP balance value to PAY_GB_EDI_P14_NI_DETAILS_INTERIM
   21-Aug-2009 krreddy      115.62  8541978    Added PRAGMA statement in the procedure submit_recon_report.
   10-Sep-2009 npannamp     115.63  8816832    Implement 2009-10 EOY validations as in MIG
   03-Nov-2009 namgoyal     115.64  8986543    Added mode P46_CAR_TIT_N_FSTNM in validate_input for
                                               P46 Car EDI version3
   05-Nov-2009 npannamp     115.65  8833756    2009-10 EOY - Added check to identify single assignments with
                                               NI Aggregation flag set wrongly.
   05-Nov-2009 npannamp     115.66  8833756    Code review comments incorporated.
   26-Feb-2010 npannamp     115.67  9414865     Bug Fix in create_record_type1 procedure.
*/
fetch_new_header  BOOLEAN := TRUE;  -- Shows if new header record needed
process_emps      BOOLEAN := FALSE; -- Shows if get employees records
edi_process_emp_header      BOOLEAN := FALSE; -- get employee header for EDI
edi_process_ni_details      BOOLEAN := FALSE; -- get employee ni details for EDI
edi_process_emp_trailer     BOOLEAN := FALSE; -- get employee trailer for EDI
fin_run           BOOLEAN := FALSE; -- End of run flag
sub_header        BOOLEAN := FALSE; -- Create the record type2 sub
permit_change     BOOLEAN := FALSE; -- set if the permit_no changes
process_dummy     BOOLEAN := FALSE; -- Set if > 4 NI codes are found
g_ni_total        NUMBER(3) := 0;   -- Number of Ni codes found
g_last_ni         NUMBER(3) := 0;   -- Index through NI PL/SQL tables
--
g_permit_no       VARCHAR2(12);     -- The current permit number must be held
g_tax_dist_ref    VARCHAR2(3) :=NULL;
g_payroll_id      NUMBER(15);       -- The current payroll id held between
g_payroll_action_id NUMBER(9);      -- The current payroll action id.
g_assignment_action_id NUMBER(15);  -- Assignment Action
g_record_index    NUMBER(2) := 0;   -- Counter for mag tape parameters
g_tot_contribs    NUMBER(15):=0;    -- Total contribution by permit_no
g_tot_student_ln  NUMBER(15):=0;    -- Total Student Loans for permit
g_tot_tax         NUMBER(12):=0;    -- Total tax by permit_no
g_tot_rec2        NUMBER(7) :=0;    -- Total of record 2's
g_tot_rec2_per    NUMBER(7) :=0;    -- Number of record 2's by permit_no
g_tot_ssp_rec     NUMBER(15):=0;    -- Total ssp by permit_no
g_tot_smp_rec     NUMBER(15):=0;    -- Total smp by permit_no
g_tot_sap_rec     NUMBER(15):=0;    -- Total sap by permit_no   --P35/P14 EOY 2003/2004
g_tot_spp_rec     NUMBER(15):=0;    -- Total spp by permit_no   --P35/P14 EOY 2003/2004
/* Start 4011263
g_tot_smp_comp    NUMBER(15):=0;    -- Total smp compensated by permit_no
g_tot_spp_comp    NUMBER(15):=0;    -- Total spp compensated by permit_no --P35/P14 EOY 2003/2004
g_tot_sap_comp    NUMBER(15):=0;    -- Total sap compensated by permit_no --P35/P14 EOY 2003/2004
   End 4011263 */
g_tot_ers_rebate  NUMBER(11):=0;    -- Total ers rebate by permit
g_tot_ees_rebate  NUMBER(11):=0;    -- Total Ees rebate by permit
g_eoy_mode        VARCHAR2(30):='P'; -- THE eoy mode defaults to partial
g_edi_sender_id   VARCHAR2(35);     -- EDI sender id
g_request_id      NUMBER;           -- Payroll action's request id
g_test_indicator  VARCHAR2(1):='N'; -- THE test indicator defaults to No
-- 4011263: Add Unique Test ID
g_unique_test_id  VARCHAR2(12);
g_return_type     VARCHAR2(1);
-- g_urgent_marker   VARCHAR2(1):='N'; THE urgent marker removed for 4011263
--
-- Record type 1 placeholders
g_new_permit_no     VARCHAR2(12);   -- The recently fetched permit number
g_new_payroll_id    NUMBER(15);     -- The recently fetched payroll id
g_tax_district_ref  VARCHAR2(3);
g_old_tax_dist_ref  VARCHAR2(3);
g_tax_ref_no        VARCHAR2(10); -- 4011263: length 10 chars
g_old_tax_ref_no    VARCHAR2(10);
-- 4011263: g_tax_district_name VARCHAR2(40);
g_tax_year          VARCHAR2(4);
g_employers_name    VARCHAR2(100);
-- 4752018:g_employers_address VARCHAR2(300);
/* Start 4011263
g_econ              VARCHAR2(9);
g_ssp_recovery      NUMBER(15);
g_smp_recovery      NUMBER(15);
g_smp_compensation  NUMBER(15);
g_spp_recovery      NUMBER(15); --P35/P14 EOY 2003/2004
g_spp_compensation  NUMBER(15); --P35/P14 EOY 2003/2004
g_sap_recovery      NUMBER(15); --P35/P14 EOY 2003/2004
g_sap_compensation  NUMBER(15); --P35/P14 EOY 2003/2004
  End 4011263 */

--
-- Record type 2 placeholders
g_employee_number           VARCHAR2(30);
g_last_name                 VARCHAR2(80);
g_first_name                VARCHAR2(80);
g_middle_name               VARCHAR2(80);
g_full_name                 VARCHAR2(165);
g_title                     VARCHAR2(80);
g_date_of_birth             VARCHAR2(8);
g_national_insurance_number VARCHAR2(9);
g_start_of_emp              VARCHAR2(8);
g_termination_date          VARCHAR2(8);
g_sex                       VARCHAR2(1);
g_address_line1             VARCHAR2(80);
g_address_line2             VARCHAR2(80);
g_address_line3             VARCHAR2(80);
g_town_or_city              VARCHAR2(80);
g_country                   VARCHAR2(80);
g_full_address              VARCHAR2(320); -- temp var used in address ordering
g_postal_code               VARCHAR2(9);
g_tax_code                  VARCHAR2(7);
g_assignment_id             per_all_assignments_f.assignment_id%type;
g_w1_m1_indicator           VARCHAR2(1);
g_ssp                       NUMBER;
g_smp                       NUMBER;
g_spp		            NUMBER; --P35/P14 EOY 2003/2004
g_sap		            NUMBER; --P35/P14 EOY 2003/2004
l_spp_adopt 		    NUMBER;	--P35/P14 EOY 2003/2004
l_spp_birth 		    NUMBER;	--P35/P14 EOY 2003/2004
--4011263: g_gross_pay                 NUMBER(15);
g_tax_paid                  NUMBER;
g_tax_refund                VARCHAR2(1);
g_previous_taxable_pay      NUMBER;
g_previous_tax_paid         NUMBER;
-- 4011263: g_superannuation_paid       NUMBER(9);
-- 4011263: g_superannuation_refund     VARCHAR2(1);
g_widows_and_orphans        NUMBER;
g_student_loans             NUMBER;
g_week_53_indicator         VARCHAR2(1);
g_taxable_pay               NUMBER;
/* 4011263
g_pension_indicator         VARCHAR2(1);
 4011263 */
g_director_indicator        VARCHAR2(1);
g_ni_multi_asg_flag         VARCHAR2(1);
--
-- Some variables for P14 EDI process
g_edi_ni_cat_count          NUMBER := 0; -- counts number of NI categories for an employee
g_edi_ni_cat_index          NUMBER := 0; -- index of NI categories of an employee
g_edi_emp_ers_rebate        NUMBER := 0; -- Total of ers rebate for an employee
g_edi_emp_ees_rebate        NUMBER := 0; -- Total of ees rebate for an employee
/*  Start 4011263
-- Bug 2696015: Added for P14 EDI Enhancement
g_edi_submitter_no   VARCHAR2(10);     -- EDI Submitter Number
--
End 4011263 */
g_rollup_ni_cat             VARCHAR2(1) := ' ';
g_rollup_scon               VARCHAR2(9) := ' ';
g_rollup_emp_contrib        NUMBER := 0;
g_rollup_tot_contrib        NUMBER := 0;
--
g_start_year                DATE;
g_end_year                  DATE;
/* PL/SQL table definitions */
--
TYPE scon_typ IS TABLE OF VARCHAR2(9)
    INDEX BY BINARY_INTEGER;
TYPE category_typ IS TABLE OF VARCHAR2(1)
    INDEX BY BINARY_INTEGER;
TYPE balance_tab_typ IS TABLE OF NUMBER(15)
    INDEX BY BINARY_INTEGER;
--
scon_tab              scon_typ;
category_tab          category_typ;
total_contrib_tab     balance_tab_typ;
employees_contrib_tab balance_tab_typ;
ni_able_et_tab        balance_tab_typ;
ni_able_lel_tab       balance_tab_typ;
ni_able_uel_tab       balance_tab_typ;
ni_able_uap_tab       balance_tab_typ;  -- 8357870
ni_able_auel_tab      balance_tab_typ;    --- EOY 07/08
employers_rebate_tab  balance_tab_typ;
employees_rebate_tab  balance_tab_typ;
--
g_rollup_lel_ni_cat      pay_gb_year_end_values_v.ni_category_code%TYPE;
g_total_rollup_lel       pay_gb_year_end_values_v.ni_able_lel%TYPE;
--
g_emp_tot_lel            NUMBER; -- total of NI ABle LEL for agg asgs (not NI X)
g_emp_tot_et             NUMBER; -- total of NI ABle ET  for agg asgs (not NI X)
g_emp_tot_uap            NUMBER; -- 8816832 total of NI ABle UAP for agg asgs (not NI X)
g_emp_tot_uel            NUMBER; -- total of NI ABle UEL for agg asgs (not NI X)
g_emp_tot_ee_contrib     NUMBER; -- total of EE Contribs for agg asgs (not NI X)
g_emp_tot_ee_er_contrib  NUMBER; -- total of EE Contribs for agg asgs (not NI X)

-- 8357870 begin - interim solution
l_ni_tax_year     Date;
--
-- Cursor definitions
CURSOR C_NI_NEW_TAX_YEAR is
        select  fnd_date.canonical_to_date(ni.global_value)
        from    ff_globals_f ni
        where   ni.global_name = 'NI_NEW_TAX_YEAR'
        and     ni.business_group_id is null
        and     ni.legislation_code = 'GB'
        and     sysdate between ni.effective_start_date
                                        and ni.effective_end_date;
-- 8357870 end
--
CURSOR header_cur(c_payroll_action_id NUMBER) IS
SELECT UPPER(a.permit_number)
  ,a.payroll_id
  ,lpad(TO_CHAR(a.tax_district_reference),3,'0')
  ,a.tax_reference_number
  ,NVL(TO_CHAR(a.tax_year),' ') -- 4011263
  ,a.employers_name
/* 4752018 - EOY 2005-06
  ,a.employers_address_line
4752018 */
/* Start 4011263
  ,UPPER(NVL(a.econ,'?'))
  ,nvl(a.ssp_recovered,0)
  ,nvl(a.smp_recovered,0)
  ,nvl(a.smp_compensation,0)
  --Added the below four fields for P35/P14 EOY 2003/2004
  ,nvl(a.spp_recovered,0)
  ,nvl(a.spp_compensation,0)
  ,nvl(a.sap_recovered,0)
  ,nvl(a.sap_compensation,0)
   End 4011263 */
FROM  pay_gb_year_end_payrolls_v a
WHERE a.payroll_action_id = c_payroll_action_id
AND EXISTS (SELECT '1'
            FROM  pay_assignment_actions paa,
                  ff_user_entities fue,
                  ff_archive_items fai
            WHERE paa.payroll_action_id = a.payroll_action_id
            AND   fue.user_entity_name = 'X_PAYROLL_ID'
      AND   fai.user_entity_id = fue.user_entity_id
            AND   fai.context1 = paa.assignment_action_id
            AND   fai.value = to_char(a.payroll_id))
ORDER BY a.tax_district_reference, a.tax_reference_number, a.permit_number,a.payroll_id;
--
CURSOR emps_cur(c_payroll_id NUMBER, c_payroll_action_id NUMBER) IS
SELECT
   max(decode(fue2.user_entity_name,'X_ASSIGNMENT_NUMBER',
                            fai2.VALUE))
  ,act.assignment_action_id
  ,nvl(max(decode(fue2.user_entity_name,'X_LAST_NAME',
                     substr(fai2.value,1,35))),' ') LAST_NAME
  ,nvl(max(decode(fue2.user_entity_name,'X_FIRST_NAME',
                     SUBSTR(ltrim(rtrim(fai2.value)),1,35))), ' ') FIRST_NAME
  ,nvl(max(decode(fue2.user_entity_name,'X_MIDDLE_NAME', SUBSTR(ltrim(rtrim(fai2.value)),1,35))), ' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_TITLE', SUBSTR(ltrim(rtrim(fai2.value)),1,35))), ' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_DATE_OF_BIRTH',
                     TO_CHAR(fnd_date.canonical_to_date(fai2.value),'DDMMYYYY'))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_SEX', substr(UPPER(fai2.value),1,1))),' ')
  ,nvl(ltrim(max(decode(fue2.user_entity_name,'X_ADDRESS_LINE1',
                     decode(fai2.value,'','',rpad(fai2.value,35))))), ' ')
  ,nvl(ltrim(max(decode(fue2.user_entity_name,'X_ADDRESS_LINE2',
                     decode(fai2.value,'','',rpad(fai2.value,35))))), ' ')
  ,nvl(ltrim(max(decode(fue2.user_entity_name,'X_ADDRESS_LINE3',
                     decode(fai2.value,'','',rpad(fai2.value,35))))), ' ')
  ,nvl(ltrim(max(decode(fue2.user_entity_name,'X_TOWN_OR_CITY',
                     decode(fai2.value,'','',rpad(fai2.value,35))))), ' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_COUNTRY', -- 4011263
                     decode(fai2.value,'','',rpad(ltrim(rtrim(fai2.value)),27)))), ' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_POSTAL_CODE',
                     substr(fai2.value,1,9))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_TAX_CODE',
                     ltrim(rtrim(UPPER(fai2.value))))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_W1_M1_INDICATOR',
                     substr(UPPER(fai2.value),1,1))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',
                     substr(UPPER(fai2.value),1,9))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_SSP', to_number(fai2.value))),0)
  ,nvl(max(decode(fue2.user_entity_name,'X_SMP', to_number(fai2.value))),0)
   -- Added the below 2 fields for P35/P14 EOY 2003/2004
  ,nvl(max(decode(fue2.user_entity_name,'X_SPP_ADOPT', to_number(fai2.value))),0) -- for SPP
  ,nvl(max(decode(fue2.user_entity_name,'X_SPP_BIRTH', to_number(fai2.value))),0) -- for SPP
  ,nvl(max(decode(fue2.user_entity_name,'X_SAP', to_number(fai2.value))),0) -- for SAP
/*4011263: Gross Pay not needed anymore
  ,nvl(max(decode(fue2.user_entity_name,'X_GROSS_PAY',to_number(fai2.VALUE))),0) gross_pay
*/
  --
  ,decode(max(decode(fue2.user_entity_name,'X_TAX_REFUND',substr(fai2.VALUE,1,1))), 'R',
         NVL(-1*max(decode(fue2.user_entity_name,'X_TAX_PAID',to_number(fai2.VALUE))),0),
              NVL(max(decode(fue2.user_entity_name,'X_TAX_PAID',to_number(fai2.VALUE))),0)) tax_paid
  --
  ,nvl(max(decode(fue2.user_entity_name,'X_TAX_REFUND',
                     substr(UPPER(fai2.value),1,1))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_PREVIOUS_TAXABLE_PAY',
                                        to_number(fai2.value))),0) previous_taxable
  ,nvl(max(decode(fue2.user_entity_name,'X_PREVIOUS_TAX_PAID', to_number(fai2.value))),0)
  ,nvl(max(decode(fue2.user_entity_name,'X_START_OF_EMP',
              TO_CHAR(fnd_date.canonical_to_date(fai2.value),'DDMMYYYY'))),' ')
  ,max(decode(fue2.user_entity_name,'X_TERMINATION_DATE',
              TO_CHAR(fnd_date.canonical_to_date(fai2.value),'DDMMYYYY')))
  ,nvl(max(decode(fue2.user_entity_name,'X_WIDOWS_AND_ORPHANS',
                         ROUND(to_number(fai2.value)/100))),0)
  ,nvl(max(decode(fue2.user_entity_name,'X_STUDENT_LOANS', trunc(fai2.value/100))),0) student_loans
  ,nvl(max(decode(fue2.user_entity_name,'X_WEEK_53_INDICATOR',
                         substr(UPPER(fai2.value),1,1))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_TAXABLE_PAY', to_number(fai2.value))),0) taxable_pay
/* 4011263
  ,nvl(max(decode(fue2.user_entity_name,'X_PENSIONER_INDICATOR',
                         substr(UPPER(fai2.value),1,1))),' ')
   4011263 */
  ,nvl(max(decode(fue2.user_entity_name,'X_DIRECTOR_INDICATOR',
                         substr(UPPER(fai2.value),1,1))),' ')
  ,act.assignment_id
  ,max(decode(fue2.user_entity_name,'X_EFFECTIVE_END_DATE',
                      fnd_date.canonical_to_date(fai2.value)))
  ,nvl(max(decode(fue2.user_entity_name,'X_ASSIGNMENT_MESSAGE',
                         SUBSTR(fai2.VALUE, 1,60))),' ')
  ,nvl(max(decode(fue2.user_entity_name,'X_MULTIPLE_ASG_FLAG',
                         SUBSTR(fai2.VALUE, 1,1))),' ')
  FROM
  ff_archive_items fai1,
  ff_user_entities fue1,
  ff_archive_items fai2,
  ff_user_entities fue2,
  pay_assignment_actions act
WHERE act.assignment_action_id = fai1.context1
AND act.payroll_action_id = c_payroll_action_id
AND act.action_status = 'C'
AND fue1.legislation_code = 'GB'
AND fue1.user_entity_name = 'X_PAYROLL_ID'
AND fue1.business_group_id IS NULL
AND fue1.user_entity_id  + decode(act.assignment_action_id,0,0,0) = fai1.user_entity_id
and fai1.value = to_char(c_payroll_id)
AND fue2.user_entity_id  = fai2.user_entity_id
AND fai2.context1 = act.assignment_action_id
GROUP BY
act.assignment_action_id
, act.assignment_id
HAVING
(
         nvl(max(decode(fue2.user_entity_name,'X_AGGREGATED_PAYE_FLAG', fai2.value)), 'N')='N'
      OR (
            nvl(max(decode(fue2.user_entity_name,'X_AGGREGATED_PAYE_FLAG', fai2.value)), 'N')='Y'
        AND nvl(max(decode(fue2.user_entity_name,'X_EOY_PRIMARY_FLAG',  fai2.value)), 'N')='Y'
         )
)
AND
(
     nvl(max(decode(fue2.user_entity_name, 'X_TAXABLE_PAY', to_number(fai2.value))),0) <> 0
  OR NVL(max(decode(fue2.user_entity_name,'X_TAX_PAID',to_number(fai2.VALUE))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_STUDENT_LOANS', trunc(fai2.value/100))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_PREVIOUS_TAXABLE_PAY', to_number(fai2.value))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_PREVIOUS_TAX_PAID', to_number(fai2.value))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_SSP', to_number(fai2.value))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_SMP', to_number(fai2.value))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_SAP', to_number(fai2.value))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_SPP_ADOPT', to_number(fai2.value))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_SPP_BIRTH', to_number(fai2.value))),0) <> 0
  OR nvl(max(decode(fue2.user_entity_name,'X_REPORTABLE_NI', fai2.value)),'N') <> 'N'
)
ORDER BY last_name, first_name;
--
CURSOR get_rollup_ni_cat(c_assignment_action_id NUMBER) IS
SELECT NVL(UPPER(a.scon),' ')       scon
      ,UPPER(a.ni_category_code)        cat_code
FROM  pay_gb_year_end_values_v a
WHERE a.assignment_action_id  = c_assignment_action_id
AND   a.reportable        <> 'N'
AND NVL(trunc(a.ni_able_uel/100),0)  > 0
AND NVL(a.employees_contributions,0) > 0
AND UPPER(a.ni_category_code) <> 'X'
AND UPPER(a.ni_category_code) <> 'C'
ORDER BY NVL(trunc(a.ni_able_uel/100),0), NVL(a.employees_contributions,0),
         UPPER(a.ni_category_code), NVL(UPPER(a.scon),' ') DESC;
--
-- Cursor to find NI category with LEL and ET > 0 so that Ni Cats with LEL but
-- no other values can be rolledup into this
--
CURSOR get_lel_rollup_ni_cat(c_assignment_action_id NUMBER) IS
SELECT UPPER(a.ni_category_code)        cat_code
FROM  pay_gb_year_end_values_v a
WHERE a.assignment_action_id  = c_assignment_action_id
AND   a.reportable        <> 'N'
AND NVL(trunc(a.ni_able_et/100),0)  > 0
AND NVL(trunc(a.ni_able_lel/100),0)  > 0
AND UPPER(a.ni_category_code) <> 'X'
ORDER BY NVL(trunc(a.ni_able_et/100),0),
         NVL(trunc(a.ni_able_lel/100),0),
         NVL(a.employees_contributions,0),
         UPPER(a.ni_category_code), NVL(UPPER(a.scon),' ') DESC;
--
-- Cursor to get total of LEL for NI Cats with LEL > 0,
-- ET=0, UEL=0, ER Cont=0 and EE Cont=0
-- Total of these LELs  will be rolled into first NI Cat
-- returned by above cursor get_lel_rollup_ni_cat
--
CURSOR get_only_lel_total(c_assignment_action_id NUMBER) IS
SELECT NVL(sum(trunc(a.ni_able_lel/100)),0)  tot_ni_able_lel
FROM  pay_gb_year_end_values_v a
WHERE a.assignment_action_id  = c_assignment_action_id
AND   a.reportable        <> 'N'
AND   UPPER(a.ni_category_code) <> 'X'
-- Check LEL > 0 but ET, UEL, EE and ER Conrib = 0
-- Bug#7043405 LEL Rollup condition reverted back
AND NVL(a.total_contributions,0) = 0    -- EOY 07/08 removed Total contribution from LEL roll up
AND NVL(trunc(a.ni_able_et/100),0) = 0
AND NVL(trunc(a.ni_able_uap/100),0) = 0  -- 8816832 EOY 09/10
AND NVL(trunc(a.ni_able_uel/100),0) = 0
-- Bug#7043405 LEL Rollup condition reverted back
AND NVL(a.employees_contributions,0) = 0  -- EOY 07/08 removed Employee contribution from LEL roll up
AND NVL(trunc(a.ni_able_lel/100),0) > 0;
--
-- ni able per threshold figures to be stored in pounds, so trunc the
-- pence value from the view after dividing by 100.
--
CURSOR emp_values(c_assignment_action_id NUMBER) IS
SELECT NVL(UPPER(a.scon),' ')       scon
  ,UPPER(a.ni_category_code)        cat_code
  ,NVL(a.total_contributions,0)     tot_cont
  ,NVL(a.employees_contributions,0) emps_cont
  ,NVL(trunc(a.ni_able_et/100),0)   ni_able_et
  ,NVL(trunc(a.ni_able_lel/100),0)  ni_able_lel
  ,NVL(trunc(a.ni_able_uel/100),0)  ni_able_uel
  ,NVL(trunc(a.ni_able_uap/100),0)  ni_able_uap  -- 8357870
  ,NVL(trunc(a.ni_able_auel/100),0)  ni_able_auel  --EOY 07/08 added AUEL for contributions rollup
  ,NVL(a.employers_rebate,0)        employers_rebate
  ,NVL(a.employees_rebate,0)        employees_rebate
FROM  pay_gb_year_end_values_v a
WHERE a.assignment_action_id  = c_assignment_action_id
AND   a.reportable        <> 'N'
-- Check atleast one value is non-zero to report
AND NOT (NVL(a.total_contributions,0) = 0
         AND NVL(trunc(a.ni_able_et/100),0) = 0
         AND NVL(trunc(a.ni_able_lel/100),0) = 0
         AND NVL(trunc(a.ni_able_uap/100),0) = 0 -- 8816832 EOY 09/10
         AND NVL(trunc(a.ni_able_uel/100),0) = 0
         AND NVL(a.employees_contributions,0) = 0)
UNION -- Added union to fix 4216135
SELECT ' '
      ,'X'
      ,0
      ,0
      ,0
      ,0  -- 8357870
      ,0   --EOY 07/08
      ,0
      ,0
      ,0
      ,0
FROM dual
WHERE NOT EXISTS
(SELECT 1 FROM pay_gb_year_end_values_v b
 WHERE b.assignment_action_id  = c_assignment_action_id
 AND   b.reportable        <> 'N'
 AND NOT (NVL(b.total_contributions,0) = 0
         AND NVL(trunc(b.ni_able_et/100),0) = 0
         AND NVL(trunc(b.ni_able_lel/100),0) = 0
         AND NVL(trunc(b.ni_able_uap/100),0) = 0 -- 8816832 EOY 09/10
         AND NVL(trunc(b.ni_able_uel/100),0) = 0
         AND NVL(b.employees_contributions,0) = 0))
/* Bug Fix 8816832 EOY 09/10 Included UAP also in order by
ORDER BY 6, 5, 7, 2, 1; -- order by clause added for 4234348 to ensure Ni Cats with 0 lel/et/uel are processed first */
ORDER BY 6, 5, 8, 7, 2, 1; -- order by clause added for 4234348 to ensure Ni Cats with 0 lel/et/uap/uel are processed first
--
/* Start 4011263
CURSOR econ_chk(c_permit_no            VARCHAR2
               ,c_tax_dist_ref         VARCHAR2
               ,c_tax_ref_no           VARCHAR2
               ,c_payroll_action_id    NUMBER) IS
SELECT 1
FROM  ff_archive_item_contexts fac,
      ff_archive_items fai,
      ff_user_entities fue,
      ff_archive_items fai2,
      ff_user_entities fue2,
      pay_assignment_actions paa
WHERE paa.payroll_action_id = c_payroll_action_id
AND   fue.user_entity_name  = 'X_NI_TOTAL_CONTRIBUTIONS'
AND   fue.user_entity_id    + decode(paa.assignment_action_id,0,0,0)
                            = fai.user_entity_id
AND   fue.legislation_code  = 'GB'
AND   fai.context1          = paa.assignment_action_id
AND   fai.archive_item_id   = fac.archive_item_id
AND   fac.sequence_no       = 2
AND   fac.context in ('D','E','L') --P35/P14 EOY 2003/2004
AND   fue2.user_entity_name = 'X_PAYROLL_ID'
AND   fue2.user_entity_id   + decode(paa.assignment_action_id,0,0,0)
                            = fai2.user_entity_id
AND   fue2.legislation_code  = 'GB'
AND   fai2.context1         = paa.assignment_action_id
AND   decode (c_tax_dist_ref,NULL,1,
              pay_gb_eoy_archive.get_arch_num(c_payroll_action_id,
                             'X_TAX_DISTRICT_REFERENCE',fai2.value),1,0) = 1
AND   decode (c_tax_ref_no,NULL,1,
              pay_gb_eoy_archive.get_arch_str(c_payroll_action_id,
                             'X_TAX_REFERENCE_NUMBER',fai2.value),1,0) = 1
AND   decode (c_permit_no,NULL,1,
              pay_gb_eoy_archive.get_arch_str(c_payroll_action_id,
                             'X_PERMIT_NUMBER',fai2.value),1,0) = 1;
End 4011263 */
------------------------------------------------------------------------------------
-- PROCEDURE:   submit_recon_report
-- DESCRIPTION: Submit year End Reconciliation Report
------------------------------------------------------------------------------------
PROCEDURE submit_recon_report(p_payroll_action_id in     number,
                         p_p35_req_id        out nocopy varchar2) IS
--
l_printer      fnd_concurrent_requests.printer%TYPE;
l_no_of_copies fnd_concurrent_requests.number_of_copies%TYPE;
l_dummy        BOOLEAN := FALSE;
--
l_p35_id       NUMBER := -1;
--
CURSOR get_print_options IS
SELECT printer, number_of_copies
FROM   fnd_concurrent_requests
WHERE  request_id = fnd_global.conc_request_id;
--
/******************************* Below line added to fix the bug 8541978.
It makes sure that even if the value for MAGTAPE_FILE_SAVE is set to 'Y',
process will not error out. ********************************************/
PRAGMA Autonomous_transaction;

BEGIN
  -- Fix 4363883: Find and Set print options as entered on EOY process
  OPEN get_print_options;
  FETCH get_print_options INTO l_printer, l_no_of_copies;
  CLOSE get_print_options;
  -- Call P35 report.
  --
  l_dummy := fnd_request.set_print_options(printer => l_printer,
                                           copies => l_no_of_copies);
  l_p35_id := fnd_request.submit_request(application       => 'PAY',
                                         program           => 'PAYRPP35',
                                         argument1         => p_payroll_action_id);
  hr_utility.trace('The p35 request ID is '||to_char(l_p35_id));
  --
  p_p35_req_id    := to_char(l_p35_id);
  --
  -- this commit ensures that reconciliation report does run even when
  -- the EOY process fails due to type 1 errors
  commit;
  EXCEPTION

  WHEN OTHERS THEN
    p_p35_req_id    := to_char(l_p35_id);
  --

END submit_recon_report;

------------------------------------------------------------------------------------
-- PROCEDURE:   submit_reports
-- DESCRIPTION: Submit the Multiple Asg Reports.
--              Called at the end of the magtape process.
------------------------------------------------------------------------------------
PROCEDURE submit_reports(p_payroll_action_id in     number,
                         p_eoy_mode          in     varchar2,
                         p_mar_req_id        out nocopy varchar2) IS
--
l_printer      fnd_concurrent_requests.printer%TYPE;
l_no_of_copies fnd_concurrent_requests.number_of_copies%TYPE;
l_dummy        BOOLEAN := FALSE;
--
l_mar_id       NUMBER := -1;
--
CURSOR get_print_options IS
SELECT printer, number_of_copies
FROM   fnd_concurrent_requests
WHERE  request_id = fnd_global.conc_request_id;
--
BEGIN
  -- Fix 4363883: Find and Set print options as entered on EOY process
  OPEN get_print_options;
  FETCH get_print_options INTO l_printer, l_no_of_copies;
  CLOSE get_print_options;
  --
  -- Call Multiple Assignments Report.
  --
  l_dummy := fnd_request.set_print_options(printer => l_printer,
                                           copies => l_no_of_copies);
  l_mar_id := fnd_request.submit_request(application => 'PAY',
                                         program     => 'PAYYEMAR',
                                         argument1   => p_payroll_action_id);
  hr_utility.trace('The mar request ID is '||to_char(l_mar_id));
  --
  --
  -- Assign Out Params
  --
  p_mar_req_id    := to_char(l_mar_id);
--


  -- Added for nocopy fix
  EXCEPTION

  WHEN OTHERS THEN
    p_mar_req_id    := to_char(l_mar_id);
  --

END submit_reports;
--
/* 8833756 begin - Added to get the count of assignments for a person
   in the tax year, with the same tax district and tax reference details
   and have overlapping effective dates.*/
FUNCTION get_assign_count(p_assignment_id          NUMBER,
                          p_min_start_year_date    DATE,
                          p_max_end_year_date      DATE,
                          p_tax_dist_ref           VARCHAR2,
                          p_tax_ref                VARCHAR2) RETURN NUMBER IS
-- Get the number of assignments for the person in the tax year
p_assg_count NUMBER;
l_person_id per_all_assignments_f.person_id%type := 0;

cursor csr_pers_id(c_assignment_id per_all_assignments_f.assignment_id%type) IS
select person_id from per_all_assignments_f where
assignment_id=c_assignment_id order by effective_end_date DESC;

cursor csr_pers_assg_count (p_person_id            per_all_assignments_f.person_id%type,
                          p_min_start_year_date    DATE,
                          p_max_end_year_date      DATE,
                          p_tax_dist_ref           VARCHAR2,
                          p_tax_ref                VARCHAR2) IS
        select count(distinct master.assignment_id) from
        (  SELECT /*+ ORDERED INDEX (asg PER_ASSIGNMENTS_F_N12,
                                    ppf PAY_PAYROLLS_F_PK,
                                    flex HR_SOFT_CODING_KEYFLEX_PK,
                                    org HR_ORGANIZATION_INFORMATIO_FK1)
                     USE_NL(asg,ppf,flex,org) */
          distinct asg.assignment_id, asg.effective_start_date, asg.effective_end_date
          FROM  per_all_assignments_f       asg,
                pay_all_payrolls_f              ppf,
                hr_soft_coding_keyflex      flex,
                hr_organization_information org
          WHERE asg.person_id = p_person_id
            AND asg.effective_end_date >= p_min_start_year_date
            AND asg.effective_start_date <= p_max_end_year_date
            AND asg.payroll_id = ppf.payroll_id
            AND asg.period_of_service_id is not null
            AND ppf.effective_end_date >= p_min_start_year_date
            AND ppf.effective_start_date <= p_max_end_year_date
            AND ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
            AND asg.business_group_id +0 = org.organization_id
            AND org.org_information_context =
                         'Tax Details References'||decode(flex.segment1,'','','')
            AND org.org_information1 = flex.segment1
            AND nvl(org.org_information10,'UK') = 'UK'
            AND nvl(p_tax_dist_ref, substr(flex.segment1,1,3)) =
                                              substr(flex.segment1,1,3)
            AND nvl(p_tax_ref, substr(ltrim(substr(org_information1,4,11),'/') ,1,10))
                           = substr(ltrim(substr(org_information1,4,11),'/') ,1,10)
        ) master,
        (  SELECT /*+ ORDERED INDEX (asg PER_ASSIGNMENTS_F_N12,
                                    ppf PAY_PAYROLLS_F_PK,
                                    flex HR_SOFT_CODING_KEYFLEX_PK,
                                    org HR_ORGANIZATION_INFORMATIO_FK1)
                     USE_NL(asg,ppf,flex,org) */
          distinct asg.assignment_id, asg.effective_start_date, asg.effective_end_date
          FROM  per_all_assignments_f       asg,
                pay_all_payrolls_f              ppf,
                hr_soft_coding_keyflex      flex,
                hr_organization_information org
          WHERE asg.person_id = p_person_id
            AND asg.effective_end_date >= p_min_start_year_date
            AND asg.effective_start_date <= p_max_end_year_date
            AND asg.payroll_id = ppf.payroll_id
            AND asg.period_of_service_id is not null
            AND ppf.effective_end_date >= p_min_start_year_date
            AND ppf.effective_start_date <= p_max_end_year_date
            AND ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
            AND asg.business_group_id +0 = org.organization_id
            AND org.org_information_context =
                         'Tax Details References'||decode(flex.segment1,'','','')
            AND org.org_information1 = flex.segment1
            AND nvl(org.org_information10,'UK') = 'UK'
            AND nvl(p_tax_dist_ref, substr(flex.segment1,1,3)) =
                                              substr(flex.segment1,1,3)
            AND nvl(p_tax_ref, substr(ltrim(substr(org_information1,4,11),'/') ,1,10))
                           = substr(ltrim(substr(org_information1,4,11),'/') ,1,10)
        ) child
        where (master.effective_start_date between child.effective_start_date and child.effective_end_date
               or
               master.effective_end_date between child.effective_start_date and child.effective_end_date)
               and master.assignment_id <> child.assignment_id;
BEGIN
  OPEN csr_pers_id(p_assignment_id);
  FETCH csr_pers_id into l_person_id;
  CLOSE csr_pers_id;
  OPEN csr_pers_assg_count(l_person_id ,
                          p_min_start_year_date ,
                          p_max_end_year_date ,
                          p_tax_dist_ref      ,
                          p_tax_ref           );
  FETCH csr_pers_assg_count INTO p_assg_count;
  CLOSE csr_pers_assg_count;
  RETURN p_assg_count;
END;
/* 8833756 End */
--
FUNCTION get_formula_id(p_formula_name VARCHAR2) RETURN INTEGER IS
-- Get the formula id from the formula name
p_formula_id INTEGER;
CURSOR form IS
     SELECT a.formula_id
     FROM   ff_formulas_f a,
            ff_formula_types t
     WHERE a.formula_name = p_formula_name
     AND   a.formula_type_id = t.formula_type_id
     AND   t.formula_type_name = 'Oracle Payroll';
BEGIN
  OPEN form;
  FETCH form INTO p_formula_id;
  CLOSE form;
  RETURN p_formula_id;
END;
--
PROCEDURE get_edi_sender_id(p_payroll_action_id IN NUMBER) IS
-- Get the EDI sender id from hr_organization_information
l_edi_sender_id VARCHAR2(35) := ' ';
CURSOR sender_id_cur IS
     SELECT upper(nvl(org_information11,' ')) edi_sender_id,
            pact.request_id
     FROM   pay_payroll_actions pact,
            hr_organization_information hoi
     WHERE  pact.payroll_action_id = p_payroll_action_id
     AND    hoi.org_information_context = 'Tax Details References'
     AND    hoi.org_information1 = g_tax_district_ref||'/'||g_tax_ref_no
     AND hoi.organization_id = pact.business_group_id;
BEGIN
  OPEN sender_id_cur;
  FETCH sender_id_cur INTO g_edi_sender_id, g_request_id;
  CLOSE sender_id_cur;
END get_edi_sender_id;
--
-- Bug 2696015: Added for P14 EDI 2003 Enhancement

/* Start 4011263
PROCEDURE get_edi_submitter_no(p_payroll_action_id IN NUMBER) IS
-- Get the EDI sender id from hr_organization_information
edi_submitter_no VARCHAR2(10) := ' ';
CURSOR cur_sumbmitter_no IS
     SELECT nvl(org_information13,' ') edi_submitter_no
     FROM   pay_payroll_actions pact,
            hr_organization_information hoi
     WHERE  pact.payroll_action_id = p_payroll_action_id
     AND    hoi.org_information_context = 'Tax Details References'
     AND    hoi.org_information1 = g_tax_district_ref||'/'||g_tax_ref_no
     AND    hoi.organization_id = pact.business_group_id;
BEGIN
  OPEN cur_sumbmitter_no;
  FETCH cur_sumbmitter_no INTO g_edi_submitter_no;
  CLOSE cur_sumbmitter_no;
END get_edi_submitter_no;
End 4011263 */
--


FUNCTION check_number(p_check_digit CHAR) RETURN BOOLEAN IS
BEGIN
  IF p_check_digit BETWEEN '0' AND '9' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
--
FUNCTION check_char(p_check_digit CHAR) RETURN BOOLEAN IS
BEGIN
  IF p_check_digit BETWEEN 'A' AND 'Z' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
--
FUNCTION check_special_char(p_check_digit CHAR) RETURN BOOLEAN IS
BEGIN
  IF p_check_digit BETWEEN 'A' AND 'Z'
  OR p_check_digit in ('''', '-', '.') THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
--
PROCEDURE mag_tape_init(p_no NUMBER) IS
-- The initialization of the record type formulae
-- and number of parameters
BEGIN
  /* Reserved parameter names */
  pay_mag_tape.internal_prm_names(1) := 'NO_OF_PARAMETERS';
  pay_mag_tape.internal_prm_names(2) := 'NEW_FORMULA_ID';
  pay_mag_tape.internal_prm_names(3) := 'TRANSFER_TYPE1_ERRORS';
  pay_mag_tape.internal_prm_names(4) := 'TRANSFER_TYPE2_ERRORS';
  pay_mag_tape.internal_prm_names(5) := 'TRANSFER_CHAR_ERRORS';
  IF p_no = 1 THEN
    /* Record type 1 */
    pay_mag_tape.internal_prm_values(1) := 15;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD1');
  ELSIF p_no = 2 THEN
    /* Record type 2 */
    pay_mag_tape.internal_prm_values(1) := 69;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD2');
    /* Reset the record index to start at the third parameter */
  ELSIF p_no = 3 THEN
    /* Sub-header */
--  hr_utility.trace('record index is '||to_char(g_record_index));
    pay_mag_tape.internal_prm_values(1) := 7;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD3');
  ELSIF p_no = 4 THEN
    /* Permit total */
--  hr_utility.trace('record index is '||to_char(g_record_index));
    pay_mag_tape.internal_prm_values(1) := 21; -- Incremented as P35/P14 EOY 2003/2004
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD4');
  ELSIF p_no = 5 THEN
    /* End of record */
--  hr_utility.trace('record index is '||to_char(g_record_index));
    pay_mag_tape.internal_prm_values(1) := 12;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD5');
  ELSIF p_no = 6 THEN
    /* Dummy record */
    pay_mag_tape.internal_prm_values(1) := 3;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD6');
  ELSIF p_no = 7 THEN
    pay_mag_tape.internal_prm_values(1) := 6;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD7');
  END IF;
  -- Set parameter count to start at transfer_char_errors
  g_record_index := 6;
END;
--
PROCEDURE p14_edi_init(p_no NUMBER) IS
-- The initialization of the P14 EDI record type formulae
-- and number of parameters
BEGIN
-- 8357870 begin - interim solution
open C_NI_NEW_TAX_YEAR;
fetch C_NI_NEW_TAX_YEAR into l_ni_tax_year;
close C_NI_NEW_TAX_YEAR;
--8357870 end

  -- Reserved parameter names
  pay_mag_tape.internal_prm_names(1) := 'NO_OF_PARAMETERS';
  pay_mag_tape.internal_prm_names(2) := 'NEW_FORMULA_ID';
  pay_mag_tape.internal_prm_names(3) := 'TRANSFER_TYPE1_ERRORS';
  pay_mag_tape.internal_prm_names(4) := 'TRANSFER_TYPE2_ERRORS';
  pay_mag_tape.internal_prm_names(5) := 'TRANSFER_CHAR_ERRORS';
  IF p_no = 1 THEN
    -- Permit Header
    -- pay_mag_tape.internal_prm_values(1) := 15; -- Changed for 4752018
    /* Removed 'TAX_YEAR' input as part of 8833756
    pay_mag_tape.internal_prm_values(1) := 16; -- EOY 09/10 8816832*/
    pay_mag_tape.internal_prm_values(1) := 15;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('PAY_GB_EDI_P14_PERMIT_HEADER');
  ELSIF p_no = 2 THEN
    -- Employee Header
    pay_mag_tape.internal_prm_values(1) := 22; -- Changed for 4752018
    pay_mag_tape.internal_prm_values(2) := get_formula_id('PAY_GB_EDI_P14_EMP_HEADER');
  ELSIF p_no = 3 THEN
    -- Employee NI details
    --pay_mag_tape.internal_prm_values(1) := 22; -- Changed for EOY 2006/7
    --pay_mag_tape.internal_prm_values(1) := 23; -- Added one more parameter for EOY 07/08
    /* 8357870 begin conditionally call formula. Added PAY_GB_EDI_P14_NI_DETAILS_INTERIM
               formula to contain new validations.
       8816832 EOY 09/10 validation in PAY_GB_EDI_P14_NI_DETAILS &
               EOY 08/09 validation in PAY_GB_EDI_P14_NI_DETAILS_INTERIM
       8833756 EOY 09/10 changes
    */
        pay_mag_tape.internal_prm_values(1) := 24; -- Added one more parameter for 8816832 EOY 09/10
        pay_mag_tape.internal_prm_values(2) := get_formula_id('PAY_GB_EDI_P14_NI_DETAILS');
    --8816832 end
  ELSIF p_no = 4 THEN
    -- Employee Trailer
    --pay_mag_tape.internal_prm_values(1) := 31; -- Changed for EOY 2006/7
       -- pay_mag_tape.internal_prm_values(1) := 32; -- Changed for 6281170
       pay_mag_tape.internal_prm_values(1) := 34; -- 8816832 EOY 09/10
       pay_mag_tape.internal_prm_values(2) := get_formula_id('PAY_GB_EDI_P14_EMP_TRAILER');
  ELSIF p_no = 5 THEN
    -- Permit Trailer
    pay_mag_tape.internal_prm_values(1) := 16; -- Changed for 4752018
    pay_mag_tape.internal_prm_values(2) := get_formula_id('PAY_GB_EDI_P14_PERMIT_TRAILER');
  ELSIF p_no = 6 THEN
    -- File Trailer
    pay_mag_tape.internal_prm_values(1) := 11;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('PAY_GB_EDI_P14_FILE_TRAILER');
  ELSIF p_no = 7 THEN
    -- Dummy EDI record
    pay_mag_tape.internal_prm_values(1) := 3;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('PAY_GB_EDI_P14_DUMMY');
  END IF;
  -- Set parameter count to start at transfer_char_errors
  g_record_index := 6;
END;
PROCEDURE mag_tape_interface(p_name   VARCHAR2
          ,p_values VARCHAR2) IS
/* The interface to the magnetic tape writer process */
BEGIN
 pay_mag_tape.internal_prm_names(g_record_index)  := p_name;
 pay_mag_tape.internal_prm_values(g_record_index) := p_values;
 /* Inc the parameter table index */
 g_record_index := g_record_index +1;
END;
--
PROCEDURE mag_tape_interface(p_name   VARCHAR2
          ,p_values NUMBER) IS
/* The interface to the magnetic tape writer process */
BEGIN
  pay_mag_tape.internal_prm_names(g_record_index)  := p_name;
  pay_mag_tape.internal_prm_values(g_record_index) := p_values;
  g_record_index := g_record_index +1;
END;
--
PROCEDURE p_mag_form_clear(l_tab_index NUMBER) IS
/* This procedure will clear the NIx to NI4 records for the
   employee. This will stop any earlier records appearing in
   later records.       */
BEGIN
  FOR l_index IN l_tab_index..4 LOOP
    mag_tape_interface('SCON'||TO_CHAR(l_index) ,' ');
    mag_tape_interface('NI_CATEGORY_CODE'||
                                 TO_CHAR(l_index),' ');
    mag_tape_interface('TOTAL_CONTRIBUTIONS'||l_index,'0');
    mag_tape_interface('EMPLOYEES_CONTRIBUTIONS'|| TO_CHAR(l_index),'0');
    mag_tape_interface('NI_ABLE_ET'|| TO_CHAR(l_index),'0');
    mag_tape_interface('NI_ABLE_LEL'|| TO_CHAR(l_index),'0');
    mag_tape_interface('NI_ABLE_UEL'|| TO_CHAR(l_index),'0');
  END LOOP;
END;
--
PROCEDURE create_record_type1 IS
l_index      NUMBER :=0;
l_result     VARCHAR2(1);
l_tax_dist_ref NUMBER :=0; --Bug Fix 9414865
-- 4011263: l_econ_required VARCHAR2(1) := '0';
BEGIN
        -- Now start validating the record type 1
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',600);
        -- Initialise the record type 1 parameters
        hr_utility.trace('Writing record type 1');
        IF g_eoy_mode in ('F - P14 EDI', 'P - P14 EDI') THEN
           p14_edi_init(1);
        ELSE
           mag_tape_init(1);
        END IF;
         -- Pass the record fields as paramteres to the mag tape process
        hr_utility.trace('Record type1 passed eoy_mode '||g_eoy_mode);
        hr_utility.trace('no params: '||pay_mag_tape.internal_prm_values(1));
        hr_utility.trace('formula id: '||pay_mag_tape.internal_prm_values(2));
        hr_utility.trace('type1 errors: '||pay_mag_tape.internal_prm_values(3));
        hr_utility.trace('type2 errors: '||pay_mag_tape.internal_prm_values(4));
        hr_utility.trace('char errors: '||pay_mag_tape.internal_prm_values(5));
        hr_utility.trace('permit: '||g_new_permit_no);
        hr_utility.trace('tax distr ref: '||g_tax_district_ref);
        hr_utility.trace('tax refno: '||g_tax_ref_no);
-- 4011263:         hr_utility.trace('tax dist name: '||g_tax_district_name);
        hr_utility.trace('tax yr: '||g_tax_year);
        hr_utility.trace('emp name: '||g_employers_name);
-- 4752018:        hr_utility.trace('emp add: '||g_employers_address);
        -- 4011263: hr_utility.trace('econ: '||g_econ);
        -- 4011263: hr_utility.trace('econ reqd: '||l_econ_required);
        mag_tape_interface('EOY_MODE',g_eoy_mode);
        mag_tape_interface('PERMIT_NO',NVL(g_new_permit_no,' '));
--
        /* Field must be three numeric characters */
        /* An invalid or missing char will be passed as a blank space*/
        /* which will cause an error to be raised in magtape formula*/
        BEGIN
          l_tax_dist_ref := TO_NUMBER(g_tax_district_ref); -- Bug Fix 9414865
          /* g_tax_district_ref may have leading zeroes */
          --g_tax_district_ref := TO_NUMBER(g_tax_district_ref);
        EXCEPTION
          WHEN VALUE_ERROR THEN
      -- Any non-numeric characters will raise an exception
            g_tax_district_ref := ' ';
            hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',610);
        END;
        mag_tape_interface('TAX_DISTRICT_REF' ,NVL(g_tax_district_ref,' '));
        mag_tape_interface('TAX_REF_NO',nvl(g_tax_ref_no,' '));
--
-- 4011263: mag_tape_interface('TAX_DISTRICT_NAME',nvl(g_tax_district_name,' '));
-- 4752018:        mag_tape_interface('TAX_YEAR',g_tax_year);
        mag_tape_interface('EMPLOYERS_NAME',NVL(g_employers_name,' '));
-- 4752018:        mag_tape_interface('EMPLOYERS_ADDRESS',NVL(g_employers_address,' '));
        --
/* Start 4011263
        -- Check whether the ECON is required, and whether the Global ECON
        -- is NULL. If it is required and is null, the formula gives a
        -- specific error. All format validation is initiated by the formula.
        --
  IF NOT(econ_chk%ISOPEN) THEN
    OPEN econ_chk(g_permit_no
           ,g_tax_dist_ref
           ,g_tax_ref_no
           ,g_payroll_action_id);
        END IF;
        --
        FETCH econ_chk INTO l_result;  -- NB l_result will be the payroll ID.
        --
        IF g_econ = '?' THEN
           -- If NVL forced a ? then overwrite to a space
           g_econ := ' ';
        END IF;
        --
        IF l_result IS NULL THEN
            --
      -- No econ is needed as no match on the above parameters to
            -- the cursor. Set ECON_REQUIRED to 0.
            --
            l_econ_required := '0';
        ELSE
            -- Econ should be present
            l_econ_required := '1';
            --
        END IF;
    mag_tape_interface('ECON',g_econ);
    mag_tape_interface('ECON_REQUIRED',l_econ_required);
ENd 4011263 */
    IF g_eoy_mode in ('F - P14 EDI', 'P - P14 EDI') THEN

       mag_tape_interface('TEST_INDICATOR', g_test_indicator);
       --mag_tape_interface('URGENT_MARKER', g_urgent_marker); 4011263
       mag_tape_interface('EDI_SENDER_ID', nvl(g_edi_sender_id,' '));
       mag_tape_interface('UNIQUE_ID', substr(g_new_payroll_id||g_request_id,1,14));
       -- 4011263: Add Unique Test Id
       mag_tape_interface('UNIQUE_TEST_ID', g_unique_test_id);
       mag_tape_interface('RETURN_TYPE', g_return_type);
       /* Removed 'TAX_YEAR' input for 8833756
       mag_tape_interface('TAX_YEAR', g_tax_year); -- EOY 09/10 8816832 */
/* Start 4011263
       -- Bug 2696015: Added for P14 EDI Enhancement 2003
       mag_tape_interface('SUBMITTER_NO', nvl(g_edi_submitter_no,' '));
End 4011263 */
    END IF;
END create_record_type1;
--
PROCEDURE create_sub_header IS
BEGIN
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',500);
  IF g_eoy_mode in ('F - P14 EDI', 'P - P14 EDI') THEN
     -- EDI process does not need sub header therefore call dummy formula to skip this step
     p14_edi_init(7);
  ELSE
     hr_utility.trace('Writing record type 2 subheader');
     mag_tape_init(3);
     mag_tape_interface('EOY_MODE',g_eoy_mode);
     mag_tape_interface('SUB_TOTAL','SUBTOTAL');
  END IF;
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',510);
END;
--
PROCEDURE create_record_type3 IS
--
-- Create the Type 3 Magtape record (Grand Total Record), and reset
-- all Permit-level global totals.
--
l_tot_refund        VARCHAR2(1)  :=NULL; -- Set to 'R' if tax refund
--l_total_nic_rebate  NUMBER(11) := 0;   --P35/P14 EOY 2003/2004
--
BEGIN
  hr_utility.trace('Writing record type 3');
  IF g_eoy_mode in ('F - P14 EDI', 'P - P14 EDI') THEN
     p14_edi_init(5);
  ELSE
     mag_tape_init(4);
  END IF;
  mag_tape_interface('EOY_MODE',g_eoy_mode);
  mag_tape_interface('PERMIT_NO',g_permit_no);  -- For inclusion in Error Messages
  mag_tape_interface('TOTAL_CONTRIBUTIONS',NVL(g_tot_contribs,0));
  g_tot_contribs := 0;
  hr_utility.trace('The tot tax is '||to_char(g_tot_tax));
  mag_tape_interface('TOTAL_TAX',NVL(ABS(g_tot_tax),0));
  IF SIGN(g_tot_tax) = -1 THEN
    -- The tax is a refund so set the refund status
    l_tot_refund := 'R';
  ELSE
    l_tot_refund := ' ';
  END IF;
  hr_utility.trace('The tot refund is '||l_tot_refund||'.');
  mag_tape_interface('TOTAL_TAX_REFUND',l_tot_refund);
  g_tot_tax := 0;
  mag_tape_interface('TOTAL_RECORDS',NVL(g_tot_rec2_per,0));
  -- Now add to the total record 2 count
  g_tot_rec2     := g_tot_rec2 + NVL(g_tot_rec2_per,0);
  hr_utility.trace('The per record is '||to_char(g_tot_rec2_per));
  hr_utility.trace('The current grand tot is '||to_char(g_tot_rec2));
  g_tot_rec2_per := 0;
  mag_tape_interface('TOTAL_SSP',NVL(g_tot_ssp_rec,0));
  -- Copy across new values to the variables
--  g_tot_ssp_rec := g_ssp_recovery;
  g_tot_ssp_rec := 0;
  mag_tape_interface('TOTAL_SMP',NVL(g_tot_smp_rec,0));
--  g_tot_smp_rec := g_smp_recovery;
  g_tot_smp_rec := 0;
/* Start 4011263
  mag_tape_interface('TOTAL_SMP_COMP',NVL(g_tot_smp_comp,0));
--  g_tot_smp_comp := g_smp_compensation;
  g_tot_smp_comp := 0;
-- l_total_nic_rebate := g_tot_ers_rebate + g_tot_ees_rebate; --P35/P14 EOY 2003/2004
   mag_tape_interface('TOTAL_SPP_COMP',NVL(g_tot_spp_comp,0));
   g_tot_spp_comp := 0;
End 4011263 */
   mag_tape_interface('TOTAL_SPP_REC',NVL(g_tot_spp_rec,0));
   g_tot_spp_rec := 0;
/* Start 4011263
   mag_tape_interface('TOTAL_SAP_COMP',NVL(g_tot_sap_comp,0));
   g_tot_sap_comp := 0;
End 4011263 */
   mag_tape_interface('TOTAL_SAP_REC',NVL(g_tot_sap_rec,0));
   g_tot_sap_rec := 0;
-- mag_tape_interface('TOTAL_NIC_REBATE', nvl(l_total_nic_rebate,0)); --P35/P14 EOY 2003/2004
-- g_tot_ers_rebate := 0;  --P35/P14 EOY 2003/2004
-- g_tot_ees_rebate := 0;  --P35/P14 EOY 2003/2004
  mag_tape_interface('TOTAL_STUDENT_LOANS',nvl(g_tot_student_ln,0));
  g_tot_student_ln := 0;
END;
--
PROCEDURE p_create_dummy(l_tab_index NUMBER
                  ,l_no_nis    NUMBER) IS
--
l_local_date        DATE;                 -- Used to hold a converted char
-- l_ers_rebate        NUMBER(9); --P35/P14 EOY 2003/2004
-- l_ees_rebate        NUMBER(9); --P35/P14 EOY 2003/2004
l_param_index       NUMBER(1);
--
BEGIN
  /* Now create a dummy record type 2 */
  /* This is for the extra NI details for an employee */
  mag_tape_init(2);
  mag_tape_interface('EOY_MODE',g_eoy_mode);
  mag_tape_interface('EMPLOYEE_NUMBER',NVL(g_employee_number,' '));
  hr_utility.trace('The employee is '||g_employee_number);
  --
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',530);
  --
  -- Note all name validation performed in formula.
  --
  mag_tape_interface('LAST_NAME',NVL(g_last_name,' '));
  mag_tape_interface('FIRST_NAME',NVL(g_first_name,' '));
  mag_tape_interface('MIDDLE_NAME',NVL(g_middle_name,'       '));
  mag_tape_interface('DATE_OF_BIRTH',g_date_of_birth);
  mag_tape_interface('GENDER',g_sex);
  mag_tape_interface('ADDRESS_LINE1',g_address_line1);
  mag_tape_interface('ADDRESS_LINE2',g_address_line2);
  mag_tape_interface('ADDRESS_LINE3',g_address_line3);
  mag_tape_interface('TOWN_OR_CITY',g_town_or_city);
  mag_tape_interface('COUNTRY',g_country);  -- 4011263
  mag_tape_interface('POSTAL_CODE',g_postal_code);
  /**************************************/
  /* Put blank space into tax code field*/
  /**************************************/
  mag_tape_interface('TAX_CODE','  ');
  mag_tape_interface('W1_M1',' ');
  mag_tape_interface('NI_NO',g_national_insurance_number);
--
--    Send the first record from the pl/sql tables to the mag tape
--
  mag_tape_interface('SCON1',scon_tab(l_tab_index + 1));
  mag_tape_interface('NI_CATEGORY_CODE1',category_tab(l_tab_index + 1));
  mag_tape_interface('TOTAL_CONTRIBUTIONS1',total_contrib_tab(l_tab_index+1));
  mag_tape_interface('EMPLOYEES_CONTRIBUTIONS1',
                employees_contrib_tab(l_tab_index+1));
  mag_tape_interface('NI_ABLE_ET1', ni_able_et_tab(l_tab_index+1));
  mag_tape_interface('NI_ABLE_LEL1', ni_able_lel_tab(l_tab_index+1));
  mag_tape_interface('NI_ABLE_UEL1', ni_able_uel_tab(l_tab_index+1));
-- l_ers_rebate := employers_rebate_tab(l_tab_index+1); --P35/P14 EOY 2003/2004
-- l_ees_rebate := employees_rebate_tab(l_tab_index+1); --P35/P14 EOY 2003/2004
  mag_tape_interface('SSP','0');
  mag_tape_interface('SMP','0');
  mag_tape_interface('SPP','0'); --P35/P14 EOY 2003/2004
  mag_tape_interface('SAP','0'); --P35/P14 EOY 2003/2004
  -- 4011263: mag_tape_interface('GROSS_PAY','0');
  mag_tape_interface('TAX_PAID','0');
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',560);
  mag_tape_interface('TAX_REFUND',' ');
  mag_tape_interface('PREVIOUS_TAXABLE_PAY','0');
--
  mag_tape_interface('PREVIOUS_TAX_PAID','0');
--
  mag_tape_interface('DATE_OF_STARTING',g_start_of_emp);
  BEGIN
    IF g_termination_date IS NOT NULL THEN
      l_local_date := TO_DATE(g_termination_date,'DDMMYYYY');
    END IF;
  EXCEPTION
    WHEN value_error THEN
      g_termination_date := ' ';
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',570);
  END;
  mag_tape_interface('TERMINATION_DATE',NVL(g_termination_date,' '));
/* Start 4011263
  mag_tape_interface('SUPERANNUATION','0');
--
  mag_tape_interface('SUPERANNUATION_REFUND',' ');
End 4011263 */
  mag_tape_interface('WIDOWS_ORPHANS','0');
--
  mag_tape_interface('STUDENT_LOANS','0');
  mag_tape_interface('TAX_CREDITS','0');
--
  mag_tape_interface('WEEK_53',' ');
  mag_tape_interface('TAXABLE_PAY','0');
--
/* 4011263
  mag_tape_interface('PENSIONER_INDICATOR',' ');
  mag_tape_interface('DIRECTOR_INDICATOR',' ');
 4011263 */
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',580);
--
--
  hr_utility.trace('Start is '||to_char(l_tab_index+2));
  hr_utility.trace('End is '||to_char(l_no_nis));
  l_param_index := 2;
  FOR l_index IN l_tab_index+2..l_tab_index+l_no_nis LOOP
    hr_utility.trace('Index is now '||to_char(l_index));
    mag_tape_interface('SCON'||TO_CHAR(l_param_index),scon_tab(l_index));
    mag_tape_interface('NI_CATEGORY_CODE'||
                                 TO_CHAR(l_param_index),category_tab(l_index));
    mag_tape_interface('TOTAL_CONTRIBUTIONS'||TO_CHAR(l_param_index)
                    ,total_contrib_tab(l_index));
    mag_tape_interface('EMPLOYEES_CONTRIBUTIONS'||
      TO_CHAR(l_param_index),employees_contrib_tab(l_index));
    mag_tape_interface('NI_ABLE_ET'|| TO_CHAR(l_param_index),
           ni_able_et_tab(l_index));
    mag_tape_interface('NI_ABLE_LEL'|| TO_CHAR(l_param_index),
                       ni_able_lel_tab(l_index));
    mag_tape_interface('NI_ABLE_UEL'|| TO_CHAR(l_param_index),
                       ni_able_uel_tab(l_index));
   -- l_ers_rebate := l_ers_rebate + employers_rebate_tab(l_index); --P35/P14 EOY 2003/2004
   -- l_ees_rebate := l_ees_rebate + employees_rebate_tab(l_index); --P35/P14 EOY 2003/2004
    l_param_index := l_param_index + 1;
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',590);
  END LOOP;
  p_mag_form_clear(l_param_index);
  -- mag_tape_interface('NI_ERS_REBATE',l_ers_rebate); --P35/P14 EOY 2003/2004
  -- mag_tape_interface('NIEES_REBATE',l_ees_rebate);  --P35/P14 EOY 2003/2004
  mag_tape_interface('ASSIGNMENT_MESSAGE', ' ');
  --
  -- g_tot_ers_rebate := g_tot_ers_rebate + l_ers_rebate; --P35/P14 EOY 2003/2004
  -- g_tot_ees_rebate := g_tot_ees_rebate + l_ees_rebate; --P35/P14 EOY 2003/2004
  --
  -- Running count of all employee records
  --
  g_tot_rec2_per := g_tot_rec2_per + 1;
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',595);
END;
-----------------------------------------------------------------------------
-- PROCEDURE:   get_parameters
-- DESCRIPTION: This procedure obtains all parameter values passed into this
--              process. The values are selected from an outside plsql table,
--              the positions of each parameter in that table is unknown
--              hence a loop is used.
-----------------------------------------------------------------------------
PROCEDURE get_parameters(p_permit_no         IN OUT nocopy VARCHAR2
                        ,p_eoy_mode          IN OUT nocopy VARCHAR2
                        ,p_tax_dist_ref      IN OUT nocopy VARCHAR2
                        ,p_tax_ref_no        IN OUT nocopy VARCHAR2
                        ,p_test_indicator    IN OUT nocopy VARCHAR2
                        --,p_urgent_marker     IN OUT nocopy VARCHAR2 4011263
                        ,p_unique_test_id    IN OUT nocopy VARCHAR2 -- 4011263
                        ,p_return_type       IN OUT nocopy VARCHAR2 -- 4011263
                        ,p_payroll_action_id IN OUT nocopy NUMBER) IS
--
l_count number := 0;
l_payroll_action_id VARCHAR2(81); -- Reqd for assertion.
--
-- Added for nocopy
ln_permit_no         VARCHAR2(12);
ln_eoy_mode          VARCHAR2(30);
ln_tax_dist_ref      VARCHAR2(3);
ln_tax_ref_no        VARCHAR2(10);
ln_test_indicator    VARCHAR2(1);
ln_unique_test_id    VARCHAR2(12); -- 4011263
ln_return_type       VARCHAR2(12); -- 4011263
-- ln_urgent_marker     VARCHAR2(1); 4011263
ln_payroll_action_id NUMBER(9);
--
cursor get_action_eoy_mode(c_payroll_action_id number) is
   select report_category
   from pay_payroll_actions
   where payroll_action_id = c_payroll_action_id;
--
BEGIN
  -- Added for nocopy
  ln_permit_no         := p_permit_no;
  ln_eoy_mode          := p_eoy_mode;
  ln_tax_dist_ref      := p_tax_dist_ref;
  ln_tax_ref_no        := p_tax_ref_no;
  ln_test_indicator    := p_test_indicator;
  ln_unique_test_id    := p_unique_test_id; -- 4011263
  ln_return_type       := p_return_type;    -- 4011263
--  ln_urgent_marker     := p_urgent_marker; 4011263
  ln_payroll_action_id := p_payroll_action_id;
  --
  -- Get the parameters passed to the module
  -- Default the EOY Mode to 'P'
  p_eoy_mode := 'P';
  --
  BEGIN
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',400);
    -- This loop is used to obtain all parameter values. The prerequisite to
    -- this functioning correctly is that rows are populated in the
    -- pay_mag_tape tables from position 1 onwards. When a row in the names
    -- table is not found, the loop exits by means of an exception.
    -- Also note that if a corresponding value is missing, the loop will exit.
    LOOP
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',405);
      l_count := l_count + 1;
      hr_utility.trace(to_char(l_count));
      hr_utility.trace('Name: '||pay_mag_tape.internal_prm_names(l_count));
      hr_utility.trace('Value: '||pay_mag_tape.internal_prm_values(l_count));
      IF pay_mag_tape.internal_prm_names(l_count) = 'TRANSFER_PAYROLL_ACTION_ID'
      THEN
        l_payroll_action_id := pay_mag_tape.internal_prm_values(l_count);
  --     elsif pay_mag_tape.internal_prm_names(l_count) = 'PERMIT' then
  --        p_permit_no := pay_mag_tape.internal_prm_values(l_count);
  --     elsif pay_mag_tape.internal_prm_names(l_count) = 'TAX_DISTRICT_REFERENCE' then
  --        p_tax_dist_ref := SUBSTR(pay_mag_tape.internal_prm_values(l_count),1,3);
  --        p_tax_ref_no   := LTRIM(SUBSTR(pay_mag_tape.internal_prm_values(l_count),4), '/');
      ELSIF pay_mag_tape.internal_prm_names(l_count) = 'TEST' THEN
        p_test_indicator := nvl(pay_mag_tape.internal_prm_values(l_count),'N');
      ELSIF pay_mag_tape.internal_prm_names(l_count) = 'UNIQUE_TEST_ID' THEN
        p_unique_test_id := nvl(pay_mag_tape.internal_prm_values(l_count),'N');
      ELSIF pay_mag_tape.internal_prm_names(l_count) = 'RETURN_TYPE' THEN
        p_return_type    := nvl(pay_mag_tape.internal_prm_values(l_count),'N');
/* Start 4011263
      ELSIF pay_mag_tape.internal_prm_names(l_count) = 'URGENT' THEN
        p_urgent_marker := nvl(pay_mag_tape.internal_prm_values(l_count),'N');
End 4011263 */
      END IF;
      --
    END LOOP;
    --
  EXCEPTION
    WHEN no_data_found THEN
      -- Use this exception to exit loop as no. of plsql tab items
      -- is not known beforehand. All values should be assigned.
      hr_utility.trace('No data Found from plsql table loop');
      NULL;
    WHEN value_error THEN
      hr_utility.trace(to_char(l_count));
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',413);
  END;
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',415);
  p_payroll_action_id := to_number(l_payroll_action_id);
  --
  -- Obtain EOY Mode from the Payroll Action ID.
  --
  OPEN get_action_eoy_mode(p_payroll_action_id);
  FETCH get_action_eoy_mode INTO p_eoy_mode;
  IF get_action_eoy_mode%notfound THEN
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',419);
    RAISE no_data_found; -- means no payroll action exists.
  END IF;
  CLOSE get_action_eoy_mode;
  --
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',420);
  --
  -- Added for nocopy
  EXCEPTION
  WHEN OTHERS THEN
    p_permit_no         := ln_permit_no;
    p_eoy_mode          := ln_eoy_mode;
    p_tax_dist_ref      := ln_tax_dist_ref;
    p_tax_ref_no        := ln_tax_ref_no;
    p_test_indicator    := ln_test_indicator;
    p_unique_test_id    := ln_unique_test_id; -- 4011263
    p_return_type       := ln_return_type;    -- 4011263
--    p_urgent_marker     := ln_urgent_marker; 4011263
    p_payroll_action_id := ln_payroll_action_id;

END get_parameters;
--
-- START HERE
--
PROCEDURE eoy_control IS
--
cursor get_errored_actions(c_payroll_action_id number) is
   select '1' from dual where exists
   (select action_status
   from   pay_assignment_actions
   where payroll_action_id = c_payroll_action_id
   and action_status = 'E');
--
-- Start of BUG 5671777-5
-- Changed start date of the EOY process to reflect start of the current tax year
-- so need to add 12 months to the start date.
--
CURSOR get_start_end_year(p_payroll_action_id NUMBER) IS
SELECT to_date('06/04/'||to_char(start_date,'YYYY'),'dd/mm/yyyy')
  -- add_months(to_date('06/04/'||to_char(start_date,'YYYY'),'dd/mm/yyyy'),12)
  -- End of BUG 5671777-5
         start_year,
    effective_date end_year
FROM pay_payroll_actions
WHERE payroll_action_id = p_payroll_action_id;
--
-- Record type 2 placeholders
l_effective_date            DATE;
l_error_text                VARCHAR2(240);
l_errored                   BOOLEAN := FALSE;
l_dummy                     VARCHAR2(1);
l_dummy_number              NUMBER;
--l_ers_rebate              NUMBER(9); --P35/P14 EOY 2003/2004
--l_ees_rebate              NUMBER(9); --P35/P14 EOY 2003/2004
l_asg_message               VARCHAR2(60);
--
-- General purpose variables
l_index             NUMBER(3) :=0;        -- General purpose loop counter
l_index2            NUMBER(3) :=0;        -- General purpose loop counter
l_plsql_index       NUMBER(3) :=0;        -- Index of the pl/sql tables
l_local_char        VARCHAR2(1);          -- Holds a char for testing
l_local_date        DATE;                 -- Used to hold a converted char
l_tot_refund        VARCHAR2(1):=NULL;    -- Set to 'R' if tax refund
l_type2_errors      NUMBER;
l_type1_errors      NUMBER;
l_char_errors       NUMBER;
l_loc_per           NUMBER;
l_mar_req_id        VARCHAR2(81) := '-1';         -- Chars, as passed into formula.
l_p35_req_id        VARCHAR2(81) := '-1';
--
BEGIN
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',0);
--
-- Start checking for record type 1
--
  IF fetch_new_header THEN
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',10);
    -- A Record type 1 is required
    IF NOT (header_cur%ISOPEN) THEN
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',20);
      -- Get all necessary parameters. The payroll action ID
      -- is validated.
      get_parameters(g_permit_no
        ,g_eoy_mode
        ,g_tax_dist_ref
        ,g_tax_ref_no
                    ,g_test_indicator
                    ,g_unique_test_id -- 4011263
                    ,g_return_type    -- 4011263
                    -- ,g_urgent_marker 4011263
                    ,g_payroll_action_id);
      hr_utility.trace('The passed in Mode is '||g_eoy_mode||'@');
      hr_utility.trace('The payroll action ID is '||g_payroll_action_id||'@');
      --
      g_old_tax_dist_ref := g_tax_dist_ref;
      g_old_tax_ref_no   := g_tax_ref_no;
      --
      OPEN get_start_end_year(g_payroll_action_id);
      FETCH get_start_end_year INTO g_start_year, g_end_year;
      CLOSE get_start_end_year;
      hr_utility.trace('After get_start_end_year, g_start_year='||
                         fnd_Date.date_to_displaydate(g_start_year));
      hr_utility.trace('g_end_year='||
                         fnd_Date.date_to_displaydate(g_end_year));
      --
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',25);
      --
      -- Check to see if the Payroll Action just retrieved has any
      -- errors. If not, check whether any assignment actions within the payroll
      -- action have errored. 1st error msg takes precedence.
      --
      l_error_text :=
          pay_gb_eoy_archive.get_arch_str(g_payroll_action_id,'X_PAYROLL_ACTION_MESSAGE');
      if l_error_text is null then
         open get_errored_actions(g_payroll_action_id);
         fetch get_errored_actions into l_dummy;
         if get_errored_actions%found then
            l_errored := TRUE;
            -- This will use the default error value in MAG_RECORD7
         end if;
         close get_errored_actions;
      else
         --
         -- There is a payroll action error, this will be picked up by
         -- the DBI call in MAG_RECORD7.
         --
         l_errored := TRUE;
      end if;
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',27);
      --
      -- First time in so clear the error type counts
      --
      pay_mag_tape.internal_prm_values(3) := 0;
      pay_mag_tape.internal_prm_values(4) := 0;
      pay_mag_tape.internal_prm_values(5) := 0;
      OPEN header_cur(g_payroll_action_id);
    END IF;
    IF NOT(permit_change) THEN
      -- Get record from EOY table as next record
      -- for record type 1 required
      hr_utility.trace('1 The global tax dist is '||g_old_tax_dist_ref);
      hr_utility.trace('1 The global tax ref  is '||g_old_tax_ref_no);
      hr_utility.trace('1 The global Permit is '||g_permit_no);
      hr_utility.trace('1 The global Payroll is '||g_payroll_id);
      --
      IF l_errored THEN
         -- Either the Payroll Action or an Assignment Action has Errored.
         hr_utility.trace('Errored Payroll Action: '||g_payroll_action_id);
         -- Call formula to error payroll.
         mag_tape_init(7);
         mag_tape_interface('L_PAYROLL_ACTION_ID',to_char(g_payroll_action_id));
         hr_utility.trace('after mag tape interface calls');
         pay_mag_tape.internal_cxt_names(1)  := 'NUMBER_OF_CONTEXT';
         pay_mag_tape.internal_cxt_values(1) := '2';
         pay_mag_tape.internal_cxt_names(2) := 'PAYROLL_ACTION_ID';
         pay_mag_tape.internal_cxt_values(2) := to_char(g_payroll_action_id);
         hr_utility.trace('after cxt calls: '||pay_mag_tape.internal_cxt_values(2));
      ELSE
         hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',28);
        -- No errors so fetch header info.
         FETCH header_cur INTO g_new_permit_no
           ,g_new_payroll_id
           ,g_tax_district_ref
           ,g_tax_ref_no
-- 4011263:           ,g_tax_district_name
           ,g_tax_year
           ,g_employers_name;
-- 4752018:           ,g_employers_address;
/* Start 4011263
           ,g_econ
           ,g_ssp_recovery
           ,g_smp_recovery
           ,g_smp_compensation
	   ,g_spp_recovery     --P35/P14 EOY 2003/2004
	   ,g_spp_compensation --P35/P14 EOY 2003/2004
	   ,g_sap_recovery     --P35/P14 EOY 2003/2004
	   ,g_sap_compensation;--P35/P14 EOY 2003/2004
         --
   End 4011263 */
         -- Fetch EDI sender ID and Payroll action's request_id
         --
         get_edi_sender_id(g_payroll_action_id);
/* Start 4011263
         -- Bug 2696015: Added for P14 EDI Enhancement 2003
         get_edi_submitter_no(g_payroll_action_id);
End 4011263 */
         --
         IF header_cur%NOTFOUND THEN
           -- No more records found so end of run
           hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',30);
           IF g_tot_rec2_per > 0 THEN
             -- If at least one record has been found then create
             -- a permit total
             create_record_type3;
           ELSE
             -- No records found for permit create dummy record
             mag_tape_init(6);
           END IF;
           fetch_new_header := FALSE;
           process_emps := FALSE;
           edi_process_emp_header  := FALSE;
           edi_process_ni_details  := FALSE;
           edi_process_emp_trailer := FALSE;
           sub_header       := FALSE;
           fin_run          := TRUE;
        /* A fetch of a new header is due to the first fetch or
           change of permit or payroll */
         ELSIF (g_tax_district_ref <> NVL(g_old_tax_dist_ref, g_tax_district_ref)
             OR g_tax_ref_no <> NVL(g_old_tax_ref_no, g_tax_ref_no)
             OR g_new_permit_no <> NVL(g_permit_no,g_new_permit_no)) THEN
           --
           -- The permit has changed so construct the record type 3
           --
           hr_utility.trace('2 Fetched tax dist is '||g_tax_district_ref);
           hr_utility.trace('2 Fetched tax ref  is '||g_tax_ref_no);
           hr_utility.trace('2 Fetched Permit is '||g_new_permit_no);
           hr_utility.trace('2 Fetched Payroll_id is '||g_new_payroll_id);
           create_record_type3;
           -- Save required values in globals
           g_old_tax_dist_ref  := g_tax_district_ref;
           g_old_tax_ref_no  := g_tax_ref_no;
           g_permit_no  := g_new_permit_no;
           g_payroll_id := g_new_payroll_id;
           permit_change := TRUE;
           -- Close the type 2 cursor so it will be re-opened with
           -- the new parameters
           CLOSE emps_cur;
           hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',40);
         ELSE
           -- No permit change so add new smp and smp values to totals
/* Start 4011263
           g_tot_ssp_rec  := g_tot_ssp_rec + g_ssp_recovery;
           g_tot_smp_rec  := g_tot_smp_rec + g_smp_recovery;
           g_tot_smp_comp := g_tot_smp_comp + g_smp_compensation;
           g_tot_spp_rec := g_tot_spp_rec + g_spp_recovery;      --P35/P14 EOY 2003/2004
	   g_tot_spp_comp := g_tot_spp_comp + g_spp_compensation;--P35/P14 EOY 2003/2004
	   g_tot_sap_rec := g_tot_sap_rec + g_sap_recovery;	 --P35/P14 EOY 2003/2004
	   g_tot_sap_comp := g_tot_sap_comp + g_sap_compensation;--P35/P14 EOY 2003/2004
   End 4011263 */
           hr_utility.trace('3 Fetched tax dist is '||g_tax_district_ref);
           hr_utility.trace('3 Fetched tax ref is '||g_tax_ref_no);
           hr_utility.trace('3 Fetched Permit is '||g_new_permit_no);
           hr_utility.trace('3 Fetched Payroll_id is '||g_new_payroll_id);
           IF g_new_payroll_id <> NVL(g_payroll_id,g_new_payroll_id) THEN
             -- The payroll_id has changed in permit_no
             g_payroll_id := g_new_payroll_id;
             -- Write the sub_header and then get the employee details
             create_sub_header;
             -- Close the type 2 cursor so it will be re-opened with
             -- the new parameters
             CLOSE emps_cur;
             fetch_new_header := FALSE;
             permit_change    := FALSE;
             IF g_eoy_mode IN ( 'F - P14 EDI', 'P - P14 EDI') THEN
                process_emps     := FALSE;
                edi_process_emp_header  := TRUE;
                edi_process_ni_details  := FALSE;
                edi_process_emp_trailer := FALSE;
             ELSE
                process_emps := TRUE;
                edi_process_emp_header  := FALSE;
                edi_process_ni_details  := FALSE;
                edi_process_emp_trailer := FALSE;
             END IF;
             hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',45);
           ELSE
             hr_utility.trace('No payroll or permit change ');
             hr_utility.trace('4 Fetched tax dist is '||g_tax_district_ref);
             hr_utility.trace('4 Fetched tax ref is '||g_tax_ref_no);
             hr_utility.trace('4 Fetched Permit is '||g_new_permit_no);
             hr_utility.trace('4 Fetched Payroll_id is '||g_new_payroll_id);
             -- Save required values in globals
             g_old_tax_dist_ref  := g_tax_district_ref;
             g_old_tax_ref_no  := g_tax_ref_no;
             g_permit_no  := g_new_permit_no;
             g_payroll_id := g_new_payroll_id;
             create_record_type1;
             fetch_new_header := FALSE;
             sub_header := TRUE;
             hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',50);
           END IF;
         END IF;
      END IF;  -- End of Errored payroll check.
    ELSE
      -- Change of permit so create a type 1 record from old values
      permit_change := FALSE;
      create_record_type1;
      fetch_new_header := FALSE;
      sub_header := TRUE;
      -- 1st record with this permit so set totals to 0
/* Start 4011263 */
      g_tot_ssp_rec  := 0; --g_ssp_recovery;
      g_tot_smp_rec  := 0; --g_smp_recovery;
      g_tot_spp_rec  := 0; --g_spp_recovery;	    --P35/P14 EOY 2003/2004
      g_tot_sap_rec  := 0; --g_sap_recovery;	    --P35/P14 EOY 2003/2004
--      g_tot_smp_comp := g_smp_compensation;
--      g_tot_spp_comp := g_spp_compensation; --P35/P14 EOY 2003/2004
--      g_tot_sap_comp := g_sap_compensation; --P35/P14 EOY 2003/2004
/* End 4011263 */

      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',60);
    END IF;
--
-- Check if sub-header required
--
  ELSIF sub_header THEN
    create_sub_header;
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',70);
    sub_header   := FALSE;
    IF g_eoy_mode IN ( 'F - P14 EDI', 'P - P14 EDI') THEN
       process_emps     := FALSE;
       edi_process_emp_header  := TRUE;
       edi_process_ni_details  := FALSE;
       edi_process_emp_trailer := FALSE;
    ELSE
       process_emps := TRUE;
       edi_process_emp_header  := FALSE;
       edi_process_ni_details  := FALSE;
       edi_process_emp_trailer := FALSE;
    END IF;
--
-- Check for a dummy record 2 needed when more than 4 Ni cats exist for
-- a single employee
--
  ELSIF process_dummy THEN
    -- A special record type 2
    -- More than 4 more NI categories exist for the employee
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',700);
    IF g_ni_total - g_last_ni > 4 THEN
      p_create_dummy(g_last_ni,4);
      g_last_ni := g_last_ni + 4;
    ELSE
      -- Less than 4 more NI categories exist for the employee
      p_create_dummy(g_last_ni,g_ni_total-g_last_ni);
      g_last_ni     := 0;
      g_ni_total    := 0;
      -- Reset the flags to continue processing any further employees
      process_emps  := TRUE;
      process_dummy := FALSE;
    END IF;
--
-- Check for processing record type 2
--
  ELSIF process_emps THEN
    -- Record type 2 required
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',100);
    hr_utility.trace('The emp tax dist is '||g_tax_district_ref);
    hr_utility.trace('The emp tax ref is '||g_tax_ref_no);
    hr_utility.trace('The emp permit_no is '||g_permit_no);
    hr_utility.trace('The emp payroll_id is '||to_char(g_payroll_id));
    IF NOT (emps_cur%ISOPEN) THEN
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',110);
      OPEN emps_cur(g_payroll_id, g_payroll_action_id);
    END IF;
    FETCH emps_cur INTO g_employee_number
      ,g_assignment_action_id
      ,g_last_name
      ,g_first_name
      ,g_middle_name
      ,g_title
      ,g_date_of_birth
      ,g_sex
      ,g_address_line1
      ,g_address_line2
      ,g_address_line3
      ,g_town_or_city
      ,g_country  -- 4011263
      ,g_postal_code
      ,g_tax_code
      ,g_w1_m1_indicator
      ,g_national_insurance_number
      ,g_ssp
      ,g_smp
      ,l_spp_adopt  --P35/P14 EOY 2003/2004
      ,l_spp_birth  --P35/P14 EOY 2003/2004
      ,g_sap 	    --P35/P14 EOY 2003/2004
      -- 4011263: ,g_gross_pay
      ,g_tax_paid
      ,g_tax_refund
      ,g_previous_taxable_pay
      ,g_previous_tax_paid
      ,g_start_of_emp
      ,g_termination_date
/* Start 4011263
      ,g_superannuation_paid
      ,g_superannuation_refund
End 4011263 */
      ,g_widows_and_orphans
      ,g_student_loans
      ,g_week_53_indicator
      ,g_taxable_pay
/* 4011263
      ,g_pension_indicator
  4011263 */
      ,g_director_indicator
      ,g_assignment_id
      ,l_effective_date
      ,l_asg_message
      ,g_ni_multi_asg_flag;
    --
    g_full_name := ltrim(rtrim(g_last_name)) ||', '|| ltrim(rtrim(g_first_name));
    --
    IF emps_cur%NOTFOUND THEN
--
--    End of record type 2
--
--    Set escape from this section
      hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',130);
      /* Each call of this package must return 1 record even */
      /* if its only a dummy formula call to do so           */
      mag_tape_init(6);
      fetch_new_header:= TRUE;
      process_emps    := FALSE;
      edi_process_emp_header  := FALSE;
      edi_process_ni_details  := FALSE;
      edi_process_emp_trailer := FALSE;
    ELSIF (nvl(g_ssp + g_smp +
               -- 4011263: g_gross_pay +
               g_tax_paid + g_previous_taxable_pay +
               g_previous_tax_paid + g_widows_and_orphans +
               g_student_loans + g_taxable_pay ,0) = 0)  THEN
-- 4011263: removed superannuation amount from above if condition
      /* The record fetched has all zero balances, no need on tape */
      /* exit to get next employee record */
      mag_tape_init(6);
      fetch_new_header:= FALSE;
      process_emps    := TRUE;
      edi_process_emp_header  := FALSE;
      edi_process_ni_details  := FALSE;
      edi_process_emp_trailer := FALSE;
    ELSE
--
--  Fetch all the ni contributions for each employee
--  in one hit.
--
      --
      -- Note SCON validation done in the formula.
      --
      l_index := 1;
      FOR emp_values_rec IN emp_values(g_assignment_action_id)
      LOOP
        scon_tab(l_index)                := emp_values_rec.scon;
        category_tab(l_index)            := emp_values_rec.cat_code;
        total_contrib_tab(l_index)       := emp_values_rec.tot_cont;
        employees_contrib_tab(l_index)   := emp_values_rec.emps_cont;
        ni_able_et_tab(l_index)          := emp_values_rec.ni_able_et;
        ni_able_lel_tab(l_index)         := emp_values_rec.ni_able_lel;
        ni_able_uel_tab(l_index)         := emp_values_rec.ni_able_uel;
        ni_able_uap_tab(l_index)         := emp_values_rec.ni_able_uap;  -- 8357870
	ni_able_auel_tab(l_index)         := emp_values_rec.ni_able_auel;  --- EOY 07/08
        employers_rebate_tab(l_index)    := emp_values_rec.employers_rebate;
        employees_rebate_tab(l_index)    := emp_values_rec.employees_rebate;
        --
        hr_utility.trace('looping for asg action: '||to_char(g_assignment_action_id));
        if (emp_values_rec.cat_code) = 'P' then
           null; -- 4752018: NIC Holiday will not be reported on P14 anymore
        else
           g_tot_contribs := g_tot_contribs + emp_values_rec.tot_cont;
        end if;  -- IF NI CODE = 'P'
        l_index := l_index + 1;
      END LOOP;
      hr_utility.trace('Fetched emp_values, now get NI for all CAT codes');
       hr_utility.trace('Total NI Cats index: '||to_char(l_index));
      /* Keep the total number of NI category codes for the employee */
      /* If > 5 then raise warning in the mag tape log file          */
      g_ni_total := l_index - 1;
      IF l_index < 5 THEN
        /* Even if no category codes exist the fields must be */
        /* defaulted and written to the mag tape.             */
        FOR l_plsql_index IN l_index..4 LOOP
          scon_tab(l_plsql_index)                := ' ';
          category_tab(l_plsql_index)            := ' ';
          total_contrib_tab(l_plsql_index)       := 0;
          employees_contrib_tab(l_plsql_index)   := 0;
          ni_able_et_tab(l_plsql_index)   := 0;
          ni_able_lel_tab(l_plsql_index)   := 0;
          ni_able_uel_tab(l_plsql_index)   := 0;
          ni_able_uap_tab(l_plsql_index)   := 0;    -- 8357870
	  ni_able_auel_tab(l_plsql_index)   := 0;   -- EOY 07/08
          employers_rebate_tab(l_plsql_index)   := 0;
          employees_rebate_tab(l_plsql_index) := 0;
        END LOOP;
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',150);
      END IF;
      hr_utility.trace('Total NI Cats index: '||to_char(l_index));
      /* Create a type 2 record */
   --   IF nvl(g_ssp + g_smp + g_gross_pay + g_tax_paid + g_previous_taxable_pay +
   --          g_previous_tax_paid + nvl(g_superannuation_paid,0) + g_widows_and_orphans +
   --     g_student_loans + g_taxable_pay ,0) > 0  THEN
        /* Set up the no of parameters and the formula professor */
        hr_utility.trace('Writing record type 2');
        mag_tape_init(2);
        /* Now create a record type 2 */
        mag_tape_interface('EOY_MODE',g_eoy_mode);
        mag_tape_interface('EMPLOYEE_NUMBER',NVL(g_employee_number,' '));
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',250);
        --
        -- Note name validation performed in formula.
        mag_tape_interface('LAST_NAME',NVL(g_last_name,' '));
        mag_tape_interface('FIRST_NAME',NVL(g_first_name,' '));
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',275);
        mag_tape_interface('MIDDLE_NAME',NVL(g_middle_name,'       '));
        mag_tape_interface('DATE_OF_BIRTH',g_date_of_birth);
        mag_tape_interface('GENDER',g_sex);
/* 4011263
    --  Order Address lines to push nulls to end, using g_full_address as
    --  a temporary variable.
        g_full_address := rpad(nvl(g_address_line1||g_address_line2||
                          g_address_line3||g_town_or_city,' '),108);
  --  Split into 4 and pass them to formula
        g_address_line1:=substr(g_full_address,1,27);
        g_address_line2:=substr(g_full_address,28,27);
        g_address_line3:=substr(g_full_address,55,27);
        g_town_or_city:=substr(g_full_address,82);
4011263 */
        mag_tape_interface('ADDRESS_LINE1',g_address_line1);
        mag_tape_interface('ADDRESS_LINE2',g_address_line2);
        mag_tape_interface('ADDRESS_LINE3',g_address_line3);
        mag_tape_interface('TOWN_OR_CITY',g_town_or_city);
        mag_tape_interface('COUNTRY',g_country);  -- 4011263
  --
        mag_tape_interface('POSTAL_CODE',g_postal_code);
        mag_tape_interface('TAX_CODE',g_tax_code);
        mag_tape_interface('W1_M1',g_w1_m1_indicator);
        mag_tape_interface('NI_NO',g_national_insurance_number);
  --
  --    Send the first record from the pl/sql tables to the mag tape
  --
        mag_tape_interface('SCON1',scon_tab(1));
        mag_tape_interface('NI_CATEGORY_CODE1',category_tab(1));
        mag_tape_interface('TOTAL_CONTRIBUTIONS1',total_contrib_tab(1));
        mag_tape_interface('EMPLOYEES_CONTRIBUTIONS1',
           employees_contrib_tab(1));
        mag_tape_interface('NI_ABLE_ET1', ni_able_et_tab(1));
        mag_tape_interface('NI_ABLE_LEL1', ni_able_lel_tab(1));
        mag_tape_interface('NI_ABLE_UEL1', ni_able_uel_tab(1));
        --l_ers_rebate := employers_rebate_tab(1); --P35/P14 EOY 2003/2004
        --l_ees_rebate := employees_rebate_tab(1); --P35/P14 EOY 2003/2004
        mag_tape_interface('SSP',g_ssp);
        mag_tape_interface('SMP',g_smp);
        g_spp := nvl(l_spp_birth,0) + nvl(l_spp_adopt,0); --P35/P14 EOY 2003/2004
	mag_tape_interface('SPP',g_spp); --P35/P14 EOY 2003/2004
        mag_tape_interface('SAP',g_sap); --P35/P14 EOY 2003/2004
        -- 4011263: mag_tape_interface('GROSS_PAY',g_gross_pay);
        mag_tape_interface('TAX_PAID',ABS(g_tax_paid));
        g_tot_tax := g_tot_tax + g_tax_paid;
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',280);
        --
        -- Tax Refund must be 'R' or blank. Formula validates this.
        --
        mag_tape_interface('TAX_REFUND',nvl(g_tax_refund,' '));
        mag_tape_interface('PREVIOUS_TAXABLE_PAY',
                g_previous_taxable_pay);
  --
        mag_tape_interface('PREVIOUS_TAX_PAID',
                  g_previous_tax_paid);
  --
        mag_tape_interface('DATE_OF_STARTING',g_start_of_emp);
        BEGIN
          IF g_termination_date IS NOT NULL THEN
            l_local_date := TO_DATE(g_termination_date,'DDMMYYYY');
          END IF;
        EXCEPTION
          WHEN value_error THEN
           g_termination_date := ' ';
            hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',300);
        END;
        mag_tape_interface('TERMINATION_DATE',NVL(g_termination_date,' '));
/* 4011263: Remove  superannuation from EOY
	--added nvl for bug fix 3614251
	mag_tape_interface('SUPERANNUATION',nvl(g_superannuation_paid,0));
        --
        -- Superannuation Refund must be 'R' or blank. Formula validates.
        --
        mag_tape_interface('SUPERANNUATION_REFUND',
                nvl(g_superannuation_refund,' '));
4011263 */
        mag_tape_interface('WIDOWS_ORPHANS',
                 g_widows_and_orphans);
  --    Added Student Loan
        mag_tape_interface('STUDENT_LOANS', g_student_loans);
        --
        -- Keep totals of Student Loans
        --
        g_tot_student_ln := g_tot_student_ln + g_student_loans;
        --
        -- Week 53 must be 3,4,6 or blank, formula validates.
        --
        mag_tape_interface('WEEK_53', nvl(g_week_53_indicator,' '));
        mag_tape_interface('TAXABLE_PAY',g_taxable_pay);
/* 4011263
        mag_tape_interface('PENSIONER_INDICATOR', nvl(g_pension_indicator,' '));
        mag_tape_interface('DIRECTOR_INDICATOR', nvl(g_director_indicator,' '));
   4011263 */
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',350);
  --
  --    Now send up to 3 of the remaining contribution records to mag tape
  --    If they do not exist they have been defaulted
  --
        FOR l_index IN 2..4 LOOP
          mag_tape_interface('SCON'||TO_CHAR(l_index),scon_tab(l_index));
          mag_tape_interface('NI_CATEGORY_CODE'||
                            TO_CHAR(l_index) ,category_tab(l_index));
          mag_tape_interface('TOTAL_CONTRIBUTIONS'||l_index
                   ,total_contrib_tab(l_index));
          mag_tape_interface('EMPLOYEES_CONTRIBUTIONS'||
        TO_CHAR(l_index), employees_contrib_tab(l_index));
          mag_tape_interface('NI_ABLE_ET'||
                    TO_CHAR(l_index), ni_able_et_tab(l_index));
          mag_tape_interface('NI_ABLE_LEL'||
                          TO_CHAR(l_index), ni_able_lel_tab(l_index));
          mag_tape_interface('NI_ABLE_UEL'||
                          TO_CHAR(l_index), ni_able_uel_tab(l_index));
   	 -- l_ers_rebate := l_ers_rebate + employers_rebate_tab(l_index); --P35/P14 EOY 2003/2004
         -- l_ees_rebate := l_ees_rebate + employees_rebate_tab(l_index); --P35/P14  EOY 2003/2004
          hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',360);
        END LOOP;
        --mag_tape_interface('NI_ERS_REBATE', l_ers_rebate); --P35/P14 EOY 2003/2004
        --mag_tape_interface('NIEES_REBATE', l_ees_rebate);  --P35/P14 EOY 2003/2004
        mag_tape_interface('ASSIGNMENT_MESSAGE', l_asg_message);
        --
        --g_tot_ers_rebate := g_tot_ers_rebate + l_ers_rebate; --P35/P14 EOY 2003/2004
        --g_tot_ees_rebate := g_tot_ees_rebate + l_ees_rebate; --P35/P14 EOY 2003/2004
        --
        -- Running count of all employee records
        --
        g_tot_rec2_per := g_tot_rec2_per + 1;
        -- Now check the number of NI categories found for this employee
        IF g_ni_total > 4 THEN
          hr_utility.trace('The employee is '||g_employee_number);
          hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',365);
    -- More than four so set flags for creation of dummy record
    process_emps := FALSE;
    process_dummy := TRUE;
    -- Index in PL/SQL tables set to the last record selected
    g_last_ni     := 4;
        END IF;
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',370);
  --
    END IF; /* End of create type 2 record */
  --
  -- If EOY mode is P14 EDI then write employee header and NI Details and employee
  -- trailer records instead of above Mag Tape type 2 record.
  ELSIF edi_process_emp_header THEN
     -- Need to process employee header record for EDI Process
     hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',100);
    hr_utility.trace('The emp tax dist is '||g_tax_district_ref);
    hr_utility.trace('The emp tax ref is '||g_tax_ref_no);
     hr_utility.trace('The emp permit_no is '||g_permit_no);
     hr_utility.trace('The emp payroll_id is '||to_char(g_payroll_id));
     --
     IF NOT (emps_cur%ISOPEN) THEN
       hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',110);
       OPEN emps_cur(g_payroll_id, g_payroll_action_id);
     END IF;
     --
     FETCH emps_cur INTO g_employee_number
          ,g_assignment_action_id
          ,g_last_name
          ,g_first_name
          ,g_middle_name
          ,g_title
          ,g_date_of_birth
          ,g_sex
          ,g_address_line1
          ,g_address_line2
          ,g_address_line3
          ,g_town_or_city
          ,g_country  -- 4011263
          ,g_postal_code
          ,g_tax_code
          ,g_w1_m1_indicator
          ,g_national_insurance_number
          ,g_ssp
          ,g_smp
          ,l_spp_adopt --P35/P14 EOY 2003/2004
	  ,l_spp_birth --P35/P14 EOY 2003/2004
	  ,g_sap       --P35/P14 EOY 2003/2004
          -- 4011263: ,g_gross_pay
          ,g_tax_paid
          ,g_tax_refund
          ,g_previous_taxable_pay
          ,g_previous_tax_paid
          ,g_start_of_emp
          ,g_termination_date
          -- 4011263: ,g_superannuation_paid
          -- 4011263: ,g_superannuation_refund
          ,g_widows_and_orphans
          ,g_student_loans
          ,g_week_53_indicator
          ,g_taxable_pay
/* 4011263
          ,g_pension_indicator
  4011263 */
          ,g_director_indicator
          ,g_assignment_id
          ,l_effective_date
          ,l_asg_message
          ,g_ni_multi_asg_flag;
     --
     g_full_name := ltrim(rtrim(g_last_name)) ||', '|| ltrim(rtrim(g_first_name));
     --
     IF emps_cur%NOTFOUND THEN
        -- End of employee details for EDI process
        -- Set escape from this section
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',130);
        -- Each call of this package must return 1 record even
        -- if its only a dummy formula call to do so
        mag_tape_init(6);
        fetch_new_header:= TRUE;
        edi_process_emp_header := FALSE;
     ELSE
        -- another employee found, increament the count
        g_tot_rec2_per := g_tot_rec2_per + 1;
        -- Update grand totals
        g_tot_tax := g_tot_tax + g_tax_paid;
        g_tot_student_ln := g_tot_student_ln + g_student_loans;
        -- Set up the no of parameters and the formula professor
        hr_utility.trace('Writing employee header');
        p14_edi_init(2);
        -- Now create employee header
        mag_tape_interface('EOY_MODE',g_eoy_mode);
        mag_tape_interface('EMPLOYEE_COUNT', nvl(g_tot_rec2_per,0));
        mag_tape_interface('EMPLOYEE_NUMBER',NVL(g_employee_number,' '));
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',250);
        --
        -- Note name validation performed in formula.
        mag_tape_interface('LAST_NAME',NVL(g_last_name,' '));
        mag_tape_interface('FIRST_NAME',NVL(g_first_name,' '));
        mag_tape_interface('MIDDLE_NAME',NVL(g_middle_name,' '));
--4011263: mag_tape_interface('TITLE',NVL(g_title,' '));
        hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',275);
        mag_tape_interface('GENDER',g_sex);
/* 4011263
        --  Order Address lines to push nulls to end, using g_full_address as
        --  a temporary variable.
        g_full_address := rpad(nvl(g_address_line1||g_address_line2||
                          g_address_line3||g_town_or_city,' '),108);
        --  Split into 4 and pass them to formula
        g_address_line1:=substr(g_full_address,1,27);
        g_address_line2:=substr(g_full_address,28,27);
        g_address_line3:=substr(g_full_address,55,27);
        g_town_or_city:=substr(g_full_address,82);
4011263 */
        mag_tape_interface('ADDRESS_LINE1', nvl(g_address_line1, ' '));
        mag_tape_interface('ADDRESS_LINE2', nvl(g_address_line2, ' '));
        mag_tape_interface('ADDRESS_LINE3', nvl(g_address_line3, ' '));
        mag_tape_interface('TOWN_OR_CITY', nvl(g_town_or_city, ' '));
        mag_tape_interface('COUNTRY', nvl(g_country, ' '));
        mag_tape_interface('POSTAL_CODE', nvl(g_postal_code, ' '));
        mag_tape_interface('NI_NO', nvl(g_national_insurance_number, ' '));
        mag_tape_interface('WEEK_53_INDICATOR', nvl(g_week_53_indicator, ' '));
/* 4011263
        mag_tape_interface('PENSION_INDICATOR', nvl(g_pension_indicator, ' '));
        mag_tape_interface('DIRECTOR_INDICATOR', nvl(g_director_indicator, ' '));
 4011263 */
        mag_tape_interface('ASSIGNMENT_MESSAGE',  nvl(l_asg_message, ' '));
        mag_tape_interface('FULL_NAME',NVL(g_full_name,' '));
        --
        hr_utility.trace('Employee Number='||g_employee_number);
        hr_utility.trace('full name='||g_first_name||' '||g_last_name);
        -- Fetch values for NI Details record
        g_edi_ni_cat_count := 0;
        g_edi_emp_ers_rebate := 0;
        g_edi_emp_ees_rebate := 0;
        g_rollup_ni_cat      := ' ';
        g_rollup_scon        := ' ';
        g_rollup_emp_contrib := 0;
        g_rollup_tot_contrib := 0;
        g_rollup_lel_ni_cat  := ' ';
        g_total_rollup_lel   := 0;
        g_emp_tot_lel        := 0;
        g_emp_tot_et         := 0;
        g_emp_tot_uap        := 0;  -- 8816832 EOY 09/10
        g_emp_tot_uel        := 0;
        g_emp_tot_ee_contrib := 0;
        g_emp_tot_ee_er_contrib := 0;
        --
        /* 8833756 begin - Added to identify agg assignments
           If for single assignments, NI Agg Flag is set wrongly, then for
           such assignments, rollup should not happen, and the validations
           inside PAY_GB_EDI_P14_NI_DETAILS should not be skipped, and
           hence g_ni_multi_asg_flag is set to 'N'.
        */
        if (g_ni_multi_asg_flag = 'Y') then
           hr_utility.trace('Inside g_ni_multi_asg_flag:'||g_ni_multi_asg_flag);
           hr_utility.trace('...g_assignment_id:'||g_assignment_id);
           hr_utility.trace('...g_start_year:'||g_start_year);
           hr_utility.trace('...g_end_year:'||g_end_year);
           hr_utility.trace('...g_tax_district_ref:'||g_tax_district_ref);
           hr_utility.trace('...g_tax_ref_no:'||g_tax_ref_no);
           if (get_assign_count(g_assignment_id,
                          g_start_year,
                          g_end_year ,
                          g_tax_district_ref ,
                          g_tax_ref_no ) = 0) then
                g_ni_multi_asg_flag := 'N';
            end if;
        end if;
        /* 8833756 - End of identify agg assignments */
        IF g_ni_multi_asg_flag = 'Y' THEN
           hr_utility.trace('Before get_rollup_ni_cat cursor.');
           OPEN get_rollup_ni_cat(g_assignment_action_id);
           FETCH get_rollup_ni_cat INTO g_rollup_scon, g_rollup_ni_cat;
           IF get_rollup_ni_cat%NOTFOUND THEN
               g_rollup_ni_cat      := ' ';
               g_rollup_scon        := ' ';
           END IF;
           CLOSE get_rollup_ni_cat;
           hr_utility.trace('After get_rollup_ni_cat cursor, g_rollup_ni_cat='||g_rollup_ni_cat);
           --
           hr_utility.trace('Before get_lel_rollup_ni_cat cursor.');
           OPEN get_lel_rollup_ni_cat(g_assignment_action_id);
           FETCH get_lel_rollup_ni_cat INTO g_rollup_lel_ni_cat;
           IF get_lel_rollup_ni_cat%NOTFOUND THEN
               g_rollup_lel_ni_cat      := ' ';
           END IF;
           CLOSE get_lel_rollup_ni_cat;
           hr_utility.trace('After get_lel_rollup_ni_cat cursor, g_rollup_lel_ni_cat='||g_rollup_lel_ni_cat);
           --
           hr_utility.trace('Before get_only_lel_total cursor.');
           OPEN get_only_lel_total(g_assignment_action_id);
           FETCH get_only_lel_total INTO g_total_rollup_lel;
           CLOSE get_only_lel_total;
		    -- For bug#7043405 begin
           IF g_total_rollup_lel = 0 AND g_rollup_lel_ni_cat IS NOT NULL THEN
             g_rollup_lel_ni_cat := NULL;
             hr_utility.trace('setting g_rollup_lel_ni_cat to NULL as g_total_rollup_lel is 0. ');
           END IF;
           -- For bug#7043405 end
           hr_utility.trace('After get_only_lel_total cursor, g_total_rollup_lel='||g_total_rollup_lel);
        END IF;
        --
        hr_utility.trace('Looping through emp_values cursor.');
        FOR emp_values_rec IN emp_values(g_assignment_action_id)
        LOOP
           hr_utility.trace('SCON='||emp_values_rec.scon);
           hr_utility.trace('CATE_CODE='||emp_values_rec.cat_code);
           hr_utility.trace('LEL='||emp_values_rec.ni_able_lel);
           hr_utility.trace('ET='||emp_values_rec.ni_able_et);
           hr_utility.trace('UEL='||emp_values_rec.ni_able_uel);
           hr_utility.trace('UAP='||emp_values_rec.ni_able_uap);  -- 8357870
	   hr_utility.trace('AUEL='||emp_values_rec.ni_able_auel);  -- EOY 07/08
           hr_utility.trace('TOT_CONT='||emp_values_rec.tot_cont);
           hr_utility.trace('EMPS_CONT='||emp_values_rec.emps_cont);
           scon_tab(g_edi_ni_cat_count)                := emp_values_rec.scon;
           category_tab(g_edi_ni_cat_count)            := emp_values_rec.cat_code;
           total_contrib_tab(g_edi_ni_cat_count)       := emp_values_rec.tot_cont;
           employees_contrib_tab(g_edi_ni_cat_count)   := emp_values_rec.emps_cont;
           ni_able_et_tab(g_edi_ni_cat_count)          := emp_values_rec.ni_able_et;
           ni_able_lel_tab(g_edi_ni_cat_count)         := emp_values_rec.ni_able_lel;
           ni_able_uel_tab(g_edi_ni_cat_count)         := emp_values_rec.ni_able_uel;
           ni_able_uap_tab(g_edi_ni_cat_count)         := emp_values_rec.ni_able_uap; -- 8357870
           ni_able_auel_tab(g_edi_ni_cat_count)        := emp_values_rec.ni_able_auel;   ---EOY  07/08
           employers_rebate_tab(g_edi_ni_cat_count)    := emp_values_rec.employers_rebate;
           employees_rebate_tab(g_edi_ni_cat_count)    := emp_values_rec.employees_rebate;
           --
           hr_utility.trace('looping for asg action: '||to_char(g_assignment_action_id));
           if (emp_values_rec.cat_code) = 'P' then
              null; -- 4752018: NIC Holiday will not be reported on P14 anymore
           else
              g_tot_contribs := g_tot_contribs + emp_values_rec.tot_cont;
           end if;  -- IF NI CODE = 'P'
           -- sum up ees and ers rebates for the employee
     g_edi_emp_ers_rebate := g_edi_emp_ers_rebate + emp_values_rec.employers_rebate;
           g_edi_emp_ees_rebate := g_edi_emp_ees_rebate + emp_values_rec.employees_rebate;
           IF g_ni_multi_asg_flag = 'Y' THEN
              --
              -- maintain total of employee's LEL/ET/UEL and EE Contributions
              --
              IF emp_values_rec.cat_code NOT IN ('X', 'C')  THEN
                 g_emp_tot_lel := g_emp_tot_lel + emp_values_rec.ni_able_lel;
                 g_emp_tot_et  := g_emp_tot_et  + emp_values_rec.ni_able_et ;
                 g_emp_tot_uap := g_emp_tot_uap + emp_values_rec.ni_able_uap; -- 8816832 EOY 09/10
                 g_emp_tot_uel := g_emp_tot_uel + emp_values_rec.ni_able_uel;
                 g_emp_tot_ee_contrib := g_emp_tot_ee_contrib
                                         + emp_values_rec.emps_cont;
                 g_emp_tot_ee_er_contrib := g_emp_tot_ee_er_contrib
                                         + emp_values_rec.tot_cont;
                 hr_utility.trace('g_emp_tot_lel='||g_emp_tot_lel);
                 hr_utility.trace('g_emp_tot_et='||g_emp_tot_et);
                 hr_utility.trace('g_emp_tot_uap='||g_emp_tot_uap); -- 8816832 EOY 09/10
                 hr_utility.trace('g_emp_tot_uel='||g_emp_tot_uel);
                 hr_utility.trace('g_emp_tot_ee_contrib='||g_emp_tot_ee_contrib);
                 hr_utility.trace('g_emp_tot_ee_er_contrib='||g_emp_tot_ee_er_contrib);
              END IF;
              -- Check whther ni figures need to roll into another cat
	      --EOY 07/08 Begin
              /*IF emp_values_rec.ni_able_lel = 0 AND
                 emp_values_rec.ni_able_et = 0 AND
                 emp_values_rec.ni_able_uel = 0 AND
                 emp_values_rec.cat_code in ('A', 'B', 'D', 'E', 'F', 'G', 'J', 'L', 'S') THEN   */

		 ---Changing the condition for Contribution Rollup
                 IF emp_values_rec.ni_able_uel = 0 AND
                 emp_values_rec.ni_able_auel <> 0 AND
                 emp_values_rec.tot_cont <> 0 AND
                 emp_values_rec.cat_code in ('A', 'B', 'D', 'E', 'F', 'G', 'J', 'L', 'S') THEN
               --EOY 07/08 End                   --
                 hr_utility.trace('Update rollup figures.');
                 --
                 g_rollup_tot_contrib := g_rollup_tot_contrib
                                        + emp_values_rec.tot_cont;
                 g_rollup_emp_contrib := g_rollup_emp_contrib
                                        + emp_values_rec.emps_cont;
                 --
                 hr_utility.trace('Rollup TOT_CONT='||g_rollup_tot_contrib);
                 hr_utility.trace('Rollup EMP_CONT='||g_rollup_emp_contrib);
              END IF;
              --
              -- Check whether this is the NI cat to rollup contrib figures into
              IF emp_values_rec.cat_code = g_rollup_ni_cat
                 AND emp_values_rec.scon = g_rollup_scon THEN
                 --
                 hr_utility.trace('TOT_CONT Before rollup='||total_contrib_tab(g_edi_ni_cat_count));
                 hr_utility.trace('EMP_CONT BEfore rollup='||employees_contrib_tab(g_edi_ni_cat_count));
                 hr_utility.trace('Roll in figures from other NI Cats.');
                 total_contrib_tab(g_edi_ni_cat_count) :=
                 total_contrib_tab(g_edi_ni_cat_count) + g_rollup_tot_contrib;
                 employees_contrib_tab(g_edi_ni_cat_count) :=
                 employees_contrib_tab(g_edi_ni_cat_count) + g_rollup_emp_contrib;
                 --
                 hr_utility.trace('TOT_CONT After rollup='||total_contrib_tab(g_edi_ni_cat_count));
                 hr_utility.trace('EMP_CONT After rollup='||employees_contrib_tab(g_edi_ni_cat_count));
              END IF;
              -- Check whether this is the NI Cat to rollup lel into
              IF emp_values_rec.cat_code = g_rollup_lel_ni_cat
                 AND g_total_rollup_lel > 0 THEN
                 --
                 hr_utility.trace('LEL before rollup='||ni_able_lel_tab(g_edi_ni_cat_count));
                 hr_utility.trace('Roll in LEL from other NI Cats.');
                 ni_able_lel_tab(g_edi_ni_cat_count) :=
                    ni_able_lel_tab(g_edi_ni_cat_count) + g_total_rollup_lel;
                 hr_utility.trace('LEL after rollup='||ni_able_lel_tab(g_edi_ni_cat_count));
              END IF;
              --
           END IF; -- g_ni_multi_asg_flag = 'Y'
           -- Inreament category count for the employee
           g_edi_ni_cat_count := g_edi_ni_cat_count + 1;
        END LOOP;
        -- Initialize index
        g_edi_ni_cat_index := 0;
        -- Sum up ees and ers rebates accross employees
        g_tot_ers_rebate := g_tot_ers_rebate + g_edi_emp_ers_rebate;
        g_tot_ees_rebate := g_tot_ees_rebate + g_edi_emp_ees_rebate;
        -- Set flags to write NI details for this employee if NI
        -- categories exist else write employee trailer in next run
        IF g_edi_ni_cat_count > 0 THEN
           edi_process_emp_header := FALSE;
           edi_process_ni_details := TRUE;
           edi_process_emp_trailer := FALSE;
        ELSE
           edi_process_emp_header := FALSE;
           edi_process_ni_details := FALSE;
           edi_process_emp_trailer := TRUE;
        END IF;
     END IF;   -- End of EDI employee header
  ELSIF edi_process_ni_details THEN
     -- Write NI details of the employee
     p14_edi_init(3);
     mag_tape_interface('EOY_MODE',g_eoy_mode);
     mag_tape_interface('NI_CATEGORY_CODE', category_tab(g_edi_ni_cat_index));
     mag_tape_interface('SCON', nvl(scon_tab(g_edi_ni_cat_index), ' '));
     mag_tape_interface('NI_ABLE_LEL', ni_able_lel_tab(g_edi_ni_cat_index));
     mag_tape_interface('NI_ABLE_ET', ni_able_et_tab(g_edi_ni_cat_index));
     mag_tape_interface('NI_ABLE_UEL', ni_able_uel_tab(g_edi_ni_cat_index));
     mag_tape_interface('NI_ABLE_AUEL', ni_able_auel_tab(g_edi_ni_cat_index));  ---EOY 07/08
     mag_tape_interface('TOTAL_CONTRIBUTIONS',total_contrib_tab(g_edi_ni_cat_index));
     mag_tape_interface('EMPLOYEE_CONTRIBUTIONS',
           employees_contrib_tab(g_edi_ni_cat_index));
     mag_tape_interface('GENDER', nvl(g_sex, ' '));
     mag_tape_interface('EMPLOYEE_NUMBER',NVL(g_employee_number,' '));
     mag_tape_interface('NI_CATEGORY_INDEX',NVL(to_char(g_edi_ni_cat_index+1),' '));
     mag_tape_interface('ROLLUP_NI_CAT',NVL(g_rollup_ni_cat,' '));
     mag_tape_interface('ROLLUP_NI_SCON',NVL(g_rollup_scon,' '));
     mag_tape_interface('ROLLUP_LEL_NI_CAT',NVL(g_rollup_lel_ni_cat,' '));
     mag_tape_interface('NI_MULTI_ASG_FLAG',NVL(g_ni_multi_asg_flag,' '));
     mag_tape_interface('DIRECTOR_INDICATOR', nvl(g_director_indicator, ' '));
     mag_tape_interface('FULL_NAME',NVL(g_full_name,' '));
     --
     -- 8357870 begin
     /* 8816832 EOY 09/10 Changed if condition
     -- if trunc(g_end_year) > trunc(l_ni_tax_year) then
     To support EOY validations for both 2008-09 and 2009-10 financial years, the below
     if structure is required. Later the if structure can be removed and the procedure
     call could be made unconditional. */
     if g_tax_year <> '2009' then
        mag_tape_interface('NI_ABLE_UAP', ni_able_uap_tab(g_edi_ni_cat_index));
     end if;
     -- 8357870 end
     g_edi_ni_Cat_index := g_edi_ni_cat_index + 1;
     --
     -- Check if all NI categories have been written then
     -- prepare to write employee trailer record
     IF g_edi_ni_cat_index > g_edi_ni_cat_count-1 THEN
           g_edi_ni_cat_index := 0;
           g_edi_ni_cat_count := 0;
           edi_process_emp_header  := FALSE;
           edi_process_ni_details := FALSE;
           edi_process_emp_trailer := TRUE;
    END IF; -- End of employee NI details
  ELSIF edi_process_emp_trailer THEN
     -- Write trailer record of the employee
     p14_edi_init(4);
     mag_tape_interface('EOY_MODE', g_eoy_mode);
     -- mag_tape_interface('NI_ERS_REBATE', g_edi_emp_ers_rebate); --P14 EDI 2003/2004
     -- mag_tape_interface('NIEES_REBATE', g_edi_emp_ees_rebate);  --P14 EDI 2003/2004
     mag_tape_interface('SSP', g_ssp);
     g_tot_ssp_rec := g_tot_ssp_rec + g_ssp; -- 4011263
     mag_tape_interface('SMP', g_smp);
     g_tot_smp_rec := g_tot_smp_rec + g_smp; -- 4011263
     g_spp := nvl(l_spp_birth,0) + nvl(l_spp_adopt,0); --P35/P14 EOY 2003/2004
     mag_tape_interface('SPP', g_spp);		       --P35/P14 EOY 2003/2004
     g_tot_spp_rec := g_tot_spp_rec + g_spp; -- 4011263
     mag_tape_interface('SAP', g_sap);		       --P35/P14 EOY 2003/2004
     g_tot_sap_rec := g_tot_sap_rec + g_sap; -- 4011263
     -- 4011263: mag_tape_interface('GROSS_PAY', g_gross_pay);
     mag_tape_interface('TAX_PAID', g_tax_paid);
     mag_tape_interface('TAX_REFUND', g_tax_refund);
     mag_tape_interface('PREVIOUS_TAXABLE_PAY', g_previous_taxable_pay);
     mag_tape_interface('PREVIOUS_TAX_PAID', g_previous_tax_paid);
/* 4011263: Remove superannuation from EOY
     --added nvl for bug fix 3614251
     mag_tape_interface('SUPERANNUATION', nvl(g_superannuation_paid,0));
     mag_tape_interface('SUPERANNUATION_REFUND', g_superannuation_refund);
4011263 */
     mag_tape_interface('WIDOWS_ORPHANS', g_widows_and_orphans);
     mag_tape_interface('STUDENT_LOANS', g_student_loans);
     mag_tape_interface('TAXABLE_PAY', g_taxable_pay);
     mag_tape_interface('DATE_OF_BIRTH', g_date_of_birth);
     mag_tape_interface('DATE_OF_STARTING', g_start_of_emp);
     -- Pass termination date to the formula only if it is in current tax year
     IF TO_DATE(g_termination_date,'DDMMYYYY') BETWEEN
        g_start_year and g_end_year THEN
        mag_tape_interface('TERMINATION_DATE', g_termination_date);
     ELSE
        mag_tape_interface('TERMINATION_DATE', ' ');
     END IF;
     mag_tape_interface('TAX_CODE', g_tax_code);
     mag_tape_interface('W1_M1', g_w1_m1_indicator);
     mag_tape_interface('EMPLOYEE_NUMBER', g_employee_number);
     mag_tape_interface('GENDER', g_sex);
     mag_tape_interface('ASSIGNMENT_ID', g_assignment_id);
     mag_tape_interface('FULL_NAME',NVL(g_full_name,' '));
     mag_tape_interface('TOT_NI_ABLE_LEL',NVL(g_emp_tot_lel,0));
     mag_tape_interface('TOT_NI_ABLE_ET',NVL(g_emp_tot_et,0));
     mag_tape_interface('TOT_NI_ABLE_UEL',NVL(g_emp_tot_uel,0));
     mag_tape_interface('TOT_EE_CONTRIB',NVL(g_emp_tot_ee_contrib,0));
     mag_tape_interface('TOT_EE_ER_CONTRIB',NVL(g_emp_tot_ee_er_contrib,0));
     mag_tape_interface('NI_NO', nvl(g_national_insurance_number, ' ')); -- 6281170
     -- 8816832 EOY 09/10 Changes, 2 additional parameters included
     mag_tape_interface('TOT_NI_ABLE_UAP',NVL(g_emp_tot_uap,0));
     mag_tape_interface('TAX_YEAR',g_tax_year);
     -- 8816832 EOY 09/10 Changes End
     edi_process_emp_header  := TRUE;
     edi_process_ni_details  := FALSE;
     edi_process_emp_trailer := FALSE;
  ELSIF fin_run THEN
    --
    -- Start the end of tape procedure.
    --
    --
    submit_recon_report(p_payroll_action_id => g_payroll_action_id,
                        p_p35_req_id     => l_p35_req_id);
    l_type2_errors := to_number(pay_mag_tape.internal_prm_values(4));
    l_type1_errors := to_number(pay_mag_tape.internal_prm_values(3));
    l_char_errors := to_number(pay_mag_tape.internal_prm_values(5));
    l_loc_per := to_number(g_tot_rec2)/200; -- Half percent.
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',600);
    --
    -- Check for type 1 and type 2 errors. Similar to MAG_RECORD5 checks.
    --
    if l_type1_errors > 0                       -- Type 1 errors
       or (to_number(g_tot_rec2) = 0)           -- No recs processed
       or (g_eoy_mode in ('F', 'P')
           AND ((l_type2_errors > 5 and l_type2_errors > l_loc_per)
                 or l_type2_errors > 200))             -- Too many type2s in Mag Tape
       or (g_eoy_mode in ('F','F - P14 EDI') and l_char_errors > 0) -- Full Mode with
                                                   -- Illegal chars.
    then
       -- error raised, do not submit reports.
       hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',602);
       NULL;
    else
       hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',605);
       -- No errors, so submit the reports.
       submit_reports(p_payroll_action_id => g_payroll_action_id,
                         p_eoy_mode       => g_eoy_mode,
                         p_mar_req_id     => l_mar_req_id);
    end if;
    --
    -- Write footer to the output report
    l_dummy_number := pay_gb_eoy_archive.write_output_footer;
    --
    hr_utility.trace('P35 Req ID: '||l_p35_req_id);
    hr_utility.trace('Writing record type 4');
    --
    IF g_eoy_mode in ('F - P14 EDI', 'P - P14 EDI') THEN
       p14_edi_init(6);
    ELSE
       mag_tape_init(5);
    END IF;
    mag_tape_interface('EOY_MODE',g_eoy_mode);
    mag_tape_interface('TOTAL_RECORDS',g_tot_rec2);
    mag_tape_interface('P35_REQUEST_ID',l_p35_req_id);
    mag_tape_interface('MAR_REQUEST_ID',l_mar_req_id);
    hr_utility.trace('The tot record is '||to_char(g_tot_rec2));
    IF g_eoy_mode NOT in ('F - P14 EDI', 'P - P14 EDI') THEN
       mag_tape_interface('END_OF_DATA','END OF DATA');
    END IF;
    hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',610);
    IF header_cur%ISOPEN THEN
      CLOSE header_cur;
    END IF;
    IF emps_cur%ISOPEN THEN
      CLOSE emps_cur;
    END IF;
  END IF;
  hr_utility.set_location('pay_gb_eoy_magtape.eoy_control',999);
END;
--
--------------------------------------------------------------------------
-- Function:    validate_input
-- Description: Validate the passed-in formula input, called from the
--              MAG_RECORD2 and MAG_RECORD1 formulae. This returns a
--              1 if invalid or 0 if valid; Boolean expressions are
--              incompatible with FF.
--              Also used by EDI processes to validate character set.
--------------------------------------------------------------------------
--
function validate_input(p_input_value    varchar2,
                        p_validate_mode  varchar2 default 'FULL_CHAR')
        return number is
--
l_valid             number := 0;
l_invalid_char      constant varchar2(1) := '~';  -- required for translate
l_char_chk          constant varchar2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
l_number_chk        constant varchar2(10) := '0123456789';
l_extra_name_chk    constant varchar2(7) := ''''||'- .'; -- Allowed in names
l_all_name_chars    varchar2(33);
l_translated_value  varchar2(200);  -- Required to output failing char.
l_all_extras_chk constant varchar2(10):= ''''||'/-,.&)( '; -- Full magtape set
l_all_allowed_chars varchar2(50);
l_alpha_numeric     varchar2(36);
l_extended_edi      constant varchar2(36) := '/-,.&)( !"%*;<>=';
l_paye_ref_chars    constant varchar2(26) := '.*-()&'''; -- Emplr PAYE Ref
l_mix_chars         constant varchar2(52) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
l_p14_extended_edi  constant varchar2(36) := ' .,-()/=!"%&*;<>''+:?';
l_p14_edi_surname   constant varchar2(36) := ' .,-()/&''';
l_p14_edi_forename  constant varchar2(36) := '-''';
l_p11d_edi          constant varchar2(26) := '/-,.''&)( ';
l_scon_fixed_value  number := 51 ;
l_scon_value       number := 0  ;
l_scon_mod_chk_string    constant varchar2(19) := 'ABCDEFHJKLMNPQRTWXY' ;
--For bug 7540858: Added space as a valid character
l_p45_46_first_name_chk2 constant varchar2(10) := '''.'||'- ';/*added for P45PT3*/
l_p45_46_title_chk       constant varchar2(10) := '''.'||'- ';     /*added for P45PT3*/
l_p45_46_postcode_chk    constant varchar2(10) := ' ';          /*added for P45PT3*/
l_p45_46_last_name	constant varchar2(10) := ''''||'- '; -- Bug 8439388
p_input_value_temp   varchar2(35) ;
--
BEGIN
--
  hr_utility.trace('Entering pay_gb_eoy_magetape.validate_input');
  hr_utility.trace('p_validate_mode='||p_validate_mode);
  hr_utility.trace('p_input_value='||p_input_value);
  --
  if p_validate_mode = 'FULL_EDI' then
    -- ensure characters exist in the EDI character set
    l_translated_value :=
      translate(p_input_value,
                l_invalid_char||l_char_chk||l_number_chk||l_extended_edi,
                l_invalid_char);
    --
    if l_translated_value is not null then
      hr_utility.trace('Invalid chars found: '||l_translated_value);
      l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
    --
  elsif p_validate_mode = 'EDI_SURNAME' then
    -- ensure characters exist in the EDI character set
    -- Surname can additionally contain apostrophe
    l_translated_value :=
      translate(p_input_value,
                l_invalid_char||l_char_chk||l_number_chk||l_extended_edi||'''',
                l_invalid_char);
    --
    if l_translated_value is not null then
      hr_utility.trace('Invalid chars found: '||l_translated_value);
      l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
    --
  elsif p_validate_mode = 'NUMBER' then
    --
    -- Ensure that the input value passed in is a number
    --
    l_translated_value := translate(p_input_value,
                                    l_invalid_char||l_number_chk,
                                    l_invalid_char);
    --
    if l_translated_value is not null then
      hr_utility.trace('Invalid chars found: '||l_translated_value);
      l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
  --
  elsif p_validate_mode = 'NUMBER_1' then
    --
    -- Ensure that the input value passed in is a number
    --
    -- Remove leading minus sign if present.
    --
    if substr(p_input_value,1,1) = '-' then
       p_input_value_temp := substr(p_input_value,2) ;
    end if ;
    l_translated_value := translate(p_input_value_temp,
                                    l_invalid_char||l_number_chk||'.',
                                    l_invalid_char);
    --
    if l_translated_value is not null then
      hr_utility.trace('Invalid chars found: '||l_translated_value);
      l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
  elsif p_validate_mode = 'CHAR' then
    --
    -- Ensure that the input value passed in is in the range A-Z
    --
    l_translated_value := translate(p_input_value,
                                    l_invalid_char||l_char_chk,
                                    l_invalid_char);
    if l_translated_value is not null then
       hr_utility.trace('Invalid chars found: '||l_translated_value);
       l_valid := 1;
    else
       l_valid := 0;
    end if;
  --
  elsif p_validate_mode = 'ALPHA_NUM' then
    --
    -- Ensure that the input value passed in is A-Z or 0-9
    --
    l_alpha_numeric := l_char_chk||l_number_chk;
    l_translated_value := translate(p_input_value,
                                    l_invalid_char||l_alpha_numeric,
                                    l_invalid_char);
    --
    if l_translated_value is not null then
       hr_utility.trace('Invalid chars found: '||l_translated_value);
       l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
  --
  elsif p_validate_mode = 'MIXED_CHAR_ALPHA_NUM' then
    --
    -- Ensure that the input value passed in is A-Z or a-z or 0-9
    --
    l_translated_value := translate(p_input_value,
                                    l_invalid_char||l_mix_chars||l_number_chk,
                                    l_invalid_char);
    --
    if l_translated_value is not null then
       hr_utility.trace('Invalid chars found: '||l_translated_value);
       l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
  --
  elsif p_validate_mode = 'SCON' or p_validate_mode = 'ECON' then
    --
    -- The first character of SCON must be 'S', the first char of
    -- ECON must be 'E'. The following 7 characters must be numeric,
    -- and the final character must be a
    -- letter. Note 2 different error codes must be returned denoting
    -- whether the scon or econ is empty or invalid.
    -- The value passed in should be 9 characters.
    --
    if ltrim(p_input_value) is null then
      l_valid := 1;
    elsif substr(p_input_value,1,1) <> substr(p_validate_mode,1,1)
               or length(p_input_value) <> 9 then
      --
      l_valid := 2;
    else
      if translate(substr(p_input_value,2,7),l_invalid_char||l_number_chk,
                   l_invalid_char)
                   is not null
      then
        l_valid := 2;
      else
        if instr(l_char_chk,substr(p_input_value,9,1)) = 0 then
           l_valid := 2;
        else
           l_valid := 0; -- All checks done, c.o. number is valid at this point
        end if;

	if p_validate_mode = 'SCON'  then
	      if not(substr(p_input_value,2,1) in ('0','1','2','4','6','8'))  then
		        l_valid := 2 ;
	      end if;

              l_scon_value := l_scon_fixed_value ;
              for j in 2..(length(p_input_value) -1 ) loop
                    l_scon_value := l_scon_value + (to_number( substr(p_input_value,j,1) ))*(8+2-j) ;
              end loop;

              if substr( l_scon_mod_chk_string, mod(l_scon_value,19)+1, 1)<> substr(p_input_value,9,1) then
			l_valid := 2;
	      end if;
        end if;

      end if;
    end if;
  --
  elsif p_validate_mode = 'NAME' then
    --
    -- For All names,  extra characters are allowed
    -- for all but the first character, which must be A-Z.
    -- Return a 1 if an Invalid character, or a 2 if an Illegal one.
    --
    l_all_name_chars := l_char_chk||l_extra_name_chk;
    l_all_allowed_chars := l_char_chk||l_number_chk||l_all_extras_chk;
    --
    if not substr(p_input_value,1,1)  between 'A' and 'Z' then
       --
       -- First char invalid
       --
       hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
       l_valid := 1;
    else
       l_translated_value :=
            translate(p_input_value,l_invalid_char||l_all_name_chars,
                      l_invalid_char);
       if l_translated_value is not null then
          hr_utility.trace('Invalid chars found: '||l_translated_value);
          l_valid := 1;
          --
          -- Now check for Illegal chars
          --
          l_translated_value :=
             translate(p_input_value,
                       l_invalid_char||l_all_allowed_chars,
                       l_invalid_char);
          if l_translated_value is not null then
             hr_utility.trace('Illegal chars found: '||l_translated_value);
             l_valid := 2;
          end if;
       else
          l_valid := 0;
       end if;
    --
    end if;
    --
    -- This mode is the default
    --
  elsif p_validate_mode = 'FULL_CHAR' then
    --
    -- Check all characters in the allowable set
    --
    l_all_allowed_chars := l_char_chk||l_number_chk||l_all_extras_chk;
    --
    l_translated_value :=
         translate(p_input_value,l_invalid_char||l_all_allowed_chars,
         l_invalid_char);
    if l_translated_value is not null then
       hr_utility.trace('Invalid chars found: '||l_translated_value);
       l_valid := 1;
    else
       l_valid := 0;
    end if;
    --
  elsif p_validate_mode = 'EDI_NAME' then
    --
    -- Check for Valid First Char
    --
    if not substr(p_input_value,1,1)  between 'A' and 'Z' then
        --
        -- First char invalid
        --
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
    else
    -- ensure characters exist in the EDI character set
    -- Surname can additionally contain apostrophe
       l_translated_value :=
           translate(p_input_value,l_invalid_char||l_char_chk||l_number_chk||l_extended_edi||'''',
                l_invalid_char);

       if l_translated_value is not null then
          hr_utility.trace('Invalid chars found: '||l_translated_value);
          l_valid := 1; -- Not valid
       else
          l_valid := 0; -- Valid
       end if;
    end if;
  elsif p_validate_mode = 'PAYE_REF' then

       l_translated_value := translate(p_input_value,
                             l_invalid_char||l_mix_chars||l_number_chk||l_paye_ref_chars,
                             l_invalid_char);
       if l_translated_value is not null then
          hr_utility.trace('Invalid chars found: '||l_translated_value);
          l_valid := 1; -- Not valid
       else
          l_valid := 0; -- Valid
       end if;
  elsif p_validate_mode = 'P14_FULL_EDI' then
    -- ensure characters exist in the EDI character set
    l_translated_value :=
      translate(p_input_value,
                l_invalid_char||l_mix_chars||l_number_chk||l_p14_extended_edi,
                l_invalid_char);
    --
    if l_translated_value is not null then
      hr_utility.trace('Invalid chars found: '||l_translated_value);
      l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
    --
  elsif p_validate_mode = 'P14_EDI_SURNAME' then
    --
    -- Check for Valid First Char
    --
    if not (substr(p_input_value,1,1)  between 'A' and 'Z'
            or substr(p_input_value,1,1)  between 'a' and 'z') then
        --
        -- First char invalid
        --
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
    else
    -- ensure characters exist in the EDI character set
    -- Surname can additionally contain apostrophe
       l_translated_value :=
           translate(p_input_value,
                l_invalid_char||l_mix_chars||l_number_chk||l_p14_edi_surname,
                l_invalid_char);

       if l_translated_value is not null then
          hr_utility.trace('Invalid chars found: '||l_translated_value);
          l_valid := 1; -- Not valid
       else
          l_valid := 0; -- Valid
       end if;
    end if;
    --
  elsif p_validate_mode = 'P14_EDI_FORENAME' then
    --
    -- Check for Valid First Char
    --
    if not (substr(p_input_value,1,1)  between 'A' and 'Z'
            or substr(p_input_value,1,1)  between 'a' and 'z') then
        --
        -- First char invalid
        --
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
    else
    -- ensure characters exist in the EDI character set
    -- Surname can additionally contain apostrophe
       l_translated_value :=
           translate(p_input_value,
                l_invalid_char||l_mix_chars||l_p14_edi_forename,
                l_invalid_char);

       if l_translated_value is not null then
          hr_utility.trace('Invalid chars found: '||l_translated_value);
          l_valid := 1; -- Not valid
       else
          l_valid := 0; -- Valid
       end if;
    end if;
    --
  elsif p_validate_mode = 'P14_EDI_ADDRESS' then
    --
    -- Check for Valid First Char
    --
     /* Bug start 8338575 Commented the first character validation for address lines */
    /*if not (substr(p_input_value,1,1)  between 'A' and 'Z'
            or substr(p_input_value,1,1)  between 'a' and 'z'
            or substr(p_input_value,1,1)  between '0' and '9') then
        --
        -- First char invalid
        --
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
    else*/
    -- ensure characters exist in the EDI character set
    -- Surname can additionally contain apostrophe
       l_translated_value :=
           translate(p_input_value,
                l_invalid_char||l_mix_chars||l_number_chk||l_p14_extended_edi,
                l_invalid_char);

       if l_translated_value is not null then
          hr_utility.trace('Invalid chars found: '||l_translated_value);
          l_valid := 1; -- Not valid
       else
          l_valid := 0; -- Valid
       end if;
    -- end if;
    --
  --
  elsif p_validate_mode = 'P11D_EDI' then
  --
    l_translated_value :=
    translate(p_input_value,
                l_invalid_char||l_char_chk||l_number_chk||l_p11d_edi||'''',
                l_invalid_char);
    --
    if l_translated_value is not null then
      hr_utility.trace('Invalid chars found: '||l_translated_value);
      l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
  --
  /*addition for P45PT3/P46 starts. Bug 6345375*/
  elsif p_validate_mode = 'P45_46_FIRST_NAME' then
     if ( not substr(p_input_value,1,1)  between 'A' and 'Z'  and
          not substr(p_input_value,1,1)  between 'a' and 'z' ) then
        --
        -- First char invalid
        --
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
     else
         l_translated_value :=
         translate(p_input_value,
                l_invalid_char||l_mix_chars||l_p45_46_first_name_chk2,
                l_invalid_char);

         if l_translated_value is not null then
            hr_utility.trace('Invalid chars found: '||l_translated_value);
            l_valid := 1; -- Not valid
         else
            l_valid := 0; -- Valid
         end if;
      end if ;
  --
    elsif p_validate_mode = 'P45_46_TITLE' then
     if ( not substr(p_input_value,1,1)  between 'A' and 'Z'  and
          not substr(p_input_value,1,1)  between 'a' and 'z' ) then
        --
        -- First char invalid
        --
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
     else
         l_translated_value :=
         translate(p_input_value,
                l_invalid_char||l_mix_chars||l_p45_46_title_chk,
                l_invalid_char);

         if l_translated_value is not null then
            hr_utility.trace('Invalid chars found: '||l_translated_value);
            l_valid := 1; -- Not valid
         else
            l_valid := 0; -- Valid
         end if;
      end if ;
  --
    elsif p_validate_mode = 'P45_46_POSTCODE' then
    --
    -- Ensure that the input value passed in is A-Z or a-z or 0-9 or spaces
    --
    l_translated_value := translate(p_input_value,
                                    l_invalid_char||l_mix_chars||l_number_chk||l_p45_46_postcode_chk,
                                    l_invalid_char);
    --
    if l_translated_value is not null then
       hr_utility.trace('Invalid chars found: '||l_translated_value);
       l_valid := 1; -- Not valid
    else
      l_valid := 0; -- Valid
    end if;
  --
  elsif p_validate_mode = 'P45_46_LAST_NAME' then
     if ( not substr(p_input_value,1,1)  between 'A' and 'Z'  and
          not substr(p_input_value,1,1)  between 'a' and 'z' ) then
        --
        -- First char invalid
        --
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
     else
        l_translated_value :=
        translate(p_input_value,
                l_invalid_char||l_mix_chars||l_p45_46_last_name,
                l_invalid_char);

        if l_translated_value is not null then
           hr_utility.trace('Invalid chars found: '||l_translated_value);
           l_valid := 1; -- Not valid
        else
           l_valid := 0; -- Valid
        end if;
     end if;
  /*addition for P45PT3/P46 ends. Bug 6345375*/
  --

  --Bug 8986543: Added for P46 Car EDI V3
  elsif p_validate_mode = 'P46_CAR_TIT_N_FSTNM' then
     -- Check for Valid First Char
     if not substr(p_input_value,1,1)  between 'A' and 'Z' then
        -- First char invalid
        hr_utility.trace('Invalid first char: '||substr(p_input_value,1,1));
        l_valid := 2;
    else
    -- ensure characters exist in the EDI character set
       l_translated_value :=
           translate(p_input_value,l_invalid_char||l_char_chk||l_number_chk||l_extended_edi,
                l_invalid_char);

       if l_translated_value is not null then
          hr_utility.trace('Invalid chars found: '||l_translated_value);
          l_valid := 1; -- Not valid
       else
          l_valid := 0; -- Valid
       end if;
    end if;

  else
    --
    -- Invalid validate mode used.
    --
    hr_utility.trace('Invalid validate mode used: '||p_validate_mode);
    --
  end if;
  --
  return l_valid;
end validate_input;

---------------------------------------------------------------
-- Function: validate_tax_code                               --
-- Description: Used to validate tax codes by End Of Year    --
--              Calls hr_gb_utility.tax_code_validate but    --
--              when no error is found it will return ' '    --
--              instead of Null so that fast formulae can    --
--              handle it.                                   --
---------------------------------------------------------------
FUNCTION validate_tax_code(p_tax_code          in varchar2,
                            p_effective_date    in date,
                            p_assignment_id     in number)
RETURN VARCHAR2 IS
l_return_value VARCHAR2(250) := NULL;
BEGIN
   --
--   hr_utility.trace_on(null, 'RMEOYVTC');
   hr_utility.trace('Entering pay_gb_eoy_magtape.validate_tax_code.');
   hr_utility.trace('p_tax_code = '|| p_tax_code);
   hr_utility.trace('p_effective_date ='|| fnd_date.date_to_displaydate(p_effective_date));
   hr_utility.trace('p_assignment_id = '||p_assignment_id);
   l_return_value := hr_gb_utility.tax_code_validate(p_tax_code => p_tax_code,
                                          p_effective_date => p_effective_date,
                                          p_assignment_id => p_assignment_id);
   --
   hr_utility.trace('validate_tax_code: l_return_value='||l_return_value);
   IF l_return_value IS NULL THEN
       l_return_value := ' ';
   END IF;
   --
--   hr_utility.trace_off;
   RETURN l_return_value;
END validate_tax_code;

/********** added validate_tax_code_yrfil .... Abhgangu******/

FUNCTION validate_tax_code_yrfil(c_assignment_action_id     in number,
                            p_tax_code          in varchar2,
                            p_effective_date    in date)
return VARCHAR2 IS
l_return_value VARCHAR2(250) := NULL;
CURSOR csr_ass_id
is
select
  assignment_id
from pay_assignment_actions
where assignment_action_id = c_assignment_action_id;

l_assignment_id     NUMBER;

BEGIN
OPEN csr_ass_id;
FETCH csr_ass_id INTO l_assignment_id;
CLOSE csr_ass_id;

l_return_value := validate_tax_code(p_tax_code => p_tax_code,
                                    p_effective_date => p_effective_date,
                                    p_assignment_id => l_assignment_id);
   --
   hr_utility.trace('validate_tax_code: l_return_value='||l_return_value);
return l_return_value;
END validate_tax_code_yrfil;


FUNCTION get_payroll_version
RETURN VARCHAR2
IS
cursor csr_get_version
is
select ver.version from
ad_file_versions ver, ad_files f
where f.file_id  =  ver.file_id
and   f.filename = 'pygbffedi.hdt'
order by ver.file_version_id desc;

l_version VARCHAR2(35);
BEGIN
  open csr_get_version;
  fetch csr_get_version into l_version;
  if csr_get_version%notfound then
    l_version := ' ';
  end if;
  close csr_get_version;
  return l_version;
END get_payroll_version;

END pay_gb_eoy_magtape;

/
