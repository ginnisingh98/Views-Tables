--------------------------------------------------------
--  DDL for Package Body PAY_IE_P45_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_P45_ARCHIVE" AS
/* $Header: pyiep45.pkb 120.34.12010000.5 2009/12/09 08:54:48 knadhan ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE P45 Archive Package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+------------------------------
**  05 APR 2002 abhaduri  N/A        Created
**  10 JUN 2002 viviswan  2268282  XML Report generator
**                                 procedure added.
**  14 JUN 2002 Kavenkat           Modified the address information fields
**  09-JUL-2002 Kavenkat  2448728  Passed on the prepayment assignment action id
**                        2450336  to pay_ie_p45_archive.process_balance to archive
**                                 the balance 'Total Pay'.
**  10-JUL-2002 viviswan  2452564  Fixed EMEA BALANCE DEFINITION context getting
**                        2450279  archived for each chunk created by the PYUGEN
**                                 process.
**  12-JUL-2002 viviswan           Modified logic for setting Non-Cumm Flag
**                                 depending on Calculation Options
**  17-JUL-2002 viviswan  2466382  open cursor csr_check_def_exists_info closed
**  18-JUL-2002 viviswan  2466773  Total Pay to be claculated as IE Taxabale Pay_YTD
**                                 value and not Total Pay_PAYMENT.
**                                 Correctd Date format. Added additional joins
**                                 for XML Report Query.
**  19-JUL-2002 viviswan  2468773  Moved the EMEA BALANCE DEFINITION archive code
**                                 from archinit to range_cursor to avoid the same
**                                 context getting archived multiple times.
**  08-AUG-2002 viviswan  2452531  Modified the logic for archiving EMEA PAYROLL INFO
**                        2499841  context for XML Reporting
**                                 Modified to archive the RUN values in case of
**                                 Supplementary Run
**  09-AUG-2002 gbutler     11.5.8 Performance fix - added ORDERED hint
**                                 to csr_prepaid_assignments in action_creation
**                                 to resolve merge cartesian join in NOT EXISTS
**                                 subquery
**  29-OCT-2002 smrobins  2567139  Mutliplied perion_num by pay_periods per
**                                 period, where pay_period_per_period
**                                 attributed to associated payroll is
**                                 greater than 1. Also added mid period
**                                 functionality to derive mid period
**                                 leaver.
**  05-NOV-2002 smrobins           Changes period_num cursor to identify
**                                 assignment uniquely by effective start and
**                                 effective end dates
**  05-DEC-2002 viviswan  2643489  Performance changes and nocopy changes.
**  20-DEC-2002 smrobins           Changes to deriving weeks at class A
**                                 following changes to prsi balance
**                                 structure
**  15-MAY-2003 nsugavan  2943335  Changed PROCEDURE setup_standard_balance_table
**                                 to archive balance, IE Taxable Social Benefit
**                                 instead of balance, IE Benefit Amount
**                                 Also, commented the cursor cur_cal_option
**                                 and used IE Taxable Social Benefit balance value
**                                 instead to check presence of benefit amount.
**  12-AUG-2003 npershad 3079945   Changed the cursor csr_iea_weeks
**                                 to derive correct insurable weeks at class A
**  12-SEP-2003 npershad 3079945   Commented cusor crs_iea_weeks and added
**                                 call to pay_balance_pkg.get_value to derive
**                                 correct insurable weeks at class A in cursor
**                                 Cur_Act_Contexts
**  07-APR-2004 ssekhar  3436737   Added code to support K and M Employee and
**                                 Employer figures when a severance payment
**                                 exists
**  12-APR-2004 npershad 3567562   Modified the cursors csr_get_org_tax_address, csr_payroll_ifo
**                                 to restrict the details fetched based on the PAYE Reference.
**				   Added a new procedure get_paye_reference to get the PAYE reference
**                                 attributed to payrolls in a consolidation set.
**  07-JUN-2004 ssekhar  3669639   Changed the code so that l_prsi_cat is now
**                                 previous classes concatenated with K or M
**  28-JUN-2004 ssekhar  3669639   Changed the space between the classes so that
**                                 the display is uniform
**  24-AUG-2004 alikhar  3817846   Changed the cursor cur_child_pay_action to get the
**			 115.26	   correct maximum assignment action id
**  05-OCT-2004 aashokan 115.27    Fixed Case issue with cursor cur_defined_balance
**  06-NOV-2004 aashokan 115.28    Bug 3986018 - Added nvl in get_bal_arch_value function
**				   Bug 3991416 - Added period,frequency and date
**					         earned check to fetch single record
**  06-NOV-2004 npershad 115.29    Bug 3986250 - Modified the cursor Cur_Act_Contexts
**                                 to report correct total insurable weeks for class or subclass 'A'.
**  12-NOV-2004 Kthampan 115.30    Bug 4001524 - Pass g_archive_end_date to the cursor
**                                 cur_child_pay_action instead of the effective_date (session date)
**                                 to report correct total insurable weeks for class or subclass 'A'.
**  17-NOV-2004 alogue   115.31    Bug 4011305 - Added hints to csr_prepaid_assignments in
**                                 action_creation to force use of optimum plan.
**  20-NOV-2004 aashokan 115.32    Bug 4016508 - Tax credit and cut off to be 0 if tax basis is
**                                 emergency or emergency no pps.
**  22-NOV-2004 KThampan 115.33    Bug 4001524 - Modified cursor csr_prepaid_assignments to
**                                 use archive start date and archive end date
**  09-DEC-2004 aashokan 115.34    Bug 4050372 - Added new cursor to fetch tax basis on termination
**                                 date
**  10-jan-2005 npershad 115.35    Bug 4108423 - Modified the cursor Cur_Act_Contexts
**                                 to report correct total insurable weeks for class or subclass 'A'.
**  21-feb-2005 aashokan 115.36    Bug 4193738 - Modified cursor csr_prepaid_assignments to fetch only those
**				   records for which pre payment is run between a given period.
**  28-feb-2005 aashokan 115.37    Bug 4208273 - Modified subquery of cursor csr_prepaid_assignments
**  28-feb-2005 aashokan 115.38    Added act2.action_status='C' in subquery of cursor csr_prepaid_assignments
**  28-APR-2005 rrajaman 115.39    Removed pay_element_types_f join from cursor cur_non_cum_tax
**                                 for performance bug 4315023
**  24-MAY-2005 sgajula  115.40    Changed to refer new Information type IE_EMPLOYER_INFO to accomodate changes
**                                 for Employer Migration
**  16-JUN-2005 alikhar  115.41    Bug 4437249: Changed the cursor csr_get_arc_bal_value to get the balance
**                                 value for balance name with length more than 30 chars.
**  30-JUN-2005 sgajula  115.42    Initialized g_archive_end_date in archinit to support Retry Option.
**  06-JUL-2005 sgajula  115.43    Moved 'PA' archive code from range_cursor to archive_deinit,handled
**                                 case of zero pay but non-zero PAYE,avoid data corruption by locking,
**                                 and proper archiving of EMEA PAYROLL INFO
**  22-JUL-2005 sgajula  115.44    Called setup_standard_balance_table in archive_deinit(4508661)
**  26-SEP-2005 rrajaman 115.45    Added IE_EXEMPTION tax_basis condition to cursor cur_non_cum_tax(4619038).
**  29-SEP-2005 sgajula  115.46    Changed the deceased attribute tags(4641660)
**  24-OCT-2005 sgajula  115.47    Modified for 2006 Changes.
**  26-OCT-2005 sgajula  115.48    Changed NOTFOUND condition for cur_child_pay_action
**  07-Nov-2005 vikgupta 115.49    Modified the formversion and xml file version to 3 and 3.0(4721955)
**  08-Nov-2005 vikgupta 115.50    revet the xml file version from 3.0 to 1.0
**  08-Nov-2005 vikgupta 115.51    Warning message to be raised if PPSN and address are missing. Also
**                                 made noncumulative attribute values to true/false instead of Y/N.
**  09-Nov-2005 vikgupta 115.52    change the attribute firstname to firstnames.
**  09-Nov-2005 vikgupta 115.53    restrict the total prsi classes to be shown is 4. bug (4724788)
**  23-Dec-2005 sgajula  115.54    Fixed Period Number issues with Offset Payrolls (4906850)
**  06-Jan-2006 sgajula  115.55    Enabled the Start Date Parameter.
**  02-Feb-2006 rbhardwa 115.56    Changed supplementary P45 to report PRSI Class A.(5015438)
**  06-Feb-2006 rbhardwa 115.57    Changed supplementary P45 to report insurable weeks for PRSI Class A correctly.(5015438)
**  14-Feb-2006 rbhardwa 115.58    Changed supplementary P45 to not report Class A if class A insurable weeks are zero.
**                                 (5015438).
**  14-Feb-2006 sgajula  115.59    Changed get_arc_bal_value to improve the performance. Also changed to support view
**                                 changes to improve the performance(5005788)
**  15-Feb-2006 sgajula  115.60    changed cur_p45_paye_prsi_details. fetched employer_prsi(5005788)
**  21-Feb-2006 sgajula  115.61    removed  csr_all_payroll_info.Used csr_payroll_info to archive
**                                 EMEA BALANCE DEFINITION(4771780)
**  3-Mar-2006  sgajula  115.62    Changed to support user assignment status (5073577)
**  8-Mar-2006  rbhardwa 115.63    Added payroll parameter to the p45 report generator process.(5059862)
**  31-Mar-2006 sgajula  115.64    Changed to fetch PAYE Details from Run Results(5128377)
**  31-Jul-2006 vikgupta 115.65    Bug 5401393 - added abs for thistax in generate_xml.
**                                 Bug 5386432 - made modifications to ensure that if there are no
**                                 results, main P45 should be generated but if there are no run-results
**                                 previous P45 exists then no supplement P45 should be generated.
**                                 Bug 5383808 - If P45 is issued for employees which are hired in the same
**                                 tax year than the commencement date should be the latest hire date.
**                                 Similary thispay and thistax should be the period for which he was rehired.
**                                 and not for the entire tax year.
**  07-Aug-2006 vikgupta 115.66    In process_balance procedure, while calculation l_p45_last_bal_value
**                                 pass source_id of previous P45 archive instead of previous p45 action
**                                 for eg case hire in jan, run payroll, terminate, rehire in feb run payroll
**                                 now run P45 for jan and then for feb. In this case total pay and tax will be zero for feb.
**  08-Sep-2006 vikgupta 115.67    1. 5519933 - noncumulative attribute does not depend upon
**                                    social benefit balance.
**                                 2. 5510536 - Tax credit and cutoff should show either monthly or
**                                    weekly figures. Added cursor to display weekly figures for bi-weekly payroll
**                                 3. 5510536 - Insurable weeks were summing up the previous tax year
**                                    insurable weeks also, modified the cursor Cur_Act_Contexts in
**                                    process_balance to have date join.
**                                 4. 5510536 - PRSI figures displayed on P45 XML should be this employment
**                                    figures. So made changes in process_balance procedure.
**  22-Sep-2006 rbhardwa 115.70    Bug 5528450. Chaged tax credit and cutoff to Period Weekly Tax Credit and
**                                 Period Weekly Standard Rate Cutoff to archive correct values.
**  28-Sep-2006 sgajula  115.71    Bug 5519933. changed to report correct value against non cumulative flag
**                                 If employee is rehired in same tax year.
**  09-oct-2006 vikgupta 115.72    5597735 - Performance fix (the same was also raised in bug 5233518)
**                                 5591812 - to display PRSI classes only if its insurable weeks are not zero.
**                                 5600150 - Changed to report deceased flag correctly.
**  15-Jan-2007 sgajula  115.73    5758951 - If rehired on a new payroll, running P45 for old payroll does not
**                                           pick the employee.
**  04-Jun-2007 vikgupta 115.74    6144761 - Modified action creation code. As case was failing when the
**                                 the employee was terminated in one tax year but has FPD in next
**                                 tax year and has payroll and prepayments in that tax year.
**  07-nov-2007 rrajaman 115.75    6615117 - The p45 process is generating xml files with incorrect data.
**                                 For rehire having no child actions is showing -ve P45 details.
**  10-oct-2008 knadhan  115.76    7291676  - New P45 Changes effective from 01-jan-2009.
**  15-oct-2008 knadhan  115.77    7291676QA - Proper PPSN with suffices if any are displayed.
**  17-oct-2008 knadhan  115.78    7291676QA - Date of payment is reporting in wrong format .
**  8-Dec-2008  knadhan  115.79  7611974  Fixes for rehire scenario
** 21-jan-2009  knadhan  115.80  7827732  Replace '-' by '' while reporting works_no
**  27-jan-2009 knadhan 115.81   8198702  Commented the check for termination date >2009 for main and supp p45
**  09-dec-2009 knadhan 115.82   9156332   intead of date earned, effective date is passed to get_supplementary_details
--------------------------------------------------------------------------------------------------------
*/

TYPE balance_rec IS RECORD (
  balance_type_id      NUMBER,
  balance_dimension_id NUMBER,  defined_balance_id   NUMBER,
  balance_narrative    VARCHAR2(30),
  balance_name         VARCHAR2(60),
  database_item_suffix VARCHAR2(30),
  legislation_code     VARCHAR2(20));

TYPE element_rec IS RECORD (
  element_type_id      NUMBER,
  input_value_id       NUMBER,
  formula_id           NUMBER,
  element_narrative    VARCHAR2(30));


TYPE balance_table   IS TABLE OF balance_rec   INDEX BY BINARY_INTEGER;
TYPE element_table   IS TABLE OF element_rec   INDEX BY BINARY_INTEGER;

g_statutory_balance_table         balance_table;
g_statutory_balance_table_ppsn    balance_table;

g_balance_archive_index           NUMBER := 0;
g_element_archive_index           NUMBER := 0;
g_max_element_index               NUMBER := 0;
g_max_user_balance_index          NUMBER := 0;
g_max_statutory_balance_index     NUMBER := 0;

g_paye_details_element_id         NUMBER;

g_tax_basis_id                    NUMBER;
g_prsi_cat_id                     NUMBER;
g_prsi_subcat_id                  NUMBER;
g_ins_weeks_id                    NUMBER;

-- Global variables used to fetch Input value ids of Tax Credit and Cutoff 5128377
g_month_tax_rate		          NUMBER;
g_week_tax_rate                   NUMBER;
g_month_std_cutoff                NUMBER;
g_week_std_cutoff                 NUMBER;
g_period_week_tax_rate            NUMBER;  /* 5528450 */
g_period_week_std_cutoff          NUMBER;  /* 5528450 */



g_package                CONSTANT VARCHAR2(30) := 'pay_ie_p45_archive.';

g_archive_pact                    NUMBER;
g_archive_effective_date          DATE;
g_archive_start_date		    DATE;
g_archive_end_date		    DATE;

g_paye_ref                        NUMBER;

-------
PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT nocopy VARCHAR2) IS

CURSOR csr_parameter_info(p_pact_id NUMBER,
                          p_token   CHAR) IS
SELECT SUBSTR(legislative_parameters,
               INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                INSTR(legislative_parameters,' ',
                       INSTR(legislative_parameters,p_token))
                 - (INSTR(legislative_parameters,p_token)+LENGTH(p_token))),
       business_group_id
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_business_group_id               VARCHAR2(20);
l_token_value                     VARCHAR2(50);

l_proc                            VARCHAR2(50) := g_package || 'get_parameters';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('p_token_name = ' || p_token_name,20);

  OPEN csr_parameter_info(p_payroll_action_id,
                          p_token_name);

  FETCH csr_parameter_info INTO l_token_value,
                                l_business_group_id;

  CLOSE csr_parameter_info;

  IF p_token_name = 'BG_ID'

  THEN

     p_token_value := l_business_group_id;

  ELSE

     p_token_value := l_token_value;

  END IF;

  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || l_proc,30);

END get_parameters;

--------------------------------
FUNCTION get_lookup_meaning(
                     p_lookup_type    in varchar2
                    ,p_lookup_code    in varchar2 ) RETURN varchar2 IS

  CURSOR csr_get_lookup IS
  SELECT meaning
  FROM   hr_lookups
  WHERE  lookup_type=p_lookup_type
         AND lookup_code=p_lookup_code;

p_lookup_meaning hr_lookups.meaning%TYPE;

BEGIN
  p_lookup_meaning := NULL;
  OPEN csr_get_lookup;
  FETCH csr_get_lookup INTO p_lookup_meaning;
  CLOSE csr_get_lookup;

RETURN(p_lookup_meaning);

END get_lookup_meaning;

--------------------------------
PROCEDURE setup_balance_definitions(p_pactid            IN NUMBER,
                                    p_payroll_pact      IN NUMBER,
                                    p_effective_date    IN DATE) IS

l_action_info_id                  NUMBER(15);
l_ovn                             NUMBER(15);
l_index                           NUMBER;

l_proc                            VARCHAR2(50) := g_package || 'setup_balance_definitions';

BEGIN


  hr_utility.set_location('Entering        ' || l_proc,10);
  hr_utility.set_location('Step            ' || l_proc,20);

  FOR l_index IN 1 ..g_max_statutory_balance_index
  LOOP

    hr_utility.set_location('p_pactid = '||p_pactid,20);
    hr_utility.set_location('p_payroll_pact = '||p_payroll_pact,20);
    hr_utility.set_location('p_effective_date = '||p_effective_date,20);
    hr_utility.set_location('defined_balance_id = '||g_statutory_balance_table(l_index).defined_balance_id,20);
    hr_utility.set_location('balance_name = '||g_statutory_balance_table(l_index).balance_name,20);

      pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_pactid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'EMEA BALANCE DEFINITION'
      , p_action_information1          =>  p_payroll_pact
      , p_action_information2          =>  g_statutory_balance_table(l_index).defined_balance_id
      , p_action_information3          =>  NULL
      , p_action_information4          =>  g_statutory_balance_table(l_index).balance_name
      , p_action_information7          =>  'N'   /*  7291676 */
      );
  END LOOP;
/* 7291676 */
   hr_utility.set_location(' creating emea balance definations for PPSN override balance table ',20);

   FOR l_index IN 1 ..g_max_statutory_balance_index
  LOOP

    hr_utility.set_location('p_pactid = '||p_pactid,20);
    hr_utility.set_location('p_payroll_pact = '||p_payroll_pact,20);
    hr_utility.set_location('p_effective_date = '||p_effective_date,20);
    hr_utility.set_location('defined_balance_id = '||g_statutory_balance_table(l_index).defined_balance_id,20);
    hr_utility.set_location('balance_name = '||g_statutory_balance_table(l_index).balance_name,20);

      pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_pactid
      , p_action_context_type          =>  'PA'
      , p_object_version_number        =>  l_ovn
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  NULL
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'EMEA BALANCE DEFINITION'
      , p_action_information1          =>  p_payroll_pact
      , p_action_information2          =>  g_statutory_balance_table_ppsn(l_index).defined_balance_id
      , p_action_information3          =>  NULL
      , p_action_information4          =>  g_statutory_balance_table_ppsn(l_index).balance_name
      , p_action_information7          =>  'Y'   /*  7291676 */
      );

  END LOOP;

  hr_utility.set_location('Leaving ' || l_proc,30);

END setup_balance_definitions;
------------------------
/* This Procedure populates PL/SQL Table with balance names and defined_balance_id which are used to
  archive Balance Names and their Values
  Balances With Index 1-19 are Total YTD Balances and
  Balances with Index 20 -33 are Balances used for Supplementary P45
*/
PROCEDURE setup_standard_balance_table
IS
TYPE balance_name_rec IS RECORD (
  balance_name VARCHAR2(60));
TYPE balance_id_rec IS RECORD (
  defined_balance_id NUMBER);
TYPE balance_name_tab IS TABLE OF balance_name_rec INDEX BY BINARY_INTEGER;
TYPE balance_id_tab   IS TABLE OF balance_id_rec   INDEX BY BINARY_INTEGER;
l_statutory_balance balance_name_tab;
l_statutory_bal_id  balance_id_tab;

/* 7291676 */

l_statutory_balance_ppsn balance_name_tab;
l_statutory_bal_id_ppsn  balance_id_tab;

CURSOR csr_balance_dimension(p_balance   IN CHAR,
                             p_dimension IN CHAR) IS
SELECT pdb.defined_balance_id
FROM   pay_balance_types pbt,
       pay_balance_dimensions pbd,
       pay_defined_balances pdb
WHERE  pdb.balance_type_id = pbt.balance_type_id
AND    pdb.balance_dimension_id = pbd.balance_dimension_id
AND    pbt.balance_name = p_balance
AND    pbd.database_item_suffix = p_dimension
AND    pdb.legislation_code = 'IE';
l_archive_index                   NUMBER       := 1;
l_archive_index_ppsn                   NUMBER       := 1; -- 7291676
-- Balances used for YTD
l_dimension                       VARCHAR2(20) := '_PER_PAYE_REF_YTD'; -- 'PER_PAYE_REF_YTD'
l_dimension_1                     VARCHAR2(30) := '_PER_PAYE_REF_PRSI_YTD';
-- Balances used for Supp P45
l_dimension_2                     VARCHAR2(30) := '_ASG_PAYE_REF_PRSI_RUN';            -- Bug 5015438
l_dimension_pay                   VARCHAR2(16) := '_PAYMENTS';
l_dimension_run                   VARCHAR2(16) := '_ASG_RUN';
l_dimension_ptd                   VARCHAR2(16) := '_ASG_PTD';


/* 7291676 */
l_dimension_ppsn                  VARCHAR2(50) := '_PER_PAYE_REF_PPSN_YTD';
l_dimension_1_ppsn                VARCHAR2(30) := '_PER_PAYE_REF_PRSI_YTD';
l_dimension_2_ppsn                VARCHAR2(30) := '_ASG_PAYE_REF_PRSI_RUN';
l_dimension_run_ppsn              VARCHAR2(16) := '_ASG_RUN';
l_dimension_ptd_ppsn              VARCHAR2(16) := '_ASG_PTD';

l_found                           VARCHAR2(1)  := 'N';
l_max_stat_balance                NUMBER       := 19;
l_pactid                          NUMBER;
l_payroll_pact                    NUMBER;
l_proc                            VARCHAR2(100) := g_package || 'setup_standard_balance_table';
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  hr_utility.set_location('Step ' || l_proc,20);
  l_statutory_balance(1).balance_name  := 'IE Taxable Pay';
  l_statutory_balance(2).balance_name  := 'IE Net Tax';
  l_statutory_balance(3).balance_name  := 'IE PRSI Employer';
  l_statutory_balance(4).balance_name  := 'IE PRSI Employee';
  l_statutory_balance(5).balance_name  := 'IE Lump Sum';
  l_statutory_balance(6).balance_name  := 'IE PRSI Insurable Weeks';
  l_statutory_balance(15).balance_name  := 'IE Reduced Tax Credit';
  l_statutory_balance(16).balance_name  := 'IE Reduced Std Rate Cut Off';
  l_statutory_balance(17).balance_name  := 'IE Taxable Social Benefit';
  l_statutory_balance(18).balance_name := 'IE P45 Pay';
  l_statutory_balance(19).balance_name := 'IE P45 Tax Deducted';
  l_statutory_balance(14).balance_name := 'IE PRSI_ClassA Insurable Weeks';             --  Bug 5015438
  -- Added new balances which needs to be archived when a severance payment exists
  l_statutory_balance(7).balance_name  := 'IE PRSI K Employee Lump Sum';
  l_statutory_balance(8).balance_name  := 'IE PRSI M Employee Lump Sum';
  l_statutory_balance(9).balance_name  := 'IE PRSI K Employer Lump Sum';
  l_statutory_balance(10).balance_name  := 'IE PRSI M Employer Lump Sum';
  l_statutory_balance(11).balance_name  := 'IE PRSI K Term Insurable Weeks';
  l_statutory_balance(12).balance_name  := 'IE PRSI M Term Insurable Weeks';
  l_statutory_balance(13).balance_name  := 'IE Term Health Levy';
  hr_utility.set_location('Step = ' || l_proc,30);
  FOR l_index IN 1 .. l_max_stat_balance
  LOOP
  /* 7291676 */
  l_statutory_balance_ppsn(l_index).balance_name:=l_statutory_balance(l_index).balance_name;
  hr_utility.set_location(' PPSN Override balance_name = ' || l_statutory_balance_ppsn(l_index).balance_name,30);

    hr_utility.set_location('l_index      = ' || l_index,30);
    hr_utility.set_location('balance_name = ' || l_statutory_balance(l_index).balance_name,30);
    hr_utility.set_location('l_dimension  = ' || l_dimension,30);
    IF (l_index < 15) THEN -- Stores RUN balance_defined information                    -- Bug 5015438
      IF l_statutory_balance(l_index).balance_name in ('IE PRSI Insurable Weeks','IE PRSI K Term Insurable Weeks','IE PRSI M Term Insurable Weeks','IE PRSI_ClassA Insurable Weeks') THEN

         IF l_index <> 14 THEN                                                          --Bug 5015438
      /* If the Balance is IE PRSI Insurable Weeks or IE PRSI K Term Insurable Weeks or IE PRSI M Term Insurable Weeks then attach the dimension ASG_PTD for Supp P45 Balances*/
           OPEN csr_balance_dimension(l_statutory_balance(l_index).balance_name,l_dimension_ptd);
           l_statutory_balance(l_max_stat_balance + l_index).balance_name :=l_statutory_balance(l_index).balance_name || 'ASG_PTD';
	 ELSE
       /* If the Balance is IE PRSI_ClassA Insurable Weeks attach the dimension _ASG_PAYE_REF_PRSI_RUN to it for Supp P45 balance*/
           OPEN csr_balance_dimension('IE PRSI Insurable Weeks',l_dimension_2);
           l_statutory_balance(l_max_stat_balance + l_index).balance_name :=l_statutory_balance(l_index).balance_name || 'ASG_PTD';
	 END IF;

     ELSE
       /* In other cases attach the dimension ASG_RUN for Supp P45 Balance */
        OPEN csr_balance_dimension(l_statutory_balance(l_index).balance_name,l_dimension_run);
        l_statutory_balance(l_max_stat_balance + l_index).balance_name :=l_statutory_balance(l_index).balance_name || 'ASG_RUN';
     END IF;

      FETCH csr_balance_dimension INTO l_statutory_bal_id(l_max_stat_balance + l_index).defined_balance_id;
       IF csr_balance_dimension%NOTFOUND THEN
            l_statutory_bal_id(l_max_stat_balance + l_index).defined_balance_id := 0;
       END IF;
      CLOSE csr_balance_dimension;
      g_statutory_balance_table(l_max_stat_balance + l_index).defined_balance_id := l_statutory_bal_id(l_max_stat_balance + l_index).defined_balance_id;
      g_statutory_balance_table(l_max_stat_balance + l_index).balance_name := l_statutory_balance(l_max_stat_balance + l_index).balance_name;

      IF l_index <> 14 THEN                 -- Bug 5015438
         g_statutory_balance_table(l_max_stat_balance + l_index).database_item_suffix := l_dimension_run;
      ELSE
         g_statutory_balance_table(l_max_stat_balance + l_index).database_item_suffix := l_dimension_2;
      END IF;

      l_archive_index := l_archive_index + 1;
    END IF;
    -- Stores ASG_YTD balance_defined information
    IF l_index <> 14 THEN                                                                           -- Bug 5015438
       OPEN csr_balance_dimension(l_statutory_balance(l_index).balance_name,l_dimension);
    ELSE
      OPEN csr_balance_dimension('IE PRSI Insurable Weeks',l_dimension_1);
    END IF;

    FETCH csr_balance_dimension INTO l_statutory_bal_id(l_index).defined_balance_id;
      IF csr_balance_dimension%NOTFOUND THEN
         l_statutory_bal_id(l_index).defined_balance_id := 0;
      END IF;
    CLOSE csr_balance_dimension;
    g_statutory_balance_table(l_index).defined_balance_id := l_statutory_bal_id(l_index).defined_balance_id;
    g_statutory_balance_table(l_index).balance_name := l_statutory_balance(l_index).balance_name;
    IF l_index <> 14 THEN                                                                            -- Bug 5015438
       g_statutory_balance_table(l_index).database_item_suffix := l_dimension;
  --     l_archive_index := l_archive_index + 1;
    ELSE
       g_statutory_balance_table(l_index).database_item_suffix := l_dimension_1;

    END IF;
       l_archive_index := l_archive_index + 1;
  END LOOP;

/* 7291676  to create a new balance table for assignments with PPSN override values */

  FOR l_index IN 1 .. l_max_stat_balance
  LOOP
    hr_utility.set_location('l_index      = ' || l_index,30);
    hr_utility.set_location('balance_name = ' || l_statutory_balance_ppsn(l_index).balance_name,30);
    hr_utility.set_location('l_dimension_ppsn  = ' || l_dimension_ppsn,30);
    IF (l_index < 15) THEN -- Stores RUN balance_defined information                    -- Bug 5015438
      IF l_statutory_balance_ppsn(l_index).balance_name in ('IE PRSI Insurable Weeks','IE PRSI K Term Insurable Weeks','IE PRSI M Term Insurable Weeks','IE PRSI_ClassA Insurable Weeks') THEN

         IF l_index <> 14 THEN                                                          --Bug 5015438
      /* If the Balance is IE PRSI Insurable Weeks or IE PRSI K Term Insurable Weeks or IE PRSI M Term Insurable Weeks then attach the dimension ASG_PTD for Supp P45 Balances*/
           OPEN csr_balance_dimension(l_statutory_balance_ppsn(l_index).balance_name,l_dimension_ptd_ppsn);
           l_statutory_balance_ppsn(l_max_stat_balance + l_index).balance_name :=l_statutory_balance_ppsn(l_index).balance_name || 'ASG_PTD';
	 ELSE
       /* If the Balance is IE PRSI_ClassA Insurable Weeks attach the dimension _ASG_PAYE_REF_PRSI_RUN to it for Supp P45 balance*/
           OPEN csr_balance_dimension('IE PRSI Insurable Weeks',l_dimension_2_ppsn);
           l_statutory_balance_ppsn(l_max_stat_balance + l_index).balance_name :=l_statutory_balance_ppsn(l_index).balance_name || 'ASG_PTD';
	 END IF;

     ELSE
       /* In other cases attach the dimension ASG_RUN for Supp P45 Balance */
        OPEN csr_balance_dimension(l_statutory_balance_ppsn(l_index).balance_name,l_dimension_run_ppsn);
        l_statutory_balance_ppsn(l_max_stat_balance + l_index).balance_name :=l_statutory_balance_ppsn(l_index).balance_name || 'ASG_RUN';
     END IF;

      FETCH csr_balance_dimension INTO l_statutory_bal_id_ppsn(l_max_stat_balance + l_index).defined_balance_id;
       IF csr_balance_dimension%NOTFOUND THEN
            l_statutory_bal_id_ppsn(l_max_stat_balance + l_index).defined_balance_id := 0;
       END IF;
      CLOSE csr_balance_dimension;
      g_statutory_balance_table_ppsn(l_max_stat_balance + l_index).defined_balance_id := l_statutory_bal_id_ppsn(l_max_stat_balance + l_index).defined_balance_id;
      g_statutory_balance_table_ppsn(l_max_stat_balance + l_index).balance_name := l_statutory_balance_ppsn(l_max_stat_balance + l_index).balance_name;

      IF l_index <> 14 THEN                 -- Bug 5015438
         g_statutory_balance_table_ppsn(l_max_stat_balance + l_index).database_item_suffix := l_dimension_run_ppsn;
      ELSE
         g_statutory_balance_table_ppsn(l_max_stat_balance + l_index).database_item_suffix := l_dimension_2_ppsn;
      END IF;

      l_archive_index_ppsn := l_archive_index_ppsn + 1;
    END IF;
    -- Stores ASG_YTD balance_defined information
    IF l_index <> 14 THEN                                                                           -- Bug 5015438
       OPEN csr_balance_dimension(l_statutory_balance_ppsn(l_index).balance_name,l_dimension_ppsn);
    ELSE
      OPEN csr_balance_dimension('IE PRSI Insurable Weeks',l_dimension_1_ppsn);
    END IF;

    FETCH csr_balance_dimension INTO l_statutory_bal_id_ppsn(l_index).defined_balance_id;
      IF csr_balance_dimension%NOTFOUND THEN
         l_statutory_bal_id_ppsn(l_index).defined_balance_id := 0;
      END IF;
    CLOSE csr_balance_dimension;
    g_statutory_balance_table_ppsn(l_index).defined_balance_id := l_statutory_bal_id_ppsn(l_index).defined_balance_id;
    g_statutory_balance_table_ppsn(l_index).balance_name := l_statutory_balance_ppsn(l_index).balance_name;
    IF l_index <> 14 THEN                                                                            -- Bug 5015438
       g_statutory_balance_table_ppsn(l_index).database_item_suffix := l_dimension_ppsn;
  --     l_archive_index := l_archive_index + 1;
    ELSE
       g_statutory_balance_table_ppsn(l_index).database_item_suffix := l_dimension_1_ppsn;

    END IF;
       l_archive_index_ppsn := l_archive_index_ppsn + 1;
 if(l_index<15) then
  hr_utility.set_location('g_statutory_ppsn(l_max)'||g_statutory_balance_table_ppsn(l_max_stat_balance + l_index).defined_balance_id,40);
  hr_utility.set_location('g_statutory_ppsn(l_max)'||g_statutory_balance_table_ppsn(l_max_stat_balance + l_index).balance_name,40);
  end if;
  hr_utility.set_location('g_statutory_ppsn(l_ind)'||g_statutory_balance_table_ppsn(l_index).defined_balance_id,40);
  hr_utility.set_location('g_statutory_ppsn(l_ind)'||g_statutory_balance_table_ppsn(l_index).balance_name,40);
  END LOOP;

  ---
    l_archive_index_ppsn := l_archive_index_ppsn - 1;
  l_archive_index := l_archive_index - 1;
 -- hr_utility.set_location('retrieving PER_PAYE_REF_PRSI_YTD bal_id for Insurable weeks',40);       -- Bug 5015438
 -- OPEN csr_balance_dimension('IE PRSI Insurable Weeks',l_dimension_1);
 -- FETCH csr_balance_dimension  INTO l_statutory_bal_id(l_archive_index).defined_balance_id;
 -- CLOSE csr_balance_dimension;
 -- g_statutory_balance_table(l_archive_index).defined_balance_id := l_statutory_bal_id(l_archive_index).defined_balance_id;
 -- g_statutory_balance_table(l_archive_index).balance_name := 'IE PRSI_ClassA Insurable Weeks';
 -- g_statutory_balance_table(l_archive_index).database_item_suffix := l_dimension_1;
 -- hr_utility.set_location('Step = ' || l_proc,40);
 -- hr_utility.set_location('l_max_stat_balance       = ' || l_max_stat_balance,40);
  g_max_statutory_balance_index := l_archive_index;
 -- hr_utility.set_location('Step ' || l_proc,50);
 -- hr_utility.set_location('l_archive_index = ' || l_archive_index,50);
 -- hr_utility.set_location('Leaving ' || l_proc,60);
END setup_standard_balance_table;
---------------------------------------

PROCEDURE archinit (p_payroll_action_id IN NUMBER)
IS

 CURSOR  csr_archive_effective_date(pactid NUMBER) IS
  SELECT effective_date
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = pactid;

  CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT pet.element_type_id,
         piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'IE'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

  l_proc                            VARCHAR2(50) := g_package || 'archinit';
  l_assignment_set_id               NUMBER;
  l_bg_id                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               NUMBER;
  l_end_date                        VARCHAR2(30);
  l_payroll_id                      NUMBER;
  l_start_date                      VARCHAR2(30);
  l_dummy                           VARCHAR2(2);
  l_error                           varchar2(1) ;
BEGIN


hr_utility.set_location('Entering ' || l_proc,10);

  g_archive_pact := p_payroll_action_id;

  OPEN csr_archive_effective_date(p_payroll_action_id);
  FETCH csr_archive_effective_date
  INTO  g_archive_effective_date;
  CLOSE csr_archive_effective_date;

  pay_ie_p45_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'EMPLOYER'
  , p_token_value       => g_paye_ref);

  pay_ie_p45_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

   pay_ie_p45_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_ie_p45_archive.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('g_paye_ref = ' || g_paye_ref,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

  -- Initialized g_archive_end_date to support Retry Option
  g_archive_end_date     := TO_DATE(l_end_date,'yyyy/mm/dd');
  g_archive_start_date   := l_canonical_start_date;

  hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);


  -- retrieve ids for tax elements
   hr_utility.set_location('stage 1',22);

  OPEN csr_input_value_id('IE PAYE details','Tax Basis');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_tax_basis_id;
  CLOSE csr_input_value_id;

  OPEN csr_input_value_id('IE PRSI Detail','Contribution Class');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_prsi_cat_id;
  CLOSE csr_input_value_id;

    OPEN csr_input_value_id('IE PRSI Detail','Subclass');
    FETCH csr_input_value_id INTO g_paye_details_element_id,
                                  g_prsi_subcat_id;
    CLOSE csr_input_value_id;

    OPEN csr_input_value_id('IE PRSI Detail','Insurable Weeks');
    FETCH csr_input_value_id INTO g_paye_details_element_id,
                                  g_ins_weeks_id;
    CLOSE csr_input_value_id;

-- Fetch the Input value ID of Monthly Tax Credit 5128377
  OPEN csr_input_value_id('IE PAYE details','Monthly Tax Credit');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_month_tax_rate;
  CLOSE csr_input_value_id;

-- Fetch the Input value ID of Weekly Tax Credit 5128377
  OPEN csr_input_value_id('IE PAYE details','Weekly Tax Credit');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_week_tax_rate;
  CLOSE csr_input_value_id;

-- Changed to Period Weekly Tax Credit for Bug 5528450.
  OPEN csr_input_value_id('IE PAYE details','Period Weekly Tax Credit');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_period_week_tax_rate;
  CLOSE csr_input_value_id;

-- Fetch the Input value ID of Monthly Standard Rate Cutoff 5128377
  OPEN csr_input_value_id('IE PAYE details','Monthly Standard Rate Cutoff');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_month_std_cutoff;
  CLOSE csr_input_value_id;

-- Fetch the Input value ID of Weekly Standard Rate Cutoff 5128377
  OPEN csr_input_value_id('IE PAYE details','Weekly Standard Rate Cutoff');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_week_std_cutoff;
  CLOSE csr_input_value_id;

-- Changed to Period Weekly Standard Rate Cutoff for Bug 5528450.
  OPEN csr_input_value_id('IE PAYE details','Period Weekly Standard Rate Cutoff');
  FETCH csr_input_value_id INTO g_paye_details_element_id,
                                g_period_week_std_cutoff;
  CLOSE csr_input_value_id;

       hr_utility.set_location('stage 2',23);
    pay_ie_p45_archive.setup_standard_balance_table;

       hr_utility.set_location('stage 3',24);

  --  hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,20);
  --  hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,20);
  --  hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
  --  hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);
    hr_utility.set_location('Leaving ' || l_proc,20);
  END archinit;
  --------------------------------------------------------------------

  PROCEDURE archive_employee_details (
    p_assactid             IN NUMBER
  , p_assignment_id        IN NUMBER
  , p_curr_pymt_ass_act_id IN NUMBER
  , p_payroll_child_actid  IN NUMBER
  , p_date_earned          IN DATE
  , p_curr_pymt_eff_date   IN DATE
  , p_time_period_id       IN NUMBER
  , p_record_count         IN NUMBER
  , p_supp_flag            IN VARCHAR2
  , p_person_id            IN NUMBER
  , p_termination_date     IN DATE
  , p_last_act_seq         IN NUMBER
  , p_last_p45_act         IN NUMBER
  -- added effective_date for bug 5591812
  , p_effective_date	   IN DATE
  ,p_ppsn_override_flag IN VARCHAR2) IS

    l_action_info_id NUMBER;
    l_ovn            NUMBER;
    --
    l_tax_basis      VARCHAR2(20);
    l_tax_basis_det  VARCHAR2(20);
    l_arch_run_count NUMBER;
    l_prsi_cat       VARCHAR2(50) :='';
    l_prsi_cur_cat   VARCHAR2(1);
    l_prsi_subcat    VARCHAR2(10);
    l_ins_weeks      VARCHAR2(10);
    l_monthly_tax_credit      NUMBER;
    l_weekly_tax_credit       NUMBER;
    l_period_weekly_tax_credit  NUMBER;   /* 5528450 */
    l_monthly_std_rate_cutoff NUMBER;
    l_weekly_std_rate_cutoff  NUMBER;
    l_period_weekly_std_cutoff  NUMBER;   /* 5528450 */
    l_tax_credit              NUMBER;
    l_std_rate_cut_off        NUMBER;
    l_period_type             VARCHAR2(20);
    l_date_of_birth           DATE;
    l_first_name              per_all_people_f.first_name%TYPE;
    l_last_name               per_all_people_f.last_name%TYPE;
    l_bg_id                   NUMBER;
    l_commencement_date        VARCHAR2(30);

-- Commented as PAYE Details are now fetched from Run Results (5128377)
/*
    cursor cur_paye_dtl is
       select nvl(monthly_tax_credit,0)
            ,nvl(weekly_tax_credit,0)
            ,nvl(monthly_std_rate_cut_off,0)
            ,nvl(weekly_std_rate_cut_off,0)
      from   pay_ie_paye_details_f pipd
       where assignment_id = p_assignment_id
         and p_date_earned between
            effective_start_date and effective_end_date
         and info_source in ('IE_P45','IE_ELECTRONIC','IE_CERT_TAX_CREDITS')
         and tax_basis not in ('IE_EMERGENCY','IE_EMERGENCY_NO_PPS'); --Bug No. 4016508
*/

   /*Bug No. 4016508*/
   /* cursor cur_credit_cutoff_emer(p_global_name varchar2) is
       select  fgf.global_value
        from   ff_globals_f fgf
       where   fgf.global_name = p_global_name
         and   fgf.legislation_code ='IE'
         and   p_date_earned between
               fgf.effective_start_date and fgf.effective_end_date;*/

    cursor cur_period_type is
       select  ptp.period_type
        from   per_time_periods ptp
       where   time_period_id = p_time_period_id;

    cursor cur_sep_name_dob(p_bg_id NUMBER) is
       select  papf.date_of_birth,papf.first_name, papf.last_name
         from  per_all_people_f papf,
               per_all_assignments_f pasf
         where pasf.assignment_id = p_assignment_id
         and   p_date_earned between
               pasf.effective_start_date and pasf.effective_end_date
         and   pasf.business_group_id = p_bg_id
         and   papf.person_id = pasf.person_id
         and   p_date_earned between
               papf.effective_start_date and papf.effective_end_date
         and   papf.business_group_id = pasf.business_group_id;

    CURSOR cur_payroll_assg_action is
       select  paa.assignment_action_id  pay_assg_act_id
         from  pay_assignment_actions paa,
               pay_payroll_actions ppa
         where paa.assignment_id in (select assignment_id
                                    from per_all_assignments_f
                                    where person_id = p_person_id
                                   )
        and   paa.tax_unit_id = g_paye_ref
         and   paa.payroll_action_id = ppa.payroll_action_id
         and   ppa.action_type in ('R','Q')
         and   paa.action_sequence > p_last_act_seq
         and   to_char(ppa.effective_date,'YYYY') = to_char(p_date_earned, 'YYYY')
         and   paa.action_status = 'C'
         and   paa.source_action_id is not null
	   --Bug 4724788
	   order by paa.assignment_action_id;
-- Modified this cursor, parameterised dimension_name for bug 5591812
	cursor balance_id (bal_name varchar2, p_dimension_name varchar2) is
	SELECT pdb.defined_balance_id
	    FROM
		     pay_balance_dimensions pbd
		    ,pay_balance_types      pbt
		    ,pay_defined_balances pdb
	    WHERE
			pbd.dimension_name = p_dimension_name
		    AND pbd.business_group_id is null
		    AND pbd.legislation_code='IE'
		    AND pbt.balance_name = bal_name
		    AND pbt.business_group_id is null
		    AND pbt.legislation_code='IE'
		    AND pdb.balance_type_id = pbt.balance_type_id
		    AND pdb.balance_dimension_id= pbd.balance_dimension_id
		    AND pdb.business_group_id is null
		    AND pdb.legislation_code='IE';

    CURSOR payroll_asg_action is
       select  max(paa.assignment_action_id)
         from  pay_assignment_actions paa,
               pay_payroll_actions ppa
         where paa.assignment_id in (select assignment_id
                                    from per_all_assignments_f
                                    where person_id = p_person_id
                                   )
         and   paa.tax_unit_id = g_paye_ref
         and   paa.payroll_action_id = ppa.payroll_action_id
         and   ppa.action_type in ('R','Q')
         and   to_char(ppa.effective_date,'YYYY') = to_char(p_date_earned, 'YYYY')
         and   paa.action_status = 'C'
         and   paa.source_action_id is not null;

-- Fetch Commencement date  when no previous p45 produced.
   CURSOR comm_date_first IS
   select act_inf.action_information11
   from   pay_action_information act_inf
   where  act_inf.action_context_id = p_assactid
   and    act_inf.action_information_category = 'EMPLOYEE DETAILS'
   and    act_inf.action_context_type = 'AAP';

-- Fetch Commencement date when p45 is produced previously.
   CURSOR comm_date_last_p45 IS
   select act_inf.action_information30
   from   pay_action_information act_inf
   where  act_inf.action_context_id = p_last_p45_act
   and    act_inf.action_information_category = 'IE EMPLOYEE DETAILS'
   and    act_inf.action_context_type = 'AAP';

-- Bug 5386432
   -- CURSOR to fetch tax credit and std cutoff from paye table for
   -- employees having 0 earnings.
   CURSOR csr_get_paye_details is
   select tax_basis
         ,weekly_tax_credit
	   ,weekly_std_rate_cut_off
         ,monthly_tax_credit
         ,monthly_std_rate_cut_off
    from pay_ie_paye_details_f
    where assignment_id = p_assignment_id
      and p_termination_date between effective_start_date and effective_end_date;

-- Added by vikas cursor to number_per_fiscal_year.
-- Since tax credit and cutoff figures are fetched from run-results, for
-- bi-weekly payroll cutoff and credit and are shown as twice of weekly figures.
-- bug 5510536
cursor csr_number_per_year (l_period_type     per_time_periods.period_type%type) is
  select number_per_fiscal_year
  from   per_time_period_types tpt
  where  period_type = l_period_type;
  --
  l_number_per_year  per_time_period_types.number_per_fiscal_year%type;

--end vikas

-- To display futher PRSI Classes only, if its insurable weeks are non-zero.
-- bug 5591812
l_prev_sequence number;
l_current_sequence number;
CURSOR c_context_id
      IS
         SELECT context_id
           FROM ff_contexts
          WHERE context_name = 'SOURCE_TEXT';
l_context_id               ff_contexts.context_id%TYPE;
l_defined_balance_id       pay_defined_balances.defined_balance_id%TYPE;
v_class			varchar2(30);


CURSOR Cur_Act_Contexts(l_defined_bal_id number,p_context_value varchar2) IS
   SELECT sum(PAY_BALANCE_PKG.GET_VALUE(l_defined_bal_id, -- changes made
    			             pac.ASSIGNMENT_ACTION_ID,
                                   g_paye_ref,
                                   null,
                                   pac.CONTEXT_ID,
                                   pac.CONTEXT_VALUE,
                                   null,
                                   null))
  FROM   pay_action_contexts pac,
         pay_assignment_actions pas,
         pay_payroll_actions ppa
  WHERE  substr(pac.Context_Value,1,4) = p_context_value
  AND    pac.assignment_id in (select papf.assignment_id
                                 from per_all_assignments_f papf
                                 where papf.person_id = p_person_id
                              )
  AND    pas.tax_unit_id = g_paye_ref
  AND    pas.assignment_action_id = pac.assignment_action_id
  AND    ppa.payroll_action_id = pas.payroll_action_id
  AND    ppa.effective_date between to_date('01-01-' || to_char(p_effective_date,'YYYY'),'DD-MM-YYYY') --Bug fix 4108423
  AND    g_archive_end_date
  and    pas.action_sequence > l_prev_sequence
  and    pas.action_sequence <= l_current_sequence;

  CURSOR cur_get_prev_run_seq is
   select paa.action_sequence
   from   pay_assignment_actions paa,
          pay_payroll_actions ppa,
          pay_action_interlocks pai,
	    pay_assignment_actions paa1
   where  paa1.source_action_id = p_last_p45_act
     and  pai.locking_action_id = paa1.assignment_action_id
    and   pai.locked_action_id = paa.assignment_action_id
    and   paa.assignment_id in (select papf.assignment_id
                                 from per_all_assignments_f papf
                                 where papf.person_id = p_person_id
                              )
    and   paa.tax_unit_id = g_paye_ref
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q','I','B','V');

   CURSOR cur_get_curr_run_seq is
   select action_sequence
   from   pay_assignment_actions ppa
   where  assignment_action_id = p_payroll_child_actid;

   l_class_weeks number;
-- end for bug 5591812




-- Variables to store K, M and Total Insurable Weeks
    k_defined_balance_id pay_defined_balances.DEFINED_BALANCE_ID%type := NULL;
    m_defined_balance_id pay_defined_balances.DEFINED_BALANCE_ID%type := NULL;
    pay_act_id number := NULL;

    l_proc           VARCHAR2(60) := g_package || 'archive_employee_details';
    l_prsi_count     NUMBER(1) := 0; --bug 4724788
  --
   BEGIN
       hr_utility.set_location('Entering ' || l_proc,10);
    -- call generic procedure to retrieve and archive all data for
    -- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE NET PAY DISTRIBUTION
    hr_utility.set_location('Calling pay_emp_action_arch',20);

    pay_emp_action_arch.get_personal_information (
        p_payroll_action_id    => g_archive_pact            -- archive payroll_action_id
      , p_assactid             => p_assactid                -- archive assignment_action_id
      , p_assignment_id        => p_assignment_id           -- current assignment_id
      , p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id    -- prepayment assignment_action_id
      , p_curr_eff_date        => p_curr_pymt_eff_date      -- prepayment effective_date(specially reqd
                                                            -- for archives later than the
                                                            -- last process date after termination date)
      , p_date_earned          => p_date_earned             -- payroll date_earned
      , p_curr_pymt_eff_date   => p_curr_pymt_eff_date      -- prepayment effective_date
      , p_tax_unit_id          => g_paye_ref                -- only required for US
      , p_time_period_id       => p_time_period_id          -- payroll time_period_id
      , p_ppp_source_action_id => NULL);

    hr_utility.set_location('Returned from pay_emp_action_arch',30);

     hr_utility.set_location('p_payroll_child_actid'||p_payroll_child_actid,30);
     hr_utility.set_location('p_ppsn_override_flag'||p_ppsn_override_flag,30);
    -- get the business group id
    pay_ie_p45_archive.get_parameters (
                          p_payroll_action_id => g_archive_pact
                        , p_token_name        => 'BG_ID'
                        , p_token_value       => l_bg_id);

    hr_utility.set_location('p_run_assignment_action_id ='||p_payroll_child_actid,40);

    -- get tax basis
    hr_utility.set_location('g_tax_basis_id ='||g_tax_basis_id,40);
-- Bug 5386432, since for terminated which does not have any element attached with FPD
-- will have no child assignment actions. Call this only if child actions exists.
    IF p_payroll_child_actid IS NOT NULL THEN
	l_tax_basis := pay_ie_archive_detail_pkg.get_tax_details (
                                p_run_assignment_action_id => p_payroll_child_actid
                               ,p_input_value_id           => g_tax_basis_id
                               ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));
    END IF;
    hr_utility.set_location('l_tax_basis = ' || l_tax_basis,40);

    -- get prsi classes
    hr_utility.set_location('g_prsi_cat_id ='||g_prsi_cat_id,40);
    -- check for supplementary run
    /*
    OPEN cur_supp_run;
    FETCH cur_supp_run INTO l_arch_run_count;
    CLOSE cur_supp_run;
    hr_utility.set_location('l_arch_run_count ='||l_arch_run_count,40);
    -- if it is a supplementary run, archive only for the current run
    IF l_arch_run_count>1
    */
    /*
    IF p_supp_flag = 'Y'
    THEN
        l_prsi_cat := pay_ie_archive_detail_pkg.get_tax_details (
                                p_run_assignment_action_id => p_payroll_child_actid
                               ,p_input_value_id           => g_prsi_cat_id
                               ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));
    -- otherise archive for all payroll runs
    ELSE
    */
    -- Added to check to dispaly further PRSI classes only if insurable
    -- weeks are not zero.
/*      OPEN c_context_id;
      FETCH c_context_id INTO l_context_id;
      CLOSE c_context_id;

	if p_supp_flag <> 'Y' then*/
	-- bug 5591812
		open balance_id('IE PRSI Insurable Weeks','_ASG_PAYE_REF_PRSI_RUN');
		FETCH balance_id into l_defined_balance_id ;
		CLOSE balance_id;

	OPEN cur_get_prev_run_seq;
		FETCH cur_get_prev_run_seq into l_prev_sequence;
		CLOSE cur_get_prev_run_seq;

		IF l_prev_sequence IS NULL THEN
			l_prev_sequence := 0;
		END IF;

		open cur_get_curr_run_seq;
		fetch cur_get_curr_run_seq into l_current_sequence;
		CLOSE cur_get_curr_run_seq;

		if l_current_sequence is null then
			l_current_sequence := 0;
		end if;
		hr_utility.set_location('l_current_sequence..'||l_current_sequence,101);
		hr_utility.set_location('l_prev_sequence..'||l_prev_sequence,101);


        FOR assg_act_rec IN cur_payroll_assg_action
        LOOP
            l_prsi_cur_cat := pay_ie_archive_detail_pkg.get_tax_details (
                                p_run_assignment_action_id => assg_act_rec.pay_assg_act_id
                               ,p_input_value_id           => g_prsi_cat_id
                               ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));
            hr_utility.set_location('l_prsi_cur_cat = ' || l_prsi_cur_cat,40);

            IF l_prsi_cur_cat IS NOT NULL AND l_prsi_cur_cat <>'A' AND (nvl(instr(l_prsi_cat,l_prsi_cur_cat),0) = 0)
            THEN

               IF l_prsi_cat <> ' ' THEN
-- Bug 3669639 Added a space after the comma so that the display is now uniform with spaces
                    hr_utility.set_location('In if l_prsi_cur_cat = ' || l_prsi_cur_cat,41);
			      open Cur_Act_Contexts(l_defined_balance_id,'IE_'||l_prsi_cur_cat);
				fetch Cur_Act_Contexts into l_class_weeks;
				CLOSE Cur_Act_Contexts;
                        hr_utility.set_location('in if l_class_weeks ..'||l_class_weeks,101);
				if nvl(l_class_weeks,0) > 0 then
					l_prsi_cat := l_prsi_cat||', '|| l_prsi_cur_cat;
					l_prsi_count := l_prsi_count + 1; --Bug 4724788
				end if;
                        hr_utility.set_location('l_prsi_count = ' || l_prsi_count,420);
			  --Bug 4724788
			  if l_prsi_count = 2 then
				exit;
			  end if;
		    ELSE
		            v_class := 'IE_'||l_prsi_cur_cat;
				hr_utility.set_location('before in else l_class_weeks ..'||l_class_weeks,101);
				hr_utility.set_location('before in else l_prsi_cur_cat ..'||l_prsi_cur_cat,101);
				hr_utility.set_location('v_class ..'||v_class,101);
				open Cur_Act_Contexts(l_defined_balance_id,v_class);
				fetch Cur_Act_Contexts into l_class_weeks;
				CLOSE Cur_Act_Contexts;
				hr_utility.set_location('in else l_class_weeks ..'||l_class_weeks,101);

				if nvl(l_class_weeks,0) > 0 then

					l_prsi_cat :=l_prsi_cur_cat;
					hr_utility.set_location('In if else v_class = ' || v_class,42);
				end if;
			  --exit;
                END IF;
            END IF;
	    hr_utility.set_location(' kal after if and else l_prsi_cat = ' || l_prsi_cat,40);

        END LOOP;
	 hr_utility.set_location(' kal after loop l_prsi_cat = ' || l_prsi_cat,40);
	  -- end bug 5591812
   -- END IF;
    hr_utility.set_location('g_prsi_subcat_id ='||g_prsi_subcat_id,40);
-- Bug 5386432, since for terminated which does not have any element attached with FPD
-- will have no child assignment actions. Call this only if child actions exists.
    IF p_payroll_child_actid IS NOT NULL THEN
	    l_prsi_subcat := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_prsi_subcat_id
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));
	    l_ins_weeks := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_ins_weeks_id
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));
     END IF;
     hr_utility.set_location('l_prsi_subcat = ' || l_prsi_subcat,40);
     hr_utility.set_location('g_ins_weeks_id ='||g_ins_weeks_id,40);
     hr_utility.set_location('l_ins_weeks = ' || l_ins_weeks,40);

   -- get tax credit and std rate cut off
   OPEN cur_period_type;
   FETCH cur_period_type INTO l_period_type;
   CLOSE cur_period_type;

-- Commented as PAYE Details are now fetched from Run Results (5128377)
/*
   OPEN cur_paye_dtl;
   FETCH cur_paye_dtl INTO l_monthly_tax_credit ,
                           l_weekly_tax_credit,
                           l_monthly_std_rate_cutoff,
                           l_weekly_std_rate_cutoff;
   IF cur_paye_dtl%NOTFOUND
   THEN */
   /*Bug No. 4016508*/
       /*OPEN cur_credit_cutoff_emer('IE_WEEKLY_TAX_CREDIT');
       FETCH cur_credit_cutoff_emer INTO l_weekly_tax_credit;
       CLOSE cur_credit_cutoff_emer;
       OPEN cur_credit_cutoff_emer('IE_MONTHLY_TAX_CREDIT');
       FETCH cur_credit_cutoff_emer INTO l_monthly_tax_credit;
       CLOSE cur_credit_cutoff_emer;*/
/*       l_weekly_tax_credit:=0;
       l_monthly_tax_credit:=0;
       l_monthly_std_rate_cutoff:=0;
       l_weekly_std_rate_cutoff:=0;
   END IF;
   CLOSE cur_paye_dtl;
*/

-- Tax Credit and Cutoff are now fetched from Run Results 5128377
-- Bug 5386432, since for terminated which does not have any element attached with FPD
-- will have no child assignment actions. Call this only if child actions exists.
   IF p_payroll_child_actid IS NOT NULL THEN
	    l_weekly_tax_credit := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_week_tax_rate
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));

            /* 5528450 */
	    l_period_weekly_tax_credit := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_period_week_tax_rate
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));

	    IF l_period_weekly_tax_credit IS NOT NULL THEN
               l_weekly_tax_credit := l_period_weekly_tax_credit;
	    END IF;

	    l_monthly_tax_credit := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_month_tax_rate
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));

	    l_monthly_std_rate_cutoff := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_month_std_cutoff
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));

	    l_weekly_std_rate_cutoff := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_week_std_cutoff
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));

            /* 5528450 */
	    l_period_weekly_std_cutoff := pay_ie_archive_detail_pkg.get_tax_details (
						  p_run_assignment_action_id => p_payroll_child_actid
						 ,p_input_value_id           => g_period_week_std_cutoff
						 ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));

             IF l_period_weekly_std_cutoff IS NOT NULL THEN
               l_weekly_std_rate_cutoff := l_period_weekly_std_cutoff;
	    END IF;
   END IF;

 hr_utility.set_location('p_payroll_child_actid'|| p_payroll_child_actid,30);
 hr_utility.set_location('l_weekly_tax_credit'|| l_weekly_tax_credit,30);
 hr_utility.set_location('l_period_weekly_tax_credit'|| l_period_weekly_tax_credit,30);
 hr_utility.set_location('l_monthly_tax_credit'|| l_monthly_tax_credit,30);
 hr_utility.set_location('l_monthly_std_rate_cutoff'|| l_monthly_std_rate_cutoff,30);
 hr_utility.set_location('l_weekly_std_rate_cutoff'|| l_weekly_std_rate_cutoff,30);
 hr_utility.set_location('l_period_weekly_std_cutoff'|| l_period_weekly_std_cutoff,30);
   -- Bug 5386432, if no child assignment actions fetch values from
   -- PAYE table.
   IF p_payroll_child_actid IS NULL THEN
	open csr_get_paye_details;
	FETCH csr_get_paye_details into l_tax_basis,l_weekly_tax_credit,l_weekly_std_rate_cutoff,l_monthly_tax_credit,l_monthly_std_rate_cutoff;
	CLOSE csr_get_paye_details;
   END IF;
   ---
   -- Bug 5510536
   IF (l_period_type IN ('Bi-Week','Week','Lunar Month'))
   THEN
	 open csr_number_per_year(l_period_type);
	 FETCH csr_number_per_year into l_number_per_year;
	 CLOSE csr_number_per_year;
       l_tax_credit :=l_weekly_tax_credit*l_number_per_year/52;
       l_std_rate_cut_off := l_weekly_std_rate_cutoff*l_number_per_year/52;
   ELSIF (l_period_type IN ('Bi-Month','Calendar Month','Quarter'))
   THEN
	 open csr_number_per_year(l_period_type);
	 FETCH csr_number_per_year into l_number_per_year;
	 CLOSE csr_number_per_year;
       l_tax_credit :=l_monthly_tax_credit* l_number_per_year/12;
       l_std_rate_cut_off := l_monthly_std_rate_cutoff* l_number_per_year/12;
   END IF;
   -- end 5510536.
   hr_utility.set_location('l_tax_credit = ' || l_tax_credit,40);
   hr_utility.set_location('l_std_rate_cut_off = ' || l_std_rate_cut_off,40);
    IF l_tax_basis = 'C'
    THEN
      l_tax_basis_det := 'Cumulative';
    ELSIF l_tax_basis = 'N'
    THEN
      l_tax_basis_det := 'Non Cumulative';
    ELSE
      l_tax_basis_det := l_tax_basis;
    END IF;

     --get the date of birth and separate name
     hr_utility.set_location('V_assignment_id = ' || p_assignment_id,40);
     hr_utility.set_location('V_date_earned = ' || p_date_earned,40);

     OPEN cur_sep_name_dob(l_bg_id);
     FETCH cur_sep_name_dob INTO l_date_of_birth,l_first_name,l_last_name;
     CLOSE cur_sep_name_dob;

-- Fetching K, M and Total Insurable Weeks which needs to be stored
-- with class name in l_prsi_cat
/* 7291676 */
IF p_ppsn_override_flag is not null THEN
open balance_id('IE PRSI K Term Insurable Weeks','_PER_PAYE_REF_PPSN_YTD');
ELSE
open balance_id('IE PRSI K Term Insurable Weeks','_PER_PAYE_REF_YTD');
END IF;
fetch balance_id into k_defined_balance_id;
close balance_id;

/* 7291676 */
IF p_ppsn_override_flag is not null  THEN
open balance_id('IE PRSI M Term Insurable Weeks','_PER_PAYE_REF_PPSN_YTD');
ELSE
open balance_id('IE PRSI M Term Insurable Weeks','_PER_PAYE_REF_YTD');
END IF;
fetch balance_id into m_defined_balance_id;
close balance_id;

open payroll_asg_action;
fetch payroll_asg_action into pay_act_id;
close payroll_asg_action;

-- Bug 3669639 : Changed the code so that l_prsi_cat is now
-- previous classes concatenated with K or M
-- Bug 5386432, since for terminated which does not have any element attached with FPD
-- will have no child assignment actions. Call this only if child actions exists.
	 hr_utility.set_location(' kal before if l_prsi_cat = ' || l_prsi_cat,40);
IF pay_act_id IS NOT NULL THEN
	if  pay_balance_pkg.get_value(k_defined_balance_id,pay_act_id,g_paye_ref,null,null,null,null,null) > 0 and
	    l_prsi_cat is not NULL and l_prsi_count <> 2 then --Bug 4724788
		  l_prsi_cat := l_prsi_cat ||', K';
	elsif pay_balance_pkg.get_value(k_defined_balance_id,pay_act_id,g_paye_ref,null,null,null,null,null) > 0 and
		l_prsi_cat is null then
		  l_prsi_cat := 'K';
	end if;

	if  pay_balance_pkg.get_value(m_defined_balance_id,pay_act_id,g_paye_ref,null,null,null,null,null) > 0 and
	    l_prsi_cat is not NULL and l_prsi_count <> 2 then --Bug 4724788
		  l_prsi_cat := l_prsi_cat ||', M';
	elsif pay_balance_pkg.get_value(m_defined_balance_id,pay_act_id,g_paye_ref,null,null,null,null,null) > 0 and
		l_prsi_cat is null then
		  l_prsi_cat := 'M';
	end if;
END IF;
 hr_utility.set_location(' kal after  if l_prsi_cat = ' || l_prsi_cat,40);

-- bug 5383808, Fetch value of latest hire date.
--if p_last_p45_act IS NULL THEN
	OPEN comm_date_first;
	FETCH comm_date_first INTO l_commencement_date;
	CLOSE comm_date_first;
/*else
	OPEN comm_date_last_p45;
	FETCH comm_date_last_p45 INTO l_commencement_date;
	CLOSE comm_date_last_p45;
end if;*/



-- end bug 5383808
    hr_utility.set_location('Archiving IE EMPLOYEE DETAILS',50);
    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_assactid
    , p_action_context_type          =>  'AAP'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  p_assignment_id
    , p_effective_date               =>  g_archive_effective_date
    , p_source_id                    =>  NULL
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'IE EMPLOYEE DETAILS'
    , p_action_information1          =>  NULL
    , p_action_information2          =>  NULL
    , p_action_information3          =>  NULL
    , p_action_information21         =>  l_tax_basis_det
    , p_action_information22         =>  l_prsi_cat
    , p_action_information23         =>  l_prsi_subcat
    , p_action_information24         =>  l_ins_weeks
    , p_action_information25         =>  to_char(l_date_of_birth,'DD-MON-YYYY')
    , p_action_information26         =>  l_tax_credit
    , p_action_information27         =>  l_std_rate_cut_off
    , p_action_information28         =>  l_first_name
    , p_action_information29         =>  l_last_name
    , p_action_information30         =>  l_commencement_date);
  END archive_employee_details;

  -----------------------------

  PROCEDURE process_balance (p_action_context_id IN NUMBER,
                             p_assignment_id     IN NUMBER,
                             p_person_id         IN NUMBER,
                             p_source_id         IN NUMBER,
                             p_effective_date    IN DATE,
                             p_balance           IN VARCHAR2,
                             p_dimension         IN VARCHAR2,
                             p_defined_bal_id    IN NUMBER,
                             p_record_count      IN NUMBER,
			           p_termination_date  IN DATE,
			           p_supp_flag         IN VARCHAR2,
			           p_last_p45_action   IN NUMBER,
			           p_last_p45_pact     IN NUMBER,           -- Bug 5005788
			           p_prev_src_id       IN NUMBER) -- p45 action locked by current P45 action.
  IS
  --
  -- Cursor for retrieving balance type id of defined balance
  --
  CURSOR csr_bal_type IS
   select balance_type_id
   from   pay_defined_balances
   where  defined_balance_id = p_defined_bal_id;
  -- Cursor for retrieving the summed run results for
  -- PRSI insurable weeks where Contribution Class
  -- starts with IE_A
  -- First part of the select retrives summed up values for Payroll runs,
  -- Second part of the select retrives summed up values for Uploaded Balance
 /* CURSOR csr_iea_weeks (p_balance_type_id in number) IS
  select  nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0) weeks
  from  pay_run_result_values   TARGET
      , pay_balance_feeds_f     FEED
      , pay_run_results         RR
      , pay_assignment_actions  ASSACT
      , pay_assignment_actions  BAL_ASSACT
      , pay_payroll_actions     PACT
      , pay_payroll_actions     BACT
      , per_time_periods        PPTP
      , per_time_periods        BPTP
      , pay_run_results         PROCESS_RR
      , pay_run_result_values   PROCESS
      , pay_input_values_f      PROCESS_IV
      , pay_action_contexts     ACX_PROCESS_ID
      , ff_contexts             CON_PROCESS_ID
  where BAL_ASSACT.assignment_action_id = p_source_id
  and   BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
  and   FEED.balance_type_id +0 = p_balance_type_id
  and   FEED.input_value_id = TARGET.input_value_id
  and   nvl(TARGET.result_value,'0') <> '0'
  and   TARGET.run_result_id = RR.run_result_id
  and   RR.assignment_action_id = ASSACT.assignment_action_id
  and   ASSACT.payroll_action_id = PACT.payroll_action_id
  and   PACT.effective_date between FEED.effective_start_date and FEED.effective_end_date
  and   RR.status in ('P','PA')
  and   ASSACT.action_sequence <= BAL_ASSACT.action_sequence
  and   ASSACT.assignment_id = BAL_ASSACT.assignment_id
  and   BPTP.payroll_id = BACT.payroll_id
  and   BACT.date_earned between BPTP.start_date and BPTP.end_date
  and   PPTP.payroll_id = PACT.payroll_id
  and   PACT.date_earned between PPTP.start_date and PPTP.end_date
  and   ASSACT.assignment_action_id = ACX_PROCESS_ID.assignment_action_id
  and   ACX_PROCESS_ID.context_id = CON_PROCESS_ID.context_id
  and   CON_PROCESS_ID.context_name = 'SOURCE_TEXT'
  and   PROCESS.result_value = ACX_PROCESS_ID.context_value
  and   PROCESS.run_result_id = PROCESS_RR.run_result_id
  and   PROCESS_RR.assignment_action_id = ASSACT.assignment_action_id
  and   PROCESS_RR.status in ('P','PA')
  and   PROCESS.input_value_id = PROCESS_IV.input_value_id
  and   PROCESS_IV.name = 'Contribution_Class'
  and   PACT.effective_date between PROCESS_IV.effective_start_date and PROCESS_IV.effective_end_date
  and   PACT.effective_date > to_date(to_char(PACT.effective_date, 'YYYY')||'01/01','YYYY/MM/DD')
  and   ACX_PROCESS_ID.context_value like 'IE_A%'
  and   PPTP.regular_payment_date >= trunc(BPTP.regular_payment_date,'Y')
  and   RR.entry_type <>'B'  -- Bug 3079945 start
  union all
  select nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0) weeks
  from  pay_run_result_values   TARGET
      , pay_run_results         RR
      , pay_assignment_actions  ASSACT
      , pay_balance_feeds_f     FEED
  where ASSACT.assignment_action_id in (select min(assignment_action_id) from
        pay_assignment_actions where assignment_id = p_assignment_id)
  and   FEED.balance_type_id +0 = p_balance_type_id
  and   FEED.input_value_id = TARGET.input_value_id
  and   nvl(TARGET.result_value,'0') <> '0'
  and   TARGET.run_result_id = RR.run_result_id
  and   RR.assignment_action_id = ASSACT.assignment_action_id
  and   RR.status in ('P','PA')
  and   RR.entry_type = 'B';*/
  --v_csr_iea_weeks csr_iea_weeks%ROWTYPE;
  -- Bug 3079945 End
  -- Cursor for retrieving the context and source id for
  -- payroll runs having prsi contribution class as A
  -- in the same tax year for which the archive is run
  /*CURSOR Cur_Act_Contexts IS
  SELECT pac.Context_ID,pac.Context_Value,pac.Assignment_action_id
  FROM   pay_action_contexts pac,pay_assignment_actions pas,
         pay_payroll_actions ppa,pay_payroll_actions appa
  WHERE  pac.Context_Value = 'IE_A'
  AND    pac.assignment_id = p_assignment_id
  AND    pas.assignment_action_id = pac.assignment_action_id
  AND    ppa.payroll_action_id = pas.payroll_action_id
  And    appa.payroll_action_id = g_archive_pact
  AND    to_char(appa.date_earned,'YYYY') = to_char(ppa.date_earned,'YYYY')
  AND    pac.assignment_action_id = (SELECT MAX(assignment_action_id)
                                      FROM pay_action_contexts
                                      WHERE Context_Value = 'IE_A'
                                      AND assignment_id = p_assignment_id);
  v_Cur_Act_Contexts Cur_Act_Contexts%ROWTYPE;*/
  --Bug 3079945 Start
  -- Cursor for retrieving the summed values for
  -- PRSI insurable weeks where Contribution Class
  -- starts with IE_A%
   l_prev_sequence number;
   l_current_sequence number;

   -- for bug 5383808, to get the action_sequence of run locked by
   -- the previous P45 archive.
   CURSOR cur_get_prev_run_seq is
   select paa.action_sequence
   from   pay_assignment_actions paa,
          pay_payroll_actions ppa,
          pay_action_interlocks pai,
	    pay_assignment_actions paa1
   where  paa1.source_action_id = p_last_p45_action
     and  pai.locking_action_id = paa1.assignment_action_id
    and   pai.locked_action_id = paa.assignment_action_id
    and   paa.assignment_id in (select papf.assignment_id
                                 from per_all_assignments_f papf
                                 where papf.person_id = p_person_id
                              )
    and   paa.tax_unit_id = g_paye_ref
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q','I','B','V');

   -- for bug 5383808, get the action_sequence of run locked by
   -- current p45 archive.
   CURSOR cur_get_curr_run_seq is
   select action_sequence
   from   pay_assignment_actions ppa
   where  assignment_action_id = p_source_id;

   --bug 5383808. IF previous P45 exists fetch the sum of PRSI insurable
   -- weeks for class between the current run action sequence locked by P45
   -- and run action locked by previous P45.
   CURSOR Cur_Act_Contexts(l_defined_bal_id number) IS
   SELECT sum(PAY_BALANCE_PKG.GET_VALUE(l_defined_bal_id, -- changes made
    			             pac.ASSIGNMENT_ACTION_ID,
                                   g_paye_ref,
                                   null,
                                   pac.CONTEXT_ID,
                                   pac.CONTEXT_VALUE,
                                   null,
                                   null))
  FROM   pay_action_contexts pac,
         pay_assignment_actions pas,
         pay_payroll_actions ppa
  WHERE  pac.Context_Value like 'IE_A%'
  AND    pac.assignment_id in (select papf.assignment_id
                                 from per_all_assignments_f papf
                                 where papf.person_id = p_person_id
                              )
  AND    pas.tax_unit_id = g_paye_ref
  AND    pas.assignment_action_id = pac.assignment_action_id
  AND    ppa.payroll_action_id = pas.payroll_action_id
 /*AND    ppa.date_earned between to_date('01-01-' || to_char(g_archive_start_date ,'YYYY'),'DD-MM-YYYY') --Bug Fix 3986250*/
  AND    ppa.effective_date between to_date('01-01-' || to_char(p_effective_date,'YYYY'),'DD-MM-YYYY') --Bug fix 4108423
  AND    g_archive_end_date
  and    pas.action_sequence > l_prev_sequence
  and    pas.action_sequence <= l_current_sequence;
/*  group by pac.context_id,pac.context_value;*/


  -- cursor to get defined balance id
  -- bug 5383808
  cursor csr_defined_bal_id(p_balance_name varchar2) is
	select defined_balance_id
	from   pay_balance_types pbt,
	       pay_balance_dimensions pbd,
		 pay_defined_balances pdb
	where  pbt.balance_name = p_balance_name
	and    pbt.balance_type_id = pdb.balance_type_id
	and    pbd.database_item_suffix = '_ASG_PAYE_REF_PRSI_RUN'
	and    pbd.balance_dimension_id = pdb.balance_dimension_id
	and    pbt.legislation_code = 'IE'
	and    pbd.legislation_code = 'IE';

-- get balance from EMEA balances
cursor get_prev_ins_bal is
   SELECT to_number(pai.action_information4)    balance_value
    FROM   pay_action_information pai
    WHERE  pai.action_context_id = p_last_p45_action
      AND  pai.action_information_category = 'EMEA BALANCES'
      AND  pai.action_information1 = p_defined_bal_id;

/* 7291676 */
CURSOR Cur_Act_Contexts_ppsn(l_defined_bal_id number,c_ppsn_override per_assignment_extra_info.aei_information1%type) IS
   SELECT sum(PAY_BALANCE_PKG.GET_VALUE(l_defined_bal_id, -- changes made
    			             pac.ASSIGNMENT_ACTION_ID,
                                   g_paye_ref,
                                   null,
                                   pac.CONTEXT_ID,
                                   pac.CONTEXT_VALUE,
                                   null,
                                   null))
  FROM   pay_action_contexts pac,
         pay_assignment_actions pas,
         pay_payroll_actions ppa
  WHERE  pac.Context_Value like 'IE_A%'
  AND    pac.assignment_id in (select paaf.assignment_id
                               from per_all_assignments_f paaf, per_assignment_extra_info paei
		               where paaf.person_id = p_person_id
			       and paaf.assignment_id=paei.assignment_id
			       and paei.information_type = 'IE_ASG_OVERRIDE'
			       and paei.aei_information1 = c_ppsn_override
                              )
  AND    pas.tax_unit_id = g_paye_ref
  AND    pas.assignment_action_id = pac.assignment_action_id
  AND    ppa.payroll_action_id = pas.payroll_action_id
 /*AND    ppa.date_earned between to_date('01-01-' || to_char(g_archive_start_date ,'YYYY'),'DD-MM-YYYY') --Bug Fix 3986250*/
  AND    ppa.effective_date between to_date('01-01-' || to_char(p_effective_date,'YYYY'),'DD-MM-YYYY') --Bug fix 4108423
  AND    g_archive_end_date
  and    pas.action_sequence > l_prev_sequence
  and    pas.action_sequence <= l_current_sequence;

cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;

   v_Cur_Act_Contexts Cur_Act_Contexts%ROWTYPE;
  --Bug 3079945 End
  l_action_info_id                 NUMBER;
  l_balance_value                  NUMBER:=0;
  l_balance_value_classA           NUMBER;
  l_ovn                            NUMBER;
  l_record_count                   VARCHAR2(10);
  l_proc                           VARCHAR2(50) := g_package || 'process_balance';
  l_balance_type_id                NUMBER;
  l_balance_value1                 NUMBER:=0;
  l_balance_value2                 NUMBER :=0;
  --bug 5383808
  l_p45_last_bal_value		     NUMBER :=0;
  l_defined_id			     NUMBER;
  l_pre_ins_bal			     number;
  --6615117
  l_source_null_flag NUMBER:= 0;

  BEGIN
   -- hr_utility.trace_on(null,'P45');
    hr_utility.set_location('Entering ' || l_proc,10);
    hr_utility.set_location('Step ' || l_proc,20);
    hr_utility.set_location('p_action_context_id      = ' || p_action_context_id,20);
    hr_utility.set_location('p_assignment_id      = ' || p_assignment_id,20);
    hr_utility.set_location('p_person_id      = ' || p_person_id,20);
    hr_utility.set_location('p_source_id      = ' || p_source_id,20);
    hr_utility.set_location('p_effective_date      = ' || p_effective_date,20);
    hr_utility.set_location('p_balance        = ' || p_balance,20);
    hr_utility.set_location('p_dimension      = ' || p_dimension,20);
    hr_utility.set_location('p_defined_bal_id = ' || p_defined_bal_id,20);
    hr_utility.set_location('p_record_count = ' || p_record_count,20);
    hr_utility.set_location('p_termination_date = ' || p_termination_date,20);
    hr_utility.set_location('p_supp_flag = ' || p_supp_flag,20);
    hr_utility.set_location('p_last_p45_action = ' || p_last_p45_action,20);
    hr_utility.set_location('p_last_p45_pact = ' || p_last_p45_pact,20);
    hr_utility.set_location('p_prev_src_id = ' || p_prev_src_id,20);

     IF p_balance = 'IE PRSI_ClassA Insurable Weeks'
     THEN
     		--bug 5383808
		OPEN cur_get_prev_run_seq;
		FETCH cur_get_prev_run_seq into l_prev_sequence;
		CLOSE cur_get_prev_run_seq;

		IF l_prev_sequence IS NULL THEN
			l_prev_sequence := 0;
		END IF;

		open cur_get_curr_run_seq;
		fetch cur_get_curr_run_seq into l_current_sequence;
		CLOSE cur_get_curr_run_seq;

		if l_current_sequence is null then
			l_current_sequence := 0;
		end if;

		/*OPEN csr_bal_type;
		FETCH csr_bal_type into l_balance_type_id;
		CLOSE csr_bal_type;*/


		open csr_defined_bal_id('IE PRSI Insurable Weeks');
		FETCH csr_defined_bal_id into l_defined_id;
		CLOSE csr_defined_bal_id;

            hr_utility.set_location ('l_prev_sequence..'||l_prev_sequence,200);
		hr_utility.set_location ('l_current_sequence..'||l_current_sequence,200);
		hr_utility.set_location ('l_defined_id..'||l_defined_id,200);
		--Commented code for bug fix 3079945
		/*OPEN csr_iea_weeks(l_balance_type_id);
		FETCH csr_iea_weeks into l_balance_value;
		CLOSE csr_iea_weeks; */
		/*OPEN Cur_Act_Contexts;
		FETCH Cur_Act_Contexts INTO v_Cur_Act_Contexts;
		IF Cur_Act_Contexts%FOUND
		THEN
			l_balance_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
                                                          v_Cur_Act_Contexts.ASSIGNMENT_ACTION_ID,
                                                          null,
                                                          null,
                                                          v_Cur_Act_Contexts.CONTEXT_ID,
                                                          v_Cur_Act_Contexts.CONTEXT_VALUE,
                                                          null,
                                                          null);
		END IF;
		CLOSE Cur_Act_Contexts;*/

		--Bug 3079945 start

		  /* 7291676 */
                 l_ppsn_override:=null;
	         OPEN csr_ppsn_override(p_assignment_id);
	         FETCH csr_ppsn_override INTO  l_ppsn_override;
	         CLOSE csr_ppsn_override;
                hr_utility.set_location('PPSN Override  value  = ' || l_ppsn_override,200);
		IF l_ppsn_override IS NOT NULL THEN
                OPEN  Cur_Act_Contexts_ppsn(l_defined_id,l_ppsn_override);
		FETCH Cur_Act_Contexts_ppsn into l_balance_value;
		CLOSE Cur_Act_Contexts_ppsn;
		ELSE
		OPEN  Cur_Act_Contexts(l_defined_id);
		FETCH Cur_Act_Contexts into l_balance_value;
		CLOSE Cur_Act_Contexts;
		END IF;


		--Bug 3079945 End
		/*IF nvl(p_supp_flag,'N') = 'N' AND (p_last_p45_action IS NOT NULL) then
			l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
    			                                                  p_last_p45_action,
											  g_paye_ref,
										        null,
										        null,
										        null,
										        null,
										        null);
			l_balance_value := l_balance_value - l_p45_last_bal_value;
		 END IF;*/
		 l_balance_value := nvl(l_balance_value,0);
		 hr_utility.set_location('IE PRSI_ClassA Insurable Weeks..'||l_balance_value,1000);
		 IF p_supp_flag = 'Y' AND p_last_p45_action IS NOT NULL THEN
			open get_prev_ins_bal;
			FETCH get_prev_ins_bal into l_pre_ins_bal;
			CLOSE get_prev_ins_bal;
			l_balance_value := l_balance_value + l_pre_ins_bal;
		 END IF;
		 hr_utility.set_location('After IE PRSI_ClassA Insurable Weeks..'||l_pre_ins_bal,1000.1);
       ELSE
  /*        l_balance_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
                                                      p_source_id );
  */
		--bug 5383808, call this only p_source_id is not null.
		if p_source_id is not null then
			l_balance_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
    			                 p_source_id,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
		--6615117
		Else
			l_source_null_flag := 1;
		end if;

		hr_utility.set_location('sg Supp Flag ='||p_supp_flag,36);
		hr_utility.set_location('sg Last P45 Action ='||p_last_p45_action,37);

		--bug 5383808
            IF (p_balance like 'IE Taxable Pay') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
			l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
    			                                                  p_prev_src_id,
											  g_paye_ref,
										        null,
										        null,
										        null,
										        null,
										        null);

			hr_utility.set_location('before IE Taxable Pay '||l_balance_value,204);
			hr_utility.set_location('before IE Taxable Pay '||l_p45_last_bal_value,205);
			hr_utility.set_location('p_last_p45_action '||p_last_p45_action,206);
			hr_utility.set_location('p_defined_bal_id '||p_defined_bal_id,207);
			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;

		END IF;


		IF (p_balance like 'IE P45 Pay') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
									  p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

		IF (p_balance like 'IE P45 Tax Deducted') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
                                                        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

		IF (p_balance like 'IE Net Tax') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
			l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
                                                        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;
		IF (p_balance like 'IE PRSI Insurable Weeks') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
								        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

	-- changes made for PRSI bug 5510536. To show this employment figures only.
		IF (p_balance like 'IE PRSI Employer') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
								        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

		IF (p_balance like 'IE PRSI K Employer Lump Sum') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
								        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

		IF (p_balance like 'IE PRSI M Employer Lump Sum') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
								        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

		IF (p_balance like 'IE PRSI Employee') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
								        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

		IF (p_balance like 'IE PRSI K Employee Lump Sum') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
								        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

		IF (p_balance like 'IE PRSI M Employee Lump Sum') AND (nvl(p_supp_flag,'N') = 'N') AND (p_last_p45_action IS NOT NULL) THEN
		      l_p45_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(p_defined_bal_id,
								        p_prev_src_id,
									  g_paye_ref,
								        null,
								        null,
								        null,
								        null,
								        null);

			--l_balance_value := l_balance_value - l_p45_last_bal_value;
			--6615117
			IF l_source_null_flag = 1 THEN
			  l_balance_value:= l_balance_value;
			ELSE
			  l_balance_value := l_balance_value - l_p45_last_bal_value;
			END IF;
		END IF;

	END IF;

	-- end changes made for PRSI

     --end bug 5383808
    hr_utility.set_location('l_balance_value = ' || l_balance_value,20);

    IF p_record_count = 0
    THEN
       l_record_count := NULL;
    ELSE
       l_record_count := p_record_count + 1;
    END IF;

    IF l_balance_value <> 0
    THEN
      hr_utility.set_location('Archiving EMEA BALANCES',20);
      pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
      , p_action_context_id            =>  p_action_context_id
      , p_action_context_type          =>  'AAP'
      , p_object_version_number        =>  l_ovn
      , p_assignment_id                =>  p_assignment_id
      , p_effective_date               =>  p_effective_date
      , p_source_id                    =>  p_source_id
      , p_source_text                  =>  NULL
      , p_action_information_category  =>  'EMEA BALANCES'
      , p_action_information1          =>  p_defined_bal_id
      , p_action_information2          =>  NULL
      , p_action_information3          =>  NULL
      , p_action_information4          =>  l_balance_value
      , p_action_information5          =>  l_record_count);
    END IF;

    hr_utility.set_location('Leaving ' || l_proc,30);
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      NULL;
  END process_balance;
  ---------------------
    PROCEDURE process_supp_balance (p_action_context_id IN NUMBER,
                                    p_assignment_id     IN NUMBER,
                                    p_person_id         IN NUMBER,
						p_source_id         IN NUMBER,
						p_effective_date    IN DATE,
						p_balance           IN VARCHAR2,
						p_dimension         IN VARCHAR2,
						p_defined_bal_id    IN NUMBER,
						p_record_count      IN NUMBER,
  						p_termination_date  IN DATE,
						p_supp_flag         IN VARCHAR2,
  						p_last_p45_action   IN NUMBER,
  						p_last_p45_pact     IN NUMBER,        -- Bug 5005788
  						p_ytd_balance       IN VARCHAR2,
  						p_ytd_def_bal_id    IN NUMBER)
    IS
    --
    -- Cursor for retrieving balance type id of defined balance
    --
    CURSOR csr_bal_type IS
     select balance_type_id
     from   pay_defined_balances
     where  defined_balance_id = p_defined_bal_id;

     CURSOR csr_get_curr_val(p_action_context_id NUMBER,p_def_bal_id NUMBER) IS
    SELECT to_number(pai.action_information4)    balance_value
    FROM   pay_action_information pai
    WHERE  pai.action_context_id = p_action_context_id
      AND  pai.action_information_category = 'EMEA BALANCES'
      AND  pai.action_information1 = p_def_bal_id;

-- cursor to fetch source_id from the last p45 action
CURSOR get_last_source_id is
select source_id from
	pay_action_information pai,
	pay_assignment_actions paa
where paa.assignment_action_id = p_last_p45_action
  and paa.assignment_action_id = pai.action_context_id
  and pai.action_information_category='EMEA BALANCES';


    --Bug 3079945 End
    l_action_info_id                 NUMBER;
    l_balance_value                  NUMBER:=0;
    l_balance_value_classA           NUMBER;
    l_ovn                            NUMBER;
    l_record_count                   VARCHAR2(10);
    l_proc                           VARCHAR2(50) := g_package || 'process_supp_balance';
    l_balance_type_id                NUMBER;
    l_balance_value1                 NUMBER:=0;
    l_prev_source_id			 number;
    BEGIN
      hr_utility.set_location('Entering ' || l_proc,10);
      hr_utility.set_location('Step ' || l_proc,20);
      hr_utility.set_location('p_action_context_id      = ' || p_action_context_id,20);  /* 7291676 */
      hr_utility.set_location('p_assignment_id      = ' || p_assignment_id,20);
      hr_utility.set_location('p_person_id      = ' || p_person_id,20);
      hr_utility.set_location('p_source_id      = ' || p_source_id,20);
      hr_utility.set_location('p_balance        = ' || p_balance,20);
      hr_utility.set_location('p_dimension      = ' || p_dimension,20);
      hr_utility.set_location('p_defined_bal_id = ' || p_defined_bal_id,20);

      hr_utility.set_location('p_last_p45_action      = ' || p_last_p45_action,20);
      hr_utility.set_location('p_action_context_id        = ' || p_action_context_id,20);
      hr_utility.set_location('p_last_p45_pact      = ' || p_last_p45_pact,20);
      hr_utility.set_location('p_ytd_balance = ' || p_ytd_balance,20);
      hr_utility.set_location('p_ytd_def_bal_id = ' || p_ytd_def_bal_id,20);

      OPEN csr_get_curr_val(p_action_context_id,p_ytd_def_bal_id);
      FETCH csr_get_curr_val INTO l_balance_value;
      CLOSE csr_get_curr_val;
	hr_utility.set_location('l_balance_value = ' || l_balance_value,20);

 --     l_balance_value := get_arc_bal_value(p_action_context_id,p_ytd_balance);

      IF p_last_p45_action IS NOT NULL THEN
	-- commented by vikas
	if p_balance = 'IE PRSI_ClassA Insurable WeeksASG_PTD' then
		l_balance_value1 := get_arc_bal_value(p_last_p45_action,p_last_p45_pact,p_ytd_balance);     -- Bug 5005788
	ELSE
		OPEN get_last_source_id;
		FETCH get_last_source_id into l_prev_source_id;
		CLOSE get_last_source_id;
		l_balance_value1 := PAY_BALANCE_PKG.GET_VALUE(p_ytd_def_bal_id,
						     l_prev_source_id,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);

      END IF;
	END IF;
	hr_utility.set_location('l_balance_value1 = ' || l_balance_value1,20);

      l_balance_value := l_balance_value - l_balance_value1;

      IF p_record_count = 0
      THEN
         l_record_count := NULL;
      ELSE
         l_record_count := p_record_count + 1;
      END IF;
      IF l_balance_value <> 0
      THEN
        hr_utility.set_location('Archiving EMEA BALANCES',20);
        pay_action_information_api.create_action_information (
          p_action_information_id        =>  l_action_info_id
        , p_action_context_id            =>  p_action_context_id
        , p_action_context_type          =>  'AAP'
        , p_object_version_number        =>  l_ovn
        , p_assignment_id                =>  p_assignment_id
        , p_effective_date               =>  p_effective_date
        , p_source_id                    =>  p_source_id
        , p_source_text                  =>  NULL
        , p_action_information_category  =>  'EMEA BALANCES'
        , p_action_information1          =>  p_defined_bal_id
        , p_action_information2          =>  NULL
        , p_action_information3          =>  NULL
        , p_action_information4          =>  l_balance_value
        , p_action_information5          =>  l_record_count);
      END IF;
      hr_utility.set_location('Leaving ' || l_proc,30);
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        NULL;
  END process_supp_balance;

  --------------------------------------------------------------------------------
-- To get the termination date and supplement flag
-- for bug 5383808
--------------------------------------------------------------------------------
PROCEDURE get_termination_date (p_action_context_id       IN  NUMBER,
                                p_assignment_id           IN  NUMBER,
                                p_person_id               IN NUMBER,
				p_date_earned		  IN DATE,
			        p_termination_date        OUT NOCOPY DATE,
				p_supp_pymt_date	  OUT NOCOPY DATE,
			        p_supp_flag		  OUT NOCOPY VARCHAR2,
			        p_deceased_flag           OUT NOCOPY VARCHAR2
			       ) is

CURSOR cur_service_leave IS
  select decode(ppos.leaving_reason, 'D','Y','N'),
        ppos.actual_termination_date
  from  per_periods_of_service ppos
  where ppos.person_id = p_person_id
  and   ppos.period_of_service_id = (select max(paf.period_of_service_id)
                                        from per_all_assignments_f paf,
                                             pay_assignment_actions paa,
  					               pay_action_interlocks pai
  	                               where   pai.locking_action_id = p_action_context_id
  				                 and pai.locked_action_id  = paa.assignment_action_id
                                         and paa.action_status = 'C'
                                         and paa.assignment_id = paf.assignment_id
                                     );

CURSOR cur_max_end_date IS
SELECT max(paaf.effective_end_date)
FROM  per_all_assignments_f paaf,
      pay_all_payrolls_f papf,
      hr_soft_coding_keyflex scl
WHERE paaf.person_id = p_person_id
  AND paaf.payroll_id = papf.payroll_id
  AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  AND scl.segment4 = to_char(g_paye_ref)
  AND paaf.assignment_status_type_id in
			   (SELECT ast.assignment_status_type_id
			      FROM per_assignment_status_types ast
			     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
			   )
  AND paaf.effective_end_date between g_archive_start_date and g_archive_end_date;

/* changed the cursor to handle case where 2 user defined assignment status exist mapping to
   same per_system_status (5073577) */
CURSOR cur_get_asg_end_date IS
SELECT max(effective_end_date)
FROM per_all_assignments_f paaf
WHERE paaf.assignment_id = p_assignment_id
  AND paaf.assignment_status_type_id in
			   (SELECT ast.assignment_status_type_id
			      FROM per_assignment_status_types ast
			     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
			   );



cursor cur_supp_run is
select act_inf.action_information3
 from  pay_assignment_actions paa_run,
       pay_action_interlocks pai,
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_action_information act_inf
 where ppa.payroll_action_id = paa.payroll_action_id
  and  ppa.report_type = 'P45'
  and  ppa.report_qualifier = 'IE'
  and  ppa.action_type = 'X'
  and  paa.assignment_action_id = act_inf.action_context_id
  and  act_inf.action_information_category = 'IE P45 INFORMATION'
  and  act_inf.action_context_type = 'AAP'
  and  ppa.payroll_action_id <> g_archive_pact
  and  paa.assignment_action_id = pai.locking_action_id
  and  paa.source_action_id is NULL
  and  pai.locked_action_id = paa_run.assignment_action_id
  and  paa_run.assignment_id = p_assignment_id
  and  paa_run.action_status = 'C'
  and  paa.action_status = 'C';


l_proc             CONSTANT VARCHAR2(50):= g_package||'get_termination_date';
l_deceased_flg              VARCHAR2(1);
l_termination_date          DATE;
l_start_date                DATE;
l_end_date                  DATE;
l_asg_end_date              DATE;
l_last_end_date             DATE;

BEGIN
     hr_utility.set_location('Entering ' || l_proc,20);
    hr_utility.set_location('Step ' || l_proc,20);
    hr_utility.set_location('p_action_context_id  = ' || p_action_context_id,20);
    hr_utility.set_location('p_assignment_id      = ' || p_assignment_id,20);
    hr_utility.set_location('p_person_id          = ' || p_person_id,20);
    hr_utility.set_location('g_paye_ref           = ' || g_paye_ref,20);
    hr_utility.set_location('p_termination_date           = ' || p_termination_date,20);



  -- get deceased flag, date of leaving
  OPEN cur_service_leave;
  FETCH cur_service_leave INTO l_deceased_flg,l_termination_date;
  CLOSE cur_service_leave;

  -- Copied to out variable (5600150)
  p_deceased_flag := l_deceased_flg;

  l_asg_end_date := l_termination_date;
  hr_utility.set_location('l_termination_date           = ' || l_termination_date,21);

  /* If employee is not terminated using end employment check for asg end date */
  IF l_termination_date IS NULL   THEN
  /* Get End Date of Employement with Employer */
	  OPEN cur_max_end_date;
	  FETCH cur_max_end_date INTO l_termination_date;
	  CLOSE cur_max_end_date;
  /* Get End Date of Assignment */
	  OPEN cur_get_asg_end_date;
	  FETCH cur_get_asg_end_date INTO l_asg_end_date;
	  CLOSE cur_get_asg_end_date;
  END IF;
 hr_utility.set_location('l_termination_date           = ' || l_termination_date,22);
 p_termination_date := l_termination_date;
 OPEN cur_supp_run;
  FETCH cur_supp_run INTO l_last_end_date;
  hr_utility.set_location('l_last_end_date = '|| l_last_end_date,20);
  IF l_last_end_date IS NOT NULL THEN
  --IF l_report_type_count >= 1 THEN
     p_supp_pymt_date := p_date_earned;
     p_supp_flag:= 'Y';
     p_termination_date := l_last_end_date;
    ELSE
     p_supp_flag:= 'N';
     p_supp_pymt_date :=null;
  END IF;
END get_termination_date;

  ------------------------------------------------------------
  -- for bug 5383808, made the p_supp_flag,p_termination_date and
  -- p_supp_pymt_date as in parameters.
  -- added p_deceased_flag as out variable 5600150
  PROCEDURE archive_p45_info(p_action_context_id       IN  NUMBER,
                             p_assignment_id           IN  NUMBER,
                             p_payroll_id              IN  NUMBER,
                             p_date_earned             IN  DATE,
                             p_child_run_ass_act_id    IN  NUMBER,
			     p_supp_flag               IN VARCHAR2, -- 5383808
			     p_person_id               IN NUMBER,
			     p_termination_date        in DATE, -- 5383808
			     p_child_pay_action        IN NUMBER,
			     p_supp_pymt_date	       IN DATE,
			     p_deceased_flag           IN VARCHAR2
				     ) -- 5383808
  IS
  l_action_info_id            NUMBER(15);
  l_proc             CONSTANT VARCHAR2(50):= g_package||'archive_p45_info';
  l_ovn                       NUMBER;
  l_deceased_flg              VARCHAR2(1);
  l_termination_date          DATE;
  l_period_num                NUMBER;
  l_calculation_option        VARCHAR2(15);
  l_non_cum_tax               VARCHAR2(20);
  l_noncum_ben_operated       VARCHAR2(5);
  l_emer_tax_operated         VARCHAR2(1);
  l_defined_balance_id        NUMBER;
  l_emer_num                  NUMBER;
  l_emer_basis_flg            VARCHAR2(1);
  l_supp_flg                  VARCHAR2(1);
  l_report_type_count         NUMBER;
  l_supp_pymt_date            DATE;
  l_number_per_fiscal_year    NUMBER;
  l_periods_per_period        NUMBER;
  l_start_date                DATE;
  l_end_date                  DATE;
  l_p45_period_num            NUMBER;
  -- Bug 2943335
  l_balance_name              varchar2(80);
  l_soc_ben_defined_bal_id     NUMBER;
  l_disability_ben_amount      NUMBER;
  l_soc_ben_amount             NUMBER;
  l_asg_end_date               DATE;
  l_last_end_date              DATE;

  -- variable used to fetch Tax Basis 5128377
  l_tax_basis                 VARCHAR2(20);
  --
  CURSOR cur_service_leave IS
  select decode(ppos.leaving_reason, 'D','Y','N'),
        ppos.actual_termination_date
  from  per_periods_of_service ppos
  where ppos.person_id = p_person_id
  and   ppos.period_of_service_id = (select max(paf.period_of_service_id)
                                        from per_all_assignments_f paf,
                                             pay_assignment_actions paa,
  					               pay_action_interlocks pai
  	                               where   pai.locking_action_id = p_action_context_id
  				                 and pai.locked_action_id  = paa.assignment_action_id
                                         and paa.action_status = 'C'
                                         and paa.assignment_id = paf.assignment_id
                                     );
  /*
     SELECT  decode(ppos.leaving_reason, 'D','Y','N'),
             ppos.actual_termination_date
      FROM per_periods_of_service ppos,
           per_all_assignments_f paf
      WHERE  paf.assignment_id = p_assignment_id
      AND    ppos.period_of_service_id = paf.period_of_service_id;
   */
/* changed the cursor to handle case where 2 user defined assignment status exist mapping to
   same per_system_status (5073577) */
CURSOR cur_max_end_date IS
SELECT max(paaf.effective_end_date)
FROM  per_all_assignments_f paaf,
      pay_all_payrolls_f papf,
      hr_soft_coding_keyflex scl
WHERE paaf.person_id = p_person_id
  AND paaf.payroll_id = papf.payroll_id
  AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  AND scl.segment4 = to_char(g_paye_ref)
  AND paaf.assignment_status_type_id in
			   (SELECT ast.assignment_status_type_id
			      FROM per_assignment_status_types ast
			     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
			   )
  AND paaf.effective_end_date between g_archive_start_date and g_archive_end_date;

/* changed the cursor to handle case where 2 user defined assignment status exist mapping to
   same per_system_status (5073577) */
CURSOR cur_get_asg_end_date IS
SELECT max(effective_end_date)
FROM per_all_assignments_f paaf
WHERE paaf.assignment_id = p_assignment_id
  AND paaf.assignment_status_type_id in
			   (SELECT ast.assignment_status_type_id
			      FROM per_assignment_status_types ast
			     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
			   );

-- Bug 2943335 used balance name as a parameter
  CURSOR cur_defined_balance(l_balance_name IN varchar2 ) IS
     SELECT pdb.defined_balance_id
      FROM   pay_balance_types pbt,
            pay_balance_dimensions pbd,
            pay_defined_balances pdb
      WHERE  pdb.balance_type_id = pbt.balance_type_id
        AND  pdb.balance_dimension_id = pbd.balance_dimension_id
        AND  UPPER(pbt.balance_name) = UPPER(l_balance_name)
        AND  pbd.database_item_suffix = '_PER_PAYE_REF_YTD';
-- Bug
  cursor cur_period_num is
     select  ptp.period_num,
             ptpt.number_per_fiscal_year,
             ptpr.periods_per_period,
             ptp.start_date,
             ptp.end_date
      from   per_all_assignments_f paf,
             per_time_periods ptp,
             per_time_period_types ptpt,
             per_time_period_rules ptpr
     where   paf.assignment_id = p_assignment_id
       and   p_date_earned between paf.effective_start_date
                               and paf.effective_end_date
       and   paf.payroll_id = ptp.payroll_id
       and   p_date_earned between ptp.start_date and ptp.end_date
       and   ptp.period_type = ptpt.period_type
       and   ptpt.number_per_fiscal_year = ptpr.number_per_fiscal_year;

  --Bug:2450336
  -- Bug 2943335 commented unwanted cursor
 /* cursor cur_cal_option is
     select calculation_option
      from pay_ie_social_benefits_f psb
     where psb.assignment_id = p_assignment_id; */
  -- Bug 4315023 Removed Pay_element_types_f join for performance
  cursor cur_non_cum_tax is
     select result_value
      from  pay_run_result_values   prr,
            pay_run_results         pr,
            pay_input_values_f      piv,
            pay_assignment_actions  pas,
            pay_payroll_actions ppa
      where pas.assignment_id in (select assignment_id
                                    from per_all_assignments_f
                                    where person_id = p_person_id)
       and  pas.tax_unit_id  = g_paye_ref
       and  pas.payroll_action_id = ppa.payroll_action_id
       and  to_char(ppa.effective_date,'YYYY') = to_char(p_date_earned,'YYYY')
       and  pr.assignment_action_id   =   pas.assignment_action_id
       and  pr.run_result_id          =   prr.run_result_id
       and  prr.input_value_id        =   piv.input_value_id
       and  pr.element_type_id         =   piv.element_type_id
       and  piv.input_value_id        =   g_tax_basis_id
       and  piv.business_group_id     IS NULL
       and  piv.legislation_code      =  'IE'
       and  result_value not in ('IE_CUMULATIVE', 'C','IE_EXEMPTION');
 /*
 cursor cur_supp_run is
   select count(*)
   from pay_action_information pai,
        pay_assignment_Actions paa
   where paa.assignment_action_id = pai.action_context_id
     and pai.action_context_type = 'AAP'
     and pai.action_information_category = 'IE P45 INFORMATION'
     and paa.tax_unit_id = g_paye_ref
     and paa.assignment_id in (     select assignment_id
                                    from per_all_assignments_f
				    where person_id = p_person_id
                               )
     and to_date(pai.action_information3) = l_termination_date;
    -- and fnd_date.canonical_to_date(pai.action_information3) = l_termination_date;
 */

/* cursor cur_supp_run is
select act_inf.action_information3
 from  pay_assignment_actions paa_run,
       pay_action_interlocks pai,
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_action_information act_inf
 where ppa.payroll_action_id = paa.payroll_action_id
  and  ppa.report_type = 'P45'
  and  ppa.report_qualifier = 'IE'
  and  ppa.action_type = 'X'
  and  paa.assignment_action_id = act_inf.action_context_id
  and  act_inf.action_information_category = 'IE P45 INFORMATION'
  and  act_inf.action_context_type = 'AAP'
  and  ppa.payroll_action_id <> g_archive_pact
  and  paa.assignment_action_id = pai.locking_action_id
  and  paa.source_action_id is NULL
  and  pai.locked_action_id = paa_run.assignment_action_id
  and  paa_run.assignment_id = p_assignment_id
  and  paa_run.action_status = 'C'
  and  paa.action_status = 'C'; */

-- Commented as Tax Basis is now fetched from Run Results (5128377)
/*Bug 4050372 */
/*
 cursor cur_tax_basis(l_termination_date date)
  is
  select 'N'
    from  pay_ie_paye_details_f
    where assignment_id=p_assignment_id
    and   l_termination_date between effective_start_date and effective_end_date
    and   tax_basis not in ('IE_EMERGENCY','IE_EMERGENCY_NO_PPS');
*/
  BEGIN
  --
     hr_utility.set_location('Entering ' || l_proc,20);
    hr_utility.set_location('Step ' || l_proc,20);
    hr_utility.set_location('p_action_context_id  = ' || p_action_context_id,20);
    hr_utility.set_location('p_payroll_id      = ' || p_payroll_id,20);
    hr_utility.set_location('p_assignment_id      = ' || p_assignment_id,20);
    hr_utility.set_location('p_person_id          = ' || p_person_id,20);
    hr_utility.set_location('g_paye_ref           = ' || g_paye_ref,20);
    hr_utility.set_location('p_date_earned      = ' || p_date_earned,20);
    hr_utility.set_location('p_child_run_ass_act_id      = ' || p_child_run_ass_act_id,20);


   -- get deceased flag, date of leaving
  /* OPEN cur_service_leave;
     FETCH cur_service_leave INTO l_deceased_flg,l_termination_date;
     CLOSE cur_service_leave;

  l_asg_end_date := l_termination_date;

  -- If employee is not terminated using end employment check for asg end date
  IF l_termination_date IS NULL   THEN
  -- Get End Date of Employement with Employer
	  OPEN cur_max_end_date;
	  FETCH cur_max_end_date INTO l_termination_date;
	  CLOSE cur_max_end_date;
-- Get End Date of Assignment
	  OPEN cur_get_asg_end_date;
	  FETCH cur_get_asg_end_date INTO l_asg_end_date;
	  CLOSE cur_get_asg_end_date;
  END IF;
 p_termination_date := l_termination_date;*/
  -- check whether this is a supplementary run
  -- and get the payment date of supplementary run
  /*OPEN cur_supp_run;
  FETCH cur_supp_run INTO l_last_end_date;
  hr_utility.set_location('l_last_end_date = '|| l_last_end_date,20);
  IF l_last_end_date IS NOT NULL THEN
  --IF l_report_type_count >= 1 THEN
     l_supp_flg :='Y';
     l_supp_pymt_date := p_date_earned;
     p_supp_flag:= 'Y';
     p_termination_date := l_last_end_date;
     l_termination_date := l_last_end_date;
  ELSE
     l_supp_flg :='N';
     p_supp_flag:= 'N';
     l_supp_pymt_date :=null;
  END IF;*/

  l_supp_flg := p_supp_flag;
  l_supp_pymt_date := p_supp_pymt_date;
  l_termination_date := p_termination_date;
  hr_utility.set_location('supplementary flag = '||l_supp_flg,20);
  hr_utility.set_location('supplementary date = '||l_supp_pymt_date,20);
  --
  --
  -- get pay_period_number
  OPEN cur_period_num;
  FETCH cur_period_num INTO l_period_num, l_number_per_fiscal_year, l_periods_per_period, l_start_date, l_end_date;
  CLOSE cur_period_num;
  hr_utility.set_location('period number = '||l_period_num,20);
  hr_utility.set_location('number per fiscal year : '||l_number_per_fiscal_year,20);
  hr_utility.set_location('periods per period : '||l_periods_per_period,20);
  hr_utility.set_location('start date : '||l_start_date,20);
  hr_utility.set_location('end date : '||l_end_date,20);
  --
  If l_periods_per_period = 1 then
     l_p45_period_num := l_period_num;
  Elsif l_asg_end_date between l_start_date and l_end_date then
     If l_number_per_fiscal_year in (13,26,52) then
        l_p45_period_num := (((l_period_num - 1) * l_periods_per_period) + (ceil(((l_asg_end_date) - (l_start_date))/7)));
     Else
        l_p45_period_num := (((l_period_num - 1) * l_periods_per_period) + (ceil(months_between((l_asg_end_date),(l_start_date)))));
     End If;
  Else
       l_p45_period_num := (l_period_num * l_periods_per_period);
  End If;
  --
  -- get emergency_tax_operated_flg
  -- Bug 2943335 passed 'IE EMERGENCY PERIOD' as a parameter to cursor which was earlier hardcoded
  /* OPEN cur_defined_balance('IE EMERGENCY PERIOD');
   FETCH cur_defined_balance INTO l_defined_balance_id;
   CLOSE cur_defined_balance;
   hr_utility.set_location('defined balance = '||l_defined_balance_id,20);
   l_emer_num := pay_balance_pkg.get_value(p_defined_balance_id => l_defined_balance_id
                                          ,p_assignment_action_id => p_child_run_ass_act_id);
   IF l_emer_num >0 THEN
     l_emer_basis_flg :='Y';
   ELSE
     l_emer_basis_flg :='N';
   END IF;*/
/*Bug 4050372*/
   l_emer_basis_flg := 'Y';

-- Emergency Flag is now fetched from Run Results 5128377
-- for bug 5386432, call only if p_child_run_ass_act_id is not null
IF p_child_run_ass_act_id IS NOT NULL THEN
    l_tax_basis := pay_ie_archive_detail_pkg.get_tax_details (
                                p_run_assignment_action_id => p_child_run_ass_act_id
                               ,p_input_value_id           => g_tax_basis_id
                               ,p_date_earned              => to_char(p_date_earned, 'yyyy/mm/dd'));
END IF;

/*
   OPEN cur_tax_basis(l_asg_end_date);
   FETCH cur_tax_basis INTO l_emer_basis_flg;
   CLOSE cur_tax_basis;
*/
IF l_tax_basis NOT IN('IE_EMERGENCY','IE_EMERGENCY_NO_PPS') THEN
	l_emer_basis_flg := 'N';
END IF;

   hr_utility.set_location('emergency basis = '||l_emer_basis_flg,20);
   --
  -- get non_cumulative_operated for benefits
-- Bug 2943335 Commented out code below
  /* OPEN cur_cal_option;
   FETCH cur_cal_option INTO l_calculation_option;
   hr_utility.set_location('l_calculation_option'||l_calculation_option,20);
   --Bug:2450336
    IF l_calculation_option IN  ('IE_OPTION3','IE_OPTION4') THEN
       l_noncum_ben_operated := 'Y';
    ELSIF l_calculation_option  IN  ('IE_OPTION1','IE_OPTION2') THEN */
-- Bug 2943335
  --
  -- get Social benefits amount paid
  -- From 1-jan-2006 noncumulative value does not depend upon social benefit
-- amount. Bug 5519933. Removed the check.

   /*OPEN cur_defined_balance('IE Taxable Social Benefit');
   FETCH cur_defined_balance INTO l_soc_ben_defined_bal_id;
   CLOSE cur_defined_balance;
   hr_utility.set_location('defined balance id = '||l_soc_ben_defined_bal_id,25);

-- bug 5386432, call only if p_child_run_ass_act_id is not null
   IF p_child_run_ass_act_id IS NOT NULL THEN
	l_soc_ben_amount := pay_balance_pkg.get_value(l_soc_ben_defined_bal_id,
                                                 p_child_run_ass_act_id
                                                ,g_paye_ref
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                );
   end if;
   hr_utility.set_location('benefit amount = '||l_soc_ben_amount,25);
-- Check this to identify if employee was ever paid social benefit amount
-- Replacing fix for Bug:2450336
IF ( l_soc_ben_amount <> 0) THEN */
-- end of changes for Bug 2943335
-- commented for Bug 5519933.
-- If Employee is terminated and rehired in same tax year tax details of previous termination are
-- reported in this termination against non cumulative flag
 /*
      OPEN cur_non_cum_tax;
      FETCH cur_non_cum_tax INTO l_non_cum_tax;
      hr_utility.set_location('l_non_cum_tax'||l_non_cum_tax,20);

      IF cur_non_cum_tax%FOUND THEN
        l_noncum_ben_operated := 'true';
      ELSE
        l_noncum_ben_operated := 'false';
      END IF;
      CLOSE cur_non_cum_tax;
*/
l_noncum_ben_operated := 'false';
IF l_tax_basis NOT IN('IE_CUMULATIVE', 'C','IE_EXEMPTION') THEN
	l_noncum_ben_operated := 'true';
END IF;

/*ELSE
      l_noncum_ben_operated := 'false';
END IF;*/

  -- CLOSE cur_cal_option;
  hr_utility.set_location('non cum basis operated = '||l_noncum_ben_operated,20);
   --
   -- archive the details
    pay_action_information_api.create_action_information (
         p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_action_context_id
       , p_action_context_type          =>  'AAP'
       , p_object_version_number        =>  l_ovn
       , p_effective_date               =>  g_archive_effective_date
       , p_source_id                    =>  p_child_pay_action
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'IE P45 INFORMATION'
       , p_action_information1          =>  p_deceased_flag
       , p_action_information2          =>  l_supp_flg
       , p_action_information3          =>  l_termination_date
       , p_action_information4          =>  l_emer_basis_flg
       , p_action_information5          =>  l_p45_period_num
       , p_action_information6          =>  l_noncum_ben_operated
       , p_action_information7          =>  l_supp_pymt_date
       , p_action_information8          =>  p_person_id
       , p_action_information9          =>  p_date_earned --7291676
      );
  --
  hr_utility.set_location('Leaving '||l_proc,20);
  END archive_p45_info;
 ---------------------------------------------------------------------------------
  --Moved the archiving Payroll Action Level Info archivng part from range_cursor 4468864
  PROCEDURE archive_deinit(p_payroll_action_id IN NUMBER) IS
  l_proc    CONSTANT VARCHAR2(50):= g_package||'archive_deinit';
    -- vars for constructing the sqlstr
    l_range_cursor              VARCHAR2(4000) := NULL;
    l_parameter_match           VARCHAR2(500)  := NULL;
    l_ovn                       NUMBER(15);
    l_request_id                NUMBER;
    l_action_info_id            NUMBER(15);
    l_business_group_id         NUMBER;
    g_tax_dis_ref               varchar2(10);
  CURSOR csr_check_archived(p_pact_id NUMBER) IS
  SELECT 1
  FROM   DUAL
  WHERE EXISTS (SELECT NULL
  		FROM pay_action_information pai
  		WHERE pai.action_context_id = p_pact_id
  		AND   pai.action_context_type = 'PA'
  		AND   rownum = 1
  	       );
    CURSOR csr_input_value_id(p_element_name CHAR,
                              p_value_name   CHAR) IS
    SELECT pet.element_type_id,
           piv.input_value_id
    FROM   pay_input_values_f piv,
           pay_element_types_f pet
    WHERE  piv.element_type_id = pet.element_type_id
    AND    pet.legislation_code = 'IE'
    AND    pet.element_name = p_element_name
    AND    piv.name = p_value_name;
-- Archive all the prepayments information locked by the P45 4468864
    CURSOR csr_payroll_info(p_pact_id NUMBER,
                       --     p_payroll_id       NUMBER,
                       --     p_consolidation_id NUMBER,
                            p_start_date       DATE,
                            p_end_date         DATE,
	--		    g_tax_dis_ref      VARCHAR2,
	                    g_paye_ref         NUMBER) IS
    SELECT pact.payroll_action_id payroll_action_id,
           pact.effective_date effective_date,
           pact.date_earned date_earned,
           pact.payroll_id payroll_id,
           org.org_information1 tax_details_ref_no,
           org.org_information2 employer_paye_ref_no,
           hrl.address_line_1 employer_tax_addr1,
           hrl.address_line_2 employer_tax_addr2,
           hrl.address_line_3 employer_tax_addr3,
           hrl.telephone_number_1 employer_tax_ref_phone
           --
    FROM   pay_all_payrolls_f ppf,
           pay_payroll_actions pact,
           hr_organization_information org,
	   hr_soft_coding_keyflex flex,
	   hr_organization_units hou,
	   hr_locations_all hrl
    WHERE  org.org_information_context = 'IE_EMPLOYER_INFO' -- for migration changes 4369280
    AND    ppf.business_group_id = hou.business_group_id
    AND    org.organization_id   = hou.organization_id
    AND    hou.location_id       = hrl.location_id(+)
        /*
           org.org_information_context = 'IE_ORG_INFORMATION'
    AND    ppf.business_group_id = org.organization_id
         */
    AND    pact.payroll_id = ppf.payroll_id
    AND    pact.effective_date BETWEEN
                 ppf.effective_start_date AND ppf.effective_end_date
--    AND    pact.payroll_id = NVL(p_payroll_id,pact.payroll_id)
--    AND    ppf.consolidation_set_id = p_consolidation_id
    AND    pact.effective_date BETWEEN
                 p_start_date AND nvl(p_end_date,to_date('31-12-4712','dd-mm-rrrr'))
    AND    (pact.action_type = 'P' OR
            pact.action_type = 'U')
    AND    pact.action_status = 'C'
    --Added for bug fix 3567562, to filter payroll information based on PAYE reference
    AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
    AND    org.organization_id  = flex.segment4
    /*
    AND    org.org_information1 = flex.segment1
    AND    org.org_information2 = flex.segment3
    */
--    AND    org.org_information_id  = g_tax_dis_ref
 --   AND    org.org_information2 = g_paye_ref
      AND    org.organization_id = g_paye_ref
    AND    exists  		   (SELECT NULL
  				    FROM   pay_assignment_actions paa,
  				    	   pay_action_interlocks pai,
  				    	   pay_assignment_actions paa_arc
  				    WHERE  pai.locked_action_id = paa.assignment_action_id
  				    AND    pai.locking_action_id = paa_arc.assignment_action_id
  				    AND    paa_arc.payroll_action_id = p_pact_id
  				    AND    paa.payroll_action_id  = pact.payroll_action_id
  				   );
  l_check_payroll_info VARCHAR2(1):='N';
  -- Cursor csr_get_org_tax_address
  CURSOR csr_get_org_tax_address(-- c_consolidation_set PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_ID%type
                       --          ,g_tax_dis_ref varchar2,
                                 g_paye_ref    number
                                  ) IS
  SELECT
           hrl.address_line_1        employer_tax_addr1,
           hrl.address_line_2        employer_tax_addr2,
           hrl.address_line_3        employer_tax_addr3,
           org_info.org_information4 employer_tax_contact,
           hrl.telephone_number_1    employer_tax_ref_phone,
           org_all.name              employer_tax_rep_name,
          org_all.business_group_id     business_group_id
           --
    FROM   hr_all_organization_units   org_all
          ,hr_organization_information org_info
      --    ,pay_consolidation_sets pcs
          ,hr_locations_all hrl
    WHERE  /*pcs.consolidation_set_id  = c_consolidation_set
    AND    org_all.organization_id   = pcs.business_group_id
    AND    org_info.organization_id  = org_all.organization_id
    AND    org_info.org_information_context  = 'IE_ORG_INFORMATION'
    AND    org_all.business_group_id   = pcs.business_group_id
    AND*/    org_info.organization_id  = org_all.organization_id
    AND    org_info.org_information_context  = 'IE_EMPLOYER_INFO' --for migration changes 4369280
    AND    org_all.location_id = hrl.location_id (+)
    --Added new condition for bug fix 3567562 to filter record based on PAYE reference and Tax District Reference
--    AND    org_info.org_information1 = g_tax_dis_ref
 --   AND    org_info.org_information2 = g_paye_ref ;
      AND    org_info.organization_id = g_paye_ref ;
  ---- Cursor csr_check_archive
  CURSOR  csr_check_archive( cp_payroll_action_id number
                            ,cp_payroll_id        number
                            ,cp_effective_date    date) IS
    SELECT  DISTINCT paf.organization_id
    FROM    per_all_assignments_f paf
    WHERE   paf.payroll_id = cp_payroll_id
    AND     cp_effective_date between paf.effective_start_date
                              AND     paf.effective_end_date
    AND     NOT EXISTS (
            SELECT  NULL
            FROM    pay_action_information pai
            WHERE   pai.action_context_id           = cp_payroll_action_id
            AND     pai.action_context_type         = 'PA'
            AND     pai.action_information_category = 'ADDRESS DETAILS'
            AND     pai.action_information1         = paf.organization_id
            AND     pai.action_information14        = 'Employer Address');
-- Archive against only those prepayments which are locked by P45 4468864
-- Commented to improve the performance 4771780
/*
    CURSOR csr_all_payroll_info(p_pact_id       NUMBER) IS
      SELECT pact.payroll_action_id payroll_action_id,
             pact.effective_date effective_date
      FROM   pay_assignment_actions paa,
             pay_action_interlocks pai,
             pay_assignment_actions paa_arc,
             pay_payroll_actions pact
      WHERE  pai.locked_action_id = paa.assignment_action_id
      AND    pai.locking_action_id = paa_arc.assignment_action_id
      AND    paa_arc.payroll_action_id = p_pact_id
      AND    paa.payroll_action_id  = pact.payroll_action_id
      AND    (pact.action_type = 'P' OR
              pact.action_type = 'U')
    AND    pact.action_status = 'C';
 */
  l_dummy                           NUMBER;
  l_assignment_set_id               NUMBER;
  l_bg_id                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               NUMBER;
  l_end_date                        VARCHAR2(30);
  l_legislation_code                VARCHAR2(30) := 'IE';
  l_payroll_id                      NUMBER;
  l_start_date                      VARCHAR2(30);
  l_tax_period_no                   VARCHAR2(30);
  l_curr_payroll_id                 NUMBER;
  l_error                           varchar2(1) ;
  l_archived                        NUMBER;
BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);
  l_archived := 0;
-- Check whether assignment action is retried 4468864
  OPEN csr_check_archived(p_payroll_action_id);
  FETCH csr_check_archived INTO l_archived;
  CLOSE csr_check_archived;
IF l_archived = 0 THEN
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => p_payroll_action_id
    , p_token_name        => 'EMPLOYER'
    , p_token_value       => g_paye_ref);
    /*
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => p_payroll_action_id
    , p_token_name        => 'CONSOLIDATION'
    , p_token_value       => l_consolidation_set);
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => p_payroll_action_id
    , p_token_name        => 'ASSIGNMENT_SET'
    , p_token_value       => l_assignment_set_id);
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => p_payroll_action_id
    , p_token_name        => 'START_DATE'
    , p_token_value       => l_start_date);
    */
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => p_payroll_action_id
    , p_token_name        => 'END_DATE'
    , p_token_value       => l_end_date);

 pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => p_payroll_action_id
    , p_token_name        => 'START_DATE'
    , p_token_value       => l_start_date);

    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => p_payroll_action_id
    , p_token_name        => 'BG_ID'
    , p_token_value       => l_bg_id);
    hr_utility.set_location('Step ' || l_proc,20);
    l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
    l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');
--get_paye_reference (l_consolidation_set,g_paye_ref,l_bg_id,l_canonical_start_date,l_canonical_end_date,l_error);
/*if l_error ='Y' then
   NULL;
else
*/
    FOR tax_info_rec IN csr_get_org_tax_address (g_paye_ref) LOOP
    --
    pay_action_information_api.create_action_information (
      p_action_information_id        => l_action_info_id
    , p_action_context_id            => p_payroll_action_id
    , p_action_context_type          => 'PA'
    , p_object_version_number        => l_ovn
    , p_action_information_category  => 'ADDRESS DETAILS'
    , p_action_information1          => tax_info_rec.business_group_id
    , p_action_information5          => tax_info_rec.employer_tax_addr1
    , p_action_information6          => tax_info_rec.employer_tax_addr2
    , p_action_information7          => tax_info_rec.employer_tax_addr3
    , p_action_information14         => 'IE Employer Tax Address'
    , p_action_information26         => tax_info_rec.employer_tax_contact
    , p_action_information27         => tax_info_rec.employer_tax_ref_phone
    , p_action_information28         => tax_info_rec.employer_tax_rep_name);
    --
    END LOOP;
    l_curr_payroll_id:= -1;
    FOR rec_payroll_info in csr_payroll_info(p_payroll_action_id,
                                    --         l_payroll_id,
                                    --         l_consolidation_set,
                                             l_canonical_start_date,
                                             l_canonical_end_date,
					--     g_tax_dis_ref,
					     g_paye_ref)
    LOOP
      -- Cursor csr_check_archive called
      OPEN csr_check_archive( p_payroll_action_id
                         ,rec_payroll_info.payroll_id
                         ,l_canonical_end_date);
      FETCH csr_check_archive INTO l_dummy;
      IF csr_check_archive%FOUND THEN
           pay_emp_action_arch.arch_pay_action_level_data (
                          p_payroll_action_id => p_payroll_action_id
                        , p_payroll_id        => rec_payroll_info.payroll_id
                        , p_effective_date    => l_canonical_end_date);
      END IF;
      CLOSE csr_check_archive;
           hr_utility.set_location('rec_payroll_info.payroll_action_id   = ' || rec_payroll_info.payroll_action_id,30);
           hr_utility.set_location('rec_payroll_info.tax_details_ref     = ' || rec_payroll_info.tax_details_ref_no,30);
           hr_utility.set_location('rec_payroll_info.employers_paye_ref_no    = ' || rec_payroll_info.employer_paye_ref_no,30);
         hr_utility.set_location('Archiving EMEA PAYROLL INFO',30);
         pay_action_information_api.create_action_information (
           p_action_information_id        =>  l_action_info_id
         , p_action_context_id            =>  p_payroll_action_id
         , p_action_context_type          =>  'PA'
         , p_object_version_number        =>  l_ovn
         , p_effective_date               =>  rec_payroll_info.effective_date
         , p_source_id                    =>  NULL
         , p_source_text                  =>  NULL
         , p_action_information_category  =>  'EMEA PAYROLL INFO'
         , p_action_information1          =>  rec_payroll_info.payroll_action_id
         , p_action_information2          =>  rec_payroll_info.payroll_id
         , p_action_information3          =>  l_consolidation_set
         , p_action_information4          =>  rec_payroll_info.tax_details_ref_no
         , p_action_information5          =>  rec_payroll_info.employer_tax_ref_phone
         , p_action_information6          =>  rec_payroll_info.employer_paye_ref_no
         , p_action_information8          =>  rec_payroll_info.employer_tax_addr1
         , p_action_information9          =>  rec_payroll_info.employer_tax_addr2
         , p_action_information10         =>  rec_payroll_info.employer_tax_addr3);
/* Coomented to improve the performance 4771780 since the cursor csr_all_payroll_info has high cost.
  as the same cursor csr_payroll_info can be used to get the required details */
/*
     END LOOP;
      -- setup statutory balances pl/sql table
      pay_ie_p45_archive.setup_standard_balance_table;
      FOR rec_payroll_info in csr_all_payroll_info(p_payroll_action_id)
      LOOP
 */
      hr_utility.trace('Entered payroll info');
      pay_balance_pkg.set_context('PAYROLL_ACTION_ID'
                                 , rec_payroll_info.payroll_action_id);
      pay_ie_p45_archive.setup_balance_definitions(p_payroll_action_id,
                                                   rec_payroll_info.payroll_action_id,
                                                   rec_payroll_info.effective_date);
      END LOOP;
--end if;
END IF;
  Exception
  when others then
   hr_utility.set_location('Leaving via exception section ' || l_proc,40);
  END archive_deinit;

 ---------------------------------------------------------------------------------

  PROCEDURE range_cursor (pactid IN NUMBER,
                          sqlstr OUT nocopy VARCHAR2)
  -- public procedure which archives the payroll information, then returns a
  -- varchar2 defining a SQL statement to select all the people that may be
  -- eligible for payslip reports.
  -- The archiver uses this cursor to split the people into chunks for parallel
  -- processing.
  IS
  --
  l_proc    CONSTANT VARCHAR2(50):= g_package||'range_cursor';
    -- vars for constructing the sqlstr
    l_range_cursor              VARCHAR2(4000) := NULL;
    l_parameter_match           VARCHAR2(500)  := NULL;
    l_ovn                       NUMBER(15);
    l_request_id                NUMBER;
    l_action_info_id            NUMBER(15);
    l_business_group_id         NUMBER;
    g_tax_dis_ref               varchar2(10);
  --
  l_check_payroll_info VARCHAR2(1):='N';
  ---- Cursor csr_check_archive
  l_dummy                           NUMBER;
  l_assignment_set_id               NUMBER;
  l_bg_id                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               NUMBER;
  l_end_date                        VARCHAR2(30);
  l_legislation_code                VARCHAR2(30) := 'IE';
  l_payroll_id                      NUMBER;
  l_start_date                      VARCHAR2(30);
  l_tax_period_no                   VARCHAR2(30);
  l_curr_payroll_id                 NUMBER;
  l_error                           varchar2(1) ;
  l_employer                        NUMBER;

  BEGIN
  -- hr_utility.trace_on(null,'P45');
    hr_utility.set_location('Entering ' || l_proc,10);
   /*
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'PAYROLL'
    , p_token_value       => l_payroll_id);
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'CONSOLIDATION'
    , p_token_value       => l_consolidation_set);
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'ASSIGNMENT_SET'
    , p_token_value       => l_assignment_set_id);
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'START_DATE'
    , p_token_value       => l_start_date);
    */
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'END_DATE'
    , p_token_value       => l_end_date);

    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'BG_ID'
    , p_token_value       => l_bg_id);

    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'EMPLOYER'
    , p_token_value       => l_employer);

    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'START_DATE'
    , p_token_value       => l_start_date);

    hr_utility.set_location('Step ' || l_proc,20);
    --hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
    --hr_utility.set_location('l_start_date = ' || l_start_date,20);
    --hr_utility.set_location('l_end_date   = ' || l_end_date,20);
    --hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);
    --hr_utility.set_location('l_start_date = ' || l_start_date,20);
 --   l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
 --   l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');
     --archive EMEA PAYROLL INFO for each prepayment run identified
    --hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,20);
    --hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,20);
    -- hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
    -- hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);
--Call made to procedure get_paye_referene to get the PAYE reference attributed at payroll level,added for bug fix 3567562.
--get_paye_reference (l_consolidation_set,g_paye_ref,l_bg_id,l_canonical_start_date,l_canonical_end_date,l_error);
--Added for bug fix 3567562
/*
if l_error ='Y' then
	sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';
else
*/
    sqlstr := 'SELECT DISTINCT person_id
               FROM   per_people_f ppf,
                      pay_payroll_actions ppa
               WHERE  ppa.payroll_action_id = :payroll_action_id
               AND    ppa.business_group_id +0= ppf.business_group_id
               ORDER BY ppf.person_id';
    hr_utility.set_location('Leaving ' || l_proc,40);
--end if;
  Exception
  when others then
   hr_utility.set_location('Leaving via exception section ' || l_proc,40);
   sqlstr:='select 1 from dual where to_char(:payroll_action_id) = dummy';
  END range_cursor;

  -------------------------------------------------
  PROCEDURE action_creation (pactid in number,
                             stperson in number,
                             endperson in number,
                             chunk in number) is
  --
  CURSOR csr_prepaid_assignments(p_pact_id          NUMBER,
                                 stperson           NUMBER,
                                 endperson          NUMBER,
                                 p_paye_ref         NUMBER,
				 l_payroll_id       NUMBER                     -- 5059862 p45 payroll parameter change
                                 ) IS
  SELECT as1.person_id person_id,
	 act.assignment_id assignment_id,
         act.assignment_action_id run_action_id,
         act1.assignment_action_id prepaid_action_id,
	 as1.assignment_number works_number,
	 as1.period_of_service_id period_of_service_id
  FROM   --per_periods_of_service ppos,
         per_all_assignments_f as1,
         pay_assignment_actions act,
         pay_payroll_actions appa,
         pay_action_interlocks pai,
         pay_assignment_actions act1,
         pay_payroll_actions appa2
  WHERE  /*appa.consolidation_set_id = p_consolidation_id*/
         act.tax_unit_id = p_paye_ref
  AND    appa.effective_date BETWEEN g_archive_start_date AND g_archive_end_date
  AND    as1.person_id BETWEEN stperson AND endperson
  /* Assignment End Date should be between archive start date and end date */
  AND    as1.effective_end_date between g_archive_start_date AND g_archive_end_date
  AND  (as1.effective_end_date = (select max(effective_end_date)
                                    from  per_all_assignments_f paf1
                                   where paf1.assignment_id = as1.assignment_id
/* changed the cursor to handle case where 2 user defined assignment status exist mapping to
   same per_system_status (5073577) */
                                     and   paf1.assignment_status_type_id in
                                           (SELECT ast.assignment_status_type_id
                                              FROM per_assignment_status_types ast
  					     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
  					   )
			         )
        AND    as1.effective_end_date <> to_date('31-12-4712','DD-MM-YYYY')
       )
  AND (as1.payroll_id in (select b.payroll_id                                      -- 5059862
                            from per_assignments_f a,per_assignments_f b
			   where a.payroll_id = l_payroll_id
			     and a.person_id = b.person_id
			     and a.period_of_Service_id = b.period_of_Service_id
			     and a.period_of_Service_id = as1.period_of_Service_id  -- 5758951
			     and a.person_id  = as1.person_id
                             and a.effective_start_date <= g_archive_end_date
                       --      and a.effective_end_date >= trunc(g_archive_end_date,'Y') -- bug 6144761
			     -- 5758951
			     and a.effective_end_date = (select max(effective_end_date)
                                                           from  per_all_assignments_f paf1
                                                          where paf1.assignment_id = a.assignment_id
                                                            and   paf1.assignment_status_type_id in
                                           (SELECT ast.assignment_status_type_id
                                              FROM per_assignment_status_types ast
  					     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
  					   )
					                 )
			 )
       OR l_payroll_id is null)

  --
  AND    appa.action_type IN ('R','Q')                             -- Payroll Run or Quickpay Run
  AND    act.payroll_action_id = appa.payroll_action_id
  AND    act.source_action_id IS NULL
  AND    as1.assignment_id = act.assignment_id
  AND    act.action_status = 'C'
  AND    act.assignment_action_id = pai.locked_action_id
  AND    act1.assignment_action_id = pai.locking_action_id
  AND    act1.action_status = 'C'
  AND    act1.payroll_action_id = appa2.payroll_action_id
  AND    appa2.action_type IN ('P','U') -- Prepayments or Quickpay Prepayments
  AND    appa2.payroll_action_id = (SELECT /*+ USE_NL(ACT2 APPA4)*/
                                        max(appa4.payroll_action_id)
                                  FROM  /*pay_pre_payments ppp, --Bug 4193738 --Bug 4468864*/
					pay_assignment_actions act2,
                                        pay_payroll_actions appa4
                                  WHERE /*ppp.assignment_action_id=act2.assignment_action_id
				  AND*/ act2.assignment_id = act.assignment_id
 				  AND   act2.action_status = 'C'
                                  AND   appa4.payroll_action_id = act2.payroll_action_id
                                  AND   appa4.action_type in ('P','U')
                                  AND appa4.effective_date BETWEEN g_archive_start_date AND g_archive_end_date)
  -- bug 5597735, change the not exists clause.
  -- refer bug 5233518 for more details.
  AND    NOT EXISTS (SELECT /*+ ORDERED use_nl(appa3)*/ null
                      from   pay_assignment_actions act3,
                             pay_payroll_actions appa3,
                             pay_action_interlocks pai, --bug 4208273
                             pay_assignment_actions act2, --bug 4208273
                             pay_payroll_actions appa4 --bug 4208273
                      where  pai.locked_action_id= act3.assignment_action_id
                      and pai.locking_action_id=act2.assignment_action_id
        and    act3.action_sequence  >= act1.action_sequence  --bug 4193738
        and    act3.assignment_id in (select distinct paaf.assignment_id
                                      from  per_all_assignments_f paaf
                                      where paaf.person_id = as1.person_id
                                     )
        and    act3.tax_unit_id = act1.tax_unit_id
        and    act3.action_status = 'C'
        and    act2.action_status = 'C'
        and    act3.payroll_action_id=appa4.payroll_action_id
        and    appa4.action_type in ('P','U')
        and    act2.payroll_action_id = appa3.payroll_action_id
                      and    appa3.action_type = 'X'
                      and    appa3.report_type = 'P45')
   /* check person does not hold employment with the employer between start of year and archive end date */
   AND       NOT EXISTS (
				SELECT MIN(paf.effective_start_date),MAX(paf.effective_end_date)
				FROM per_all_assignments_f paf,
				     pay_all_payrolls_f papf,
				     hr_soft_coding_keyflex scl
				WHERE paf.person_id = as1.person_id
				AND paf.payroll_id = papf.payroll_id
/* changed the cursor to handle case where 2 user defined assignment status exist mapping to
   same per_system_status (5073577) */
				AND paf.assignment_status_type_id in
		                                           (SELECT ast.assignment_status_type_id
                                                              FROM per_assignment_status_types ast
  					                     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
  					                   )
				AND  g_archive_end_date  between papf.effective_start_date and papf.effective_end_date
				AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
				AND scl.segment4 = to_char(p_paye_ref)
				group by paf.assignment_id
				having min(paf.effective_start_date) <= g_archive_end_date
				and    max(paf.effective_end_date) > g_archive_end_date
			  )
  ORDER BY as1.person_id,as1.assignment_number,act.assignment_id
  FOR UPDATE OF as1.assignment_id;

  /* 7291676 */

cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;

cursor csr_ppsn_min_asg(p_ppsn_override varchar2, p_person_id number)
is
select MIN(paei.assignment_id) ovrride_asg
from per_assignment_extra_info paei
where paei.information_type = 'IE_ASG_OVERRIDE'
and paei.aei_information1 = p_ppsn_override
and exists
(select 1 from per_all_assignments_f paaf
  where paaf.assignment_id = paei.assignment_id
  and paaf.person_id  = p_person_id)
GROUP BY paei.aei_information1;

l_ppsn_override_asg per_assignment_extra_info.assignment_id%type;
l_temp_person_id		per_people_f.person_id%TYPE :=0;


  l_actid                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               VARCHAR2(30);
  l_end_date                        VARCHAR2(20);
  l_payroll_id                      NUMBER;
  l_prepay_action_id                NUMBER;
  l_start_date                      VARCHAR2(20);
  l_person_id                       NUMBER;
  l_error                           varchar2(1) ;
  l_period_of_service_id            NUMBER;
  l_bg_id                           NUMBER;
 --
  l_proc VARCHAR2(50) := g_package||'action_creation';
  BEGIN

    --hr_utility.trace_on(null,'P45');
    hr_utility.set_location('Entering ' || l_proc,10);
    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'EMPLOYER'
    , p_token_value       => g_paye_ref);

    pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'END_DATE'
    , p_token_value       => l_end_date);

    pay_ie_p45_archive.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);

      pay_ie_p45_archive.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'START_DATE'
    , p_token_value       => l_start_date);

    pay_ie_p45_archive.get_parameters (                         -- 5059862
      p_payroll_action_id => pactid
    , p_token_name        => 'PAYROLL'
    , p_token_value       => l_payroll_id);

    hr_utility.set_location('Step ' || l_proc,20);
    hr_utility.set_location('g_paye_ref = ' || g_paye_ref,20);
    hr_utility.set_location('l_end_date   = ' || l_end_date,20);

    l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
    l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');
    g_archive_start_date   := l_canonical_start_date;
    g_archive_end_date     := TO_DATE(l_end_date,'yyyy/mm/dd');
--    l_payroll_id           := TO_NUM(l_payroll_id);

    l_prepay_action_id := 0;
    l_person_id := 0;
    l_period_of_service_id := 0;

    hr_utility.set_location('l_start_date = ' || l_canonical_start_date,20);


    --get_paye_reference (l_consolidation_set,g_paye_ref,l_bg_id,l_canonical_start_date,l_canonical_end_date,l_error);
    hr_utility.set_location('Before csr_prepaid_assignments',21);

    l_ppsn_override := NULL;
    l_ppsn_override_asg := NULL;

    FOR csr_rec IN csr_prepaid_assignments(pactid,
                                           stperson,
                                           endperson,
                                           g_paye_ref,
					   l_payroll_id)
    LOOP

   /* 7291676 */
    hr_utility.set_location('Person id..'||to_char(csr_rec.person_id),21-1);
    hr_utility.set_location('Temp Person id..'||to_char(l_person_id),21-2);
	--
	     /* 7291676QA */
	     l_ppsn_override := NULL;
             l_ppsn_override_asg := NULL;
	     hr_utility.set_location('before fetch l_ppsn_override'||to_char(l_ppsn_override),21-3);
	     hr_utility.set_location(' before fetch l_ppsn_override_asg'||to_char(l_ppsn_override_asg),21-3);

            OPEN csr_ppsn_override(csr_rec.assignment_id);
            FETCH csr_ppsn_override INTO l_ppsn_override;
            CLOSE csr_ppsn_override;

	hr_utility.set_location('l_ppsn_override'||to_char(l_ppsn_override),21-3);

           IF l_ppsn_override IS NOT NULL THEN
		OPEN csr_ppsn_min_asg(l_ppsn_override,csr_rec.person_id);
	        FETCH csr_ppsn_min_asg INTO l_ppsn_override_asg;
		CLOSE csr_ppsn_min_asg;
		hr_utility.set_location('l_ppsn_override_asg'||to_char(l_ppsn_override_asg),21-4);
	   END IF;



	hr_utility.set_location('csr_rec.assignment_id'||csr_rec.assignment_id,21-4);

       IF (l_person_id <> csr_rec.person_id and l_ppsn_override IS NULL )
       OR
       (l_ppsn_override_asg=csr_rec.assignment_id and l_ppsn_override IS NOT NULL)
       THEN

      hr_utility.set_location('Different Person '|| csr_rec.person_id ,22);

      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM   dual;

      -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
      hr_utility.set_location('ASSIGNMENT ID : ' || csr_rec.assignment_id,23);
      hr_utility.trace('ASSIGNMENT ID : ' || csr_rec.assignment_id);

      hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,g_paye_ref);
      -- CREATE THE ARCHIVE TO PAYROLL MASTER ASSIGNMENT ACTION INTERLOCK AND
      -- THE ARCHIVE TO PREPAYMENT ASSIGNMENT ACTION INTERLOCK
      -- hr_utility.set_location('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id,20);
      -- hr_utility.set_location('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id,20);
     END IF; --
      hr_utility.set_location('l_prepay_action_id : ' || l_prepay_action_id,100);
	hr_utility.set_location('csr_rec.prepaid_action_id : ' || csr_rec.prepaid_action_id,101);
	hr_utility.set_location('l_actid : ' || l_actid,102);

      IF l_prepay_action_id <> csr_rec.prepaid_action_id THEN
      hr_utility.set_location('locked id : ' || csr_rec.prepaid_action_id,23);
       hr_nonrun_asact.insint(l_actid,csr_rec.prepaid_action_id);
      END IF;

      hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);

      l_prepay_action_id := csr_rec.prepaid_action_id;
      l_person_id := csr_rec.person_id;
      l_period_of_service_id := csr_rec.period_of_service_id;

    END LOOP;

    hr_utility.set_location('Leaving ' || l_proc,20);
  END action_creation;

  ----------------------------
  PROCEDURE archive_code (p_assactid       in number,
                          p_effective_date in date) IS
  CURSOR csr_assignment_actions(p_locking_action_id NUMBER) IS
  SELECT pre.locked_action_id      pre_assignment_action_id,
         pay.locked_action_id      master_assignment_action_id,
         assact.assignment_id      assignment_id,
         assact.payroll_action_id  pay_payroll_action_id,
         paa.effective_date        effective_date,
         ppaa.effective_date       pre_effective_date,
         paa.date_earned           date_earned,
         ptp.time_period_id        time_period_id
  FROM   pay_action_interlocks pre,
         pay_action_interlocks pay,
         pay_payroll_actions paa,
         pay_payroll_actions ppaa,
         pay_assignment_actions assact,
         pay_assignment_actions passact,
         per_time_periods ptp  -- Added to retrieve correct time_period_id 4906850
  WHERE  pre.locked_action_id = pay.locking_action_id
  AND    pre.locking_action_id = p_locking_action_id
  AND    pre.locked_action_id = passact.assignment_action_id
  AND    passact.payroll_action_id = ppaa.payroll_action_id
  AND    ppaa.action_type IN ('P','U')
  AND    pay.locked_action_id = assact.assignment_action_id
  AND    assact.payroll_action_id = paa.payroll_action_id
  AND    assact.source_action_id IS NULL
  AND    ptp.payroll_id = paa.payroll_id
  AND    paa.date_earned between ptp.start_date and ptp.end_date
  --
  ORDER BY pay.locked_action_id DESC;

  -- cursor to retrieve payroll run assignment_action_ids
  -- Bug Fix 3817846
  -- Changed the cursor cur_child_pay_action
  /*CURSOR cur_child_pay_action(p_assignment_id NUMBER,
                              p_date_earned   DATE)is
  SELECT max(paa.assignment_action_id)
  FROM pay_assignment_actions paa,
       pay_payroll_actions ppa
  where paa.assignment_id = p_assignment_id
  AND paa.payroll_action_id = ppa.payroll_action_id
  AND ppa.date_earned =p_date_earned
  AND ppa.action_type in ('R','Q')
  AND paa.action_status = 'C'
  AND paa.source_action_id is not null;*/
/*New Cursor to fetch latest child action */
CURSOR cur_child_pay_action (p_person_id IN NUMBER,
                             p_effective_date IN DATE,
                             p_lat_act_seq IN NUMBER) is
SELECT /*+ USE_NL(paa, ppa) */
      fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa,
     pay_payroll_actions ppa
WHERE paa.payroll_action_id = ppa.payroll_action_id
  AND paa.assignment_id in (select assignment_id
                              from per_all_assignments_f
		             where person_id = p_person_id
			   )
  AND paa.tax_unit_id = g_paye_ref
  AND  (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
    AND  ppa.effective_date between trunc(p_effective_date,'Y') and p_effective_date
  AND  paa.action_sequence > p_lat_act_seq
  AND  ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
  AND  paa.action_status = 'C';

  -- cursor to find assignment action locked by latest P45 child action
  CURSOR cur_get_latest_p45(p_pact_id NUMBER,
                            p_person_id NUMBER
			   ) IS
 SELECT max(lpad(paa_src.action_sequence,15,'0')|| paa_src.assignment_action_id)
    FROM pay_payroll_actions ppa_p45,
         pay_assignment_actions p45_src,
	 pay_action_information pai_p45,
	 pay_assignment_actions paa_src
    WHERE ppa_p45.action_type = 'X'
      AND ppa_p45.report_type = 'P45'
      AND ppa_p45.report_qualifier = 'IE'
      AND ppa_p45.payroll_action_id <> p_pact_id
      AND ppa_p45.payroll_action_id = p45_src.payroll_action_id
      AND p45_src.assignment_action_id = pai_p45.action_context_id
      AND pai_p45.action_context_type = 'AAP'
      AND pai_p45.action_information_category = 'IE P45 INFORMATION'
      AND pai_p45.source_id = paa_src.assignment_action_id
      AND p45_src.action_status = 'C'
      AND paa_src.tax_unit_id = g_paye_ref
      AND p45_src.tax_unit_id = g_paye_ref
      AND pai_p45.action_information8 = to_char(p_person_id);

 -- Cursor to fetch action context id of P45 for previous period of service.
 /* 7291676 */
  CURSOR cur_get_last_p45(p_person_id NUMBER,p_termination_date DATE,p_pact NUMBER, c_assignment_id NUMBER) IS
  SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
  FROM pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_action_information pai
  WHERE paa.assignment_action_id = pai.action_context_id
   AND  pai.action_information_category = 'IE P45 INFORMATION'
   AND  pai.action_context_type = 'AAP'
   AND  paa.tax_unit_id = g_paye_ref
   AND  pai.action_information3 between trunc(p_termination_date,'Y') and p_termination_date
   AND  ppa.payroll_action_id = paa.payroll_action_id
   AND  ppa.report_type = 'P45'
   AND  ppa.report_category = 'ARCHIVE'
   AND  ppa.report_qualifier = 'IE'
   AND  ppa.effective_date between trunc(g_archive_end_date,'Y') and g_archive_end_date
   AND  paa.payroll_action_id <> p_pact
   AND  paa.action_status = 'C'
   AND  pai.action_information8 = to_char(p_person_id)
  -- AND  paa.assignment_id=c_assignment_id
  ; /* knadhan QA */

  -- cursor to fetch Payroll action of Last P45 to pass to get_arc_bal_value 5005788
  CURSOR cur_get_p45_pact(p_p45_aact pay_assignment_actions.assignment_action_id%TYPE) IS
 SELECT paa.payroll_action_id
   FROM pay_assignment_actions paa
 WHERE  paa.assignment_action_id = p_p45_aact;

  -- cursor to retrieve payroll id
  CURSOR cur_assgn_payroll(p_assignment_id NUMBER,
                           p_date_earned DATE) IS
  SELECT payroll_id,person_id,period_of_service_id
  FROM per_all_assignments_f
  WHERE assignment_id = p_assignment_id
  AND p_date_earned
      BETWEEN effective_start_date AND effective_end_date;

/* 7291676 */

cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;

CURSOR cur_child_pay_action_ppsn (p_person_id IN NUMBER,
                             p_effective_date IN DATE,
                             p_lat_act_seq IN NUMBER,
			     c_ppsn_override per_assignment_extra_info.aei_information1%type) is
SELECT /*+ USE_NL(paa, ppa) */
      fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa,
     pay_payroll_actions ppa
WHERE paa.payroll_action_id = ppa.payroll_action_id
  AND paa.assignment_id in (select paaf.assignment_id
                              from per_all_assignments_f paaf, per_assignment_extra_info paei
		             where paaf.person_id = p_person_id
			       and paaf.assignment_id=paei.assignment_id
			       and paei.information_type = 'IE_ASG_OVERRIDE'
			       and paei.aei_information1 = c_ppsn_override     --'314678745T'
			   )
  AND paa.tax_unit_id = g_paye_ref
  AND  (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
    AND  ppa.effective_date between trunc(p_effective_date,'Y') and p_effective_date
  AND  paa.action_sequence > p_lat_act_seq
  AND  ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
  AND  paa.action_status = 'C';

  l_child_pay_action_ppsn           NUMBER;

  l_actid                           NUMBER;
  l_action_context_id               NUMBER;
  l_action_info_id                  NUMBER(15);
  l_assignment_action_id            NUMBER;
  l_business_group_id               NUMBER;
  l_chunk_number                    NUMBER;
  l_assignment_id                   NUMBER;
  l_date_earned                     DATE;
  l_ovn                             NUMBER;
  l_person_id                       NUMBER;
  l_pos_id                          NUMBER;
  l_record_count                    NUMBER;
  l_salary                          VARCHAR2(10);
  l_sequence                        NUMBER;
  l_child_pay_action                NUMBER;
  l_payroll_id                      NUMBER;
  l_supp_flag                       VARCHAR2(1):='N';
  l_deceased_flag                   VARCHAR2(1):='N';
  l_proc                            VARCHAR2(50) := g_package || 'archive_code';
  l_lat_act_seq                     NUMBER;
  l_termination_date                DATE;
  l_last_p45_action                 NUMBER;
  l_max_stat_balance                NUMBER       := 19;
  l_concat_sequence                 VARCHAR2(40);
  l_prev_src_id                     NUMBER;
  l_last_p45_pact                   NUMBER;
  -- 5386432
  l_supp_pymt_date                  DATE;



  BEGIN

    l_lat_act_seq := NULL;
    hr_utility.set_location('Entering'|| l_proc,10);
    hr_utility.set_location('Step '|| l_proc,20);
    hr_utility.set_location('p_assactid = ' || p_assactid,20);

    -- retrieve the chunk number for the current assignment action
    SELECT paa.chunk_number,paa.assignment_id
    INTO   l_chunk_number,l_assignment_id
    FROM   pay_assignment_actions paa
    WHERE  paa.assignment_action_id = p_assactid;

    l_action_context_id := p_assactid;
    l_record_count := 0;

    FOR csr_rec IN csr_assignment_actions(p_assactid)
    LOOP
      hr_utility.set_location('csr_rec.master_assignment_action_id = ' || csr_rec.master_assignment_action_id,20);
      hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' || csr_rec.pre_assignment_action_id,20);
      hr_utility.set_location('csr_rec.assignment_id    = ' || csr_rec.assignment_id,20);
      hr_utility.set_location('csr_rec.date_earned    = ' ||to_char( csr_rec.date_earned,'dd-mon-yyyy'),20);
      hr_utility.set_location('csr_rec.pre_effective_date    = ' ||to_char( csr_rec.pre_effective_date,'dd-mon-yyyy'),20);
      hr_utility.set_location('csr_rec.time_period_id    = ' || csr_rec.time_period_id,20);

           OPEN cur_assgn_payroll(csr_rec.assignment_id,csr_rec.date_earned);
           FETCH cur_assgn_payroll INTO l_payroll_id,l_person_id,l_pos_id;
           CLOSE cur_assgn_payroll;
 /* 7291676 */
           l_ppsn_override:=null; -- 7291676
	   open csr_ppsn_override(csr_rec.assignment_id);
	   fetch csr_ppsn_override into  l_ppsn_override;
	   close csr_ppsn_override;
           hr_utility.set_location('PPSN Override  value  = ' || l_ppsn_override,20);


      --Fetch the action sequence of latest payroll run child action locked by latest P45
      --For the assignment 4468864
      OPEN cur_get_latest_p45(g_archive_pact,l_person_id);
      FETCH cur_get_latest_p45 INTO l_concat_sequence;

	      IF cur_get_latest_p45%NOTFOUND THEN
	      hr_utility.set_location('Action Sequence notfound   = ' || l_lat_act_seq,21);
		l_lat_act_seq := 0;
		l_prev_src_id := 0;
	      END IF;

            l_lat_act_seq := nvl(substr(l_concat_sequence,1,15),0);
            l_prev_src_id := nvl(substr(l_concat_sequence,16),0);

	      hr_utility.set_location('Action Sequence  = ' || l_lat_act_seq,21);
      CLOSE cur_get_latest_p45;

      hr_utility.set_location('Action Sequence    = ' || l_lat_act_seq,21);

      -- Bug Fix 3817846
      -- OPEN cur_child_pay_action(csr_rec.assignment_id, csr_rec.date_earned);
      -- Bug Fix 4001524
      -- OPEN cur_child_pay_action(csr_rec.assignment_id, csr_rec.effective_date);
      /* 7291676 */

      l_child_pay_action_ppsn := NULL;
      OPEN cur_child_pay_action_ppsn(l_person_id,g_archive_end_date,l_lat_act_seq,l_ppsn_override);
      FETCH cur_child_pay_action_ppsn INTO l_child_pay_action_ppsn;
      hr_utility.set_location('Child Action PPSN ='||l_child_pay_action_ppsn,20);
      CLOSE cur_child_pay_action_ppsn;

      l_child_pay_action := NULL;
      OPEN cur_child_pay_action(l_person_id,g_archive_end_date,l_lat_act_seq);
      FETCH cur_child_pay_action INTO l_child_pay_action;

      if (l_child_pay_action_ppsn is null) THEN
      l_child_pay_action_ppsn:=l_child_pay_action;
      end if;
      hr_utility.set_location('Child Action PPSN after assigning ='||l_child_pay_action_ppsn,20);

    --  hr_utility.set_location('Child Action PPSN  ='|| l_child_pay_action_ppsn,24);
       hr_utility.set_location('Child Action ='||l_child_pay_action,24);

	 -------------- Moved here for bug 5386432  ----
	   get_termination_date(p_action_context_id     => p_assactid,
                            p_assignment_id           => csr_rec.assignment_id,
                            p_person_id               => l_person_id,
				    p_date_earned             =>  csr_rec.effective_date, -- csr_rec.date_earned,  9156332
			          p_termination_date        => l_termination_date,
				    p_supp_pymt_date		=> l_supp_pymt_date,
				    p_supp_flag			=> l_supp_flag,
				    p_deceased_flag             => l_deceased_flag
			          );
	   OPEN cur_get_last_p45(l_person_id,l_termination_date,g_archive_pact,csr_rec.assignment_id);
	   FETCH cur_get_last_p45 into l_last_p45_action;
	   CLOSE cur_get_last_p45;

	   -- Fetch the Payroll action of Last P45 5005788
	   OPEN cur_get_p45_pact(l_last_p45_action);
	   FETCH cur_get_p45_pact INTO l_last_p45_pact;
	   CLOSE cur_get_p45_pact;
	   hr_utility.set_location(' l_termination_date = '||l_termination_date,30);
	   hr_utility.set_location(' l_supp_pymt_date = '||l_supp_pymt_date,30);
	   hr_utility.set_location(' l_supp_flag = '||l_supp_flag,30);

     ------------------
    IF ((l_child_pay_action IS NULL) and l_supp_flag = 'Y' ) THEN
     NULL;
    ELSE
      IF (l_record_count = 0 AND csr_rec.assignment_id = l_assignment_id)
      THEN
      -- Create child P45 action to lock the child payroll process child action
      -- To avoid data corruption 4468864
      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM dual;

      hr_nonrun_asact.insact(
        lockingactid => l_actid
      , assignid     => l_assignment_id
      , pactid       => g_archive_pact
      , chunk        => l_chunk_number
      , greid        => g_paye_ref
      , prepayid     => NULL
      , status       => 'C'
      , source_act   => p_assactid);

          hr_utility.set_location('creating lock4 ' || l_actid || ' to ' || l_child_pay_action,30);
          -- bug 5386432, checks l_child_pay_action is not null, since for zero
	    -- earnigns there will not child actions, so cant lock any
	    IF l_child_pay_action IS NOT NULL THEN
		hr_nonrun_asact.insint(
			lockingactid => l_actid
		    , lockedactid  => l_child_pay_action);
	    END IF;

           pay_ie_p45_archive.archive_p45_info(
                    p_action_context_id    => p_assactid,
                    p_assignment_id        => csr_rec.assignment_id, -- assignment_id
                    p_payroll_id           => l_payroll_id,
                    p_date_earned          => csr_rec.date_earned,
                    p_child_run_ass_act_id => l_child_pay_action,
                    p_supp_flag            => l_supp_flag,
		        p_person_id            => l_person_id,
		        p_termination_date     => l_termination_date,
		        p_child_pay_action     => l_child_pay_action_ppsn,   -- child payroll assignment action id
			p_supp_pymt_date	 => l_supp_pymt_date,
			p_deceased_flag        => l_deceased_flag);

	   -- Moved this above as we will now have to archive for Main P45 even if
	   -- it has no run-results. bug 5386432
	   /*open cur_get_last_p45(l_person_id,l_termination_date,g_archive_pact);
	   fetch cur_get_last_p45 into l_last_p45_action;
	   close cur_get_last_p45;

	   -- Fetch the Payroll action of Last P45 5005788
	   OPEN cur_get_p45_pact(l_last_p45_action);
	   FETCH cur_get_p45_pact INTO l_last_p45_pact;
	   CLOSE cur_get_p45_pact; */



	   hr_utility.set_location('sg Person Id ='||l_person_id,32);
	   hr_utility.set_location('sg Termination Date ='||l_termination_date,33);
           hr_utility.set_location('sg Payroll action ='||g_archive_pact,34);
            hr_utility.set_location('sg P45 action ='||l_last_p45_action,35);

	   IF l_last_p45_action IS NOT NULL THEN
		hr_nonrun_asact.insint(
            lockingactid => l_actid
          , lockedactid  => l_last_p45_action);
	   END IF;

           pay_ie_p45_archive.archive_employee_details(
                    p_assactid             => l_action_context_id -- P45 master action
                  , p_assignment_id        => l_assignment_id
                  , p_curr_pymt_ass_act_id => csr_rec.pre_assignment_action_id  -- prepayment assignment_action_id
                  , p_date_earned          => csr_rec.date_earned               -- payroll date_earned
                  , p_payroll_child_actid  => l_child_pay_action_ppsn                -- payroll assignment action id ( 7291676)
                  , p_curr_pymt_eff_date   => csr_rec.pre_effective_date        -- prepayment effective_date
                  , p_time_period_id       => csr_rec.time_period_id            -- payroll time_period_id
                  , p_record_count         => l_record_count
                  , p_supp_flag             => l_supp_flag
                  , p_person_id            => l_person_id
                  , p_termination_date     => l_termination_date
                  , p_last_act_seq         => l_lat_act_seq
                  , p_last_p45_act         => l_last_p45_action
			,p_effective_date		 => csr_rec.effective_date
			,p_ppsn_override_flag => l_ppsn_override  /* 7291676 */
			);

           -- Statutory Balances are archived for all Separate Payment assignment actions
           -- and the last (i.e. highest action_sequence) Process Separately assignment action
           -- (EMEA BALANCES)
           hr_utility.set_location('Archive User Balances - Complete',60);
           -- archive statutory balances
           hr_utility.set_location('Archive Statutory Balances - Starting',70);
           hr_utility.set_location('g_max_statutory_balance_index = '|| g_max_statutory_balance_index,70);


           hr_utility.set_location('PPSN Override  value  = ' || l_ppsn_override,70);

           FOR l_index IN 1 .. g_max_statutory_balance_index
           LOOP

	   if (l_ppsn_override is null) then

               hr_utility.set_location('l_index = ' || l_index,70);
               hr_utility.set_location('balance_name ='||g_statutory_balance_table(l_index).balance_name,70);
               hr_utility.set_location('database_item_suffix ='||g_statutory_balance_table(l_index).database_item_suffix,70);
             /*
              --Bug:2448728.Passing the prepayment assignment action id to p_source_id as the _PAYMENTS
              --balances are fed only during pre Payments.
               If g_statutory_balance_table(l_index).balance_name = 'Total Pay' Then
               pay_ie_p45_archive.process_balance (
                       p_action_context_id => l_action_context_id
                     , p_assignment_id     => csr_rec.assignment_id
                     , p_source_id         => csr_rec.pre_assignment_action_id
                     , p_effective_date    => csr_rec.effective_date
                     , p_balance           => g_statutory_balance_table(l_index).balance_name
                     , p_dimension         => g_statutory_balance_table(l_index).database_item_suffix
                     , p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id
                     , p_record_count      => l_record_count);
                Else
              */
          --      IF ( l_supp_flag = 'Y' OR  l_index < 19 OR l_index > 31 ) THEN

                  IF (l_index < 20) THEN                                                        -- Bug 5015438
				pay_ie_p45_archive.process_balance (
                                     p_action_context_id => l_action_context_id
                                   , p_assignment_id     => csr_rec.assignment_id
                                   , p_person_id         => l_person_id
                                   , p_source_id         => l_child_pay_action
                                   , p_effective_date    => csr_rec.effective_date
                                   , p_balance           => g_statutory_balance_table(l_index).balance_name
                                   , p_dimension         => g_statutory_balance_table(l_index).database_item_suffix
                                   , p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id
                                   , p_record_count      => l_record_count
				           , p_termination_date  => l_termination_date
				           , p_supp_flag         => l_supp_flag
				           , p_last_p45_action   => l_last_p45_action
				           , p_last_p45_pact     => l_last_p45_pact         -- Bug 5005788
				           , p_prev_src_id       => l_prev_src_id);
		  ELSE
		    IF (l_supp_flag = 'Y') THEN
                               pay_ie_p45_archive.process_supp_balance (
                                     p_action_context_id => l_action_context_id
                                   , p_assignment_id     => csr_rec.assignment_id
                                   , p_person_id         => l_person_id
                                   , p_source_id         => l_child_pay_action
                                   , p_effective_date    => csr_rec.effective_date
                                   , p_balance           => g_statutory_balance_table(l_index).balance_name
                                   , p_dimension         => g_statutory_balance_table(l_index).database_item_suffix
                                   , p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id
                                   , p_record_count      => l_record_count
				           , p_termination_date  => l_termination_date
				           , p_supp_flag         => l_supp_flag
				           , p_last_p45_action   => l_last_p45_action
				           , p_last_p45_pact     => l_last_p45_pact          -- Bug 5005788
				           , p_ytd_balance       => g_statutory_balance_table(l_index - l_max_stat_balance).balance_name
				           , p_ytd_def_bal_id    => g_statutory_balance_table(l_index - l_max_stat_balance).defined_balance_id);
		    END IF;

	          END IF;

		  ELSE   /* if ppsn override is present */
		   hr_utility.set_location('entered the else block in the archve code  ' ,70);
                     hr_utility.set_location('l_index = ' || l_index,70);
               hr_utility.set_location('balance_name ='||g_statutory_balance_table_ppsn(l_index).balance_name,70);
               hr_utility.set_location('database_item_suffix ='||g_statutory_balance_table_ppsn(l_index).database_item_suffix,70);

                   IF (l_index < 20) THEN                                                        -- Bug 5015438
				pay_ie_p45_archive.process_balance (
                                     p_action_context_id => l_action_context_id
                                   , p_assignment_id     => csr_rec.assignment_id
                                   , p_person_id         => l_person_id
                                   , p_source_id         => l_child_pay_action_ppsn
                                   , p_effective_date    => csr_rec.effective_date
                                   , p_balance           => g_statutory_balance_table_ppsn(l_index).balance_name
                                   , p_dimension         => g_statutory_balance_table_ppsn(l_index).database_item_suffix
                                   , p_defined_bal_id    => g_statutory_balance_table_ppsn(l_index).defined_balance_id
                                   , p_record_count      => l_record_count
				           , p_termination_date  => l_termination_date
				           , p_supp_flag         => l_supp_flag
				           , p_last_p45_action   => l_last_p45_action
				           , p_last_p45_pact     => l_last_p45_pact         -- Bug 5005788
				           , p_prev_src_id       => l_prev_src_id);

		  ELSE
		    IF (l_supp_flag = 'Y') THEN
                    hr_utility.set_location('entered the if  block and supp flag is y  ' ,70);
                               pay_ie_p45_archive.process_supp_balance (
                                     p_action_context_id => l_action_context_id
                                   , p_assignment_id     => csr_rec.assignment_id
                                   , p_person_id         => l_person_id
                                   , p_source_id         => l_child_pay_action_ppsn
                                   , p_effective_date    => csr_rec.effective_date
                                   , p_balance           => g_statutory_balance_table_ppsn(l_index).balance_name
                                   , p_dimension         => g_statutory_balance_table_ppsn(l_index).database_item_suffix
                                   , p_defined_bal_id    => g_statutory_balance_table_ppsn(l_index).defined_balance_id
                                   , p_record_count      => l_record_count
				           , p_termination_date  => l_termination_date
				           , p_supp_flag         => l_supp_flag
				           , p_last_p45_action   => l_last_p45_action
				           , p_last_p45_pact     => l_last_p45_pact          -- Bug 5005788
				           , p_ytd_balance       => g_statutory_balance_table_ppsn(l_index - l_max_stat_balance).balance_name
				           , p_ytd_def_bal_id    => g_statutory_balance_table_ppsn(l_index - l_max_stat_balance).defined_balance_id);
		    END IF;

	          END IF;

		  END IF; --  ppsn override if condition
              --  End If;
           END LOOP;
	   l_ppsn_override:=null; -- 7291676
           hr_utility.set_location('Archive Statutory Balances - Complete',70);
	   	      l_record_count := l_record_count + 1;
        END IF;
       END IF;
      CLOSE cur_child_pay_action;
      l_date_earned := csr_rec.date_earned;
    END LOOP;
    hr_utility.set_location('Leaving '|| l_proc,80);
  END archive_code;

  --------------------------------------------------------------------------------
  -- Bug 2643489: Function to return balnce values archived by P45 Archive Process
  --------------------------------------------------------------------------------

-- Added the parameter p_payroll_action_id to improve the performance,
  FUNCTION get_arc_bal_value(
                       p_assignment_action_id  in number
                      ,p_payroll_action_id     in number
                      ,p_balance_name          in varchar2 ) return number
  AS

 /* Split the cursor to 2 cursors to improve the performace.new parameter is added to reduce the number of
    tables involved to 2 from 5 (5005788) */
    CURSOR csr_get_def_bal(p_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE
    			        ,p_balance_name      pay_balance_types.balance_name%TYPE
				,c_ppsn_flag varchar2) IS
    SELECT pai1.action_information2
      FROM pay_action_information pai1
     WHERE pai1.action_context_type         = 'PA'
       AND pai1.action_information_category = 'EMEA BALANCE DEFINITION'
       AND substr(pai1.action_information4, 1,50) = p_balance_name
       AND pai1.action_context_id = p_payroll_action_id
      -- AND pai1.action_information7 = c_ppsn_flag
      -- and ((nvl(pai1.action_information7,'N')='N') or (pai1.action_information7='Y'))
 and ((nvl(pai1.action_information7,'N')='N' and c_ppsn_flag='N') or (nvl(pai1.action_information7,'N')='Y' and c_ppsn_flag='Y') ) ;

    CURSOR csr_get_arc_bal_value(p_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE
                                ,p_def_bal_id          pay_action_information.action_information1%TYPE) IS
      SELECT to_number(pai2.action_information4)    balance_value
        FROM pay_action_information pai2
      WHERE pai2.action_context_id = p_assignment_action_id
        AND pai2.action_information_category = 'EMEA BALANCES'
        AND pai2.action_context_type         = 'AAP'
        AND pai2.action_information1         =  p_def_bal_id;

/* 7291676 */
   CURSOR csr_check_override_present (p_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE) IS
   SELECT paei.aei_information1
   FROM   per_assignment_extra_info paei,
          pay_assignment_actions paa
   WHERE paa.assignment_action_id=p_assignment_action_id
     and paei.assignment_id=paa.assignment_id
     and paei.aei_information_category = 'IE_ASG_OVERRIDE';

  l_ppsn_override  per_assignment_extra_info.aei_information1%type;
  l_ppsn_override_flag varchar2(2);

  l_bal_value number:=null;
  l_def_bal_id pay_action_information.action_information1%TYPE := NULL;

  BEGIN

--hr_utility.trace_on(null,'P45XML');
    OPEN csr_check_override_present(p_assignment_action_id);
    FETCH csr_check_override_present INTO l_ppsn_override;

    IF csr_check_override_present%found and l_ppsn_override is not null THEN
    l_ppsn_override_flag:='Y';
    ELSE
    l_ppsn_override_flag:='N';
    END IF;
    CLOSE csr_check_override_present;

    hr_utility.set_location('l_ppsn_override_flag '||l_ppsn_override_flag,400);

    IF p_assignment_action_id IS NOT NULL AND p_balance_name IS NOT NULL THEN
      OPEN csr_get_def_bal(p_payroll_action_id,p_balance_name,l_ppsn_override_flag);
      FETCH csr_get_def_bal INTO l_def_bal_id;
      CLOSE csr_get_def_bal;
	hr_utility.set_location('p_payroll_action_id '||p_payroll_action_id,400);
	hr_utility.set_location('p_balance_name '||p_balance_name,400);
	hr_utility.set_location('l_def_bal_id '||l_def_bal_id,400);

      IF l_def_bal_id IS NOT NULL THEN
        OPEN csr_get_arc_bal_value(p_assignment_action_id,l_def_bal_id);
        FETCH csr_get_arc_bal_value into l_bal_value;
        CLOSE csr_get_arc_bal_value;
      END IF;

    END IF;
/*Bug 3986018*/
hr_utility.set_location('l_def_bal_id '||l_def_bal_id,400);

    return(nvl(l_bal_value,0));

  END get_arc_bal_value;

  ---------------------------------------------------------------------
  -- Procedure generate_xml - Generates P45 XML Output File
  -- viviswan 29-may-2002 created
  ---------------------------------------------------------------------
  PROCEDURE generate_xml(
                         errbuf                   out nocopy varchar2
                        ,retcode                  out nocopy varchar2
                        ,p_p45_archive_process    in  number
                        ,p_assignment_id          in  number) IS
  -- Commented for Bug 2643489 Performance
    /*SELECT  paa.assignment_id assignment_id
         ,paa.assignment_action_id
         ,pai_iep45.action_information2                                   supp_flag
         ,emp_details.pps_no                                              ppsn
         ,emp_details.last_name                                           surname
         ,emp_details.first_name                                          firstname
         ,emp_details.works_no                                            works
         ,emp_details.deceased                                            deceased
         ,to_char(emp_details.date_of_birth,'dd/mm/rrrr')                 dob
         ,emp_address.address1                                            address1
         ,emp_address.address2                                            address2
         ,emp_address.address3                                            address3
         ,to_char(emp_details.date_of_commencement,'dd/mm/rrrr')          start1
         ,to_char(emp_details.date_of_leaving,'dd/mm/rrrr')               end1
         ,decode(ptp.period_type,'Lunar Month','W',decode(instr(ptp.period_type,'Week'),0,'M','W')) freq
         ,to_number(substr(pai_iep45.action_information5, 1,30))                  period
         ,(round(to_number(substr(pai_ieed.action_information26, 1,30)),2)*100)     taxcredit
         ,(round(to_number(substr(pai_ieed.action_information27, 1,30)),2)*100)     cutoff
         ,pai_iep45.action_information4                                   emergency_tax
         ,substr(pai_ieed.action_information22, 1,30)                     prsi_class
         ,(round(to_number(emp_paye.total_tax),2)*100)                    totaltax
         ,(round(to_number(emp_paye.total_pay),2)*100)                    totalpay
         ,(round(to_number(emp_paye.this_tax),2)*100)                     thistax
         ,(round(to_number(emp_paye.this_pay),2)*100)                     thispay
         ,(round(to_number(emp_paye.lump_sum),2)*100)                     lumpsum
         ,(round(to_number(emp_prsi.total_prsi),2)*100)                   totalprsi
         ,(round(to_number(emp_prsi.total_employee_prsi),2)*100)          employeeprsi
         ,emp_prsi.insurable_weeks                                        totalweeks
         ,emp_prsi.class_a_insurable_weeks                                totalaweeks
         ,(round(to_number(emp_soc.disability_benefit),2)*100)            benefit
         ,(round(to_number(emp_soc.red_tax_credit),2)*100)                taxcreditreduction
         ,(round(to_number(emp_soc.red_std_cut_off),2)*100)               cutoffreduction
         ,emp_soc.non_cummulative_basis                                   noncumulative
         ,pai_epif.action_information6                                    employer_number
         ,(round(to_number(emp_supp.total_tax),2)*100)                    supp_totaltax
         ,(round(to_number(emp_supp.total_pay),2)*100)                    supp_totalpay
         ,(round(to_number(emp_supp.lump_sum),2)*100)                     supp_lumpsum
         ,(round(to_number(emp_supp.total_prsi),2)*100)                   supp_totalprsi
         ,(round(to_number(emp_supp.total_employee_prsi),2)*100)          supp_employeeprsi
         ,emp_supp.insurable_weeks                                        supp_totalweeks
  FROM    pay_action_information                  pai_ed
         ,pay_action_information                  pai_iep45
         ,pay_action_information                  pai_ieed
         ,pay_action_information                  pai_epif
         ,pay_assignment_actions                  paa
         ,pay_action_interlocks                   pai_arc
         ,pay_assignment_actions                  paa_payroll
         ,per_time_periods                        ptp
         ,pay_ie_p45_address_details              emp_address
         ,pay_ie_p45_employee_details             emp_details
         ,pay_ie_p45_soc_ben_details              emp_soc
         ,pay_ie_p45_prsi_details                 emp_prsi
         ,pay_ie_p45_paye_details                 emp_paye
         ,pay_ie_p45_supp_details                 emp_supp
  WHERE   paa.payroll_action_id                   = c_p45_arch_id
  AND     paa.assignment_action_id                = pai_arc.locking_action_id
  AND     paa_payroll.assignment_action_id        = pai_arc.locked_action_id
  AND     paa.assignment_action_id                = pai_iep45.action_context_id
  AND     pai_iep45.action_context_type           ='AAP'
  AND     pai_iep45.action_information_category   = 'IE P45 INFORMATION'
  AND     paa.assignment_action_id                = pai_ed.action_context_id
  AND     pai_ed.action_context_type              ='AAP'
  AND     pai_ed.action_information_category      = 'EMPLOYEE DETAILS'
  AND     ptp.time_period_id                      = pai_ed.action_information16
  AND     paa.assignment_action_id                = pai_ieed.action_context_ID
  AND     pai_ieed.action_context_type            ='AAP'
  AND     pai_ieed.action_information_category    = 'IE EMPLOYEE DETAILS'
  AND     paa.payroll_action_id                   = pai_epif.action_context_ID (+)
  AND     pai_epif.action_context_type    (+)     ='PA'
  AND     pai_epif.action_information_category (+)= 'EMEA PAYROLL INFO'
  AND     pai_epif.action_information1            =  paa_payroll.payroll_action_id
  AND     emp_address.assignment_action_id        = paa.assignment_action_id
  AND     emp_details.assignment_action_id        = paa.assignment_action_id
  AND     emp_soc.assignment_action_id            = paa.assignment_action_id
  AND     emp_prsi.assignment_action_id           = paa.assignment_action_id
  AND     emp_paye.assignment_action_id           = paa.assignment_action_id
  AND     emp_supp.assignment_id (+)              = paa.assignment_id
  AND     paa.assignment_id                       = NVL(p_assignment_id,paa.assignment_id)
  ORDER BY pai_iep45.action_information2;
  */
  -- The above cursor has been modified as specified below.
  CURSOR  cur_p45_details(
          c_p45_arch_id pay_payroll_actions.payroll_action_id%TYPE) IS
  SELECT  paa.assignment_id assignment_id
         ,paa.assignment_action_id
         ,pai_iep45.action_information2                                   supp_flag
         ,decode(ptp.period_type,'Lunar Month','W',decode(instr(ptp.period_type,'Week'),0,'M','W')) freq
         ,to_number(substr(pai_iep45.action_information5, 1,30))                  period
         ,pai_iep45.action_information4                                   emergency_tax,
          to_date(substr(pai_iep45.action_information7, 1,30),'DD/MM/RRRR') date_paid --Bug 3991416
	  ,pai_iep45.action_information8  person_id  -- 7291676
	  ,pai_iep45.action_information9  main_p45_date_paid  -- 7291676
  FROM    pay_action_information                  pai_ed
         ,pay_action_information                  pai_iep45
         ,pay_assignment_actions                  paa
         ,per_time_periods                        ptp
  WHERE   paa.payroll_action_id                   = c_p45_arch_id
  AND     paa.assignment_action_id                = pai_iep45.action_context_id
  AND     pai_iep45.action_context_type           ='AAP'
  AND     pai_iep45.action_information_category   = 'IE P45 INFORMATION'
  AND     ptp.time_period_id                      = pai_ed.action_information16
  AND     paa.assignment_action_id                = pai_ed.action_context_ID
  AND     pai_ed.action_context_type              ='AAP'
  AND     pai_ed.action_information_category      = 'EMPLOYEE DETAILS'
  AND     paa.assignment_id                       = NVL(p_assignment_id,paa.assignment_id)
  ORDER BY pai_iep45.action_information2;
--
CURSOR  cur_p45_employer_no (p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE )IS
SELECT  pai_epif.action_information6                                    employer_number
FROM    pay_assignment_actions                  paa
       ,pay_action_interlocks                   pai_arc
       ,pay_assignment_actions                  paa_payroll
       ,pay_action_information                  pai_epif
WHERE   paa.assignment_action_id                = p_assignment_action_id
AND     paa.assignment_action_id                = pai_arc.locking_action_id
AND     paa_payroll.assignment_action_id        = pai_arc.locked_action_id
AND     paa.payroll_action_id                   = pai_epif.action_context_ID
AND     pai_epif.action_context_type            ='PA'
AND     pai_epif.action_information_category   = 'EMEA PAYROLL INFO'
AND     pai_epif.action_information1            =  paa_payroll.payroll_action_id;
--
CURSOR  cur_p45_ie_emp_details (p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE )IS
SELECT  (round(to_number(substr(nvl(pai_ieed.action_information26,'0'), 1,30)),2)*100)     taxcredit
       ,(round(to_number(substr(nvl(pai_ieed.action_information27,'0'), 1,30)),2)*100)     cutoff
       ,substr(pai_ieed.action_information22, 1,30)                               prsi_class
FROM    pay_action_information                  pai_ieed
WHERE   pai_ieed.action_context_ID              = p_assignment_action_id
AND     pai_ieed.action_context_type            = 'AAP'
AND     pai_ieed.action_information_category    = 'IE EMPLOYEE DETAILS';
cur_p45_ie_emp_details_rec cur_p45_ie_emp_details%ROWTYPE;
--
--6615117
CURSOR  cur_p45_emp_soc_details (p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE )IS
SELECT       (round(to_number(nvl(emp_soc.disability_benefit,'0')),2)*100)            benefit
            ,(round(to_number(nvl(emp_soc.red_tax_credit,'0')),2)*100)                taxcreditreduction
            ,(round(to_number(nvl(emp_soc.red_std_cut_off,'0')),2)*100)               cutoffreduction
            ,emp_soc.non_cummulative_basis                                   noncumulative
FROM        pay_ie_p45_soc_ben_details              emp_soc
WHERE       emp_soc.assignment_action_id        = p_assignment_action_id;
cur_p45_emp_soc_details_rec cur_p45_emp_soc_details%ROWTYPE;
--
--6615117
CURSOR  cur_p45_emp_details (p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE )IS
SELECT      emp_details.pps_no                                              ppsn
           ,emp_details.last_name                                           surname
           ,emp_details.first_name                                          firstname
           ,emp_details.works_no                                            works
           ,emp_details.deceased                                            deceased
           ,to_char(emp_details.date_of_birth,'dd/mm/rrrr')                 dob
           ,to_char(emp_details.date_of_commencement,'dd/mm/rrrr')          start1
           ,to_char(emp_details.date_of_leaving,'dd/mm/rrrr')               end1
FROM        pay_ie_p45_employee_details              emp_details
WHERE       emp_details.assignment_action_id        = p_assignment_action_id;
cur_p45_emp_details_rec cur_p45_emp_details%ROWTYPE;
--
CURSOR  cur_p45_emp_address (p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE )IS
SELECT      emp_address.address1                                            address1
           ,emp_address.address2                                            address2
           ,emp_address.address3                                            address3
FROM        pay_ie_p45_address_details              emp_address
WHERE       emp_address.assignment_action_id        = p_assignment_action_id;
cur_p45_emp_address_rec cur_p45_emp_address%ROWTYPE;
--
CURSOR  cur_p45_paye_prsi_details (p_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE )IS
SELECT   (round(to_number(emp_paye.total_tax),2)*100)                     totaltax
         ,(round(to_number(emp_paye.total_pay),2)*100)                    totalpay
         ,(round(to_number(emp_paye.this_tax),2)*100)                     thistax
         ,(round(to_number(emp_paye.this_pay),2)*100)                     thispay
         ,(round(to_number(emp_paye.lump_sum),2)*100)                     lumpsum
         ,(round(to_number(emp_prsi.total_employer_prsi),2)*100)          employerprsi          -- Bug  5005788
         ,(round(to_number(emp_prsi.total_employee_prsi),2)*100)          employeeprsi
         ,emp_prsi.insurable_weeks                                        totalweeks
         ,emp_prsi.class_a_insurable_weeks                                totalaweeks
FROM     pay_ie_p45_prsi_details                 emp_prsi
        ,pay_ie_p45_paye_details                 emp_paye
WHERE   emp_prsi.assignment_action_id            = p_assignment_action_id
AND     emp_paye.assignment_action_id                   = p_assignment_action_id;
cur_p45_paye_prsi_rec  cur_p45_paye_prsi_details%ROWTYPE;
--
--Bug 3991416 Added period,frequency and date earned check to fetch single record
CURSOR  cur_p45_supp_details (p_assignment_id per_all_assignments_f.assignment_id%TYPE,
                              p_date_earned date,
                              p_period NUMBER,
                              p_freq VARCHAR2) IS
SELECT  (round(to_number(emp_supp.total_tax),2)*100)                    supp_totaltax
       ,(round(to_number(emp_supp.total_pay),2)*100)                    supp_totalpay
       ,(round(to_number(emp_supp.lump_sum),2)*100)                     supp_lumpsum
       ,(round(to_number(emp_supp.total_employer_prsi),2)*100)           supp_totalprsi           -- Bug  5005788
       ,(round(to_number(emp_supp.total_employee_prsi),2)*100)          supp_employeeprsi
       ,emp_supp.insurable_weeks                                        supp_totalweeks
       ,emp_supp.supp_insurable_classA_weeks                            supp_classA_weeks          -- Bug 5015438
FROM    pay_ie_p45_supp_details                 emp_supp
WHERE   emp_supp.assignment_id                  = p_assignment_id
AND     emp_supp.date_paid =p_date_earned
AND     emp_supp.pay_period =p_period
AND     emp_supp.period_frequency = decode(p_freq,'M','Monthly','Weekly');
--
CURSOR  cur_p30_start_date(
        c_p30_data_lock_process pay_payroll_actions.payroll_action_id%TYPE) IS
SELECT  to_char(MIN(ppa_arc.start_date),'DD/MM/RRRR') start_date
FROM    pay_assignment_actions paa_p30,
        pay_action_interlocks  pai_p30,
        pay_assignment_actions paa_arc,
        pay_payroll_actions    ppa_arc
WHERE   paa_p30.payroll_Action_id    = c_p30_data_lock_process
AND     paa_p30.assignment_action_id = pai_p30.locking_action_id
AND     paa_arc.assignment_action_id = pai_p30.locked_action_id
AND     ppa_arc.payroll_action_id    = paa_arc.payroll_action_id;
--
CURSOR  cur_employer_address(
        c_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE) IS
SELECT  substr(pai.action_information5,1,30)  employer_tax_addr1
       ,substr(pai.action_information6,1,30)  employer_tax_addr2
       ,substr(pai.action_information7,1,30)  employer_tax_addr3
       ,substr(pai.action_information26,1,30) employer_tax_contact
       ,substr(pai.action_information27,1,12) employer_tax_ref_phone
       ,substr(pai.action_information28,1,30) employer_tax_rep_name
FROM    pay_action_information pai
WHERE   pai.action_context_id            =  c_payroll_action_id
AND     pai.action_context_type          = 'PA'
AND     pai.action_information_category  = 'ADDRESS DETAILS'
AND     pai.action_information14         = 'IE Employer Tax Address';


/* 7291676 */
/* to check whether the termination date of the assignment is after 2009 */
CURSOR cur_service_leave_year(c_person_id per_all_people_f.person_id%type,c_action_context_id pay_assignment_actions.assignment_action_id%type) IS
  select 'Y'
  from  per_periods_of_service ppos
  where ppos.person_id = c_person_id
  and   ppos.period_of_service_id = (select max(paf.period_of_service_id)
                                        from per_all_assignments_f paf,
                                             pay_assignment_actions paa,
  					               pay_action_interlocks pai
  	                               where   pai.locking_action_id = c_action_context_id
  				                 and pai.locked_action_id  = paa.assignment_action_id
                                         and paa.action_status = 'C'
                                         and paa.assignment_id = paf.assignment_id
                                     )
  and to_char(trunc(ppos.actual_termination_date,'Y'),'YYYY')>='2009';
l_term_yr_2009     boolean;
l_flag      varchar2(1);

cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;

cursor csr_supp_paydetails(p_asg_id number)
is
select aei_information1 year1
      ,(round(to_number(nvl(aei_information2,'0')),2)*100) pay1
      ,aei_information3 year2
      ,(round(to_number(nvl(aei_information4,'0')),2)*100) pay2
      ,aei_information5 year3
      ,(round(to_number(nvl(aei_information6,'0')),2)*100) pay3
      ,aei_information7 year4
      ,(round(to_number(nvl(aei_information8,'0')),2)*100) pay4
      ,aei_information9 year5
      ,(round(to_number(nvl(aei_information10,'0')),2)*100) pay5
      ,(round(to_number(nvl(aei_information11,'0')),2)*100) allotherpay
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_SUPP_P45_PAY';

csr_supp_paydetails_rec csr_supp_paydetails%rowtype;
l_eit_sum number;

error_message boolean;
l_str_Common VARCHAR2(2000);
l_start_date                      VARCHAR2(30);
l_eit_supp_flag boolean;


--
--
l_root_start_tag        varchar2(200);
l_root_start_tag_new    varchar2(200);
l_root_end_tag          varchar2(50);
--
l_employer_start_tag    varchar2(20);
l_employer_end_tag      varchar2(20);
--
l_p45_start_tag         varchar2(20);
l_p45_end_tag           varchar2(20);
--
--
l_employer_paye_number  varchar2(80);
l_employer_number       varchar2(10);
l_employer_name         varchar2(30);
l_employer_add1         varchar2(30);
l_employer_add2         varchar2(30);
l_employer_add3         varchar2(30);
l_employer_contact      varchar2(20);
l_employer_phone        varchar2(12);
--
l_supp_totaltax         number;
l_supp_totalpay         number;
l_supp_lumpsum          number;
l_supp_totalprsi        number;
l_supp_employeeprsi     number;
l_supp_totalweeks       varchar2(10);
l_supp_classA_weeks     varchar2(10);                          -- Bug 5015438
--
l_employment_unit       varchar2(3);
once_per_run            varchar2(1);
vfrom                   number;
vfound                  number;
vto                     number;
v_prsi_class            varchar2(10);
ppsn_flag			number(1) :=1;
warn_status			number(1) := 0;
l_conc_status		BOOLEAN;
l_total_prsi            NUMBER;
BEGIN
  once_per_run          := 'N' ;
  l_employment_unit     := '000';
  l_root_start_tag      :='<P45File currency="E" formversion="3" language="E" printer="0">';
  l_root_start_tag_new  :='<P45File currency="E" formversion="4" language="E" printer="0">'; -- 7291676
  l_root_end_tag        :='</P45File>';
  FOR p45_rec IN cur_p45_details(p_p45_archive_process) LOOP
    OPEN cur_p45_paye_prsi_details(p45_rec.assignment_action_id);
      FETCH cur_p45_paye_prsi_details into cur_p45_paye_prsi_rec;
    CLOSE cur_p45_paye_prsi_details;
    --
    OPEN cur_p45_emp_address(p45_rec.assignment_action_id);
      FETCH cur_p45_emp_address into cur_p45_emp_address_rec;
    CLOSE cur_p45_emp_address;
    --
    OPEN cur_p45_emp_soc_details(p45_rec.assignment_action_id);
      FETCH cur_p45_emp_soc_details into cur_p45_emp_soc_details_rec;
    CLOSE cur_p45_emp_soc_details;
    --
    OPEN cur_p45_emp_details(p45_rec.assignment_action_id);
      FETCH cur_p45_emp_details into cur_p45_emp_details_rec;
    CLOSE cur_p45_emp_details;
    --
    OPEN cur_p45_ie_emp_details(p45_rec.assignment_action_id);
      FETCH cur_p45_ie_emp_details into cur_p45_ie_emp_details_rec;
    CLOSE cur_p45_ie_emp_details;
    --
    OPEN cur_p45_employer_no(p45_rec.assignment_action_id);
      FETCH cur_p45_employer_no into l_employer_number;
    CLOSE cur_p45_employer_no;

    l_total_prsi := 0;          -- Bug  5005788


  IF  p45_rec.supp_flag = 'Y' THEN
        -- Get Supp Details
	/*Bug 3991416*/
         OPEN cur_p45_supp_details(p45_rec.assignment_id,p45_rec.date_paid,p45_rec.period,p45_rec.freq);
         FETCH cur_p45_supp_details INTO  l_supp_totaltax
                                          ,l_supp_totalpay
                                          ,l_supp_lumpsum
                                          ,l_supp_totalprsi
                                          ,l_supp_employeeprsi
                                          ,l_supp_totalweeks
					  ,l_supp_classA_weeks ;                          -- Bug 5015438
        l_supp_totalprsi := NVL(l_supp_totalprsi,0) + NVL(l_supp_employeeprsi,0);         -- Bug  5005788
        CLOSE cur_p45_supp_details;
  END IF;
  -- Report the assignment if the Pay and Tax values exist.
  IF  (((p45_rec.supp_flag = 'N') /*AND (NVL(cur_p45_paye_prsi_rec.totalpay,0) <> 0 OR
                                      NVL(cur_p45_paye_prsi_rec.totaltax,0) <> 0 OR
                                      NVL(cur_p45_paye_prsi_rec.thispay,0) <> 0 OR
                                      NVL(cur_p45_paye_prsi_rec.thistax,0) <> 0 OR
                                      NVL(cur_p45_paye_prsi_rec.lumpsum,0) <> 0 OR
                                      NVL(cur_p45_paye_prsi_rec.employerprsi,0) <> 0 OR     -- Bug  5005788
                                      NVL(cur_p45_paye_prsi_rec.employeeprsi,0) <> 0 OR
                                      NVL(cur_p45_paye_prsi_rec.totalweeks,0) <> 0
                                      )*/
       ) OR
       ((p45_rec.supp_flag = 'Y') AND (NVL(l_supp_totalpay,0) <> 0 OR
                                      NVL(l_supp_totaltax,0) <> 0 OR
                                      NVL(l_supp_totalprsi,0) <> 0 OR
                                      NVL(l_supp_employeeprsi,0) <> 0 OR
                                      NVL(l_supp_lumpsum,0) <> 0 OR
                                      NVL(l_supp_totalweeks,0) <> 0 OR
				      NVL(l_supp_classA_weeks,0) <> 0                            -- Bug 5015438
                                      )
       )
      ) THEN
		IF once_per_run = 'N' THEN
			-- Start of xml doc
			/* 7291676 */
			    pay_ie_p45_archive.get_parameters (
				     p_payroll_action_id => p_p45_archive_process
				    , p_token_name        => 'START_DATE'
				    , p_token_value       => l_start_date);


			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0" encoding="UTF-8"?>');
			-- P45File root ELEMENT
			IF (to_number(to_char(to_date(l_start_date,'yyyy/mm/dd'),'yyyy')) >= 2009) THEN   -- 7291676
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_root_start_tag_new);
			ELSE
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_root_start_tag);
			END IF;

			-- Get Employer Address
			OPEN cur_employer_address(p_p45_archive_process);
			FETCH cur_employer_address INTO l_employer_add1
								    ,l_employer_add2
								    ,l_employer_add3
								    ,l_employer_contact
								    ,l_employer_phone
								    ,l_employer_name;
			CLOSE cur_employer_address;
			-- Employer ELEMENT
			FND_FILE.PUT(FND_FILE.OUTPUT,'  <Employer ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'number="' || l_employer_number ||'" ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'name="'   || l_employer_name        ||'" ');
			IF l_employer_add1 IS NOT NULL THEN
				FND_FILE.PUT(FND_FILE.OUTPUT,'address1="' || l_employer_add1    ||'" ');
			END IF;
			IF l_employer_add2 IS NOT NULL THEN
				FND_FILE.PUT(FND_FILE.OUTPUT,'address2="' || l_employer_add2    ||'" ');
			END IF;
			IF l_employer_add3 IS NOT NULL THEN
				FND_FILE.PUT(FND_FILE.OUTPUT,'address3="' || l_employer_add3    ||'" ');
			END IF;
			FND_FILE.PUT(FND_FILE.OUTPUT,'contact="'  || l_employer_contact ||'" ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'phone="'    || l_employer_phone   ||'" ');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			-- End of Employer
			once_per_run := 'Y';
		END IF;
	IF (to_number(to_char(nvl(p45_rec.date_paid,p45_rec.main_p45_date_paid),'yyyy')) >= 2009) THEN   -- 7291676
		IF p45_rec.supp_flag = 'N' THEN
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  <P45>');
		ELSE
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  <P45Supp>');
		END IF;
		-- Employee
		FND_FILE.PUT(FND_FILE.OUTPUT,'    <Employee ');
		IF cur_p45_emp_details_rec.ppsn  IS NOT NULL THEN  -- Optional
                /* 7291676 */
		        l_ppsn_override:=null;
			open csr_ppsn_override(p45_rec.assignment_id);
			fetch csr_ppsn_override into l_ppsn_override;
			close csr_ppsn_override;
			FND_FILE.PUT(FND_FILE.OUTPUT,'ppsn="'     ||nvl(l_ppsn_override, cur_p45_emp_details_rec.ppsn )     ||'" ');
			ppsn_flag := 1;
		 ELSE
			ppsn_flag := 0;
		END IF;

		-- required
		FND_FILE.PUT(FND_FILE.OUTPUT,'surname="'    || cur_p45_emp_details_rec.surname   ||'" ');
		FND_FILE.PUT(FND_FILE.OUTPUT,'firstnames="'  || cur_p45_emp_details_rec.firstname ||'" ');
		IF cur_p45_emp_details_rec.works IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'works="'    || replace(cur_p45_emp_details_rec.works,'-','')     ||'" '); /* 7827732 */
		END IF;

		IF cur_p45_emp_details_rec.dob IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'dob="'      || cur_p45_emp_details_rec.dob       ||'" ');
		END IF;

		IF cur_p45_emp_address_rec.address1  IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'address1="' || cur_p45_emp_address_rec.address1  ||'" ');
		ELSIF  cur_p45_emp_address_rec.address1  IS NULL and ppsn_flag = 0 THEN
		-- Enter the employee details in the log
			warn_status := 1;
			Fnd_file.put_line(FND_FILE.LOG,'Employee '|| cur_p45_emp_details_rec.works||' : PPSN and Address Line 1 missing for employee' );
		END IF;

		IF cur_p45_emp_address_rec.address2 IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'address2="' || cur_p45_emp_address_rec.address2  ||'" ');
		ELSIF  cur_p45_emp_address_rec.address2  IS NULL and ppsn_flag = 0 THEN
			-- Enter the employee details in the log
			warn_status := 1;
			Fnd_file.put_line(FND_FILE.LOG,'Employee '|| cur_p45_emp_details_rec.works||' : PPSN and Address Line 2 missing for employee');
		END IF;

		IF cur_p45_emp_address_rec.address3  IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'address3="' || cur_p45_emp_address_rec.address3  ||'" ');
		END IF;
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
		-- Employment
		IF p45_rec.supp_flag = 'N' THEN
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <Employment ');
			IF cur_p45_emp_details_rec.start1  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'start="' || cur_p45_emp_details_rec.start1    ||'" ');
			END IF;
		-- required
		         /* 7291676 */
			 /* 8198702 */
		    --   IF (to_number(to_char(to_date(nvl(cur_p45_emp_details_rec.end1,'01/01/2009'),'dd/mm/yyyy'),'yyyy')) >= 2009) THEN   -- 7291676
			FND_FILE.PUT(FND_FILE.OUTPUT,'end="'   || cur_p45_emp_details_rec.end1      ||'" ');
		   --	END IF;
			FND_FILE.PUT(FND_FILE.OUTPUT,'unit="'  || l_employment_unit ||'" ');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
                ELSE
                       FND_FILE.PUT(FND_FILE.OUTPUT,'    <EmploymentSupp ');
		       /* 7291676 */
		       /* 8198702 */
		     --  IF (to_number(to_char(to_date(nvl(cur_p45_emp_details_rec.end1,'01/01/2009'),'dd/mm/yyyy'),'yyyy')) >= 2009) THEN   -- 7291676
		       FND_FILE.PUT(FND_FILE.OUTPUT,'end="'   || cur_p45_emp_details_rec.end1      ||'" ');
		     -- END IF;
			FND_FILE.PUT(FND_FILE.OUTPUT,'unit="'  || l_employment_unit ||'" ');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
		END IF;
		-- Pay
		IF p45_rec.supp_flag = 'N' THEN /* 7291676 Pay tag only for main p45, for supp its paydetails */

		-- required
		        FND_FILE.PUT(FND_FILE.OUTPUT,'    <Pay ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'freq="'      || p45_rec.freq      ||'" ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'period="'    || p45_rec.period    ||'" ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'taxcredit="' || cur_p45_ie_emp_details_rec.taxcredit ||'" ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'cutoff="'   || cur_p45_ie_emp_details_rec.cutoff    ||'" ');

			IF p45_rec.emergency_tax = 'Y' THEN
				FND_FILE.PUT(FND_FILE.OUTPUT,'emergency="' ||  'true'     ||'" ');
		        ELSE
				FND_FILE.PUT(FND_FILE.OUTPUT,'emergency="' ||  'false'     ||'" ');
		        END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />'); -- 7291676
		ELSE
		        OPEN csr_supp_paydetails(p45_rec.assignment_id);
			FETCH csr_supp_paydetails INTO csr_supp_paydetails_rec;

			IF csr_supp_paydetails%FOUND THEN
			    /*   l_eit_sum:= to_number(nvl(csr_supp_paydetails_rec.pay1,0))
			                   + to_number(nvl(csr_supp_paydetails_rec.pay2,0))
					   + to_number(nvl(csr_supp_paydetails_rec.pay3,0))
					   + to_number(nvl(csr_supp_paydetails_rec.pay4,0))
					   + to_number(nvl(csr_supp_paydetails_rec.pay5,0))
					   + to_number(nvl(csr_supp_paydetails_rec.allotherpay,0));  */
                               l_eit_supp_flag:= false;

                            --   IF l_eit_sum= l_supp_totalpay THEN
					FND_FILE.PUT(FND_FILE.OUTPUT,'    <PaymentDetails ');
					IF csr_supp_paydetails_rec.year1 IS NOT NULL THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,' year1="'      || csr_supp_paydetails_rec.year1        ||'" ');
						FND_FILE.PUT(FND_FILE.OUTPUT,' pay1="'      || csr_supp_paydetails_rec.pay1        ||'" ');

					END IF;
					IF csr_supp_paydetails_rec.year2 IS NOT NULL THEN
					   IF csr_supp_paydetails_rec.year1=csr_supp_paydetails_rec.year2 THEN
                                                l_eit_supp_flag:= true;
                                           END IF;
					   IF NOT l_eit_supp_flag THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,' year2="'      || csr_supp_paydetails_rec.year2        ||'" ');
						FND_FILE.PUT(FND_FILE.OUTPUT,' pay2="'      || csr_supp_paydetails_rec.pay2        ||'" ');
                                           END IF;
					END IF;
					IF csr_supp_paydetails_rec.year3 IS NOT NULL THEN
					   IF( (csr_supp_paydetails_rec.year1=csr_supp_paydetails_rec.year3 )
					     OR ( csr_supp_paydetails_rec.year2=csr_supp_paydetails_rec.year3 )
					     )THEN
                                                l_eit_supp_flag:= true;
                                           END IF;
					   IF NOT l_eit_supp_flag THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,' year3="'      || csr_supp_paydetails_rec.year3        ||'" ');
						FND_FILE.PUT(FND_FILE.OUTPUT,' pay3="'      || csr_supp_paydetails_rec.pay3        ||'" ');
					   END IF;
					END IF;
					IF csr_supp_paydetails_rec.year4 IS NOT NULL THEN
					   IF ((csr_supp_paydetails_rec.year1=csr_supp_paydetails_rec.year4)
					     OR (csr_supp_paydetails_rec.year2=csr_supp_paydetails_rec.year4)
					     OR (csr_supp_paydetails_rec.year3=csr_supp_paydetails_rec.year4 )
					     )THEN
                                                l_eit_supp_flag:= true;
                                           END IF;
					   IF NOT l_eit_supp_flag THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,' year4="'      || csr_supp_paydetails_rec.year4        ||'" ');
						FND_FILE.PUT(FND_FILE.OUTPUT,' pay4="'      || csr_supp_paydetails_rec.pay4        ||'" ');
                                           END IF;
					END IF;
					IF csr_supp_paydetails_rec.year5 IS NOT NULL THEN
					   IF ((csr_supp_paydetails_rec.year1=csr_supp_paydetails_rec.year5 )
					     OR (csr_supp_paydetails_rec.year2=csr_supp_paydetails_rec.year5)
					     OR (csr_supp_paydetails_rec.year3=csr_supp_paydetails_rec.year5)
					     OR (csr_supp_paydetails_rec.year4=csr_supp_paydetails_rec.year5)
					     )THEN
                                                l_eit_supp_flag:= true;
                                           END IF;
					   IF NOT l_eit_supp_flag THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,' year5="'      || csr_supp_paydetails_rec.year5        ||'" ');
						FND_FILE.PUT(FND_FILE.OUTPUT,' pay5="'      || csr_supp_paydetails_rec.pay5        ||'" ');
                                           END IF;
					END IF;
					IF csr_supp_paydetails_rec.allotherpay <>0 THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,' allotherpay="'      || csr_supp_paydetails_rec.allotherpay        ||'" ');
					END IF;
					 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
					 IF l_eit_supp_flag THEN
					 l_str_Common:=' Ensure that the Year1, Year2, Year3, Year4, and Year5 values are not the same for the assignment  '|| p45_rec.assignment_id;
					Fnd_file.put_line(FND_FILE.LOG,l_str_common);
					error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
			                                 'IE P45 XML report completed with validation warning(s).');
					END IF;
                        /*      ELSE
					l_str_Common:=' Ensure that the sum of Pay1, Pay2, Pay3, Pay4, Pay5 and All Other Pay is equal to the total pay in supplementary p45 for the asssingment'|| p45_rec.assignment_id;
					Fnd_file.put_line(FND_FILE.LOG,l_str_common);
					error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
			                                 'IE P45 XML report completed with validation warning(s).');

                              END IF;  */

			ELSE
			        FND_FILE.PUT(FND_FILE.OUTPUT,'    <PaymentDetails ');
				FND_FILE.PUT(FND_FILE.OUTPUT,' year1="'      || to_char(p45_rec.date_paid,'yyyy')        ||'" ');
				FND_FILE.PUT(FND_FILE.OUTPUT,' pay1="'      || l_supp_totalpay        ||'" ');
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			END IF;
			CLOSE csr_supp_paydetails;
		END IF;




		IF p45_rec.supp_flag = 'N' THEN
		-- Tax Details for Normal P45 Run
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <TaxDetails ');
			IF cur_p45_paye_prsi_rec.totalpay  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'totalpay="' || cur_p45_paye_prsi_rec.totalpay  ||'" ');
			END IF;
			IF cur_p45_paye_prsi_rec.totaltax  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'totaltax="' || cur_p45_paye_prsi_rec.totaltax  ||'" ');
			END IF;
			IF cur_p45_paye_prsi_rec.thispay  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'thispay="'  || cur_p45_paye_prsi_rec.thispay   ||'" ');
			END IF;
			IF cur_p45_paye_prsi_rec.thistax  IS NOT NULL THEN  -- Optional
			      -- for bug 5401393, negative tax should not be displayed with - sign.
				FND_FILE.PUT(FND_FILE.OUTPUT,'thistax="'  || abs(cur_p45_paye_prsi_rec.thistax)   ||'" ');
				IF cur_p45_paye_prsi_rec.thistax < 0 THEN
					FND_FILE.PUT(FND_FILE.OUTPUT,'thistaxrefunded="true" ');
				ELSE
					FND_FILE.PUT(FND_FILE.OUTPUT,'thistaxrefunded="false" ');
				END IF;
			END IF;

			IF cur_p45_paye_prsi_rec.lumpsum  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'lumpsum="'  || cur_p45_paye_prsi_rec.lumpsum   ||'" ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			-- PRSI
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <PRSI ');
			-- Bug  5005788
			l_total_prsi := NVL(cur_p45_paye_prsi_rec.employerprsi,0) + NVL(cur_p45_paye_prsi_rec.employeeprsi,0);
			FND_FILE.PUT(FND_FILE.OUTPUT,'total="'    || NVL(l_total_prsi,0)  ||'" ');
			IF cur_p45_paye_prsi_rec.employeeprsi  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'employee="' || NVL(cur_p45_paye_prsi_rec.employeeprsi,0) ||'" ');
			END IF;
			FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="'    || NVL(cur_p45_paye_prsi_rec.totalweeks,0)   ||'" ');

		ELSE
		-- Tax Details for  P45 Supp Run
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <TaxDetailsSupp '); -- 7291676
			IF l_supp_totalpay  IS NOT NULL THEN  -- Optional
			--	FND_FILE.PUT(FND_FILE.OUTPUT,'totalpay="' || l_supp_totalpay  ||'" '); /* 7291676 */
			        FND_FILE.PUT(FND_FILE.OUTPUT,'paysupp="' || l_supp_totalpay  ||'" ');  /* 7291676 */
			END IF;
			IF l_supp_totaltax  IS NOT NULL THEN  -- Optional
			--	FND_FILE.PUT(FND_FILE.OUTPUT,'totaltax="' || l_supp_totaltax  ||'" '); /* 7291676 */
			        FND_FILE.PUT(FND_FILE.OUTPUT,'taxdsupp="' || l_supp_totaltax  ||'" '); /* 7291676 */
			END IF;
                        /* 7291676 */
			IF p45_rec.date_paid IS NOT NULL THEN

                                FND_FILE.PUT(FND_FILE.OUTPUT,'dateofpayment="' || to_char(p45_rec.date_paid,'dd/mm/rrrr')  ||'" ');
			END IF;

                        IF l_supp_totalprsi IS NOT NULL THEN

                                FND_FILE.PUT(FND_FILE.OUTPUT,'totalprsi="' || l_supp_totalprsi  ||'" ');
			END IF;
			IF l_supp_employeeprsi IS NOT NULL THEN

                                FND_FILE.PUT(FND_FILE.OUTPUT,'employeeshare="' || l_supp_employeeprsi  ||'" ');
			END IF;

			/* 7291676 */
			/*
			IF l_supp_lumpsum  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'lumpsum="'  || l_supp_lumpsum   ||'" ');
			END IF;
			*/
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			-- PRSI details for P45 Supp Run
			/* 7291676 commenting the PRSI section for supp p45 */
			/*
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <PRSI ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'total="'    || NVL(l_supp_totalprsi,0)    ||'" ');
			IF l_supp_employeeprsi  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'employee="' || NVL(l_supp_employeeprsi,0) ||'" ');
			END IF;
			FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="'    || NVL(l_supp_totalweeks,0)  ||'" '); */
		END IF;
		-- PRSIClass for main P45
      	IF cur_p45_ie_emp_details_rec.prsi_class  IS NOT NULL OR
	         ( NVL(cur_p45_paye_prsi_rec.totalaweeks,0) <> 0 and p45_rec.supp_flag <> 'Y' ) OR
	         ( NVL(l_supp_classA_weeks,0) <> 0 and p45_rec.supp_flag <> 'N' ) THEN
		       /* 7291676 */
		       IF p45_rec.supp_flag <> 'Y' THEN
			 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'>');
		       END IF;
			IF (NVL(cur_p45_paye_prsi_rec.totalaweeks,0) <> 0) and p45_rec.supp_flag <> 'Y'  THEN 	-- Bug 5015438
				FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || 'A'  ||'" ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="' || cur_p45_paye_prsi_rec.totalaweeks ||'" ');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
			END IF;
			 /* 7291676 */
			/*
			IF (NVL(l_supp_classA_weeks,0) <> 0 ) and p45_rec.supp_flag <> 'N'  THEN
				FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || 'A'  ||'" ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="' || l_supp_classA_weeks ||'" ');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
			END IF; */
			vfrom:=1;
			vto:=length(cur_p45_ie_emp_details_rec.prsi_class);
			LOOP
				vfound:= instr(cur_p45_ie_emp_details_rec.prsi_class,',',vfrom,1);
				IF (vfound > 0 ) THEN
					vto:=vfound-vfrom;
					v_prsi_class:= substr(cur_p45_ie_emp_details_rec.prsi_class,vfrom,vto);
					FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
					FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || v_prsi_class  ||'" ');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
					vfrom:=vfound+1;
				ELSE
					v_prsi_class:= substr(cur_p45_ie_emp_details_rec.prsi_class,vfrom);
					IF v_prsi_class IS NOT NULL THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
						FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || v_prsi_class  ||'" ');
						FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
					END IF;
					EXIT;
				END IF;
			END LOOP;
			/* 7291676 */
			IF p45_rec.supp_flag <> 'Y' THEN
                			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    </PRSI>');
			END IF;
		ELSE
		        /* 7291676 */
		        IF p45_rec.supp_flag <> 'Y' THEN
			        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
			END IF;
		END IF;
		IF p45_rec.supp_flag = 'N' THEN
			-- Disability
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <Disability ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'benefit="'            || nvl(cur_p45_emp_soc_details_rec.benefit,0)            ||'" ');
			IF cur_p45_emp_soc_details_rec.taxcreditreduction  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'taxcreditreduction="' || cur_p45_emp_soc_details_rec.taxcreditreduction ||'" ');
			END IF;
			IF cur_p45_emp_soc_details_rec.cutoffreduction  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'cutoffreduction="'    || cur_p45_emp_soc_details_rec.cutoffreduction    ||'" ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			-- Deceased

			FND_FILE.PUT(FND_FILE.OUTPUT,'    <Basis ');
			IF cur_p45_emp_soc_details_rec.noncumulative  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'noncumulative="'      || cur_p45_emp_soc_details_rec.noncumulative      ||'" ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');

			IF cur_p45_emp_details_rec.deceased = 'Y' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    <Deceased/> ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  </P45> ');
		ELSE
			--  FND_FILE.PUT(FND_FILE.OUTPUT,' <Disability ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'benefit="'            || p45_rec.benefit            ||'" ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'taxcreditreduction="' || p45_rec.taxcreditreduction ||'" ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'cutoffreduction="'    || p45_rec.cutoffreduction    ||'" ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'noncumulative="'      || p45_rec.noncumulative      ||'" ');
			--  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			IF cur_p45_emp_details_rec.deceased = 'Y' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    <Deceased/> '); /* 7291676 */
			END IF;

			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  </P45Supp> ');
		END IF;
    ELSE

    IF p45_rec.supp_flag = 'N' THEN
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  <P45>');
		ELSE
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  <P45Supp>');
		END IF;
		-- Employee
		FND_FILE.PUT(FND_FILE.OUTPUT,'    <Employee ');
		IF cur_p45_emp_details_rec.ppsn  IS NOT NULL THEN  -- Optional
		/* 7291676QA */
		        l_ppsn_override:=null;
			open csr_ppsn_override(p45_rec.assignment_id);
			fetch csr_ppsn_override into l_ppsn_override;
			close csr_ppsn_override;
			FND_FILE.PUT(FND_FILE.OUTPUT,'ppsn="'     || nvl(l_ppsn_override, cur_p45_emp_details_rec.ppsn )      ||'" ');
			ppsn_flag := 1;
		ELSE
			ppsn_flag := 0;
		END IF;

		-- required
		FND_FILE.PUT(FND_FILE.OUTPUT,'surname="'    || cur_p45_emp_details_rec.surname   ||'" ');
		FND_FILE.PUT(FND_FILE.OUTPUT,'firstnames="'  || cur_p45_emp_details_rec.firstname ||'" ');
		IF cur_p45_emp_details_rec.works IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'works="'    || replace(cur_p45_emp_details_rec.works,'-','')     ||'" ');  /* 7827732 */
		END IF;

		IF cur_p45_emp_details_rec.dob IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'dob="'      || cur_p45_emp_details_rec.dob       ||'" ');
		END IF;

		IF cur_p45_emp_address_rec.address1  IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'address1="' || cur_p45_emp_address_rec.address1  ||'" ');
		ELSIF  cur_p45_emp_address_rec.address1  IS NULL and ppsn_flag = 0 THEN
		-- Enter the employee details in the log
			warn_status := 1;
			Fnd_file.put_line(FND_FILE.LOG,'Employee '|| cur_p45_emp_details_rec.works||' : PPSN and Address Line 1 missing for employee' );
		END IF;

		IF cur_p45_emp_address_rec.address2 IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'address2="' || cur_p45_emp_address_rec.address2  ||'" ');
		ELSIF  cur_p45_emp_address_rec.address2  IS NULL and ppsn_flag = 0 THEN
			-- Enter the employee details in the log
			warn_status := 1;
			Fnd_file.put_line(FND_FILE.LOG,'Employee '|| cur_p45_emp_details_rec.works||' : PPSN and Address Line 2 missing for employee');
		END IF;

		IF cur_p45_emp_address_rec.address3  IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'address3="' || cur_p45_emp_address_rec.address3  ||'" ');
		END IF;
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
		-- Employment
		FND_FILE.PUT(FND_FILE.OUTPUT,'    <Employment ');
		IF cur_p45_emp_details_rec.start1  IS NOT NULL THEN  -- Optional
			FND_FILE.PUT(FND_FILE.OUTPUT,'start="' || cur_p45_emp_details_rec.start1    ||'" ');
		END IF;
		-- required
		FND_FILE.PUT(FND_FILE.OUTPUT,'end="'   || cur_p45_emp_details_rec.end1      ||'" ');
		FND_FILE.PUT(FND_FILE.OUTPUT,'unit="'  || l_employment_unit ||'" ');
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
		-- Pay
		FND_FILE.PUT(FND_FILE.OUTPUT,'    <Pay ');
		-- required
		FND_FILE.PUT(FND_FILE.OUTPUT,'freq="'      || p45_rec.freq      ||'" ');
		FND_FILE.PUT(FND_FILE.OUTPUT,'period="'    || p45_rec.period    ||'" ');
		FND_FILE.PUT(FND_FILE.OUTPUT,'taxcredit="' || cur_p45_ie_emp_details_rec.taxcredit ||'" ');
		FND_FILE.PUT(FND_FILE.OUTPUT,'cutoff="'   || cur_p45_ie_emp_details_rec.cutoff    ||'" ');

		IF p45_rec.emergency_tax = 'Y' THEN
			FND_FILE.PUT(FND_FILE.OUTPUT,'emergency="' ||  'true'     ||'" ');
		ELSE
			FND_FILE.PUT(FND_FILE.OUTPUT,'emergency="' ||  'false'     ||'" ');
		END IF;
	      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');

		IF p45_rec.supp_flag = 'N' THEN
		-- Tax Details for Normal P45 Run
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <TaxDetails ');
			IF cur_p45_paye_prsi_rec.totalpay  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'totalpay="' || cur_p45_paye_prsi_rec.totalpay  ||'" ');
			END IF;
			IF cur_p45_paye_prsi_rec.totaltax  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'totaltax="' || cur_p45_paye_prsi_rec.totaltax  ||'" ');
			END IF;
			IF cur_p45_paye_prsi_rec.thispay  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'thispay="'  || cur_p45_paye_prsi_rec.thispay   ||'" ');
			END IF;
			IF cur_p45_paye_prsi_rec.thistax  IS NOT NULL THEN  -- Optional
			      -- for bug 5401393, negative tax should not be displayed with - sign.
				FND_FILE.PUT(FND_FILE.OUTPUT,'thistax="'  || abs(cur_p45_paye_prsi_rec.thistax)   ||'" ');
				IF cur_p45_paye_prsi_rec.thistax < 0 THEN
					FND_FILE.PUT(FND_FILE.OUTPUT,'thistaxrefunded="true" ');
				ELSE
					FND_FILE.PUT(FND_FILE.OUTPUT,'thistaxrefunded="false" ');
				END IF;
			END IF;

			IF cur_p45_paye_prsi_rec.lumpsum  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'lumpsum="'  || cur_p45_paye_prsi_rec.lumpsum   ||'" ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			-- PRSI
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <PRSI ');
			-- Bug  5005788
			l_total_prsi := NVL(cur_p45_paye_prsi_rec.employerprsi,0) + NVL(cur_p45_paye_prsi_rec.employeeprsi,0);
			FND_FILE.PUT(FND_FILE.OUTPUT,'total="'    || NVL(l_total_prsi,0)  ||'" ');
			IF cur_p45_paye_prsi_rec.employeeprsi  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'employee="' || NVL(cur_p45_paye_prsi_rec.employeeprsi,0) ||'" ');
			END IF;
			FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="'    || NVL(cur_p45_paye_prsi_rec.totalweeks,0)   ||'" ');
		ELSE
		-- Tax Details for  P45 Supp Run
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <TaxDetails ');
			IF l_supp_totalpay  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'totalpay="' || l_supp_totalpay  ||'" ');
			END IF;
			IF l_supp_totaltax  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'totaltax="' || l_supp_totaltax  ||'" ');
			END IF;
			IF l_supp_lumpsum  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'lumpsum="'  || l_supp_lumpsum   ||'" ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			-- PRSI details for P45 Supp Run
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <PRSI ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'total="'    || NVL(l_supp_totalprsi,0)    ||'" ');
			IF l_supp_employeeprsi  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'employee="' || NVL(l_supp_employeeprsi,0) ||'" ');
			END IF;
			FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="'    || NVL(l_supp_totalweeks,0)  ||'" ');
		END IF;
		-- PRSIClass for main P45
      	IF cur_p45_ie_emp_details_rec.prsi_class  IS NOT NULL OR
	         ( NVL(cur_p45_paye_prsi_rec.totalaweeks,0) <> 0 and p45_rec.supp_flag <> 'Y' ) OR
	         ( NVL(l_supp_classA_weeks,0) <> 0 and p45_rec.supp_flag <> 'N' ) THEN
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'>');
			IF (NVL(cur_p45_paye_prsi_rec.totalaweeks,0) <> 0) and p45_rec.supp_flag <> 'Y'  THEN 	-- Bug 5015438
				FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || 'A'  ||'" ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="' || cur_p45_paye_prsi_rec.totalaweeks ||'" ');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
			END IF;
			IF (NVL(l_supp_classA_weeks,0) <> 0 ) and p45_rec.supp_flag <> 'N'  THEN
				FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || 'A'  ||'" ');
				FND_FILE.PUT(FND_FILE.OUTPUT,'weeks="' || l_supp_classA_weeks ||'" ');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
			END IF;
			vfrom:=1;
			vto:=length(cur_p45_ie_emp_details_rec.prsi_class);
			LOOP
				vfound:= instr(cur_p45_ie_emp_details_rec.prsi_class,',',vfrom,1);
				IF (vfound > 0 ) THEN
					vto:=vfound-vfrom;
					v_prsi_class:= substr(cur_p45_ie_emp_details_rec.prsi_class,vfrom,vto);
					FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
					FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || v_prsi_class  ||'" ');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
					vfrom:=vfound+1;
				ELSE
					v_prsi_class:= substr(cur_p45_ie_emp_details_rec.prsi_class,vfrom);
					IF v_prsi_class IS NOT NULL THEN
						FND_FILE.PUT(FND_FILE.OUTPUT,'      <PRSIClass ');
						FND_FILE.PUT(FND_FILE.OUTPUT,'class="' || v_prsi_class  ||'" ');
						FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
					END IF;
					EXIT;
				END IF;
			END LOOP;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    </PRSI>');
		ELSE
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'/>');
		END IF;
		IF p45_rec.supp_flag = 'N' THEN
			-- Disability
			FND_FILE.PUT(FND_FILE.OUTPUT,'    <Disability ');
			FND_FILE.PUT(FND_FILE.OUTPUT,'benefit="'            || nvl(cur_p45_emp_soc_details_rec.benefit,0)            ||'" ');
			IF cur_p45_emp_soc_details_rec.taxcreditreduction  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'taxcreditreduction="' || cur_p45_emp_soc_details_rec.taxcreditreduction ||'" ');
			END IF;
			IF cur_p45_emp_soc_details_rec.cutoffreduction  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'cutoffreduction="'    || cur_p45_emp_soc_details_rec.cutoffreduction    ||'" ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			-- Deceased

			FND_FILE.PUT(FND_FILE.OUTPUT,'    <Basis ');
			IF cur_p45_emp_soc_details_rec.noncumulative  IS NOT NULL THEN  -- Optional
				FND_FILE.PUT(FND_FILE.OUTPUT,'noncumulative="'      || cur_p45_emp_soc_details_rec.noncumulative      ||'" ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');

			IF cur_p45_emp_details_rec.deceased = 'Y' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'    <Deceased/> ');
			END IF;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  </P45> ');
		ELSE
			--  FND_FILE.PUT(FND_FILE.OUTPUT,' <Disability ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'benefit="'            || p45_rec.benefit            ||'" ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'taxcreditreduction="' || p45_rec.taxcreditreduction ||'" ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'cutoffreduction="'    || p45_rec.cutoffreduction    ||'" ');
			--  FND_FILE.PUT(FND_FILE.OUTPUT,'noncumulative="'      || p45_rec.noncumulative      ||'" ');
			--  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' />');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  </P45Supp> ');
		END IF;
  END IF; -- 7291676
	END IF;
END LOOP;
IF once_per_run = 'Y' THEN
	-- End of ROOT P45File ELEMENT
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_root_end_tag);
END IF;


IF warn_status =1 then
	l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS
		 (
		  status => 'WARNING',
		  message => 'PPSN and Address missing. Please check the log file for more details.'
		 );

END IF;

END generate_xml;

END pay_ie_p45_archive;


/
