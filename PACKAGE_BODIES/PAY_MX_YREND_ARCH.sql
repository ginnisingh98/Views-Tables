--------------------------------------------------------
--  DDL for Package Body PAY_MX_YREND_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_YREND_ARCH" AS
/* $Header: paymxyrendarch.pkb 120.32.12010000.9 2009/04/22 09:08:15 sivanara ship $ */
/*  +=========================================================================+
    |                Copyright (c) 2005 Oracle Corporation                    |
    |                       IDC, Hyderabad, India                             |
    |                        All rights reserved.                             |
    +=========================================================================+
    Package File Name : paymxyrendarch.pkb
    Description       : This package contains the procedures needed to
                        implement Year End Archiver for Mexico HRMS
                        localization (MX).


    Change List:
    ------------

    =========================================================================
    Version  Date         Author    Bug No.  Description of Change
    -------  -----------  --------  -------  --------------------------------
    115.0    06-SEP-2005  ardsouza           Initial Version
    115.1    16-SEP-2005  ardsouza           Modified range_cursor to check
                                             only Completed runs of past
                                             archiver or Format 37.
                                             Relaxed date constraint on cursor
                                             c_get_eff_date to allow terminated
                                             employees.
    115.2    29-SEP-2005  sdahiya   4625794  Modified range_code and
                                             assignment_action_code. Added
                                             sub-programs gre_exists and
                                             load_gre.
    115.3    04-OCT-2005  sdahiya            Modified archive_code to archive
                                             data only for that legal employer
                                             which was selected at the
                                             parameter window.

                                    4649954  Union Worker should be archived as
                                             "N" when collective agreement on
                                             assignment form is null.
    115.4    14-OCT-2005  sdahiya            - Removed action_status = 'C' check
                                             - Modified range code to pick
                                               terminated/re-hired persons too.
                                             - Added missing join condition
                                               for effective dates in cursor
                                               c_get_ytd_aaid.
                                             - Added join with
                                               pay_action_classifications in
                                               c_get_ytd_aaid.
    115.5    18-OCT-2005  ardsouza           Modified to store start and end
                                             dates instead of months.
                                             Collective agreement of all
                                             assignments for the person checked
                                             to derive Union Worker flag.
    115.6    24-OCT-2005  ardsouza           - Modified to stamp 31st Dec on
                                             archive record for active EEs.
                                             - State ID archived.
                                             - 31st Dec always used for fetching
                                             latest YTD aaid .
                                    4690778  - Seniority archived as null for
                                             Active EEs.
                                             - Person to be picked up if any
                                             assignment found in assignment set.
                                    4687345  - Added date check in cursor
                                             c_get_emp_asg_range.
                                    4693525  - Corrected calculation for Tax
                                             Subsidy Proportion.
    115.7    26-OCT-2005  ardsouza           - Modified cursors c_get_emp_asg
                                             and c_get_emp_asg_range to create
                                             multiple assignment actions for a
                                             re-hired person, if archiver not
                                             already run for previous stint.
                                             - Relaxed date constraint on
                                             c_get_ytd_aaid to allow terminated
                                             EEs.
                                    4703130  Hyphens not used for validation in
                                             ER RFC.
    115.8    02-NOV-2005  ardsouza  4712450  - Subsidy Proportion applied only
                                             if a different one used and if
                                             Annual Tax Adjustment is run.
                                             - Archived "ISR Exempt by Previous
                                             ER".
                                             - Rounded Subsidy Proportion to 4
                                             places instead of 2.
    115.9    03-NOV-2005  ardsouza  4693525  - Reverted changes made in 115.6
                                             for "Subsidy Proportion Applied".
                                             The changes are needed only for
                                             "Subsidy Proportion".
    115.10   07-NOV-2005  ardsouza           - Annual Tax Adj Run checked only
                                             for "Subsidy Proportion Applied"
                                             and not "Subsidy Proportion".
    115.11   14-DEC-2005  ardsouza           - Modified to allow multiple runs
                                             of Archiver for same period of
                                             service as long as payroll runs
                                             exist after the last archiver was
                                             run.
                                             - Effective date of balance calls
                                             to be the effective date specified
                                             as parameter.
                                             - The second archiver run would
                                             always lock the first.
    115.12   06-JAN-2006  vpandya            Replace get_seniority function with
                                             get_seniority_social_security to
                                             get seniority years.
    115.13   12-JAN-2006  ardsouza  4938724  - Modified to use p_effective_date
                                             as the effective_date for all
                                             purposes.
    115.14   17-JAN-2006  ardsouza  4960302  - Termination Date would still be
                                             used to fetch person details.
                                    4956977  Reverted changes in 115.12.
    115.15   17-JAN-2006  ardsouza           Bumped version to fix arcs message.
    115.16   25-JAN-2006  ardsouza  4998030  Corrected c_chk_last_archiver.
    115.17   02-FEB-2006  ardsouza  5004297  '<First Name> <Second Name>' to be
                                             stored under "Names".
                                    5002968  Seniority not archived if archiver
                                             is run for PTU, even for ex-EEs.
    115.18   06-FEB-2006  ardsouza  5019199  R,Q,B,V,I actions after the prev
                                             archiver would be detected based on
                                             effective date rather than action
                                             sequence because Archiver itself
                                             is a Non-Sequenced action.
    115.19   06-FEB-2006  ardsouza  5019199  Fix in 115.18 modified to restrict
                                             R,Q,B,V,I actions only upto the
                                             effective date of the archiver.
    115.20   13-FEB-2006  vpandya   5035094  Changed populate_balances:
                                             When YREND Archiver run previously
                                             and it is run again for PTU,
                                             ISR Withheld would be
                                             ISR Withheld YTD - ISR Withheld of
                                             previous archived value.
    115.21   15-FEB-2006  ardsouza  5002968  Seniority displayed as 0 instead
                                             of NULL, when not needed.
    115.22   10-MAR-2006  ardsouza           PL-SQL table g_gre_tab made public
                                             for use within "PAY_MX_PTU_CALC".
    115.23   04-MAY-2006  ardsouza  5205255  Removed unwanted table references
                                             in cursor c_chk_asg.
    115.24   02-AUG-2006  sbairagi  5042700  Cursor c_get_emp_asg of procedure
                                             assignment_action_code is tuned.
    115.25   03-AUG-2006  vpandya            same as 115.24. Arcsed in 120
                                             version mistakenly. Got error and
                                             corrected in 115.25.
    115.26   07-AUG-2006  nragavar  5457394  Archive_code to archive 'Y' where
                                             there exists AnnTaxAdj process run.
                                             Pkg has been modified to take out
                                             all un-wanted comments to make the
                                             package more readable. Procedure
                                             archive_code has been modifed to
                                             consider the action_status to 'C'
                                             ie to select the assignments that
                                             had been processed successfully.
    115.28   20-Sep-2006  nragavar  5552748  added code to archive two flags
                                             RATE_1991_IND,RATE_FISCAL_YEAR_IND
    115.29   26-Sep-2006  vmehta    5565656  Changed the logic for identifying
                                             union member. Use the
                                             LABOUR_UNION_MEMBER_FLAG instead
                                             of collective agreement lookup.
    115.30   06-Dec-2006  vpandya   5701000  Changed assignment_action_code.
                                             Initializing previous archiver date
                                             and asg act id for each assignment.
    115.31   06-Dec-2006  vpandya   5701701  Changed archive_code:
                                             Taking greatest of hire date and
                                             archiver start date. Also taking
                                             least of archiver end date and
                                             p_effective_date.
    115.32   03-Jan-2007  vpandya   5714195  Changed assignment_action_code:
                                             cursors c_chk_last_archiver and
                                             c_chk_non_arch_runs.
                                             Also changed archive_code:
                                             added a condition where date for
                                             PTU is populating.
    115.33   11-Sep-2007  nrgavar   5923989  Modified to archive ISR Calculated,
                                             Creditable Subsidy and
                                             non-creditable subsidy.
    115.34   17-Sep-2007  vpandya   5002968  Changed archive_date: seniority
                                             should not be archived for term-ee
                                             when YREND arch is run only 4 PTU.
                                             as mentioned in 115.17
    115.36   25-Feb-2008  nragavar  6807997  modified the function archive_code
    115.37   25-Feb-2008  nragavar  6807997  modified the function populate_balances
    115.41   26-Feb-2009  sivanara  7529502  Changed techinal logic for performance
	                                     issue.
    115.42   08-Apr-2009  sivanara  8402505  Modified cursor c_get_eff_date, to get
                                             actual termination date also.
    115.43   17-Apr-2009  sivanara  8402464  Added condition
                                              ld_PUT_DATE > ld_arch_end_date.
					      for getting archive end date
					      and enabling only_PTU_flag.
    115.44   20-Apr-2009 sivanara   8402464 Added code computation of seniority
                                            for test case ,when emp
                                            terminated and ran PTU before the
					    year end process.
*/
--
/******************************************************************************
** Global Variables
******************************************************************************/
   gv_package   VARCHAR2(100);
   gn_prev_asg_act_id NUMBER;
/* Bug 7529502*/
   TYPE rec_entity_details IS RECORD
   ( user_entity_name ff_user_entities.user_entity_name%TYPE,
     def_bal_id ff_user_entities.creator_id%TYPE,
     bal_value  NUMBER);
   TYPE entity_details_tab IS TABLE OF rec_entity_details INDEX BY BINARY_INTEGER;
   g_archive_item_details entity_details_tab;
   g_ptu_bal_details      entity_details_tab;
---------------------------------------------------------------------------------------------------------------------------+
--For year end Balances define global variable to store defined_balance_id's and the corresponding balance values for BBR.
---------------------------------------------------------------------------------------------------------------------------+
g_ye_balance_value_tab     pay_balance_pkg.t_balance_value_tab;
---------------------------------------------------------------------------------------------------------------------------+
--For year end Balances define global variable to store defined_balance_id's and the corresponding balance values for BBR.
---------------------------------------------------------------------------------------------------------------------------+
g_ptu_balance_value_tab     pay_balance_pkg.t_balance_value_tab;
--------------------------------------------------------------------------

--                                                                      --
-- Name           : load_ye_balance                                     --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to load the year end balance value        --
-- Parameters     :                                                     --
--            OUT : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
/*Added for bug 7529502*/
procedure load_ye_balance as
-- Get balances for archival
    CURSOR c_get_balances IS
      SELECT DISTINCT
             fue_live.user_entity_name,
	     fue_live.creator_id,
	     0 tmp_bal_value
      FROM   pay_bal_attribute_definitions pbad,
             pay_balance_attributes        pba,
             pay_defined_balances          pdb_attr,
             pay_defined_balances          pdb_call,
             pay_balance_dimensions        pbd,
             ff_user_entities              fue_live
      WHERE  pbad.attribute_name           = 'Year End Balances'
        AND  pbad.legislation_code         = 'MX'
        AND  pba.attribute_id              = pbad.attribute_id
        AND  pdb_attr.defined_balance_id   = pba.defined_balance_id
        AND  pdb_attr.balance_type_id      = pdb_call.balance_type_id
        AND  pdb_call.balance_dimension_id = pbd.balance_dimension_id
        AND  pbd.database_item_suffix      = '_PER_PDS_GRE_YTD'
        AND  pbd.legislation_code          = pbad.legislation_code
        AND  fue_live.creator_id           = pdb_call.defined_balance_id
        AND  fue_live.creator_type         = 'B'
   ORDER BY  fue_live.user_entity_name;

 -- Get Profit Sharing balances for archival
    CURSOR c_get_PTU_balances IS
      SELECT DISTINCT
             fue_live.user_entity_name,
	     fue_live.creator_id,
    	     0 tmp_bal_value
     FROM   pay_defined_balances    pdb_call,
             pay_balance_dimensions  pbd,
             pay_balance_types       pbt,
             ff_user_entities        fue_live
      WHERE  pbt.balance_name IN ('ISR Withheld',
                                  'Year End ISR Subject for Profit Sharing',
                                  'Year End ISR Exempt for Profit Sharing')
        AND  pbt.balance_type_id           = pdb_call.balance_type_id
        AND  pdb_call.balance_dimension_id = pbd.balance_dimension_id
        AND  pbd.database_item_suffix      = '_PER_PDS_GRE_YTD'
        AND  pbd.legislation_code          = pbt.legislation_code
        AND  pbt.legislation_code          = 'MX'
        AND  fue_live.creator_id           = pdb_call.defined_balance_id
        AND  fue_live.creator_type         = 'B'
   ORDER BY  fue_live.user_entity_name;

lv_procedure_name varchar2(30) := 'load_ye_balance';

begin
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     -- Clearing the global tables before initializing ..
     g_archive_item_details.DELETE;
     g_ptu_bal_details.DELETE;
     g_ptu_balance_value_tab.DELETE;
     g_ye_balance_value_tab.DELETE;

     /*This code will be move to script and mapped to this file if needed*/
    pay_mx_archive_dbi_pkg.create_archive_routes;
     hr_utility.trace('Called from initialization_code and initialized for whole process');
     hr_utility.trace('Getting the year end balances ');
     OPEN c_get_balances ;
     FETCH c_get_balances BULK COLLECT INTO g_archive_item_details;
     CLOSE c_get_balances;
     hr_utility.trace('Getting the PTU year end balances ');
     OPEN c_get_PTU_balances;
     FETCH c_get_PTU_balances BULK COLLECT INTO g_ptu_bal_details;
     CLOSE c_get_PTU_balances;
     /*This code will be move to script and mapped to this file if needed*/
    FOR i IN g_archive_item_details.first..g_archive_item_details.last
     LOOP
      -- initialize for year end balance id for BBR
      g_ye_balance_value_tab(i).defined_balance_id := g_archive_item_details(i).def_bal_id;
      pay_mx_archive_dbi_pkg.create_archive_dbi('A_' || g_archive_item_details(i).user_entity_name);
     END loop;

     FOR j IN g_ptu_bal_details.first..g_ptu_bal_details.last
     LOOP
        -- initialize for ptu year end balance id for BBR
        g_ptu_balance_value_tab(j).defined_balance_id := g_archive_item_details(j).def_bal_id;
        pay_mx_archive_dbi_pkg.create_archive_dbi('A_' || g_ptu_bal_details(j).user_entity_name);
     END loop;

end load_ye_balance;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : load_gre                                            --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to load all GREs for a given legal        --
--                  employer based on the Mexico Statutory Reporting    --
--                  Hierarchy as on the given date.                     --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--                  p_le_id                 NUMBER                      --
--                  p_effective_date        DATE                        --
--            OUT : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE load_gre(p_business_group_id NUMBER,
                   p_le_id             NUMBER,
                   p_effective_date    DATE) IS
--
    CURSOR csr_get_gres IS
       SELECT gre_node.entity_id
         FROM per_gen_hierarchy_nodes gre_node,
              per_gen_hierarchy_nodes le_node,
              per_gen_hierarchy_versions hier_ver,
              fnd_lookup_values lv
        WHERE gre_node.node_type =  'MX GRE'
        AND   le_node.node_type = 'MX LEGAL EMPLOYER'
        AND   le_node.entity_id = p_le_id
        AND   le_node.business_group_id = p_business_group_id
        AND   gre_node.hierarchy_version_id = le_node.hierarchy_version_id
        AND   gre_node.business_group_id = le_node.business_group_id
        AND   le_node.hierarchy_node_id = gre_node.parent_hierarchy_node_id
        AND   gre_node.hierarchy_version_id = hier_ver.hierarchy_version_id
        AND   status = lv.lookup_code
        AND   lv.meaning = 'Active'
        AND   lv.LANGUAGE = 'US'
        AND   lv.lookup_type = 'PQH_GHR_HIER_VRSN_STATUS'
        AND   p_effective_date BETWEEN hier_ver.date_from
                                   AND NVL(hier_ver.date_to, hr_general.end_of_time);

       lv_procedure_name    VARCHAR2(100);
       ln_gre_id            NUMBER;

BEGIN

   lv_procedure_name := '.load_gre';

   hr_utility.trace('Entering '|| gv_package || lv_procedure_name);

   hr_utility.trace ('parameters ...');
   hr_utility.trace ('p_business_group_id = '||p_business_group_id);
   hr_utility.trace ('p_le_id = '||p_le_id);
   hr_utility.trace ('p_effective_date = '||p_effective_date);

   g_gre_tab.delete();
   OPEN csr_get_gres;
        LOOP
            FETCH csr_get_gres INTO ln_gre_id;
            EXIT WHEN csr_get_gres%NOTFOUND;
            g_gre_tab (g_gre_tab.count() + 1) := ln_gre_id;
        END LOOP;
   CLOSE csr_get_gres;

   IF g_gre_tab.count() > 0 THEN
       hr_utility.trace('List of GREs ...');
       FOR cntr_gre IN g_gre_tab.first()..g_gre_tab.last() LOOP
            hr_utility.trace(g_gre_tab(cntr_gre));
       END LOOP;
   ELSE
       hr_utility.trace('No GREs found.');
   END IF;

   hr_utility.trace('Leaving '|| gv_package || lv_procedure_name);
END load_gre;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : gre_exists                                          --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to determine whether a GRE exists in the   --
--                  global variable g_gre_tab                           --
-- Parameters     :                                                     --
--             IN : p_gre_id    NUMBER                                  --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION gre_exists (p_gre_id   NUMBER)
RETURN NUMBER IS

    lv_procedure_name    VARCHAR2(100);

BEGIN
    lv_procedure_name := '.gre_exists';
    hr_utility.trace('Entering '|| gv_package || lv_procedure_name);
    hr_utility.trace('p_gre_id = ' || p_gre_id);

    IF g_gre_tab.count() <> 0 THEN
        FOR cntr_gre IN g_gre_tab.first()..g_gre_tab.last() LOOP
            IF g_gre_tab (cntr_gre) = p_gre_id THEN
                hr_utility.trace ('GRE exists');
                hr_utility.trace('Leaving '|| gv_package || lv_procedure_name);
                RETURN 1;
            END IF;
        END LOOP;
    END IF;

    hr_utility.trace ('GRE does not exist');
    hr_utility.trace('Leaving '|| gv_package || lv_procedure_name);
    RETURN 0;
END gre_exists;

 /******************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for Year End Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
               p_legal_employer_id - Legal Employer ID when submitting Archiver
               p_asg_set_id        - Assignment Set ID when submitting Archiver
 ******************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     IN        NUMBER
                                   ,p_end_date             OUT NOCOPY DATE
                                   ,p_business_group_id    OUT NOCOPY NUMBER
                                   ,p_legal_employer_id    OUT NOCOPY NUMBER
                                   ,p_asg_set_id           OUT NOCOPY NUMBER
                                   )
  IS
    CURSOR c_payroll_Action_info
              (cp_payroll_action_id IN NUMBER) IS
      SELECT effective_date,
             business_group_id,
             pay_mx_utility.get_parameter('TRANSFER_LEGAL_EMPLOYER',
                            legislative_parameters) Legal_Employer_ID,
             pay_mx_utility.get_parameter('TRANSFER_ASSIGNMENT_SET_ID',
                            legislative_parameters) Assignment_SET_ID
        FROM pay_payroll_actions
       WHERE payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ln_business_group_id NUMBER;
    ln_asg_set_id        NUMBER;
    ln_legal_er_id       NUMBER;
    lv_procedure_name    VARCHAR2(100);

    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;

   BEGIN
       lv_procedure_name  := '.get_payroll_action_info';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       OPEN c_payroll_action_info(p_payroll_action_id);
       FETCH c_payroll_action_info INTO ld_end_date,
                                        ln_business_group_id,
                                        ln_legal_er_id,
                                        ln_asg_set_id;
       CLOSE c_payroll_action_info;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);

       p_end_date          := ld_end_date;
       p_business_group_id := ln_business_group_id;
       p_legal_employer_id := ln_legal_er_id;
       p_asg_set_id        := ln_asg_set_id;

       hr_utility.set_location(gv_package || lv_procedure_name, 50);
       ln_step := 2;

  EXCEPTION
    WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_payroll_action_info;

 /******************************************************************************
   Name      : create_archive_item
   Purpose   : This procedure creates the archive item for the assignments by calling api.
   Arguments : p_user_entity_name       - archiver_item name
               p_balance_value          - Archiver item bal value
               p_prev_archiver_exists   - Flag to create PTU archiver item
               p_tax_unit_id            - GRE id
               p_archive_action_id      - current  Assignment action ID.
 ******************************************************************************/
/*Added for bug 7529502*/

    PROCEDURE  create_archive_item(p_user_entity_name    IN ff_user_entities.user_entity_name%TYPE
                                 ,p_balance_value        IN NUMBER
				 ,p_prev_archiver_exists IN VARCHAR2
				 ,p_tax_unit_id          IN NUMBER
				 ,p_archive_action_id    IN NUMBER)

     IS
  --
    lv_procedure_name        VARCHAR2(100);
    lv_error_message         VARCHAR2(200);
    ln_arch_user_entity_id   NUMBER;
    ln_value                 NUMBER;
    ln_ovn                   NUMBER;
    l_some_warning           BOOLEAN;
    ln_archive_item_id       NUMBER;
    ln_prev_isr_whld_value   NUMBER;
    lv_arch_user_entity_name ff_user_entities.user_entity_name%TYPE;
    lv_live_user_entity_name ff_user_entities.user_entity_name%TYPE;
    ltab_entity_det   entity_details_tab;
    ln_count NUMBER;
    ln_arc_item              NUMBER;

 -- Get archive DBI user entity ID
     CURSOR c_get_arch_ue_id(cp_archive_item_name VARCHAR2)
     IS
       SELECT user_entity_id
         FROM ff_user_entities
        WHERE user_entity_name = cp_archive_item_name
          AND creator_type     = 'X'
          AND creator_id       =  0
          AND legislation_code = 'MX';

    BEGIN
      -- Creating the archiver item code.
           lv_procedure_name  := '.populate_balances';
        hr_utility.trace('Entering '||  gv_package || lv_procedure_name);
        hr_utility.set_location(gv_package || lv_procedure_name, 10);

        ln_value := p_balance_value;
        OPEN  c_get_arch_ue_id('A_' || p_user_entity_name);
        FETCH c_get_arch_ue_id INTO ln_arch_user_entity_id;
        CLOSE c_get_arch_ue_id;
        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        hr_utility.trace('Archive User Entity ID: '|| ln_arch_user_entity_id);
        hr_utility.trace('Item Name '                 || p_user_entity_name);
        hr_utility.trace('Value: '                    || ln_value);

        IF p_prev_archiver_exists = 'Y' AND p_user_entity_name = 'ISR_WITHHELD_PER_PDS_GRE_YTD' THEN

           /**************************************************************
           ** ISR Withheld for PTU would be
           ** ISR Withheld YTD - ISR Withheld of previous archived value
           ** Whenevere there is previous archiver is run.
           **************************************************************/
           begin
              hr_utility.set_location(gv_package || lv_procedure_name, 30);
              SELECT fai.value
                INTO ln_prev_isr_whld_value
                FROM ff_archive_items fai
               WHERE fai.context1 = gn_prev_asg_act_id
                 AND fai.user_entity_id = ln_arch_user_entity_id;
              hr_utility.set_location(gv_package || lv_procedure_name, 40);
           exception
             when no_data_found then
                  ln_prev_isr_whld_value := 0;
           end;


           ln_value := ln_value - ln_prev_isr_whld_value;

        END IF;
              hr_utility.set_location(gv_package || lv_procedure_name, 50);
        select count(1)
        into   ln_arc_item
        from   ff_archive_items fai,
               ff_archive_item_contexts faic
        where  fai.archive_item_id = faic.archive_item_id
        and    fai.user_entity_id = ln_arch_user_entity_id
        and    fai.context1 = p_archive_action_id
        and    fai.value    = ln_value
        and    faic.context = p_tax_unit_id;

        if nvl(ln_arc_item,0) = 0 then

           ff_archive_api.create_archive_item(
                          p_archive_item_id       => ln_archive_item_id,
                          p_user_entity_id        => ln_arch_user_entity_id,
                          p_archive_value         => ln_value,
                          p_archive_type          => 'AAP',
                          p_action_id             => p_archive_action_id,
                          p_legislation_code      => 'MX',
                          p_object_version_number => ln_ovn,
                          p_some_warning          => l_some_warning,
                          p_context_name1         => 'TAX_UNIT_ID',
                          p_context1              => p_tax_unit_id);
        end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 60);
     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);
   END create_archive_item;


  /************************************************************
   Name      : populate_balances
   Purpose   : This procedure archives Balances which are used
               in Year End Reporting for Mexico.
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE populate_balances(p_archive_action_id       IN NUMBER
                             ,p_ytd_action_id           IN NUMBER
                             ,p_tax_unit_id             IN NUMBER
                             ,p_prev_archiver_exists    IN VARCHAR2)
  IS
--
    lv_procedure_name        VARCHAR2(100);
    lv_error_message         VARCHAR2(200);
    ln_step                  NUMBER;
    ln_index                 NUMBER;

    ltab_entity_det   entity_details_tab;
    ln_count NUMBER;
    lt_ye_bal_context_tab     pay_balance_pkg.t_context_tab;
    lt_ye_bal_result_tab      pay_balance_pkg.t_detailed_bal_out_tab;
    lt_ptu_bal_result_tab     pay_balance_pkg.t_detailed_bal_out_tab;

  BEGIN
  --
     lv_procedure_name  := '.populate_balances';
     ln_count := 0;
     ltab_entity_det.DELETE;
     lt_ye_bal_result_tab.DELETE;
     lt_ptu_bal_result_tab.DELETE;

     lt_ye_bal_context_tab(1).tax_unit_id := p_tax_unit_id;

     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);
    --
    --     pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);

     -- Create the Archive DBI routes if they don't exist
     --
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
/*     pay_mx_archive_dbi_pkg.create_archive_routes;*/
    hr_utility.trace('p_prev_archiver_exists ' || p_prev_archiver_exists);
    hr_utility.trace('p_ytd_action_id ' || p_ytd_action_id);
/*Modified the code logic, by using BBR for bug 7529502*/
     IF p_prev_archiver_exists = 'Y' THEN

       pay_balance_pkg.get_value
         (p_assignment_action_id     => p_ytd_action_id
         ,p_defined_balance_lst      => g_ptu_balance_value_tab
         ,p_context_lst              => lt_ye_bal_context_tab
         ,p_output_table             => lt_ptu_bal_result_tab
         );

        FOR j IN g_ptu_bal_details.first..g_ptu_bal_details.last
         LOOP
         hr_utility.trace('About populate ptu balance');
         hr_utility.trace('Def Bal Id....' ||g_ptu_bal_details(j).def_bal_id);
         hr_utility.trace('lt_ptu_bal_result_tab Id....' ||lt_ptu_bal_result_tab(j).defined_balance_id);
         hr_utility.trace('Item Name ....' ||g_ptu_bal_details(j).user_entity_name);
         ln_count := ln_count +1;
         g_ptu_bal_details(j).bal_value := nvl(lt_ptu_bal_result_tab(j).balance_value,0);
         hr_utility.trace('Item Name ....' ||g_ptu_bal_details(j).user_entity_name||' bal value' ||  g_ptu_bal_details(j).bal_value);
         ltab_entity_det(ln_count) := g_ptu_bal_details(j);
         -- creating archive item for the assignment action
         create_archive_item(p_user_entity_name      => g_ptu_bal_details(j).user_entity_name
                            ,p_balance_value         => g_ptu_bal_details(j).bal_value
	         	    ,p_prev_archiver_exists  => p_prev_archiver_exists
			    ,p_tax_unit_id           => p_tax_unit_id
			    ,p_archive_action_id     => p_archive_action_id );

        END LOOP;
     ELSE
     --
          pay_balance_pkg.get_value
          (p_assignment_action_id     => p_ytd_action_id
          ,p_defined_balance_lst      => g_ye_balance_value_tab
          ,p_context_lst              => lt_ye_bal_context_tab
          ,p_output_table             => lt_ye_bal_result_tab
          );

          FOR i IN g_archive_item_details.first..g_archive_item_details.last
            LOOP
	    hr_utility.trace('About populate other balance');
            hr_utility.trace('Def Bal Id....' ||g_archive_item_details(i).def_bal_id);
            hr_utility.trace('lt_ye_bal_result_tab Id....' ||lt_ye_bal_result_tab(i).defined_balance_id);
            hr_utility.trace('Item Name ....' ||g_archive_item_details(i).user_entity_name);
            ln_count := ln_count +1;
            g_archive_item_details(i).bal_value := nvl(lt_ye_bal_result_tab(i).balance_value,0);
            hr_utility.trace('Item Name ....' ||g_archive_item_details(i).user_entity_name||' bal value' ||  g_archive_item_details(i).bal_value);
            ltab_entity_det(ln_count) := g_archive_item_details(i);
	    -- creating archive item for the assignment action
            create_archive_item(p_user_entity_name      => g_archive_item_details(i).user_entity_name
                               ,p_balance_value         => g_archive_item_details(i).bal_value
                	       ,p_prev_archiver_exists  => p_prev_archiver_exists
			       ,p_tax_unit_id           => p_tax_unit_id
			       ,p_archive_action_id     => p_archive_action_id );
          END LOOP;
     END IF;

     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);
  --
  END populate_balances;

 /******************************************************************
   Name      : range_code
   Purpose   : This returns the select statement that is
               used to create the range rows for the Year End
               Archiver.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE range_code(
                    p_payroll_action_id IN        NUMBER
                   ,p_sqlstr           OUT NOCOPY VARCHAR2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_asg_set_id        NUMBER;
    ln_legal_employer_id NUMBER;

    lv_sql_string        VARCHAR2(32000);
    lv_procedure_name    VARCHAR2(100);

  BEGIN
     lv_procedure_name  := '.range_code';

     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_legal_employer_id => ln_legal_employer_id
                            ,p_asg_set_id        => ln_asg_set_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     load_gre (ln_business_group_id,
               ln_legal_employer_id,
               ld_end_date);

     ld_start_date := TRUNC(ld_end_date, 'Y');

     IF ln_asg_set_id IS NULL THEN

        lv_sql_string :=
            'SELECT DISTINCT paf.person_id
               FROM pay_assignment_actions paa,
                    pay_payroll_actions    ppa,
                    per_assignments_f      paf
              WHERE ppa.business_group_id  = ' || ln_business_group_id || '
                AND ppa.effective_date BETWEEN fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_start_date) || ''')
                                           AND fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_end_date) || ''')
                AND ppa.action_type IN (''Q'',''R'',''B'',''V'',''I'')
                AND paa.action_status = ''C''
                AND ppa.payroll_action_id = paa.payroll_action_id
                AND paa.source_action_id IS NULL
                AND paf.assignment_id = paa.assignment_id
                AND ppa.effective_date BETWEEN paf.effective_start_date
                                           AND paf.effective_end_date
                AND pay_mx_yrend_arch.gre_exists (paa.tax_unit_id) = 1
                AND :payroll_action_id > 0
           ORDER BY paf.person_id';
     ELSE

        lv_sql_string :=
            'SELECT DISTINCT paf.person_id
               FROM pay_assignment_actions paa,
                    pay_payroll_actions    ppa,
                    per_assignments_f      paf
              WHERE ppa.business_group_id  = ' || ln_business_group_id || '
                AND ppa.effective_date BETWEEN fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_start_date) || ''')
                                           AND fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_end_date) || ''')
                AND ppa.action_type IN (''Q'',''R'',''B'',''V'',''I'')
                AND paa.action_status = ''C''
                AND ppa.payroll_action_id = paa.payroll_action_id
                AND paa.source_action_id IS NULL
                AND paf.assignment_id = paa.assignment_id
                AND ppa.effective_date BETWEEN paf.effective_start_date
                                           AND paf.effective_end_date
                AND pay_mx_yrend_arch.gre_exists (paa.tax_unit_id) = 1
                AND EXISTS
                    (SELECT ''x''
                       FROM hr_assignment_sets has,
                            hr_assignment_set_amendments hasa,
                            per_assignments_f  paf_all
                      WHERE has.assignment_set_id = ' || ln_asg_set_id || '
                      AND   has.assignment_set_id = hasa.assignment_set_id
                      AND   hasa.assignment_id = paf_all.assignment_id
                      AND   paf_all.person_id = paf.person_id
                      AND   hasa.include_or_exclude = ''I'')
                AND :payroll_action_id > 0
           ORDER BY paf.person_id';

     END IF; -- ln_asg_set_id is null

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.trace ('SQL string :' ||p_sqlstr);
     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

  END range_code;

/************************************************************
   Name      : assignment_action_code
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the Year End Archiver process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE assignment_action_code(
                 p_payroll_action_id IN NUMBER
                ,p_start_person_id   IN NUMBER
                ,p_end_person_id     IN NUMBER
                ,p_chunk             IN NUMBER)
  IS


   CURSOR c_chk_asg (cp_asg_set_id NUMBER,
                      cp_asg_id     NUMBER) IS
        SELECT 'X'
          FROM hr_assignment_sets has,
               hr_assignment_set_amendments hasa
         WHERE has.assignment_set_id = cp_asg_set_id
           AND has.assignment_set_id = hasa.assignment_set_id
           AND hasa.assignment_id IN (SELECT DISTINCT
                                             paf_all.assignment_id
                                        FROM per_assignments_f paf,
                                             per_assignments_f paf_all
                                       WHERE paf.person_id = paf_all.person_id
                                         AND paf.assignment_id = cp_asg_id)
           AND hasa.include_or_exclude = 'E';

    CURSOR c_get_emp_asg_range (cp_gre_id     NUMBER,
                                cp_start_date DATE,
                                cp_end_date   DATE) IS
        SELECT /*+ index(PPA PAY_PAYROLL_ACTIONS_PK) */  paf_pri.assignment_id,
               paf_pri.person_id,
               paf_pri.period_of_service_id
          FROM per_assignments_f      paf,
               per_assignments_f      paf_pri,
               pay_assignment_actions paa,
               pay_payroll_actions    ppa,
               pay_population_ranges  ppr
         WHERE paf.assignment_id            = paa.assignment_id
           AND paa.tax_unit_id              = cp_gre_id
           AND ppr.payroll_action_id        = p_payroll_action_id
           AND ppr.chunk_number             = p_chunk
           AND ppr.person_id                = paf.person_id
           AND paf_pri.period_of_service_id = paf.period_of_service_id
           AND paf_pri.primary_flag         = 'Y'
           AND paa.payroll_action_id        = ppa.payroll_action_id
           AND ppa.action_type              IN ('Q','R','B','V','I')
           AND ppa.effective_date    BETWEEN cp_start_date
                                      AND cp_end_date
           AND paf_pri.effective_start_date <= cp_end_date
           AND paf_pri.effective_end_date >= cp_start_date
           AND ppa.effective_date BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date
        ORDER BY paf_pri.person_id,
                 paf_pri.effective_end_date DESC;

    CURSOR c_get_emp_asg (cp_gre_id     NUMBER,
                          cp_bg_id      NUMBER,
                          cp_start_date DATE,
                          cp_end_date   DATE) IS
       SELECT /*+ USE_NL(pap paf) */
               paf_pri.assignment_id,
               paf_pri.person_id,
               paf_pri.period_of_service_id
          FROM per_assignments_f      paf,
               per_assignments_f      paf_pri,
               pay_assignment_actions paa,
               pay_payroll_actions    ppa,
               pay_all_payrolls_f     pap
         WHERE ppa.business_group_id + 0 = cp_bg_id
           AND ppa.effective_date BETWEEN cp_start_date
                                      AND cp_end_date
           AND ppa.action_type IN ('Q','R','B','V','I')
           AND pap.business_group_id = cp_bg_id
           AND ppa.payroll_id = pap.payroll_id
           AND ppa.payroll_action_id = paa.payroll_action_id
           AND paa.source_action_id IS NULL
           AND paf.assignment_id = paa.assignment_id
           AND paf_pri.period_of_service_id = paf.period_of_service_id
           AND paf_pri.primary_flag         = 'Y'
           AND ppa.effective_date BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date
           AND paf_pri.effective_start_date <= cp_end_date
           AND paf_pri.effective_end_date >=  cp_start_date
           AND paa.tax_unit_id =  cp_gre_id
           AND paf_pri.person_id = paf.person_id
           AND paf.person_id BETWEEN  p_start_person_id
                                 AND  p_end_person_id
        ORDER BY paf_pri.person_id,
                 paf_pri.effective_end_date DESC;

    -- Check if any previous archiver exists for the same period of service
    --
    CURSOR c_chk_last_archiver(cp_period_of_service_id NUMBER,
                               cp_start_date           DATE,
                               cp_end_date             DATE) IS
    SELECT ppa1.effective_date,
           paa1.assignment_action_id
      FROM pay_payroll_actions    ppa1,
           pay_assignment_actions paa1,
           per_assignments_f      paf1
     WHERE ppa1.payroll_action_id    = paa1.payroll_action_id
       AND paa1.assignment_id        = paf1.assignment_id
       AND paf1.period_of_service_id = cp_period_of_service_id
       AND ppa1.report_type          = 'MX_YREND_ARCHIVE'
       AND ppa1.report_qualifier     = 'MX'
       AND ppa1.report_category      = 'ARCHIVE'
       AND paf1.effective_start_date <= cp_end_date
       AND paf1.effective_end_date   >= cp_start_date
       AND TO_CHAR(ppa1.effective_date, 'YYYY')
                                     = TO_CHAR(cp_end_date, 'YYYY')
     ORDER BY ppa1.effective_date DESC;

    -- Check if runs exist after the last archiver run
    --
    CURSOR c_chk_non_arch_runs(cp_period_of_service_id NUMBER,
                               cp_prev_arch_eff_date   DATE,
                               cp_start_date           DATE,
                               cp_end_date             DATE) IS
    SELECT 'Y'
      FROM pay_payroll_actions        ppa2,
           pay_assignment_actions     paa2,
           per_assignments_f          paf2
     WHERE ppa2.payroll_action_id    =  paa2.payroll_action_id
       AND ppa2.action_type          IN ('R', 'Q', 'B', 'V', 'I')
       AND paa2.assignment_id        =  paf2.assignment_id
       AND paf2.period_of_service_id =  cp_period_of_service_id
       AND ppa2.effective_date       >  cp_prev_arch_eff_date
       AND ppa2.effective_date       <= cp_end_date
       AND paf2.effective_start_date <= cp_end_date
       AND paf2.effective_end_date   >= cp_start_date;

    ln_assignment_id        NUMBER;
    ln_tax_unit_id          NUMBER;

    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_legal_employer_id    NUMBER;
    ln_asg_set_id           NUMBER;

    ln_yrend_action_id      NUMBER;

    lv_procedure_name       VARCHAR2(100);
    lv_error_message        VARCHAR2(200);
    ln_step                 NUMBER;

    lb_range_person         BOOLEAN;
    ln_person_id            NUMBER;
    ln_prev_pos_id          NUMBER;
    ln_pos_id               NUMBER;
    lv_excl_flag            VARCHAR2(2);
    lv_run_exists           VARCHAR2(2);

    ln_prev_arch_aaid       NUMBER;
    ld_prev_arch_eff_date   DATE;

  BEGIN
     lv_procedure_name  := '.assignment_action_code';
     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);

     ln_pos_id      := -1;
     ln_prev_pos_id := -1;
     lv_excl_flag   := '-1';
     lv_run_exists  := 'N';

     hr_utility.trace('p_payroll_action_id = '|| p_payroll_action_id);
     hr_utility.trace('p_start_person_id = '|| p_start_person_id);
     hr_utility.trace('p_end_person_id = '|| p_end_person_id);
     hr_utility.trace('p_chunk = '|| p_chunk);

     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_legal_employer_id => ln_legal_employer_id
                            ,p_asg_set_id        => ln_asg_set_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     hr_utility.trace('ld_end_date: ' || ld_end_date);
     hr_utility.trace('ln_business_group_id: ' || ln_business_group_id);
     hr_utility.trace('ln_legal_employer_id: ' || ln_legal_employer_id);
     hr_utility.trace('ln_asg_set_id: ' || ln_asg_set_id);

     ld_start_date := TRUNC(ld_end_date, 'Y');

     hr_utility.trace('ld_start_date: ' || ld_start_date);

     IF g_gre_tab.count() = 0 THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 30);

         load_gre (ln_business_group_id,
                   ln_legal_employer_id,
                   ld_end_date);
     END IF;

     lb_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'MX_YREND_ARCHIVE'
                          ,p_report_format    => 'MX_YREND_ARCHIVE'
                          ,p_report_qualifier => 'MX'
                          ,p_report_category  => 'ARCHIVE');

     FOR cntr_gre IN g_gre_tab.first()..g_gre_tab.last() LOOP
        IF lb_range_person THEN
            hr_utility.set_location(gv_package || lv_procedure_name, 40);

            OPEN c_get_emp_asg_range(g_gre_tab(cntr_gre),
                                     ld_start_date,
                                     ld_end_date);
        ELSE
            hr_utility.set_location(gv_package || lv_procedure_name, 50);

            OPEN c_get_emp_asg (g_gre_tab(cntr_gre),
                                ln_business_group_id,
                                ld_start_date,
                                ld_end_date);
        END IF;

        LOOP
            IF lb_range_person THEN

                hr_utility.trace('lb_range_person');

                FETCH c_get_emp_asg_range INTO ln_assignment_id,
                                               ln_person_id,
                                               ln_pos_id;
                EXIT WHEN c_get_emp_asg_range%NOTFOUND;
            ELSE
                FETCH c_get_emp_asg INTO ln_assignment_id,
                                         ln_person_id,
                                         ln_pos_id;
                EXIT WHEN c_get_emp_asg%NOTFOUND;
            END IF;

            hr_utility.trace('Previous period of service = ' || ln_prev_pos_id);
            hr_utility.trace('Current period of service = ' || ln_pos_id);
            hr_utility.trace('Person ID= ' || ln_person_id);
            hr_utility.trace('Assignment ID= ' || ln_assignment_id);

            IF ln_pos_id <> ln_prev_pos_id THEN

               ln_prev_pos_id := ln_pos_id;

                IF ln_asg_set_id IS NOT NULL THEN

                    hr_utility.set_location(gv_package || lv_procedure_name,60);
                    hr_utility.trace('Assignment SET ID FOUND');

                    lv_excl_flag   := '-1';
                    OPEN  c_chk_asg (ln_asg_set_id, ln_assignment_id);
                    FETCH c_chk_asg INTO lv_excl_flag;
                    CLOSE c_chk_asg;


                END IF;

                hr_utility.trace('lv_excl_flag: '||lv_excl_flag);

                IF lv_excl_flag <> 'X' THEN

                    ld_prev_arch_eff_date := NULL;
                    ln_prev_arch_aaid     := NULL;

                    hr_utility.set_location(gv_package || lv_procedure_name,70);

                    OPEN  c_chk_last_archiver(ln_pos_id,
                                              ld_start_date,
                                              ld_end_date);
                    FETCH c_chk_last_archiver INTO ld_prev_arch_eff_date,
                                                   ln_prev_arch_aaid;
                    CLOSE c_chk_last_archiver;

                    IF ld_prev_arch_eff_date IS NOT NULL THEN

                    -- A previous Year End Archiver run exists for the person's
                    -- period of service.
                    --

                        hr_utility.trace('Prev Arch Effective Date = ' ||
                            fnd_date.date_to_canonical(ld_prev_arch_eff_date));
                        hr_utility.trace('Prev Arch Asg Action ID = ' ||
                                         ln_prev_arch_aaid);
                        hr_utility.set_location(gv_package ||
                                                        lv_procedure_name, 80);

                        lv_run_exists := 'N';

                        -- Check if payroll is run after year end
                        -- archiver

                        OPEN  c_chk_non_arch_runs (ln_pos_id,
                                                   ld_prev_arch_eff_date,
                                                   ld_start_date,
                                                   ld_end_date);
                        FETCH c_chk_non_arch_runs INTO lv_run_exists;
                        CLOSE c_chk_non_arch_runs;

                        hr_utility.trace('lv_run_exists: '||lv_run_exists);

                        IF lv_run_exists = 'Y' THEN

                        -- The person has had a SEQUENCED action since the last
                        -- archiver run and should therefore be archived. The
                        -- last archiver action will be locked by this new
                        -- action.

                           hr_utility.set_location(gv_package ||
                                                   lv_procedure_name, 90);

                           SELECT pay_assignment_actions_s.NEXTVAL
                             INTO ln_yrend_action_id
                             FROM dual;

                           hr_nonrun_asact.insact(ln_yrend_action_id,
                                                  ln_assignment_id,
                                                  p_payroll_action_id,
                                                  p_chunk,
                                                  g_gre_tab(cntr_gre),
                                                  NULL,
                                                  'U',
                                                  NULL);

                           hr_utility.set_location(gv_package ||
                                                        lv_procedure_name, 100);

                           UPDATE pay_assignment_actions
                              SET serial_number = ln_person_id
                            WHERE assignment_action_id = ln_yrend_action_id;

                           hr_utility.trace('Archiver asg action ' ||
                                             ln_yrend_action_id || ' created.');

                           -- insert an interlock to this action
                           hr_utility.trace('Locking Action = ' ||
                                             ln_yrend_action_id);
                           hr_utility.trace('Locked Action = '  ||
                                             ln_prev_arch_aaid);
                           hr_nonrun_asact.insint(ln_yrend_action_id,
                                                  ln_prev_arch_aaid);

                           hr_utility.set_location(gv_package ||
                                                        lv_procedure_name, 110);

                        ELSE

                           hr_utility.set_location(gv_package ||
                                                   lv_procedure_name, 120);

                           hr_utility.trace('The person has not been paid ' ||
                           'since the last archiver and is therefore skipped.');

                        END IF;

                    ELSE

                    -- No previous archiver run exists for this person.
                    -- New assignment action would still be created, but no
                    -- interlocks inserted.

                        hr_utility.set_location(gv_package ||
                                                lv_procedure_name, 130);

                        SELECT pay_assignment_actions_s.NEXTVAL
                          INTO ln_yrend_action_id
                          FROM dual;

                        hr_utility.set_location(gv_package ||
                                                lv_procedure_name, 140);

                        hr_nonrun_asact.insact(ln_yrend_action_id,
                                               ln_assignment_id,
                                               p_payroll_action_id,
                                               p_chunk,
                                               g_gre_tab(cntr_gre),
                                               NULL,
                                               'U',
                                               NULL);

                        hr_utility.set_location(gv_package ||
                                                lv_procedure_name, 150);

                        UPDATE pay_assignment_actions
                           SET serial_number        = ln_person_id
                         WHERE assignment_action_id = ln_yrend_action_id;

                        hr_utility.trace('Archiver asg action ' ||
                                          ln_yrend_action_id || ' created.');

                    END IF;

                ELSE
                    hr_utility.trace('Assignment is excluded in asg set.');
                    lv_excl_flag := '-1';
                END IF;
            ELSE
                hr_utility.trace ('Assignment skipped.');
            END IF;
        END LOOP;

        IF lb_range_person THEN
            CLOSE c_get_emp_asg_range;
        ELSE
            CLOSE c_get_emp_asg;
        END IF;
     END LOOP;

     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

  EXCEPTION
    WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END assignment_action_code;

  /************************************************************
    Name      : initialization_code
    Purpose   : This performs the context initialization.
    Arguments :
    Notes     :
  ************************************************************/

  PROCEDURE initialization_code(p_payroll_action_id IN NUMBER) IS
  --
    lv_procedure_name       VARCHAR2(100);
    lv_error_message        VARCHAR2(200);
    ln_step                 NUMBER;

    ld_end_date             DATE;
    ln_business_group_id    NUMBER;
    ln_legal_employer_id    NUMBER;
    ln_asg_set_id           NUMBER;

    CURSOR c_get_legal_er_info(cp_legal_er_id    NUMBER,
                               cp_effective_date DATE)
    IS
      SELECT hoi.org_information1    "Name",
             hoi.org_information2    "Employer RFC",
             ppf.full_name           "Legal Representative Name",
             ppf.per_information2    "Legal Representative RFC",
             ppf.national_identifier "Legal Representative CURP"
      FROM   hr_organization_information hoi,
             per_people_f                ppf
      WHERE  hoi.organization_id         = cp_legal_er_id
      AND    hoi.org_information_context = 'MX_TAX_REGISTRATION'
      AND    hoi.org_information3        = ppf.person_id
      AND    cp_effective_date BETWEEN ppf.effective_start_date
                                   AND ppf.effective_end_date;


  BEGIN
     lv_procedure_name  := '.initialization_code';

     ln_step := 1;

     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_legal_employer_id => ln_legal_employer_id
                            ,p_asg_set_id        => ln_asg_set_id);

     g_payroll_action_id := p_payroll_action_id;

     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     ln_step := 2;

     OPEN c_get_legal_er_info(ln_legal_employer_id,
                              ld_end_date);
     FETCH c_get_legal_er_info INTO g_ER_legal_name,
                                    g_ER_RFC,
                                    g_ER_legal_rep_name,
                                    g_ER_legal_rep_RFC,
                                    g_ER_legal_rep_CURP;
     CLOSE c_get_legal_er_info;

     hr_utility.set_location(gv_package || lv_procedure_name, 30);

     ln_step := 3;

     SELECT TO_CHAR(ld_end_date, 'YYYY')
     INTO g_fiscal_year
     FROM dual;

     hr_utility.set_location(gv_package || lv_procedure_name, 40);
     hr_utility.trace('About to initialize the route and database items');
     /*Added for bug 7529502*/
     load_ye_balance;
     hr_utility.trace('Global data for archive items are set ' ||g_archive_item_details.count);
     hr_utility.trace('Global data for PTU balance are set ' ||g_ptu_bal_details.count);
     hr_utility.set_location(gv_package || lv_procedure_name, 50);
  EXCEPTION
    WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END initialization_code;

  /************************************************************
   Name      : archive_code
   Purpose   : This procedure Archives data which is used in
               Year End Reporting for Mexico.
   Arguments : p_archive_action_id            IN NUMBER
               p_effective_date               IN DATE
   Notes     :
  ************************************************************/
  PROCEDURE archive_code(p_archive_action_id  IN NUMBER
                        ,p_effective_date     IN DATE)
  IS
  --
    lv_procedure_name       VARCHAR2(100);
    lv_error_message        VARCHAR2(200);
    ln_step                 NUMBER;
    ln_index                NUMBER;
    ln_pay_action_count     NUMBER;

    lv_economic_zone        VARCHAR2(1);
    ld_effective_date       DATE;

    ln_business_group_id    NUMBER;
    ln_person_id            NUMBER;
    ln_assignment_id        NUMBER;
    ln_tax_unit_id          NUMBER;
    ln_chunk_number         NUMBER;
    lv_paternal_last_name   per_people_f.last_name%TYPE;
    lv_maternal_last_name   per_people_f.per_information1%TYPE;
    lv_names                per_people_f.full_name%TYPE;
    lv_CURP                 per_people_f.national_identifier%TYPE;
    lv_RFC_ID               per_people_f.per_information2%TYPE;
    ld_arch_start_date      DATE;
    ld_arch_end_date        DATE;
    ln_seniority            NUMBER;
    ln_tax_subsidy_prop     NUMBER;
    lv_jurisdiction         VARCHAR2(10);
    lv_is_union_worker      VARCHAR2(1);
    ld_hire_date            DATE;

    ln_legal_er_id          NUMBER;
    ln_gre_id               NUMBER;
    i                       NUMBER;

    TYPE other_ER_rec IS RECORD
    (RFC              VARCHAR2(30),
     ISR_Withheld     NUMBER,
     Cred_Subsidy     NUMBER,
     Non_Cred_Subsidy NUMBER,
     Total_Earnings   NUMBER,
     Exempt_Earnings  NUMBER);

    TYPE other_ER_tbl IS TABLE OF other_ER_rec INDEX BY BINARY_INTEGER;

    PEI  other_ER_tbl;

    ln_total_cred_subsidy       NUMBER;
    ln_total_subsidy            NUMBER;
    ln_ytd_aa_id                NUMBER;
    ld_start_date               DATE;
    ld_end_date                 DATE;
    ln_cred_subsidy             NUMBER;
    ln_non_cred_subsidy         NUMBER;
    ln_isr_calc                 NUMBER;
    ln_total_isr_calc           NUMBER;
    ld_PTU_date                 DATE;
    ln_gross_earnings           NUMBER;
    ln_profit_sharing           NUMBER;
    l_valid_rfc                 VARCHAR2(30);
    lv_plain_rfc                VARCHAR2(30);
    ln_legal_employer_id        NUMBER;
    ln_asg_set_id               NUMBER;
    lb_is_term_ee               BOOLEAN;
    lv_prev_arch_exists         VARCHAR2(1);
    lv_arch_for_ptu_only        VARCHAR2(1);

    ln_amends_aaid              NUMBER;
    ld_amends_date_earned       DATE;
    ln_amends_payroll_id        NUMBER;

    ln_LMOS                     NUMBER;
    ln_ISR_on_LMOS              NUMBER;

    lv_ann_adj                  VARCHAR2(1);
    ln_row_count                NUMBER;
    ld_act_term_date            DATE; /*8402505*/

    INVALID_RFC                 EXCEPTION;

 -- Added for Perf bug 7529502
    CURSOR c_asg_action_details IS
     SELECT assignment_id,
            serial_number,
	    tax_unit_id
       FROM pay_assignment_actions
       WHERE assignment_action_id = p_archive_action_id;

    -- Get employee details
    CURSOR c_emp_details(cp_effective_date DATE) IS
      select per_det.*, rownum row_count
      from   (SELECT DISTINCT
             paf.business_group_id,
             ppf.person_id,
             paf.assignment_id,
             paa.tax_unit_id,
             paa.chunk_number,
             ppf.last_name           "Paternal Last Name",
             ppf.per_information1    "Maternal Last Name",
             ppf.first_name || ' ' || ppf.middle_names,
             ppf.national_identifier "CURP",
             ppf.per_information2    "RFC ID",
             GREATEST(fnd_date.canonical_to_date(g_fiscal_year || '/01/01'),
                            DECODE(TO_CHAR(pps.date_start, 'YYYY'),
                                   TO_CHAR(cp_effective_date, 'YYYY'),
                                   pps.date_start,
                                   fnd_date.canonical_to_date(g_fiscal_year ||
                                                              '/01/01'))
                     ),

             hr_mx_utility.get_seniority(paf.business_group_id,
                                         paa.tax_unit_id,
                                         paf.payroll_id,
                                         ppf.person_id,
                                         cp_effective_date),
             NVL(paf_all.labour_union_member_flag, 'N'),
             hoi.org_information7 "Economic Zone",
             ROUND(0.5 + 0.005 * hr_mx_utility.get_tax_subsidy_percent(
                                                         ppf.business_group_id,
                                                         paa.tax_unit_id,
                                                         cp_effective_date), 4),
             hl.region_1 "Jurisdiction"
        FROM per_people_f                ppf,
             per_assignments_f           paf,
             per_assignments_f           paf_all,
             pay_assignment_actions      paa,
             per_periods_of_service      pps,
             hr_organization_units       hou,
             hr_organization_information hoi,
             hr_locations_all            hl,
             pay_payroll_actions         ppa
       WHERE paa.assignment_action_id in
                 (select assignment_action_id
                  from   pay_assignment_actions
                  where  assignment_id in
                         (select assignment_id
                          from   pay_assignment_actions
                          where  assignment_action_id = p_archive_action_id)
                  and payroll_action_id = ppa.payroll_action_id )
         and not exists
              ( select 1 from pay_action_information
                where  action_context_id in
                       (select assignment_action_id
                        from   pay_assignment_actions
                        where  assignment_id in
                               (select assignment_id
                                from   pay_assignment_actions
                                where  assignment_action_id = p_archive_action_id)
                        and payroll_action_id = ppa.payroll_action_id) )
         and ppa.payroll_action_id = paa.payroll_action_id
         and paa.tax_unit_id in (SELECT DISTINCT gre_node.entity_id
                          FROM per_gen_hierarchy_nodes    gre_node,
                               per_gen_hierarchy_nodes    le_node,
                               per_gen_hierarchy_versions hier_ver,
                               fnd_lookup_values          flv
                         WHERE gre_node.node_type = 'MX GRE'
                           AND gre_node.business_group_id = paf.business_group_id
                           AND gre_exists (gre_node.entity_id) = 1
                           AND le_node.node_type = 'MX LEGAL EMPLOYER'
                           AND gre_node.hierarchy_version_id = le_node.hierarchy_version_id
                           AND le_node.hierarchy_node_id     = gre_node.parent_hierarchy_node_id
                           AND gre_node.hierarchy_version_id = hier_ver.hierarchy_version_id
                           AND status = flv.lookup_code
                           AND flv.meaning = 'Active'
                           AND flv.LANGUAGE = 'US'
                           AND flv.lookup_type = 'PQH_GHR_HIER_VRSN_STATUS'
                           AND cp_effective_date   BETWEEN hier_ver.date_from
                                                   AND NVL(hier_ver.date_to,
                                                           hr_general.end_of_time))
         AND cp_effective_date     BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
         AND cp_effective_date     BETWEEN paf.effective_start_date
                                       AND paf.effective_end_date
         AND cp_effective_date     BETWEEN paf_all.effective_start_date
                                       AND paf_all.effective_end_date
         AND paf.assignment_id           = paa.assignment_id
         and paf_all.assignment_id       = paf.assignment_id
         and paf.assignment_id           = paf_all.assignment_id
         AND ppf.person_id               = paf.person_id
         AND paf.person_id               = paf_all.person_id
         and pps.person_id               = ppf.person_id
         AND pps.period_of_service_id    = paf.period_of_service_id
         AND hou.organization_id         = paa.tax_unit_id
         AND hou.organization_id         = hoi.organization_id
         AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
         AND hl.location_id              = paf.location_id) per_det;

    -- Get Other ER info for ERs of the current year
    CURSOR c_get_other_er_info(cp_person_id      NUMBER,
                               cp_effective_date DATE) IS
      SELECT pei_information1                                 RFC,
             fnd_number.canonical_to_number(pei_information5) ISR_Withheld,
             fnd_number.canonical_to_number(pei_information6) Cr_Subsidy,
             fnd_number.canonical_to_number(pei_information7) Non_Cr_Subsidy,
             fnd_number.canonical_to_number(pei_information8) Total_Earnings,
             fnd_number.canonical_to_number(pei_information9) Exempt_Earnings
        FROM per_people_extra_info
       WHERE information_type = 'MX_PREV_EMPLOYMENT_INFO'
         AND person_id        = cp_person_id
         AND TO_CHAR(fnd_date.canonical_to_date(pei_information4), 'YYYY') =
             TO_CHAR(cp_effective_date, 'YYYY')
    ORDER BY pei_information4 DESC;

    -- Get end date of Format 37 for the person
    CURSOR c_get_eff_date IS
      SELECT DISTINCT
             pps.actual_termination_date, /*Bug 8402505*/
             NVL(pps.actual_termination_date,
                 nvl(paf.effective_end_date, p_effective_date)),
             NVL(pps.actual_termination_date,
                 fnd_date.canonical_to_date(g_fiscal_year || '/12/31')
                )
        FROM per_people_f            ppf,
             per_assignments_f       paf,
             pay_assignment_actions  paa,
             pay_payroll_actions     ppa,
             per_periods_of_service  pps
       WHERE paa.assignment_action_id = p_archive_action_id
         AND ppa.payroll_action_id    = paa.payroll_action_id
         AND paf.assignment_id        = paa.assignment_id
         AND ppf.person_id            = paf.person_id
         AND pps.period_of_service_id = paf.period_of_service_id;



    CURSOR c_check_pay_action(cp_payroll_action_id IN NUMBER) IS
      SELECT count(*)
        FROM pay_action_information
       WHERE action_context_id = cp_payroll_action_id
         AND action_context_type = 'PA';

    -- Get Generic Hierarchy Details for the current BG
    CURSOR c_get_gen_hier_details(cp_business_group_id NUMBER,
                                  cp_effective_date    DATE
              ) IS
      SELECT DISTINCT le_node.entity_id,
             gre_node.entity_id
        FROM per_gen_hierarchy_nodes    gre_node,
             per_gen_hierarchy_nodes    le_node,
             per_gen_hierarchy_versions hier_ver,
             fnd_lookup_values          flv
       WHERE gre_node.node_type = 'MX GRE'
         AND gre_node.business_group_id = cp_business_group_id
         AND gre_exists (gre_node.entity_id) = 1
         AND le_node.node_type = 'MX LEGAL EMPLOYER'
         AND gre_node.hierarchy_version_id = le_node.hierarchy_version_id
         AND le_node.hierarchy_node_id     = gre_node.parent_hierarchy_node_id
         AND gre_node.hierarchy_version_id = hier_ver.hierarchy_version_id
         AND status = flv.lookup_code
         AND flv.meaning = 'Active'
         AND flv.LANGUAGE = 'US'
         AND flv.lookup_type = 'PQH_GHR_HIER_VRSN_STATUS'
         AND cp_effective_date BETWEEN hier_ver.date_from
                                   AND NVL(hier_ver.date_to,
                                           hr_general.end_of_time);

    -- Get latest ytd aaid
    -- Date constraint relaxed since terminated assignments are also included.
    CURSOR c_get_ytd_aaid(cp_arch_period_start_date DATE,
                          cp_arch_period_end_date   DATE,
                          cp_tax_unit_id           NUMBER) IS
      select /*+ ordered index(PPA PAY_PAYROLL_ACTIONS_PK)*/ paa_all.assignment_action_id
         from pay_assignment_actions paa_pri      ,
              per_assignments_f paf_pri           ,
              per_assignments_f paf_all           ,
              pay_assignment_actions paa_all,
              pay_payroll_actions ppa             ,
              pay_action_classifications pac
      WHERE  paa_pri.assignment_action_id = p_archive_action_id
      AND    paf_pri.assignment_id        = paa_pri.assignment_id
      AND    paf_all.period_of_service_id = paf_pri.period_of_service_id
      AND    paa_all.tax_unit_id          = cp_tax_unit_id
      AND    paa_all.assignment_id        = paf_all.assignment_id
      AND    paa_all.payroll_action_id    = ppa.payroll_action_id
      AND    ppa.action_type              = pac.action_type
      AND    pac.classification_name      = 'SEQUENCED'
      AND    paa_all.action_status        = 'C'
      AND    ppa.effective_date     BETWEEN cp_arch_period_start_date
                                        AND cp_arch_period_end_date
      ORDER BY paa_all.action_sequence DESC;

    -- Get the creditable and non-creditable subsidy for the person under
    -- the current employer
    /*CURSOR c_get_subsidy(cp_ytd_action_id NUMBER
              ) IS
      SELECT pay_balance_pkg.get_value(pdb_cr.defined_balance_id,
                                       cp_ytd_action_id),
             pay_balance_pkg.get_value(pdb_ncr.defined_balance_id,
                                       cp_ytd_action_id)
        FROM pay_defined_balances   pdb_cr,
             pay_defined_balances   pdb_ncr,
             pay_balance_types      pbt_cr,
             pay_balance_types      pbt_ncr,
             pay_balance_dimensions pbd
       WHERE pdb_cr.balance_type_id       = pbt_cr.balance_type_id
         AND pdb_ncr.balance_type_id      = pbt_ncr.balance_type_id
         AND pdb_cr.balance_dimension_id  = pbd.balance_dimension_id
         AND pdb_ncr.balance_dimension_id = pbd.balance_dimension_id
         AND pbt_cr.balance_name          = 'ISR Creditable Subsidy'
         AND pbt_ncr.balance_name         = 'ISR Non Creditable Subsidy'
         AND pbd.database_item_suffix     = '_PER_PDS_GRE_YTD'
         AND pbt_cr.legislation_code      = 'MX'
         AND pbt_ncr.legislation_code     = pbt_cr.legislation_code
         AND pbd.legislation_code         = pbt_ncr.legislation_code; */

    -- Get the ISR Calculated, creditable and non-creditable subsidy
    -- for the person under the current employer
    CURSOR c_get_subsidy(cp_ytd_action_id NUMBER
              ) IS
      SELECT pay_balance_pkg.get_value(pdb_cr.defined_balance_id,
                                       cp_ytd_action_id)
        FROM pay_defined_balances   pdb_cr,
             pay_balance_types      pbt_cr,
             pay_balance_dimensions pbd
       WHERE pdb_cr.balance_type_id       = pbt_cr.balance_type_id
         AND pdb_cr.balance_dimension_id  = pbd.balance_dimension_id
         AND pbt_cr.balance_name          = 'ISR Creditable Subsidy'
         AND pbd.database_item_suffix     = '_PER_PDS_GRE_YTD'
         AND pbt_cr.legislation_code      = 'MX';

    CURSOR c_get_nonsubsidy(cp_ytd_action_id NUMBER
              ) IS
      select pay_balance_pkg.get_value(pdb_ncr.defined_balance_id,
                                       cp_ytd_action_id)
        FROM pay_defined_balances   pdb_ncr,
             pay_balance_types      pbt_ncr,
             pay_balance_dimensions pbd
       WHERE pdb_ncr.balance_type_id      = pbt_ncr.balance_type_id
         AND pdb_ncr.balance_dimension_id = pbd.balance_dimension_id
         AND pbt_ncr.balance_name         = 'ISR Non Creditable Subsidy'
         AND pbd.database_item_suffix     = '_PER_PDS_GRE_YTD'
         AND pbt_ncr.legislation_code      = 'MX'
         AND pbd.legislation_code         = pbt_ncr.legislation_code;

    CURSOR c_get_calc(cp_ytd_action_id NUMBER
              ) IS
      select pay_balance_pkg.get_value(pdb_calc.defined_balance_id,
                                       cp_ytd_action_id)
        FROM pay_defined_balances   pdb_calc,
             pay_balance_types      pbt_calc,
             pay_balance_dimensions pbd
       WHERE pdb_calc.balance_type_id      = pbt_calc.balance_type_id
         AND pdb_calc.balance_dimension_id = pbd.balance_dimension_id
         AND pbt_calc.balance_name         = 'ISR Calculated'
         AND pbd.database_item_suffix      = '_PER_PDS_GRE_YTD'
         AND pbt_calc.legislation_code     = 'MX'
         AND pbd.legislation_code          = pbt_calc.legislation_code;


    -- Get the month of payment of Profit Sharing
    CURSOR c_get_PTU_month(cp_person_id   NUMBER,
                           cp_tax_unit_id NUMBER,
                           cp_start_date  DATE,
                           cp_end_date    DATE
              ) IS
      SELECT /*+ index(PPA PAY_PAYROLL_ACTIONS_PK)*/ DISTINCT ppa.effective_date
        FROM pay_run_results        prr,
             pay_run_result_values  prrv,
             pay_assignment_actions paa,
             pay_payroll_actions    ppa,
             pay_input_values_f     piv,
             pay_balance_feeds_f    pbf,
             pay_balance_types      pbt,
             per_assignments_f      paf
       WHERE pbt.balance_name         = 'Profit Sharing'
         AND pbt.legislation_code     = 'MX'
         AND pbf.balance_type_id      = pbt.balance_type_id
         AND piv.input_value_id       = pbf.input_value_id
         AND prr.element_type_id      = piv.element_type_id
         AND prrv.run_result_id       = prr.run_result_id
         AND prr.assignment_action_id = paa.assignment_action_id
         AND paa.assignment_id        = paf.assignment_id
         AND paf.person_id            = cp_person_id
         AND paa.tax_unit_id          = cp_tax_unit_id
         AND ppa.payroll_action_id    = paa.payroll_action_id
         AND ppa.action_type         IN ('R', 'Q', 'B', 'V', 'I')
         AND ppa.effective_date BETWEEN piv.effective_start_date
                                    AND piv.effective_end_date
         AND ppa.effective_date BETWEEN pbf.effective_start_date
                                    AND pbf.effective_end_date
         AND ppa.effective_date BETWEEN paf.effective_start_date
                                    AND paf.effective_end_date
         AND ppa.effective_date BETWEEN cp_start_date
                                    AND cp_end_date
    ORDER BY 1 DESC;

    -- Check if any previous archiver exists for the same period of service
    --
    CURSOR c_chk_last_archiver(cp_assignment_id  NUMBER,
                               cp_start_date     DATE,
                               cp_end_date       DATE,
                               cp_tax_unit_id    NUMBER) IS
    SELECT paa1.assignment_action_id, 'Y'
      FROM pay_payroll_actions    ppa1,
           pay_assignment_actions paa1,
           per_assignments_f      paf1,
           per_assignments_f      paf2
     WHERE ppa1.payroll_action_id                = paa1.payroll_action_id
       AND paa1.assignment_id                    = paf1.assignment_id
       AND paf1.period_of_service_id             = paf2.period_of_service_id
       AND paf2.assignment_id                    = cp_assignment_id
       AND ppa1.report_type                      = 'MX_YREND_ARCHIVE'
       AND ppa1.report_qualifier                 = 'MX'
       AND ppa1.report_category                  = 'ARCHIVE'
       AND paa1.assignment_action_id            <> p_archive_action_id
       AND paf1.effective_start_date            <= cp_end_date
       AND paf1.effective_end_date              >= cp_start_date
       AND paf2.effective_start_date            <= cp_end_date
       AND paf2.effective_end_date              >= cp_start_date
       AND TO_CHAR(ppa1.effective_date, 'YYYY')  = TO_CHAR(cp_end_date, 'YYYY')
       AND paa1.tax_unit_id                      = cp_tax_unit_id
     ORDER BY 1 desc;

    CURSOR c_fetch_Ann_adj(cp_person_id NUMBER
                          ,cd_end_date  DATE   ) is
    SELECT distinct 'Y'
      FROM per_all_assignments_f paf
     WHERE paf.person_id = cp_person_id
       AND EXISTS ( SELECT 1
                      FROM pay_assignment_actions paa
                           ,pay_payroll_actions ppa
                     WHERE paa.payroll_action_id = ppa.payroll_action_id
                       AND ppa.action_type = 'B'
                       AND ppa.effective_date BETWEEN trunc(cd_end_date,'Y')
                                                  and cd_end_date
                       AND ppa.business_group_id = ln_business_group_id
                       AND pay_mx_utility.get_legi_param_val('PROCESS',
                                        legislative_parameters) = 'MX_ANN_ADJ'
                       AND paa.assignment_id = paf.assignment_id
                  );

    CURSOR c_ann_tax_type (cp_business_group_id NUMBER
                          ,cp_effective_date    DATE
                          ,cp_person_id         NUMBER) IS
     SELECT pay_mx_utility.get_legi_param_val('CALC_MODE'
                                             ,legislative_parameters)
           ,paa.assignment_action_id
       FROM per_all_assignments_f paf
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
      WHERE person_id = cp_person_id
        AND paa.payroll_action_id = ppa.payroll_action_id
        AND ppa.action_type = 'B'
        AND ppa.effective_date = cp_effective_date
        AND ppa.business_group_id = cp_business_group_id
        AND pay_mx_utility.get_legi_param_val('PROCESS'
                          ,legislative_parameters) = 'MX_ANN_ADJ'
        AND paa.assignment_id = paf.assignment_id
      ORDER BY ppa.payroll_action_id desc;

   CURSOR c_pact_info ( cp_assignment_action_id NUMBER) IS
     select ppa.business_group_id
           ,ppa.effective_date
       from pay_payroll_actions ppa
           ,pay_assignment_actions paa
      where paa.assignment_action_id = cp_assignment_action_id
        and ppa.payroll_action_id = paa.payroll_action_id;

   CURSOR c_input_value_id IS
     SELECT piv.input_value_id
       FROM pay_element_types_f pet
           ,pay_input_values_f piv
      WHERE pet.legislation_code = 'MX'
        AND pet.element_name     = 'Annual Tax Adjustment'
        AND piv.element_type_id  = pet.element_type_id
        AND piv.name             = 'Calculation Mode';

   CURSOR c_get_anntaxadj_article ( cp_assignment_action_id NUMBER
                                   ,cp_input_value_id       NUMBER ) IS
     SELECT result_value
       FROM pay_run_results prr
           ,pay_run_result_values prrv
     WHERE prr.assignment_action_id = cp_assignment_action_id
       AND prrv.run_result_id       = prr.run_result_id
       AND prrv.input_value_id      = cp_input_value_id;

   CURSOR c_get_hire_date ( cp_person_id    NUMBER
                           ,cp_effective_date DATE ) IS
     SELECT MAX (pps.date_start)
       FROM per_periods_of_service pps
      WHERE pps.person_id   = cp_person_id
        AND pps.date_start <= cp_effective_date;

   lv_ann_tax_calc_type     VARCHAR2(240);
   ln_anntaxadj_asgactid    NUMBER;
   ln_input_value_id        NUMBER;
   lv_anntaxadj_article     VARCHAR2(240);


  BEGIN
     lv_procedure_name  := '.archive_code';
     --hr_utility.trace_on(null,'MX_NR');
     lv_prev_arch_exists := 'N';
     lv_arch_for_ptu_only := 'N';
     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);

     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     -- Load GRE cache
     IF g_gre_tab.count() = 0 THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 20);

         get_payroll_action_info(p_payroll_action_id => g_payroll_action_id
                                ,p_end_date          => ld_end_date
                                ,p_business_group_id => ln_business_group_id
                                ,p_legal_employer_id => ln_legal_employer_id
                                ,p_asg_set_id        => ln_asg_set_id);

         hr_utility.trace('ld_end_date: ' || ld_end_date);
         hr_utility.trace('ln_business_group_id: ' || ln_business_group_id);
         hr_utility.trace('ln_legal_employer_id: ' || ln_legal_employer_id);
         hr_utility.trace('ln_asg_set_id: ' || ln_asg_set_id);

         load_gre (ln_business_group_id,
                   ln_legal_employer_id,
                   ld_end_date);
     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     OPEN c_asg_action_details;
     FETCH c_asg_action_details INTO ln_assignment_id,ln_person_id,ln_tax_unit_id;
     CLOSE c_asg_action_details;

     hr_utility.set_location(gv_package || lv_procedure_name, 30);

     OPEN  c_get_eff_date;
     FETCH c_get_eff_date INTO ld_act_term_date,ld_effective_date, ld_arch_end_date;
     CLOSE c_get_eff_date;

     hr_utility.trace('ld_effective_date: '||ld_effective_date);
     hr_utility.trace('ld_arch_end_date: '||ld_arch_end_date);

     IF ld_arch_end_date <> fnd_date.canonical_to_date(g_fiscal_year ||
                                                                '/12/31') THEN

          hr_utility.set_location(gv_package || lv_procedure_name, 40);
          lb_is_term_ee := TRUE;
          hr_utility.trace('lb_is_term_ee= TRUE');
     ELSIF (ld_act_term_date IS NOT NULL) AND (ld_act_term_date =  fnd_date.canonical_to_date
                                                             (g_fiscal_year ||'/12/31')) THEN
         hr_utility.trace('ld_act_term_date: '||ld_act_term_date);
          hr_utility.set_location(gv_package || lv_procedure_name, 45);
          hr_utility.trace('Emp is terminated on last pay period');
          lb_is_term_ee := TRUE;
          hr_utility.trace('lb_is_term_ee= TRUE');
     ELSE
          hr_utility.set_location(gv_package || lv_procedure_name, 50);
          lb_is_term_ee := FALSE;
          hr_utility.trace('lb_is_term_ee= FALSE');
     END IF;

     ln_step := 2;
     hr_utility.trace('Effective Date of archiver for the person: ' ||
                      fnd_date.date_to_canonical(p_effective_date));


     ln_step := 3;
     ld_start_date := fnd_date.canonical_to_date(g_fiscal_year || '/01/01');

     hr_utility.set_location(gv_package || lv_procedure_name, 60);

     -- Fetch the YTD Assignment Action ID.
     --
     ln_ytd_aa_id := NULL;

     OPEN  c_get_ytd_aaid(ld_start_date,
                          p_effective_date,
                          ln_tax_unit_id);
     FETCH c_get_ytd_aaid INTO ln_ytd_aa_id;

     IF c_get_ytd_aaid%NOTFOUND THEN

         hr_utility.trace('No assignment action found for the person''s ' ||
                          'period of service within the GRE!');
         hr_utility.raise_error;

     ELSE

         hr_utility.trace('YTD Assactid: '|| ln_ytd_aa_id);

     END IF;

     CLOSE c_get_ytd_aaid;

     pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);

     ln_step := 5;
     hr_utility.set_location(gv_package || lv_procedure_name, 80);


     OPEN  c_chk_last_archiver(ln_assignment_id,
                               ld_start_date,
                               p_effective_date,
                               ln_tax_unit_id);
     FETCH c_chk_last_archiver INTO gn_prev_asg_act_id
                                   ,lv_prev_arch_exists;
     CLOSE c_chk_last_archiver;

     hr_utility.trace('ln_person_id: '|| ln_person_id);
     hr_utility.trace('ln_assignment_id: '|| ln_assignment_id);
     hr_utility.trace('gn_prev_asg_act_id: '|| gn_prev_asg_act_id);
     hr_utility.trace('lv_prev_arch_exists: '|| lv_prev_arch_exists);

     IF ( lv_prev_arch_exists = 'Y' OR lb_is_term_ee ) THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 90);

         ld_PTU_date := NULL;

         OPEN  c_get_PTU_month(ln_person_id,
                               ln_tax_unit_id,
                               ld_start_date,
                               p_effective_date);
         FETCH c_get_PTU_month INTO ld_PTU_date;
         CLOSE c_get_PTU_month;

         IF ld_PTU_date IS NOT NULL
	     AND (ld_PTU_DATE > ld_arch_end_date) -- Added for bug 8402464
   	    THEN

            ld_PTU_date := TRUNC(ld_PTU_date, 'MM');
            ld_arch_end_date   := ADD_MONTHS(ld_PTU_date, 1) - 1;

            hr_utility.trace('PTU ld_arch_start_date: '||ld_PTU_date);
            hr_utility.trace('PTU ld_arch_end_date: '||ld_arch_end_date);
	     hr_utility.trace('ld_PTU_date,YYYY: '||to_char(ld_PTU_date,'YYYY'));
            hr_utility.trace('ld_act_term_date: '||to_char(ld_act_term_date,'YYYY'));
          /*For seniority computation 8402464*/
	    IF lv_prev_arch_exists = 'N'
    	      AND (TO_CHAR (ld_PTU_date,'YYYY') = TO_CHAR(ld_act_term_date,'YYYY'))
 	    THEN
               lv_arch_for_ptu_only := 'N';
            ELSE
               lv_arch_for_ptu_only := 'Y';
	    END IF;
         END IF;

     END IF;

     ln_step := 6;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

     /*OPEN  c_get_subsidy(ln_ytd_aa_id);
     FETCH c_get_subsidy INTO ln_cred_subsidy,
                              ln_non_cred_subsidy;
     CLOSE c_get_subsidy;
     */
     OPEN  c_get_calc(ln_ytd_aa_id);
     FETCH c_get_calc INTO ln_isr_calc;
     CLOSE c_get_calc;

     OPEN  c_get_subsidy(ln_ytd_aa_id);
     FETCH c_get_subsidy INTO ln_cred_subsidy;
     CLOSE c_get_subsidy;

     OPEN  c_get_nonsubsidy(ln_ytd_aa_id);
     FETCH c_get_nonsubsidy INTO ln_non_cred_subsidy;
     CLOSE c_get_nonsubsidy;

     ln_step := 7;
     hr_utility.set_location(gv_package || lv_procedure_name, 105);
     -- Initialise the variables
     --
     ln_total_subsidy      := ln_cred_subsidy + ln_non_cred_subsidy;
     ln_total_cred_subsidy := ln_cred_subsidy;
     i                     := 0;
     --
     hr_utility.set_location(gv_package || lv_procedure_name, 110);


     populate_balances(p_archive_action_id    => p_archive_action_id
                      ,p_ytd_action_id        => ln_ytd_aa_id
                      ,p_tax_unit_id          => ln_tax_unit_id
                      ,p_prev_archiver_exists => lv_prev_arch_exists);

     hr_utility.set_location(gv_package || lv_procedure_name, 115);
     -- EE details need to be fetched as on the Actual
     --               Termination Date, or p_effective_date, in that order.
     --
     OPEN  c_emp_details(ld_effective_date);
     loop
     FETCH c_emp_details INTO ln_business_group_id,
                              ln_person_id,
                              ln_assignment_id,
                              ln_tax_unit_id,
                              ln_chunk_number,
                              lv_paternal_last_name,
                              lv_maternal_last_name,
                              lv_names,
                              lv_CURP,
                              lv_RFC_ID,
                              ld_arch_start_date,
                              ln_seniority,
                              lv_is_union_worker,
                              lv_economic_zone,
                              ln_tax_subsidy_prop,
                              lv_jurisdiction,
                              ln_row_count;
     exit when c_emp_details%NOTFOUND;

     --CLOSE c_emp_details;

     ln_step := 4;
     hr_utility.set_location(gv_package || lv_procedure_name, 70);
     hr_utility.trace('ld_start_date: ' || ld_start_date);
     hr_utility.trace('p_effective_date: ' || p_effective_date);
     hr_utility.trace('ln_tax_unit_id: ' || ln_tax_unit_id);
     hr_utility.trace('ln_person_id: ' || ln_person_id);
     hr_utility.trace('ln_assignment_id: ' || ln_assignment_id);
     hr_utility.trace('ln_row_count: ' || ln_row_count);

     FOR c_rec IN c_get_other_er_info(ln_person_id,
                                      p_effective_date)
     LOOP
         i := i + 1;
         PEI(i).isr_withheld      :=  c_rec.isr_withheld;
         PEI(i).cred_subsidy      :=  c_rec.cr_subsidy;
         PEI(i).non_cred_subsidy  :=  c_rec.non_cr_subsidy;
         PEI(i).total_earnings    :=  c_rec.total_earnings;
         PEI(i).exempt_earnings   :=  c_rec.exempt_earnings;

         ln_total_cred_subsidy := ln_total_cred_subsidy +
                                  NVL(PEI(i).cred_subsidy, 0);
         ln_total_subsidy := ln_total_subsidy + NVL(PEI(i).cred_subsidy, 0) +
                             NVL(PEI(i).non_cred_subsidy, 0);

         -- RFC Validation to be performed
         -- Hyphens are stripped and RFC is then validated.
         --
         hr_utility.set_location(gv_package || lv_procedure_name, 120);
         lv_plain_rfc :=
                    TRANSLATE(c_rec.RFC, 'A !"$%^&*()-_+=`[]{};''#:@~<>?','A');

         l_valid_rfc := hr_ni_chk_pkg.chk_nat_id_format(lv_plain_rfc,
                                                        'AAADDDDDDXXX');
         IF l_valid_rfc = '0' THEN
                hr_utility.set_location(gv_package || lv_procedure_name, 130);
                RAISE INVALID_RFC;
         ELSE
                PEI(i).RFC  := l_valid_rfc;
         END IF;

     END LOOP;

     lv_ann_adj := NULL;

     OPEN  c_fetch_Ann_adj(ln_person_id,p_effective_date);
     FETCH c_fetch_Ann_adj INTO lv_ann_adj;
     CLOSE c_fetch_Ann_adj;

     ld_hire_date := fnd_date.canonical_to_date('1900/01/01');

     OPEN  c_get_hire_date(ln_person_id,ld_effective_date); /*Re-hire bug*/
     FETCH c_get_hire_date INTO ld_hire_date;
     CLOSE c_get_hire_date;

     hr_utility.trace('B4 ld_arch_start_date: '||ld_arch_start_date);
     hr_utility.trace('B4 ld_arch_end_date: '||ld_arch_end_date);
     hr_utility.trace('ld_hire_date: '||ld_hire_date);

     IF  lv_arch_for_ptu_only = 'Y' THEN
       ld_arch_start_date := ld_PTU_date;
     END IF ;
      hr_utility.trace('After PTU check ld_arch_start_date: '||ld_arch_start_date);
     ld_arch_start_date := GREATEST( ld_arch_start_date, ld_hire_date );

     IF TRUNC( ld_arch_end_date, 'Y' ) = TRUNC( p_effective_date, 'Y' ) THEN

        ld_arch_end_date   := LEAST( ld_arch_end_date, p_effective_date );

     ELSE

        ld_arch_end_date   :=  p_effective_date;

     END IF;

     hr_utility.trace('AFTER ld_arch_start_date: '||ld_arch_start_date);
     hr_utility.trace('AFTER ld_arch_end_date: '||ld_arch_end_date);

     ln_step := 7;

     If ln_row_count = 1 then
     ln_index := pai_tab.count;

     pai_tab(ln_index).action_info_category := 'MX YREND EE DETAILS';
     pai_tab(ln_index).jurisdiction_code    := lv_jurisdiction;
     pai_tab(ln_index).action_context_id    := p_archive_action_id;
     pai_tab(ln_index).act_info1            := lv_paternal_last_name;
     pai_tab(ln_index).act_info2            := lv_maternal_last_name;
     pai_tab(ln_index).act_info3            := lv_names;
     pai_tab(ln_index).act_info4            := lv_CURP;
     pai_tab(ln_index).act_info5            := lv_RFC_ID;
     pai_tab(ln_index).act_info6            :=
                                fnd_date.date_to_canonical(ld_arch_start_date);
     pai_tab(ln_index).act_info7            :=
                                  fnd_date.date_to_canonical(ld_arch_end_date);

    IF lb_is_term_ee AND lv_prev_arch_exists = 'N' AND
        lv_arch_for_ptu_only = 'N' THEN

         pai_tab(ln_index).act_info8        := ln_seniority;

     ELSE

         pai_tab(ln_index).act_info8        := 0;

     END IF;

     -- sets the flag for the person where Annual Tax Adjusment process
     -- has been run act_info9
     pai_tab(ln_index).act_info9            := lv_ann_adj;
     pai_tab(ln_index).act_info10           := lv_is_union_worker;
     pai_tab(ln_index).act_info11           := lv_economic_zone;

     hr_utility.set_location(gv_package || lv_procedure_name, 140);
     --
     IF ln_total_subsidy > 0 THEN

         pai_tab(ln_index).act_info12       := ln_tax_subsidy_prop;
     ELSE

         pai_tab(ln_index).act_info12       := NULL;
     END IF;

     --
     -- Archived only if Annual Tax Adjustment is run for the EE
     --               and a different subsidy proportion has been used.
     --
     IF ln_total_subsidy > 0 AND lv_ann_adj = 'Y' THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 150);
         pai_tab(ln_index).act_info13       :=
                            ROUND(ln_total_cred_subsidy / ln_total_subsidy, 4);

         IF ln_tax_subsidy_prop <> pai_tab(ln_index).act_info13 THEN

             hr_utility.set_location(gv_package || lv_procedure_name, 160);
             pai_tab(ln_index).act_info13       := NULL;

         END IF;

     ELSE

         hr_utility.set_location(gv_package || lv_procedure_name, 170);
         pai_tab(ln_index).act_info13       := NULL;

     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 180);
     --
     IF PEI.EXISTS(1) THEN
        pai_tab(ln_index).act_info14           := PEI(1).RFC;
        pai_tab(ln_index).act_info24           := PEI(1).total_earnings;
        pai_tab(ln_index).act_info25           := PEI(1).isr_withheld;
        pai_tab(ln_index).act_info27           := PEI(1).exempt_earnings;

     ELSE -- No "Other Employer Info" exists.

        pai_tab(ln_index).act_info14           := NULL;
        pai_tab(ln_index).act_info24           := NULL;
        pai_tab(ln_index).act_info25           := NULL;
     END IF;

     IF PEI.EXISTS(2) THEN
        pai_tab(ln_index).act_info15           := PEI(2).RFC;
     ELSE
        pai_tab(ln_index).act_info15           := NULL;
     END IF;

     IF PEI.EXISTS(3) THEN
        pai_tab(ln_index).act_info16           := PEI(3).RFC;
     ELSE
        pai_tab(ln_index).act_info16           := NULL;
     END IF;

     IF PEI.EXISTS(4) THEN
        pai_tab(ln_index).act_info17           := PEI(4).RFC;
     ELSE
        pai_tab(ln_index).act_info17           := NULL;
     END IF;

     IF PEI.EXISTS(5) THEN
        pai_tab(ln_index).act_info18           := PEI(5).RFC;
     ELSE
        pai_tab(ln_index).act_info18           := NULL;
     END IF;

     IF PEI.EXISTS(6) THEN
        pai_tab(ln_index).act_info19           := PEI(6).RFC;
     ELSE
        pai_tab(ln_index).act_info19           := NULL;
     END IF;

     IF PEI.EXISTS(7) THEN
        pai_tab(ln_index).act_info20           := PEI(7).RFC;
     ELSE
        pai_tab(ln_index).act_info20           := NULL;
     END IF;

     IF PEI.EXISTS(8) THEN
        pai_tab(ln_index).act_info21           := PEI(8).RFC;
     ELSE
        pai_tab(ln_index).act_info21           := NULL;
     END IF;

     IF PEI.EXISTS(9) THEN
        pai_tab(ln_index).act_info22           := PEI(9).RFC;
     ELSE
        pai_tab(ln_index).act_info22           := NULL;
     END IF;

     IF PEI.EXISTS(10) THEN
        pai_tab(ln_index).act_info23           := PEI(10).RFC;
     ELSE
        pai_tab(ln_index).act_info23           := NULL;
     END IF;
     --

     pai_tab(ln_index).act_info26              :=
     hr_general.decode_lookup('PAY_MX_STATE_IDS', lv_jurisdiction);
     --
     --  to get the values for RATE_1991_IND and RATE_FISCAL_YEAR_IND
     --
     pai_tab(ln_index).act_info28 := '0';
     pai_tab(ln_index).act_info29 := '1';

     IF lv_ann_adj = 'Y' THEN

        OPEN  c_pact_info(p_archive_action_id);
        FETCH c_pact_info INTO ln_business_group_id
                              ,ld_effective_date;
        CLOSE c_pact_info;

        OPEN  c_ann_tax_type( ln_business_group_id
                             ,ld_effective_date
                             ,ln_person_id);
        FETCH c_ann_tax_type INTO lv_ann_tax_calc_type
                                 ,ln_anntaxadj_asgactid;
        CLOSE c_ann_tax_type;

        IF lv_ann_tax_calc_type = 'BEST' THEN

           OPEN  c_input_value_id;
           FETCH c_input_value_id INTO ln_input_value_id;
           CLOSE c_input_value_id;

           OPEN  c_get_anntaxadj_article( ln_anntaxadj_asgactid
                                         ,ln_input_value_id);
           FETCH c_get_anntaxadj_article INTO lv_anntaxadj_article;
           CLOSE c_get_anntaxadj_article;

        ELSE

           lv_anntaxadj_article := lv_ann_tax_calc_type;

        END IF;

        IF lv_anntaxadj_article = 'ARTICLE141' THEN

           pai_tab(ln_index).act_info28 := '1';
           pai_tab(ln_index).act_info29 := '2';

        ELSIF lv_anntaxadj_article  = 'ARTICLE177' THEN

           pai_tab(ln_index).act_info28 := '2';
           pai_tab(ln_index).act_info29 := '1';

        END IF;

     END IF;

     ln_step := 8;
     hr_utility.set_location(gv_package || lv_procedure_name, 190);
     pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id   => p_archive_action_id
                 ,p_action_context_type => 'AAP'
                 ,p_assignment_id       => ln_assignment_id
                 ,p_tax_unit_id         => ln_tax_unit_id
                 ,p_curr_pymt_eff_date  => p_effective_date
                 ,p_tab_rec_data        => pai_tab
                 );
     pai_tab.delete;

     ln_step := 9;
     hr_utility.set_location(gv_package || lv_procedure_name, 200);
     OPEN  c_check_pay_action(g_payroll_action_id);
     FETCH c_check_pay_action INTO ln_pay_action_count;
     CLOSE c_check_pay_action;

     ln_step := 10;
     IF ln_pay_action_count = 0 THEN

        hr_utility.set_location(gv_package || lv_procedure_name, 210);
        IF ln_row_count = 1 THEN

           ln_step := 11;
           ln_index := pai_tab.count;

           pai_tab(ln_index).action_info_category :='MX YREND LEGAL ER DETAILS';
           pai_tab(ln_index).jurisdiction_code    := NULL;
           pai_tab(ln_index).action_context_id    := g_payroll_action_id;
           pai_tab(ln_index).act_info1            := g_fiscal_year;
           pai_tab(ln_index).act_info2            := g_ER_RFC;
           pai_tab(ln_index).act_info3            := g_ER_legal_name;
           pai_tab(ln_index).act_info4            := g_ER_legal_rep_name;
           pai_tab(ln_index).act_info5            := g_ER_legal_rep_RFC;
           pai_tab(ln_index).act_info6            := g_ER_legal_rep_CURP;

           hr_utility.set_location(gv_package || lv_procedure_name, 220);

           OPEN c_get_gen_hier_details(ln_business_group_id,
                                       p_effective_date);
           LOOP

               ln_step := 12;
               hr_utility.set_location(gv_package || lv_procedure_name, 230);

               FETCH c_get_gen_hier_details INTO ln_legal_er_id,
                                                 ln_gre_id;
               EXIT WHEN c_get_gen_hier_details%NOTFOUND;

               ln_index := pai_tab.count;

               hr_utility.set_location(gv_package || lv_procedure_name, 240);

               pai_tab(ln_index).action_info_category := 'MX GENERIC ' ||
                                                         'HIERARCHY DETAILS';
               pai_tab(ln_index).jurisdiction_code    := NULL;
               pai_tab(ln_index).action_context_id    := g_payroll_action_id;
               pai_tab(ln_index).act_info1            := ln_gre_id;
               pai_tab(ln_index).act_info2            := ln_legal_er_id;

           END LOOP;

           ln_step := 13;
           hr_utility.set_location(gv_package || lv_procedure_name, 250);

           pay_emp_action_arch.insert_rows_thro_api_process(
                      p_action_context_id   => g_payroll_action_id
                     ,p_action_context_type => 'PA'
                     ,p_assignment_id       => NULL
                     ,p_tax_unit_id         => NULL
                     ,p_curr_pymt_eff_date  => p_effective_date
                     ,p_tab_rec_data        => pai_tab);

           hr_utility.set_location(gv_package || lv_procedure_name, 260);
           pai_tab.delete;

        END IF;

     END IF;
     end if;

     ln_step := 14;
     hr_utility.set_location(gv_package || lv_procedure_name, 270);

     end loop;
     Close c_emp_details;
     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

  EXCEPTION
    WHEN INVALID_RFC THEN
         hr_utility.set_message(800, 'HR_MX_INVALID_ER_RFC');
         hr_utility.raise_error;

    WHEN OTHERS THEN
         lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                              gv_package || lv_procedure_name;

         hr_utility.trace(lv_error_message || '-' || SQLERRM);

         lv_error_message :=
            pay_emp_action_arch.set_error_message(lv_error_message);

         hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
         hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
         hr_utility.raise_error;

  END archive_code;

BEGIN
    --hr_utility.trace_on (NULL, 'MX_IDC');
    gv_package := 'pay_mx_yrend_arch';
END pay_mx_yrend_arch;

/
