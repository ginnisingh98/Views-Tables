--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_BALS_ADJ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_BALS_ADJ_API" AS
/* $Header: pytbaapi.pkb 120.2.12010000.8 2010/01/06 15:22:48 tclewis ship $ */
/*+======================================================================+
  |                Copyright (c) 1997 Oracle Corporation                 |
  |                   Redwood Shores, California, USA                    |
  |                        All rights reserved.                          |
  +======================================================================+
  Package Body Name : PAY_US_TAX_BALS_ADJ_API
  Package File Name : pytbaapi.pkb

        Description : Defines procedures for the main PLSQL execution engine.
                      See package header for details.

 Change List:
 ------------

 Name       Date        Version Bug     Text
 ---------- ----------- ------- ------- ----------------------------------
 mcpham     12-JUN-2000  115.0           Initial Version

 irgonzal   13-SEP-2000  115.1  1398865  Modified csr_sdi_check cursor
                                         to check business_group_id on
                                         assignment record to ensure only one
                                         is returned when same assignment
                                         number exist in different business
                                         groups.
 ahanda     04-JAN-2001 115.2            Added commit before exit stmt.
 meshah     24-JAN-2001 115.3   1608907  Now seperate checking is done for
                                         CITY and COUNTY, if tax_exists returns
                                         'N' then give error.
 tclewis    11-JAN-2001 115.4   1569312  SUI and SDI taxable were only
                                         being adjusted when an adjustment
                                         about was entered for SUI / SDI
                                         liablity. I removed the code
                                         (if statements) where we check if
                                         l_sui_er/l_sdi_er (or ee) were
                                         eneterd before we process the
                                         adjustment.
 ahanda     16-OCT-2001 115.5   2060597  Changed process_limit to take care
                                         of -ve amounts.
 rmonge     14-NOV-2001 115.6   2060597  Made modifications to process limit
                                         to take care of Negative Adjustments
                                2102153  Added new if then else logic, to
                                         execute process_elements for
                                         ('SUI_EE', 'SUI_ER','SDI_ER',
                                          'SDI_EE') when there is an
                                         Adjustment to be made. Before, the
                                         code only executed if the gross
                                         amount was different than 0. This
                                         did not work in the case where the
                                         user did not enter a gross amount
                                         Adjustment.
  tclewis    28-DEC-2001 115.9   2164393  Modified code around the calls to
                                         process limits to NOT make the call
                                         to the process_limits procedure
                                         if the element to be processed is
                                         MEDICARE_EE or MEDICARE_ER.
                                         Modified the logic in process limits
                                         as some of the condition checking was
                                         not taking into consideration the adjustment
                                         amount.
  tclewis    03-JAN-2002 115.11  2170112 Modified csr_sui_geocode cursor
                                         added a check for business group id
                                         when getting the sui geo using the
                                         "assignment number".
 jgoswami    04-JAN-2002 115.12          Changed SUBJECT to REDUCED_SUBJ_WHABLE in
                                         balance call for limit_subject_bal in
                                         process_limits procedure.
 tclewis     10-JAN-2002 115.13          With in the Process_inputs procedure when
                                         checking city / count_subj, if we don't find
                                         a taxability rule for city subj, we must first
                                         check for the existence city subj NWHable, before
                                         defaulting to the state taxablily rule.  The
                                         opposite goes for checking city subj NWhable.
 meshah      22-JAN-2002 115.4           Added checkfile entry to the file.
 tclewis     13-feb-2002 115.15          1) bug 2176643 modified the sdi_check cursor to
                                         check for any work location withing the year.
                                         Not just as of the effective_date of the balance
                                         adjustment.
                                         2) bug 2190000 modified the code to handle school
                                         district taxes.
                                         3)  Fixed a bug with the process limits routine.
                                         Currently we are fetching the reduced_subj_whable
                                         balance as of adjustment date where we should be
                                         fetching the balance as to  the eoy.

 tclewis     11-feb-2002  115.16         Added parameter p_balance_adj_prepay_flag
                                         to the create_tax_balance_adjustment
                                         procedure.   This new parameter is now
                                         passed to the pay_bal_adjust.init_batch
                                         function.
 tclewis     16-apr-2002  115.18         Added new cursor to the process_input procedure
                                         csr_chk_all_taxability.  This will be used
                                         to check for the existance of ANY taxability
                                         rules a the local level.   We will use this in
                                         the following sequence (example will be element)
                                         city_subject_wk.  check city subject TR.  if
                                         no data found check city_NW.  if no data found
                                         check for any TR at local level, if found assume
                                         element is NOT SUBJECT, NOT WITHHELD.   IF no
                                         data found, default to state level.
 tclewis     17-apr-2002  115.19         Memoved the following code
                                         "and
                                         (l_old_taxable_bal + p_earn_amount) > 0"
                                         from within the negative balance adjustment
                                         section, this created an error with large
                                         negative adjustment with taxable.
tclewis       18-apr-2002 115.20         added a check for tax exists before processing
                                         subject balances on County and city taxes
tclewis	      05-SEP-2002 115.21         Modified the balance calls in the
                                         process_limits and taxable_balance
                                         procedure / functions to use PER
                                         or PER_TG (in the case of tax group)
                                         for the p_asg_type parameter.  With
                                         respect to PER_TG, this parameter
                                         will only be used if the GRE on the
                                         assignment is in a tax group and
                                         the balance type is MEDICARE, SS or
                                         FUTA.
                                          Also added a check for L_gross_amount
                                         <> 0 to the check for l_SUI /l_SDI
                                         respectively when making the taxable
                                         and withheld balance adjustment.
tclewis       12-SPE-2002 115.22         modified the process_limits procedure
                                         to handle a condition with subject
                                         and taxbable don't match and are below
                                         the limit.
                                         Also added code the check for tax exemptions
                                         for limit taxes (Medicare, SS, futa, sui and
                                         SDI).  If balance adjustment is made
                                         when assignment is exempt, will not adjust
                                         the taxable balance.  If an value is entered
                                         into the withheld or liability filed we will
                                         adjust that balance regardless of the
                                         exemption.
tclewis      12-sep-2002  115.23         Left the foundation for tax group
                                         but removed initial implementation
                                         as pay_us_Tax_bals_view_pkg is
                                         not yet fixed to handel 'PER_TG'
                                         asg_type.
asasthnna    03-DEC-2002  115.24         added nocopy for gscc compliance
tclewis      10-DEC-2002  115.25         removed check for existance on global
                                         rate variables.  Now  will fetch values
                                         on each call of create_tax_balance_adjustment.
                                         Made performance fix to csr_element in the
                                         process_element procedure.
asasthan     30-MAY-2003  115.26         changes for 2904628
asasthan     02-JUN-2003  115.26         Further changes for 2904628
schauhan     29-JUN-2004  115.28 3697701 Removed the condition l_gross_amount<>0
                                         from the IF condition when calculating
                                         l_jd_level_needed.
					 Also put a format mask DD-MM-YYYY in
					 process_limits for p_adjustment_date
					 for GSCC compliance.
trugless     04-Oct-2004  115.29 3887144 Modified cursor c_get_sui_self_adjust_method,
                                         changed hoi.org_information5 = h1.LOOKUP_CODE
                                         to  hoi.org_information4 = h1.LOOKUP_CODE.
                                         hoi.org_information5 is SDI,
                                         hoi.org_information4 is SUI.
sackumar    26-Apr-2005   115.30 4188782 Modified the Procedure create_tax_balance_adjusment
					 and process_element procedure for Supplimental earning.
sackumar    26-Apr-2005   115.31 4627851 Modified the Procedure create_tax_balance_adjusment
					 and process_element procedure for Imputed Earning.
sackumar    16-Nov-2005   115.32 4721086 Modified the value passed to p_virtual_date parameter in
					 pay_us_tax_bals_pkg.us_tax_balance procedure call from the
					 Procedure process_limits,It is changed now l_virtual_adjustment_date
					 local variable is used to pass the last date of the year.
tclewis     09-SEP-2008   115.33 7362837 Added code to create run result for the
                     'SIT_WK_NON_AGGREGATE_RED_SUBJ_WHABLE' Element for supplemental and
                      imputed earnings.
tclewis     17-OCT-2008   115.34 7362837 Added code to create run result for the
                     'FIT_NON_AGGREGATE_RED_SUBJ_WHABLE' Element for supplemental and
                      imputed earnings.
pannapur    19-Jan-2009  Bug 7692482.
tclewis     22-dec-2009  115.35  9110226   modified csr_sdi_check to handle
                                           assignment work_at_home.
 ========================================================================*/


 -- global variables
 g_classification               VARCHAR2(80);
 g_earnings_category            VARCHAR2(30);
 g_classification_id            NUMBER;
 g_fed_jd                       VARCHAR2(11) := '00-000-0000';
 g_state_jd                     VARCHAR2(11) := '00-000-0000';
 g_sui_jd                       VARCHAR2(11) := '00-000-0000';
 g_sui_state_code               VARCHAR2(2);
 g_county_jd                    VARCHAR2(11) := '00-000-0000';
 g_city_jd                      VARCHAR2(11) := '00-000-0000';
 g_sch_dist_jur                 VARCHAR2(10) := '00-00000';
 g_dummy_varchar_tbl            hr_entry.varchar2_table;
 g_dummy_number_tbl             hr_entry.number_table;

 /* federal level 'balances' */
 g_medicare_ee_taxable          NUMBER := 0;
 g_medicare_er_taxable          NUMBER := 0;
 g_futa_taxable                 NUMBER := 0;
 g_ss_ee_taxable                NUMBER := 0;
 g_ss_er_taxable                NUMBER := 0;

 /* Federal self adjust methods */
 g_futa_sa_method               varchar2(25);
 g_ss_sa_method                 varchar2(25);
 g_medicare_sa_method           varchar2(25);

 /* state level 'balances' */
 g_sdi_ee_taxable               NUMBER := 0;
 g_sdi1_ee_taxable              NUMBER := 0;
 g_sdi_er_taxable               NUMBER := 0;
 g_sui_ee_taxable               NUMBER := 0;
 g_sui_er_taxable               NUMBER := 0;

 /*state Self Adjust method */
 g_sdi_sa_method               varchar2(25);
 g_sdi1_sa_method              varchar2(25);
 g_sui_sa_method                 varchar2(25);

 /* federal level 'limits' */
 g_futa_wage_limit              NUMBER := 0;
 g_ss_ee_wage_limit             NUMBER := 0;
 g_ss_er_wage_limit             NUMBER := 0;

 /* state level 'limits' */
 g_sdi_ee_wage_limit            NUMBER := 0;
 g_sdi1_ee_wage_limit           NUMBER := 0;
 g_sdi_er_wage_limit            NUMBER := 0;
 g_sui_ee_wage_limit            NUMBER := 0;
 g_sui_er_wage_limit            NUMBER := 0;

/* federal level tax group */
 g_tax_group                   varchar2(240) := 'NOT_ENTERED';

PROCEDURE process_input(
  p_element_type        IN      VARCHAR2,
  p_element_type_id     IN      NUMBER,
  p_iv_tbl              IN OUT NOCOPY  hr_entry.number_table,
  p_iv_names_tbl        IN OUT NOCOPY  hr_entry.varchar2_table,
  p_ev_tbl              IN OUT NOCOPY  hr_entry.varchar2_table,
  p_bg_id               IN      NUMBER,
  p_adj_date            IN      DATE,
  p_input_name          IN      VARCHAR2,
  p_entry_value         IN      VARCHAR2,
  p_row                 IN OUT NOCOPY  NUMBER) IS

  CURSOR csr_inputs(v_element_type_id IN NUMBER,
                    v_input_name      IN VARCHAR2) IS
    SELECT i.input_value_id
      FROM pay_input_values_f i
     WHERE i.element_type_id    = v_element_type_id
       AND (i.business_group_id = p_bg_id
            OR i.business_group_id IS NULL)
       AND upper(i.name) = upper(v_input_name)
       AND p_adj_date BETWEEN
                i.effective_start_date AND i.effective_end_date
    ;

  CURSOR  csr_chk_taxability(v_tax_type VARCHAR2,
                             v_jurisdiction_code  VARCHAR2) IS
    SELECT 'Y'
    FROM   PAY_TAXABILITY_RULES
    WHERE  jurisdiction_code = v_jurisdiction_code
    and    tax_category      = g_earnings_category
    and    tax_type          = v_tax_type
    and    classification_id = g_classification_id
    and    nvl(status,'VALID') <> 'D'
    ;

  CURSOR  csr_chk_fed_taxability(v_tax_type VARCHAR2) IS
    SELECT 'Y'
    FROM   PAY_TAXABILITY_RULES
    WHERE  jurisdiction_code = g_fed_jd
    and    tax_category      = g_earnings_category
    and    tax_type          = v_tax_type
    and    classification_id = g_classification_id
    and    nvl(status,'VALID') <> 'D'
    ;

  CURSOR  csr_chk_all_taxability(v_jurisdiction_code  VARCHAR2) IS
    SELECT 'N'
    FROM   PAY_TAXABILITY_RULES
    WHERE  jurisdiction_code = v_jurisdiction_code
    and    nvl(status,'VALID') <> 'D'

    ;

   CURSOR csr_get_school_jd_level IS
     SELECT 'Y'
     FROM pay_us_county_school_dsts pcsd
     WHERE pcsd.state_code = substr(g_sch_dist_jur,1,2)
     AND  pcsd.school_dst_code = substr(g_sch_dist_jur,4,5)
    ;

  l_input_value_id      NUMBER;
  l_taxable             VARCHAR2(1)  := 'N';
  c_proc                VARCHAR2(100) := 'pay_us_tax_bals_adj_pkg.process_input';
  l_jurisdiction_code   VARCHAR2(11);
  l_county_sch_dsts     VARCHAR2(10) := 'N';

BEGIN
  hr_utility.set_location(c_proc, 10);

  OPEN csr_inputs (p_element_type_id, p_input_name);
  FETCH csr_inputs INTO l_input_value_id;
  CLOSE csr_inputs;

  IF (l_input_value_id IS NULL) THEN
    hr_utility.set_location(c_proc, 20);
    hr_utility.set_message(801, 'PY_50014_TXADJ_IV_ID_NOT_FOUND');
    hr_utility.raise_error;
  END IF;

  -- check taxability of the tax balance element
  hr_utility.set_location(c_proc, 30);

  IF (g_classification IN ('Imputed Earnings', 'Supplemental Earnings')) THEN

/** sbilling **/
    /*
    ** no RRVs were being generated for Medicare_EE's TAXABLE EV as p_element_type
    ** (Medicare_EE) didn't satisfy any if conditions in the inner block,
    ** l_taxable was not set to Y,
    ** therefore the table structure was not populated,
    ** at a later stage Medicare_EE's TAXABLE EV would be defaulted to 0,
    ** causing the taxable amount to appear in Excess,
    */
    IF (p_input_name = 'Subj Whable' OR p_input_name = 'TAXABLE') THEN

      hr_utility.set_location(c_proc, 40);

      IF (p_element_type IN ('SUI_EE', 'SUI_SUBJECT_EE',
                             'SUI_ER', 'SUI_SUBJECT_ER')) THEN
        hr_utility.set_location(c_proc, 41);
        OPEN  csr_chk_taxability ('SUI', g_state_jd );
        FETCH csr_chk_taxability INTO l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type IN ('Medicare_EE', 'Medicare_ER')) THEN
        hr_utility.set_location(c_proc, 42);
        OPEN  csr_chk_fed_taxability ('MEDICARE');
        FETCH csr_chk_fed_taxability INTO l_taxable;
        CLOSE csr_chk_fed_taxability;

      ELSIF (p_element_type IN ('SS_EE', 'SS_ER')) THEN
        hr_utility.set_location(c_proc, 43);
        OPEN  csr_chk_fed_taxability ('SS');
        FETCH csr_chk_fed_taxability INTO l_taxable;
        CLOSE csr_chk_fed_taxability;

      ELSIF (p_element_type IN ('FUTA')) THEN
        hr_utility.set_location(c_proc, 43);
        OPEN  csr_chk_fed_taxability ('FUTA');
        FETCH csr_chk_fed_taxability INTO l_taxable;
        CLOSE csr_chk_fed_taxability;

      ELSIF (p_element_type IN ('SDI_EE', 'SDI_SUBJECT_EE',
                                'SDI_ER', 'SDI_SUBJECT_ER',
                                'SDI1_EE' )) THEN
        hr_utility.set_location(c_proc, 42);
        OPEN  csr_chk_taxability ('SDI', g_state_jd );
        FETCH csr_chk_taxability INTO l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type = ('SIT_SUBJECT_WK') )  THEN
             hr_utility.set_location(c_proc, 43);
        OPEN  csr_chk_taxability ('SIT', g_state_jd );
        FETCH csr_chk_taxability INTO l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type = ('City_SUBJECT_WK')  )  THEN
        hr_utility.set_location(c_proc, 44);
        l_jurisdiction_code := substr(g_city_jd,1,3) || '000' || substr(g_city_jd,7,5);
        OPEN  csr_chk_taxability ('CITY', l_jurisdiction_code);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        --  as we are checking for SUBJ whable here.  If we don't find a row for locality
        --  subj whable, we must check for subj NWhable befor defaulting to state level.
        --  NOTE currently is does not cover a situation where the specific element type
        --  is not subject (WHable or NWhable) and the state is Whable.
        IF csr_chk_taxability%NOTFOUND THEN  -- 1
          CLOSE csr_chk_taxability;
          OPEN  csr_chk_taxability ('NW_CITY', l_jurisdiction_code);
          FETCH csr_chk_taxability INTO l_taxable;
          IF csr_chk_taxability%NOTFOUND THEN -- 2
          -- check for the existance of any taxability rules at this JD level.
          -- if we get to this point and the csr_chk_all_taxability returns data
          -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
             CLOSE csr_chk_taxability;
             OPEN  csr_chk_all_taxability (l_jurisdiction_code);
             FETCH csr_chk_all_taxability INTO l_taxable;
             IF csr_chk_all_taxability%NOTFOUND THEN  --3
                 CLOSE csr_chk_all_taxability;
                 OPEN  csr_chk_taxability ('SIT', g_state_jd);
                 FETCH csr_chk_taxability INTO l_taxable;
                 CLOSE csr_chk_taxability;
             ELSE -- 3
                 l_taxable := 'N';
                 CLOSE csr_chk_all_taxability;
             END IF; -- 3
          ELSE -- 2
             l_taxable := 'N';
             CLOSE csr_chk_taxability;
          END IF; --2
        ELSE -- 1
           CLOSE csr_chk_taxability;
        END IF; --1

/*  NEW code for school district processing */

       ELSIF p_element_type = ('School_SUBJECT_WK') THEN
       -- IF THE STATE JURISDICTION IS OHIO THEN CHECK TAXABLILITY RULES OF THE STATE LEVEL
       -- ELESE CHECK THE TAXABLILITY RULES OF THE RESPECTIVE CITY OR COUNTY THE SCHOOL
       -- DISTRICT BELONGS TO.
          IF  SUBSTR(G_city_jd,1,2) = '36' THEN
            OPEN  csr_chk_taxability ('SIT', g_state_jd);
            FETCH csr_chk_taxability INTO l_taxable;
            CLOSE csr_chk_taxability;
          ELSE  -- state code =  36
            OPEN  csr_get_school_jd_level;
            fetch csr_get_school_jd_level inTO l_county_sch_dsts;
            if csr_get_school_jd_level%NOTFOUND THEN
                l_jurisdiction_code := substr(g_city_jd,1,3) || '000' || substr(g_city_jd,7,5);
                OPEN  csr_chk_taxability ('CITY', l_jurisdiction_code);
                FETCH csr_chk_taxability INTO l_taxable;
                --  If the above query returns no rows then check the state level taxablility rule
                --  as we are checking for SUBJ whable here.  If we don't find a row for locality
                --  subj whable, we must check for subj NWhable befor defaulting to state level.
                --  NOTE currently is does not cover a situation where the specific element type
                --  is not subject (WHable or NWhable) and the state is Whable.
                IF csr_chk_taxability%NOTFOUND THEN
                  CLOSE csr_chk_taxability;
                  OPEN  csr_chk_taxability ('NW_CITY', l_jurisdiction_code);
                  FETCH csr_chk_taxability INTO l_taxable;
                  IF csr_chk_taxability%NOTFOUND THEN -- 2
                  -- check for the existance of any taxability rules at this JD level.
                  -- if we get to this point and the csr_chk_all_taxability returns data
                  -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
                     CLOSE csr_chk_taxability;
                     OPEN  csr_chk_all_taxability (l_jurisdiction_code);
                     FETCH csr_chk_all_taxability INTO l_taxable;
                     IF csr_chk_all_taxability%NOTFOUND THEN  --3
                         CLOSE csr_chk_all_taxability;
                         OPEN  csr_chk_taxability ('SIT', g_state_jd);
                         FETCH csr_chk_taxability INTO l_taxable;
                         CLOSE csr_chk_taxability;
                     ELSE -- 3
                         l_taxable := 'N';
                         CLOSE csr_chk_all_taxability;
                     END IF; -- 3
                  ELSE -- 2
                     l_taxable := 'N';
                     CLOSE csr_chk_taxability;
                  END IF; --2
                ELSE
                   CLOSE csr_chk_taxability;
                END IF;

              ELSE     -- csr_get_school_jd_level%NOT_FOUND
                       -- row found in cursor so this is a county school district
                       -- check the county TR

                OPEN  csr_chk_taxability ('COUNTY', g_county_jd);
                FETCH csr_chk_taxability INTO l_taxable;
                --  If the above query returns no rows then check the state level taxablility rule
                --  as we are checking for SUBJ whable here.  If we don't find a row for locality
                --  subj whable, we must check for subj NWhable befor defaulting to state level.
                --  NOTE currently is does not cover a situation where the specific element type
                --  is not subject (WHable or NWhable) and the state is Whable.
                IF csr_chk_taxability%NOTFOUND THEN
                  CLOSE csr_chk_taxability;
                  OPEN  csr_chk_taxability ('NW_COUNTY', g_county_jd);
                  FETCH csr_chk_taxability INTO l_taxable;
                  IF csr_chk_taxability%NOTFOUND THEN -- 2
                  -- check for the existance of any taxability rules at this JD level.
                  -- if we get to this point and the csr_chk_all_taxability returns data
                  -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
                     CLOSE csr_chk_taxability;
                     OPEN  csr_chk_all_taxability (g_county_jd);
                     FETCH csr_chk_all_taxability INTO l_taxable;
                     IF csr_chk_all_taxability%NOTFOUND THEN  --3
                         CLOSE csr_chk_all_taxability;
                         OPEN  csr_chk_taxability ('SIT', g_state_jd);
                         FETCH csr_chk_taxability INTO l_taxable;
                         CLOSE csr_chk_taxability;
                     ELSE -- 3
                         l_taxable := 'N';
                         CLOSE csr_chk_all_taxability;
                     END IF; -- 3
                  ELSE -- 2
                     l_taxable := 'N';
                     CLOSE csr_chk_taxability;
                  END IF; --2
               ELSE
                   CLOSE csr_chk_taxability;
                END IF;
              END IF; -- csr_get_school_jd_level%NOT_FOUND

              CLOSE csr_get_school_jd_level;

            END IF;  -- state code = '36'

/* End of code for school district taxes. */

        ELSIF (p_element_type IN ('County_SUBJECT_WK')) THEN
        hr_utility.set_location(c_proc, 45);
        OPEN  csr_chk_taxability ('COUNTY', g_county_jd);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        --  as we are checking for SUBJ whable here.  If we don't find a row for locality
        --  subj whable, we must check for subj NWhable befor defaulting to state level.
        --  NOTE currently is does not cover a situation where the specific element type
        --  is not subject (WHable or NWhable) and the state is Whable.
        IF csr_chk_taxability%NOTFOUND THEN
          CLOSE csr_chk_taxability;
          OPEN  csr_chk_taxability ('NW_COUNTY', g_county_jd);
          FETCH csr_chk_taxability INTO l_taxable;
          IF csr_chk_taxability%NOTFOUND THEN -- 2
          -- check for the existance of any taxability rules at this JD level.
          -- if we get to this point and the csr_chk_all_taxability returns data
          -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
             CLOSE csr_chk_taxability;
             OPEN  csr_chk_all_taxability (g_county_jd);
             FETCH csr_chk_all_taxability INTO l_taxable;
             IF csr_chk_all_taxability%NOTFOUND THEN  --3
                 CLOSE csr_chk_all_taxability;
                 OPEN  csr_chk_taxability ('SIT', g_state_jd);
                 FETCH csr_chk_taxability INTO l_taxable;
                 CLOSE csr_chk_taxability;
             ELSE -- 3
                 l_taxable := 'N';
                 CLOSE csr_chk_all_taxability;
             END IF; -- 3
          ELSE -- 2
             l_taxable := 'N';
             CLOSE csr_chk_taxability;
          END IF; --2
        ELSE
          CLOSE csr_chk_taxability;
        END IF;

      END IF;

    ELSIF (p_input_name = 'Subj NWhable') THEN
           hr_utility.set_location(c_proc, 50);

     IF (p_element_type = ('SIT_SUBJECT_WK') )  THEN
        hr_utility.set_location(c_proc, 51);
        OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
        FETCH csr_chk_taxability INTO l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type = ('City_SUBJECT_WK') )  THEN
        hr_utility.set_location(c_proc, 52);
        l_jurisdiction_code := substr(g_city_jd,1,3) || '000' || substr(g_city_jd,7,5);
        OPEN  csr_chk_taxability ('NW_CITY', l_jurisdiction_code);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        --  as we are checking for SUBJ Nwhable here.  If we don't find a row for locality
        --  subj whable, we must check for SUBJ Whable befor defaulting to state level.
        --  NOTE currently is does not cover a situation where the specific element type
        --  is not subject (WHable or NWhable) and the state is Whable.
        IF csr_chk_taxability%NOTFOUND THEN
          CLOSE csr_chk_taxability;
          OPEN  csr_chk_taxability ('CITY', l_jurisdiction_code);
          FETCH csr_chk_taxability INTO l_taxable;
          IF csr_chk_taxability%NOTFOUND THEN -- 2
          -- check for the existance of any taxability rules at this JD level.
          -- if we get to this point and the csr_chk_all_taxability returns data
          -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
             CLOSE csr_chk_taxability;
             OPEN  csr_chk_all_taxability (l_jurisdiction_code);
             FETCH csr_chk_all_taxability INTO l_taxable;
             IF csr_chk_all_taxability%NOTFOUND THEN  --3
                 CLOSE csr_chk_all_taxability;
                 OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
                 FETCH csr_chk_taxability INTO l_taxable;
                 CLOSE csr_chk_taxability;
             ELSE -- 3
                 l_taxable := 'N';
                 CLOSE csr_chk_all_taxability;
             END IF; -- 3
          ELSE -- 2
             l_taxable := 'N';
             CLOSE csr_chk_taxability;
          END IF; --2
        ELSE
           CLOSE csr_chk_taxability;
        END IF;

      ELSIF (p_element_type IN ('County_SUBJECT_WK')) THEN
        hr_utility.set_location(c_proc, 53);
        OPEN  csr_chk_taxability ('NW_COUNTY', g_county_jd);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        --  as we are checking for SUBJ Nwhable here.  If we don't find a row for locality
        --  subj whable, we must check for SUBJ Whable befor defaulting to state level.
        --  NOTE currently is does not cover a situation where the specific element type
        --  is not subject (WHable or NWhable) and the state is Whable.
        IF csr_chk_taxability%NOTFOUND THEN
          CLOSE csr_chk_taxability;
          OPEN  csr_chk_taxability ('COUNTY', g_county_jd);
          FETCH csr_chk_taxability INTO l_taxable;
          IF csr_chk_taxability%NOTFOUND THEN -- 2
          -- check for the existance of any taxability rules at this JD level.
          -- if we get to this point and the csr_chk_all_taxability returns data
          -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
             CLOSE csr_chk_taxability;
             OPEN  csr_chk_all_taxability (g_county_jd);
             FETCH csr_chk_all_taxability INTO l_taxable;
             IF csr_chk_all_taxability%NOTFOUND THEN  --3
                 CLOSE csr_chk_all_taxability;
                 OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
                 FETCH csr_chk_taxability INTO l_taxable;
                 CLOSE csr_chk_taxability;
             ELSE -- 3
                 l_taxable := 'N';
                 CLOSE csr_chk_all_taxability;
             END IF; -- 3
          ELSE -- 2
             l_taxable := 'N';
             CLOSE csr_chk_taxability;
          END IF; --2
        ELSE
           CLOSE csr_chk_taxability;
        END IF;

/*  NEW code for school district processing */

       ELSIF p_element_type = ('School_SUBJECT_WK') THEN
       -- IF THE STATE JURISDICTION IS OHIO THEN CHECK TAXABLILITY RULES OF THE STATE LEVEL
       -- ELESE CHECK THE TAXABLILITY RULES OF THE RESPECTIVE CITY OR COUNTY THE SCHOOL
       -- DISTRICT BELONGS TO.
          IF  SUBSTR(G_city_jd,1,2) = '36' THEN
            OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
            FETCH csr_chk_taxability INTO l_taxable;
            CLOSE csr_chk_taxability;
          ELSE  -- state code =  36
            OPEN  csr_get_school_jd_level;
            fetch csr_get_school_jd_level inTO l_county_sch_dsts;
            if csr_get_school_jd_level%NOTFOUND THEN
                l_jurisdiction_code := substr(g_city_jd,1,3) || '000' || substr(g_city_jd,7,5);
                OPEN  csr_chk_taxability ('NW_CITY', l_jurisdiction_code);
                FETCH csr_chk_taxability INTO l_taxable;
                --  If the above query returns no rows then check the state level taxablility rule
                --  as we are checking for SUBJ whable here.  If we don't find a row for locality
                --  subj whable, we must check for subj NWhable befor defaulting to state level.
                --  NOTE currently is does not cover a situation where the specific element type
                --  is not subject (WHable or NWhable) and the state is Whable.
                IF csr_chk_taxability%NOTFOUND THEN
                  CLOSE csr_chk_taxability;
                  OPEN  csr_chk_taxability ('CITY', l_jurisdiction_code);
                  FETCH csr_chk_taxability INTO l_taxable;
                  IF csr_chk_taxability%NOTFOUND THEN -- 2
                  -- check for the existance of any taxability rules at this JD level.
                  -- if we get to this point and the csr_chk_all_taxability returns data
                  -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
                     CLOSE csr_chk_taxability;
                     OPEN  csr_chk_all_taxability (l_jurisdiction_code);
                     FETCH csr_chk_all_taxability INTO l_taxable;
                     IF csr_chk_all_taxability%NOTFOUND THEN  --3
                         CLOSE csr_chk_all_taxability;
                         OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
                         FETCH csr_chk_taxability INTO l_taxable;
                         CLOSE csr_chk_taxability;
                     ELSE -- 3
                         l_taxable := 'N';
                         CLOSE csr_chk_all_taxability;
                     END IF; -- 3
                  ELSE -- 2
                    l_taxable := 'N';
                     CLOSE csr_chk_taxability;
                  END IF; --2
                ELSE
                   CLOSE csr_chk_taxability;
                END IF;

              ELSE     -- csr_get_school_jd_level%NOT_FOUND
                       -- row found in cursor so this is a county school district
                       -- check the county TR

                OPEN  csr_chk_taxability ('NW_COUNTY', g_county_jd);
                FETCH csr_chk_taxability INTO l_taxable;
                --  If the above query returns no rows then check the state level taxablility rule
                --  as we are checking for SUBJ whable here.  If we don't find a row for locality
                --  subj whable, we must check for subj NWhable befor defaulting to state level.
                --  NOTE currently is does not cover a situation where the specific element type
                --  is not subject (WHable or NWhable) and the state is Whable.
                IF csr_chk_taxability%NOTFOUND THEN
                  CLOSE csr_chk_taxability;
                  OPEN  csr_chk_taxability ('COUNTY', g_county_jd);
                  FETCH csr_chk_taxability INTO l_taxable;
                  IF csr_chk_taxability%NOTFOUND THEN -- 2
                  -- check for the existance of any taxability rules at this JD level.
                  -- if we get to this point and the csr_chk_all_taxability returns data
                  -- then we assume that the element is NOT SUBJECT, NOT WITHHELD
                     CLOSE csr_chk_taxability;
                     OPEN  csr_chk_all_taxability (g_county_jd);
                     FETCH csr_chk_all_taxability INTO l_taxable;
                     IF csr_chk_all_taxability%NOTFOUND THEN  --3
                         CLOSE csr_chk_all_taxability;
                         OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
                         FETCH csr_chk_taxability INTO l_taxable;
                         CLOSE csr_chk_taxability;
                     ELSE -- 3
                         l_taxable := 'N';
                         CLOSE csr_chk_all_taxability;
                     END IF; -- 3
                  ELSE -- 2
                     l_taxable := 'N';
                     CLOSE csr_chk_taxability;
                  END IF; --2
                ELSE
                   CLOSE csr_chk_taxability;
                END IF;
              END IF; -- csr_get_school_jd_level%NOT_FOUND

              CLOSE csr_get_school_jd_level;

            END IF;  -- state code = '36'

/* End of code for school district taxes. */


      END IF;

    ELSE
      hr_utility.set_location(c_proc, 60);
      -- otherwise we do not need to check taxability_rules
      -- in order to set the value of the input value,
      -- NB. that this step gets executed for tax elements like FIT, Medicare
      -- as well as Tax balance elements like SUI_SUBJECT_EE
      l_taxable := 'Y';
    END IF;

  ELSE
    -- an Earnings Element so no taxability rules
    hr_utility.set_location(c_proc, 70);

    l_taxable := 'Y';

  END IF;


  IF (l_taxable = 'Y') THEN
    hr_utility.set_location (c_proc, 200);

    p_iv_tbl(p_row)       := l_input_value_id;
    p_iv_names_tbl(p_row) := p_input_name;
    p_ev_tbl(p_row)       := p_entry_value;
    p_row                 := p_row + 1;  -- next row in plsql table
  END IF;

END process_input;



PROCEDURE fetch_wage_limits(
  p_effective_date      IN      DATE     DEFAULT NULL,
  p_state_abbrev        IN      VARCHAR2 DEFAULT NULL,
  p_futa_wage_limit     OUT NOCOPY     NUMBER,
  p_ss_ee_wage_limit    OUT NOCOPY     NUMBER,
  p_ss_er_wage_limit    OUT NOCOPY     NUMBER,
  p_sdi_ee_wage_limit   OUT NOCOPY     NUMBER,
  p_sdi1_ee_wage_limit   OUT NOCOPY     NUMBER,
  p_sdi_er_wage_limit   OUT NOCOPY     NUMBER,
  p_sui_ee_wage_limit   OUT NOCOPY     NUMBER,
  p_sui_er_wage_limit   OUT NOCOPY     NUMBER) IS

  c_proc        VARCHAR2(100) := 'fetch_wage_limits';

  l_futa_wage_limit   NUMBER;
  l_ss_ee_wage_limit  NUMBER;
  l_ss_er_wage_limit  NUMBER;
  l_sdi_ee_wage_limit NUMBER;
  l_sdi1_ee_wage_limit NUMBER;
  l_sdi_er_wage_limit NUMBER;
  l_sui_ee_wage_limit NUMBER;
  l_sui_er_wage_limit NUMBER;


  CURSOR csr_get_fed_wage_limits(v_effective_date DATE) IS
    SELECT  ftax.futa_wage_limit,
            ftax.ss_ee_wage_limit,
            ftax.ss_er_wage_limit
    FROM    PAY_US_FEDERAL_TAX_INFO_F ftax
    WHERE   v_effective_date BETWEEN ftax.effective_start_date
                                 AND ftax.effective_end_date
      AND ftax.fed_information_category = '401K LIMITS';


  CURSOR csr_get_state_wage_limits(v_effective_date DATE,
                                   v_state_abbrev VARCHAR2) IS
    SELECT  ti.sdi_ee_wage_limit,
            ti.sdi_er_wage_limit,
            ti.sui_ee_wage_limit,
            ti.sui_er_wage_limit,
            ti.STA_INFORMATION21
    FROM    PAY_US_STATES st,
            PAY_US_STATE_TAX_INFO_F ti
    WHERE   v_effective_date BETWEEN
                    ti.effective_start_date AND ti.effective_end_date
    and     st.state_code =
                           ti.state_code
    and     st.state_abbrev = v_state_abbrev
    ;



BEGIN
  /*
  ** fetch state level wage limits,
  ** not all states have sdi/sui ee/er wage limits,
  ** therefore do not check for success
  */
  OPEN csr_get_state_wage_limits(p_effective_date, p_state_abbrev);
  FETCH csr_get_state_wage_limits INTO
    l_sdi_ee_wage_limit,
    l_sdi_er_wage_limit,
    l_sui_ee_wage_limit,
    l_sui_er_wage_limit,
    l_sdi1_ee_wage_limit;
  CLOSE csr_get_state_wage_limits;



  /*
  ** fetch federal level wage limits
  */
  OPEN csr_get_fed_wage_limits(p_effective_date);
  FETCH csr_get_fed_wage_limits INTO
      l_futa_wage_limit,
      l_ss_ee_wage_limit,
      l_ss_er_wage_limit;
  CLOSE csr_get_fed_wage_limits;


  /*
  ** always expect federal level wage limits,
  ** if fetch failed then error, inform user
  */
  /** stub - find an apppriate error message **/
  IF (l_futa_wage_limit IS NULL OR
      l_ss_ee_wage_limit IS NULL OR
      l_ss_er_wage_limit IS NULL) THEN
    hr_utility.set_location(c_proc, 10);
    hr_utility.set_message(801, 'PY_50014_TXADJ_IV_ID_NOT_FOUND');
    hr_utility.raise_error;
  END IF;


  /*
  ** copy limits INTO return parameters
  */
  p_futa_wage_limit  := l_futa_wage_limit;
  p_ss_ee_wage_limit := l_ss_ee_wage_limit;
  p_ss_er_wage_limit := l_ss_er_wage_limit;
  p_sdi_ee_wage_limit := l_sdi_ee_wage_limit;
  p_sdi1_ee_wage_limit := l_sdi1_ee_wage_limit;
  p_sdi_er_wage_limit := l_sdi_er_wage_limit;
  p_sui_ee_wage_limit := l_sui_ee_wage_limit;
  p_sui_er_wage_limit := l_sui_er_wage_limit;

END fetch_wage_limits;


/* NOTE:  Though the code still resides here for MEDICARE EE and
   MEDICARE ER we will not call the process_limits procedure for
   those elements
*/

PROCEDURE process_limits(
  p_element_type        IN      VARCHAR2,
  p_earn_amount         IN      NUMBER,
  p_iv_tbl              IN      Hr_Entry.number_table,
  p_iv_names_tbl        IN      Hr_Entry.varchar2_table,
  p_ev_tbl              IN OUT NOCOPY  Hr_Entry.varchar2_table,
  p_num_ev              IN      NUMBER,
  p_assignment_id       IN      NUMBER,
  p_jurisdiction        IN      VARCHAR2,
  p_tax_unit_id         IN      VARCHAR2,
  p_adjustment_date     IN      DATE) IS

  c_proc         VARCHAR2(100) := 'process_limits';

  l_return_bal       VARCHAR2(30);
  l_adj_amt          NUMBER;
  l_excess           NUMBER;
  l_taxable_iv_pos   NUMBER := 0;
  l_old_taxable_bal  NUMBER;
  l_limit            NUMBER;
  l_asg_type         VARCHAR2(6) := 'PER';

  l_virtual_adjustment_date date;
  l_limit_subject_bal number:=0;
BEGIN

   FOR l_i IN 1..(p_num_ev - 1) LOOP
     FOR l_j IN 1..1000 LOOP
       NULL;
     END LOOP;
   END LOOP;

  /*
  ** find position of TAXABLE IV in tbl structure
  */
  FOR l_i IN 1..(p_num_ev - 1) LOOP
    if p_element_type = 'SDI1_EE' THEN
        IF (p_iv_names_tbl(l_i) = 'Taxable') THEN
          l_taxable_iv_pos := l_i;
        END IF;
    else
        IF (p_iv_names_tbl(l_i) = 'TAXABLE') THEN
          l_taxable_iv_pos := l_i;
        END IF;
    end if;
  END LOOP;

  /*
  ** set up taxable balance and limit for limit processing
  */

  /* Rmonge 17-NOV-2001                                             */
  /* For each IF statment to get the taxable balance, I have added
     a call to PAY_US_TAX_BALS_PKG.US_TAX_BALANCE. The package is going to
     return the Adjusted Subject To Tax Balance for the element being
     processed.
*/
/*   TCLEWIS 02-25-2002
     In our fetches of reduced_subj_whable we must fetch the balance as of
     the end of the year.
*/

l_virtual_adjustment_date := add_months(trunc(p_adjustment_date,'Y'),12) -1;
/*l_virtual_adjustment_date for bug 4721086*/

  IF (p_element_type = 'Medicare_EE') THEN
    l_old_taxable_bal := g_medicare_ee_taxable;
    /*
    ** Medicare EE and ER should have an infinite limit,
    ** at a later stage a legislative limit may be defined,
    ** therefore set to an arbitary value (99,999,999),
    ** as used in PAY_US_STATE_TAX_INFO_F for NY
    */
    l_limit := 99999999;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'MEDICARE',
                        p_ee_or_er              => 'EE',
                        p_time_type             => 'YTD',
                        p_asg_type              => l_asg_type,
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'Medicare_ER') THEN
    l_old_taxable_bal := g_medicare_er_taxable;
    l_limit := 99999999;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'MEDICARE',
                        p_ee_or_er              => 'ER',
                        p_time_type             => 'YTD',
                        p_asg_type              => l_asg_type,
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'FUTA') THEN

    l_old_taxable_bal := g_futa_taxable;

    l_limit := g_futa_wage_limit;
    if g_tax_group <> 'NOT_ENTERED' Then
       l_asg_type := 'PER';
--       l_asg_type := 'PER_TG';
    else
       l_asg_type := 'PER';
    end if;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'FUTA',
                        p_ee_or_er              => 'ER',
                        p_time_type             => 'YTD',
                        p_asg_type              => l_asg_type,
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'SS_EE') THEN
    l_old_taxable_bal := g_ss_ee_taxable;
    l_limit := g_ss_ee_wage_limit;

    if g_tax_group <> 'NOT_ENTERED' Then
      l_asg_type := 'PER';
--       l_asg_type := 'PER_TG';
    else
       l_asg_type := 'PER';
    end if;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'SS',
                        p_ee_or_er              => 'EE',
                        p_time_type             => 'YTD',
                        p_asg_type              => l_asg_type,
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'SS_ER') THEN
    l_old_taxable_bal := g_ss_er_taxable;
    l_limit := g_ss_er_wage_limit;

    if g_tax_group <> 'NOT_ENTERED' Then
       l_asg_type := 'PER';
--       l_asg_type := 'PER_TG';
    else
       l_asg_type := 'PER';
    end if;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'SS',
                        p_ee_or_er              => 'ER',
                        p_time_type             => 'YTD',
                        p_asg_type              => l_asg_type,
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'SDI_EE') THEN
    l_old_taxable_bal := g_sdi_ee_taxable;
    l_limit := g_sdi_ee_wage_limit;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'SDI',
                        p_ee_or_er              => 'EE',
                        p_time_type             => 'YTD',
                        p_asg_type              => 'PER',
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'SDI1_EE') THEN
    l_old_taxable_bal := g_sdi1_ee_taxable;
    l_limit := g_sdi1_ee_wage_limit;

-- USE SDI EE Reduced Subject Whable as we don't have a subject balance for SDI1

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'SDI',
                        p_ee_or_er              => 'EE',
                        p_time_type             => 'YTD',
                        p_asg_type              => 'PER',
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);

  ELSIF (p_element_type = 'SDI_ER') THEN
    l_old_taxable_bal := g_sdi_er_taxable;
    l_limit := g_sdi_er_wage_limit;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'SDI',
                        p_ee_or_er              => 'ER',
                        p_time_type             => 'YTD',
                        p_asg_type              => 'PER',
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'SUI_EE') THEN
    l_old_taxable_bal := g_sui_ee_taxable;
    l_limit := g_sui_ee_wage_limit;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'SUI',
                        p_ee_or_er              => 'EE',
                        p_time_type             => 'YTD',
                        p_asg_type              => 'PER',
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701

  ELSIF (p_element_type = 'SUI_ER') THEN
    l_old_taxable_bal := g_sui_er_taxable;
    l_limit := g_sui_er_wage_limit;

    l_limit_subject_bal:=  pay_us_tax_bals_pkg.us_tax_balance(
                        p_tax_balance_category  => 'REDUCED_SUBJ_WHABLE',
                        p_tax_type              => 'SUI',
                        p_ee_or_er              => 'ER',
                        p_time_type             => 'YTD',
                        p_asg_type              => 'PER',
                        p_gre_id_context        => p_tax_unit_id,
                        p_jd_context            => p_jurisdiction,
                        p_assignment_action_id  => NULL,
                        p_assignment_id         => p_assignment_id,
                        p_virtual_date          => l_virtual_adjustment_date);   --Bug3697701
  ELSE
    /** stub - find appropriate message **/
    hr_utility.set_location(c_proc, 10);
    hr_utility.set_message(801, 'PY_50014_TXADJ_IV_ID_NOT_FOUND');
    hr_utility.raise_error;

  END IF;


  /*
  ** generic block, applies to all limit processing
  ** Excess is never passed or adjusted as it is a derived balance
  */

hr_utility.trace('P_earn_amount='||to_char(p_earn_amount));
hr_utility.trace('subject balance = ' || to_char(l_limit_subject_bal));

  IF ((l_old_taxable_bal + p_earn_amount) <= l_limit) THEN

  /*
    ** no limit exceeded,
    ** ok to make the balance adjustment,
    ** do nothing with EV amount of TAXABLE IV
    */
/* Rosie Monge 14-NOV-2001                                             */

      /* if the p_earn_amount (adjustment amount made ) is Negative
         we need to account for 3 different possibilities.
         1) Subject Taxable Balance is grater than the limit (7000)
            In this scenario, The balance after the Adjustment is made
            is grater than the Limit, so it is not necessary to adjust
            the amount, because it is at its maximun already.

         2) Subject Taxable Balance is between the limit (0 -7000)
            If the Adjusted Subject Balance is between the limit, then,
            it is necessary to calculate how much the adjustment will be.
            This amount is the Limit_Subject_Balance - limit (7000).
         3) Subject Taxable Balance is Negative (less than 0).
            If the Subject Taxable Balance is Negative, then, we have to
            substract the entire balance, so that we make it 0.
      */

      /* note the limit subject balance has already been adjusted for
         the gross earnings element has been processed.
      */


      if p_earn_amount < 0 then -- negative adjustment reguires special
                                -- attentions.

           if ( l_limit_subject_bal  ) >=  l_limit then

                l_adj_amt := 0;

           elsif (l_limit_subject_bal ) >= 0 and
                 (l_limit_subject_bal )  < l_limit  then


                 if (l_limit_subject_bal - p_earn_amount) <> l_old_taxable_bal then

                    if (l_limit_subject_bal - p_earn_amount) < l_limit then
                    /* subject balance is below the limit and not = to taxable
                       make adjustment on the taxable balance and ignore the
                       subject balance
                    */
                       if l_old_taxable_bal - l_adj_amt < 0 then
                          /* if the amount of the adjustment is greater that taxbale
                             the adjust taxable to 0
                          */
                          l_adj_amt := l_old_taxable_bal * -1;
                       else
                         /* The taxable balance + the adjustment (which is negative)
                            will not = 0, to take full amount of the adjustment
                         */
                          l_adj_amt := p_earn_amount;
                       end if;
                    else
                    /* subject is over the limit so adjust taxable based on subject
                       balance
                    */
                       l_adj_amt := (l_limit_subject_bal ) - l_limit;

                       /* check to make sure that the adjustment amount will
                          not cause taxable to go negative.  If this occurs
                          then adjust taxable to 0 (zero)
                       */
                       if l_old_taxable_bal - l_adj_amt < 0 then
                          /* if the amount of the adjustment is greater that taxbale
                             the adjust taxable to 0
                          */
                          l_adj_amt := l_old_taxable_bal * -1;
                       end if;
                    end if;
                 else
                 /* is subject is below the limit then the adjustment should be ok
                 */

                    l_adj_amt := p_earn_amount;

                 end if;

           elsif (l_limit_subject_bal < 0 ) then

                  l_adj_amt := l_old_taxable_bal * -1;

           end if;
           p_ev_tbl(l_taxable_iv_pos) :=
                  fnd_number.number_to_canonical(l_adj_amt);

     end if;

  ELSIF ((l_old_taxable_bal > l_limit) or
         ((l_old_taxable_bal + p_earn_amount) < 0 )) THEN

    /*
    ** taxable balance already exceeds limit or if sum of old and
    ** adj amount is -ve, set EV amount of TAXABLE IV to 0,
    ** therefore the EV amount feeds Excess
    ** put EV amount of TAXABLE IV INTO excess
    */
    p_ev_tbl(l_taxable_iv_pos) := 0;

  ELSIF (l_old_taxable_bal + p_earn_amount > l_limit) THEN
    /*
    ** EV amount of TAXABLE IV will cause limit to be exceeded,
    ** set EV amount up to limit
    */

   hr_utility.trace('in the elsif l_old_tax_amount + p_earn_amount > 0');

    l_adj_amt := l_limit - l_old_taxable_bal;
hr_utility.trace('l_adj_amt = '||to_char(l_adj_amt));

    l_excess := (p_earn_amount + l_old_taxable_bal) - l_limit;
hr_utility.trace('l_excess ='|| to_char(l_excess));
    /*
    ** modify EV amount of TAXABLE IV before BA processing,
    ** set EV amount up to limit, remainder goes INTO excess
    */
    p_ev_tbl(l_taxable_iv_pos) := fnd_number.number_to_canonical(l_adj_amt);

  END IF;

END process_limits;



PROCEDURE process_element(
  p_assignment_id        IN     NUMBER,
  p_consolidation_set_id IN     NUMBER,
  p_element_type         IN     VARCHAR2,
  p_abbrev_element_type  IN     VARCHAR2,
  p_bg_id                IN     NUMBER,
  p_adjustment_date      IN     DATE,
  p_earn_amount          IN     NUMBER,
  p_adj_amount           IN     NUMBER,
  p_jurisdiction         IN     VARCHAR2,
  p_payroll_action_id    IN     NUMBER,
  p_tax_unit_id          IN     VARCHAR2,
  p_balance_adj_costing_flag                 IN     VARCHAR2
) IS

  c_proc                  VARCHAR2(100)   := 'process_element';

  -- p_abbrev_element_type - shorter name for the element,
  --                         used to ensure that the group key for all the adjustments
  --                         does not exceed 240 chars (assuming that the
  --                         length of payroll_action_id <= 7
  -- p_earn_amount         - gross earnings. i.e. p_gross_amount
  -- p_adj_amount          - amount of the tax withheld
  -- p_jurisdiction        - jd where the tax was withheld

  CURSOR   csr_element IS
    SELECT e.element_type_id,
           c.classification_name,
           e.element_information_category earnings_lookup_type,
           e.classification_id,
           e.element_information1         earnings_category
      FROM PAY_ELEMENT_CLASSIFICATIONS    c,
           PAY_ELEMENT_TYPES_F            e,
           hr_organization_information    hoi
     WHERE e.element_name         = p_element_type
       AND (e.business_group_id   = p_bg_id
              OR e.business_group_id IS NULL
           )
       AND e.classification_id    = c.classification_id
       AND p_adjustment_date BETWEEN
                e.effective_start_date AND e.effective_end_date
       AND hoi.organization_id = p_bg_id
       AND hoi.org_information_context = 'Business Group Information'
       AND c.legislation_code = hoi.org_information9
    ;

  CURSOR    csr_set_mandatory_inputs (v_element_type_id NUMBER) IS
    SELECT  i.name INPUT_NAME,
            i.input_value_id,
            NVL(hr.meaning, NVL(i.default_value,
               DECODE(i.uom,
                  'I',            '0',
                  'M',            '0',
                  'N',            '0',
                  'T',            '0',
                  'C',            'Unknown - US_TAX_BAL_ADJ',
                  'H_DECIMAL1',   '0.0',
                  'H_DECIMAL2',   '0.00',
                  'H_DECIMAL3',   '0.000',
                  'H_HH',         '12',
                  'H_HHMM',       '12:00',
                  'H_HHMMSS',     '12:00:00',
	          'D',            fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_adjustment_date)),
                  'ND',           To_Char(p_adjustment_date, 'Day')))
          ) default_value
     FROM   HR_LOOKUPS            hr,
            PAY_INPUT_VALUES_F    i
    WHERE   i.element_type_id     = v_element_type_id
      AND   i.mandatory_flag      = 'Y'
      AND   i.default_value       = hr.lookup_code (+)
      AND   i.lookup_type         = hr.lookup_type (+)
      AND   i.name NOT IN ('Pay Value')
    ;

  l_iv_tbl                hr_entry.number_table;
  l_iv_names_tbl          hr_entry.varchar2_table;
  l_ev_tbl                hr_entry.varchar2_table;
  l_num_ev                NUMBER;
  l_element               csr_element%ROWTYPE;
  l_ele_link_id           NUMBER;
  l_counter               NUMBER;
  l_payroll_action_id     NUMBER;

BEGIN

  hr_utility.trace('IN Process_element Element_type ='||p_element_type);
  HR_Utility.trace('Abbrev Element Type ='||p_abbrev_element_type);

  hr_utility.set_location(c_proc, 10);
  OPEN csr_element;
  FETCH csr_element INTO l_element;
  CLOSE csr_element;

  IF (l_element.element_type_id IS NULL) THEN
    hr_utility.set_location(c_proc, 20);
    hr_utility.set_message(801, 'HR_6884_ELE_ENTRY_NO_ELEMENT');
    hr_utility.raise_error;
  END IF;

  hr_utility.set_location(c_proc, 30);
  l_ele_link_id := hr_entry_api.get_link(
                        p_assignment_id   => p_assignment_id,
                        p_element_type_id => l_element.element_type_id,
                        p_session_date    => p_adjustment_date);

  IF (l_ele_link_id IS NULL) THEN
    hr_utility.set_location(c_proc, 40);
    hr_utility.set_message(801, 'PY_51132_TXADJ_LINK_MISSING');
    hr_utility.set_message_token ('ELEMENT', p_element_type);
    hr_utility.raise_error;
  END IF;

  -- initialize tables
  l_iv_names_tbl := g_dummy_varchar_tbl;
  l_iv_tbl       := g_dummy_number_tbl;
  l_ev_tbl       := g_dummy_varchar_tbl;
  l_num_ev       := 1;

  -- explicitly set the various input values,
  -- this clearly identifies which input values are expected and will cause failure
  -- if the input value has been deleted somehow
  hr_utility.set_location(c_proc, 50);

  IF (l_element.classification_name IN ('Earnings', 'Imputed Earnings',
                                        'Supplemental Earnings')) THEN
    -- element is an Earnings element,
    -- populate the global tables to be used later for taxability checking for
    -- subject withholdable, not-withholdable input values of tax balance elements
    g_classification_id    := l_element.classification_id;
    g_earnings_category    := l_element.earnings_category;
    g_classification       := l_element.classification_name;

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_earn_amount),          l_num_ev);

  ELSIF (p_element_type IN ('FIT')) THEN
    hr_utility.set_location (c_proc, 60);
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);

    IF (g_classification = 'Supplemental Earnings') THEN
      process_input(p_element_type, l_element.element_type_id,
                    l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                    p_bg_id,        p_adjustment_date,
                    'Supp Tax',     fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    END IF;
-- 4188782
  ELSIF (p_element_type IN ('FSP_SUBJECT')) THEN
     hr_utility.set_location (c_proc, 62);
     process_input(p_element_type, l_element.element_type_id,
                   l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                   p_bg_id,        p_adjustment_date,
                   'Reduced Subj Whable',
     fnd_number.number_to_canonical(p_earn_amount),  l_num_ev);

  ELSIF (p_element_type IN ('FIT 3rd Party')) THEN
    hr_utility.set_location (c_proc, 65);
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);

  ELSIF (p_element_type IN ('SS_EE', 'Medicare_EE')) THEN
    hr_utility.set_location(c_proc, 71);
    IF (p_adj_amount <> 0) THEN
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    END IF;

    hr_utility.set_location(c_proc, 72);
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'TAXABLE',      fnd_number.number_to_canonical(p_earn_amount), l_num_ev);

    /*
    ** cap the EV amount for the TAXABLE IV if necessary
    */

    /* MEDICARE EE has no limit */
    IF p_element_type = 'SS_EE' THEN
       process_limits(p_element_type, p_earn_amount, l_iv_tbl,
                   l_iv_names_tbl, l_ev_tbl, l_num_ev,p_assignment_id,
                   p_jurisdiction,p_tax_unit_id,p_adjustment_date);
    END IF;


-- SD1
  ELSIF (p_element_type IN ('Medicare_ER', 'SS_ER', 'FUTA')) THEN
/** sbilling **/
    /*
    ** only if processing Medicare_ER, SS_ER or FUTA, the Pay Value should be set
    ** to the corresponding field on the TBA form (Medicare, FUTA_ER or SS),
    */
    IF (p_adj_amount <> 0) THEN
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    END IF;

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'TAXABLE',      fnd_number.number_to_canonical(p_earn_amount), l_num_ev);

    /*
    ** cap the EV amount for the TAXABLE IV if necessary
    */

    /* MEDICARE EE has no limit */
    IF (p_element_type IN ( 'SS_ER', 'FUTA')) THEN
       process_limits(p_element_type, p_earn_amount, l_iv_tbl,
                      l_iv_names_tbl, l_ev_tbl, l_num_ev,p_assignment_id,
                      p_jurisdiction,p_tax_unit_id,p_adjustment_date);
    END IF;

  ELSIF (p_element_type IN ('SIT_WK')) THEN
    hr_utility.set_location(c_proc, 81);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    hr_utility.set_location(c_proc, 82);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);

    IF (g_classification = 'Supplemental Earnings') THEN
      process_input(p_element_type, l_element.element_type_id,
                    l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                    p_bg_id,        p_adjustment_date,
                    'Supp Tax',     fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    END IF;

   ELSIF (p_element_type IN ('SIT_WK_NON_AGGREGATE_RED_SUBJ_WHABLE')) THEN
      hr_utility.set_location (c_proc, 84);
      process_input(p_element_type, l_element.element_type_id,
                    l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                    p_bg_id,        p_adjustment_date,
                    'SuppGross',
      fnd_number.number_to_canonical(p_earn_amount),  l_num_ev);

      process_input(p_element_type, l_element.element_type_id,
                   l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                   p_bg_id,        p_adjustment_date,
                   'Jurisdiction', p_jurisdiction,         l_num_ev);

   ELSIF (p_element_type IN ('FIT_NON_AGGREGATE_RED_SUBJ_WHABLE')) THEN
      hr_utility.set_location (c_proc, 84);
      process_input(p_element_type, l_element.element_type_id,
                    l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                    p_bg_id,        p_adjustment_date,
                    'SuppGross',
      fnd_number.number_to_canonical(p_earn_amount),  l_num_ev);

/** sbilling **/
  /*
  ** new tax element to be processed, use SIT_WK as a template
  */
  ELSIF (p_element_type IN ('County_SC_WK')) THEN
    hr_utility.set_location(c_proc, 86);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    hr_utility.set_location(c_proc, 87);


    /*
    ** can't put the Gross for the BA INTO the Gross for the school district tax,
    ** County_SC_WK has no TAXABLE input
    */
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);

  ELSIF (p_element_type IN ('SUI_EE', 'SDI_EE', 'SDI1_EE')) THEN
    hr_utility.set_location(c_proc, 91);

    IF (p_adj_amount <> 0) THEN
      process_input(p_element_type, l_element.element_type_id,
                    l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                    p_bg_id,        p_adjustment_date,
                    'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
      hr_utility.set_location(c_proc, 915);
    END IF;

    hr_utility.set_location(c_proc, 92);

    if p_element_type = 'SDI1_EE' then
        process_input(p_element_type, l_element.element_type_id,
                      l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                      p_bg_id,        p_adjustment_date,
                      'Taxable',
fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    else
        process_input(p_element_type, l_element.element_type_id,
                      l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                      p_bg_id,        p_adjustment_date,
                      'TAXABLE',
fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    end if;


    hr_utility.set_location(c_proc, 93);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);

    /*
    ** cap the EV amount for the TAXABLE EV if necessary
    */
    process_limits(p_element_type, p_earn_amount, l_iv_tbl,
                   l_iv_names_tbl, l_ev_tbl, l_num_ev,p_assignment_id,
                   p_jurisdiction,p_tax_unit_id,p_adjustment_date);

  ELSIF (p_element_type IN ('City_WK', 'County_WK')) THEN
    hr_utility.set_location(c_proc, 101);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    hr_utility.set_location(c_proc, 102);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);

  ELSIF (p_element_type IN ('SIT_SUBJECT_WK', 'City_SUBJECT_WK',
                            'County_SUBJECT_WK', 'School_SUBJECT_WK')) THEN
    hr_utility.set_location(c_proc, 111);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);
    hr_utility.set_location(c_proc, 112);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Gross',        fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    hr_utility.set_location(c_proc, 113);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Subj Whable',  fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    hr_utility.set_location(c_proc, 114);

    IF (g_classification IN ('Imputed Earnings',
                             'Supplemental Earnings')) THEN
      hr_utility.set_location(c_proc, 115);

      process_input (p_element_type, l_element.element_type_id,
                     l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                     p_bg_id,        p_adjustment_date,
                     'Subj NWhable', fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    END IF;

  ELSIF (p_element_type IN ('SDI_SUBJECT_EE', 'SDI_SUBJECT_ER',
                            'SUI_SUBJECT_EE', 'SUI_SUBJECT_ER')) THEN
    hr_utility.set_location(c_proc, 121);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);
    hr_utility.set_location(c_proc, 122);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Gross',        fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    hr_utility.set_location(c_proc, 123);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Subj Whable',  fnd_number.number_to_canonical(p_earn_amount), l_num_ev);

  ELSIF (p_element_type IN ('SUI_ER', 'SDI_ER')) THEN
    hr_utility.set_location (c_proc, 124);


/** sbilling **/
    /*
    ** for SUI_ER and SDI_ER set the amount to be paid for tax equal
    ** to the amount entered on the corresponding ER field
    */
  IF (p_adj_amount <> 0) THEN
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
  END IF;

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'TAXABLE',      fnd_number.number_to_canonical(p_earn_amount), l_num_ev);

    /*
    ** cap the EV amount for the TAXABLE IV if necessary
    */
    process_limits(p_element_type, p_earn_amount, l_iv_tbl,
                   l_iv_names_tbl, l_ev_tbl, l_num_ev,p_assignment_id,
                   p_jurisdiction,p_tax_unit_id,p_adjustment_date);
  END IF;

  -- because process_input will increment l_num_ev if it is successful
  l_num_ev := l_num_ev - 1;


  -- set mandatory input values,
  -- cannot set these to NULL, core package expects mandatory values to be entered
  hr_utility.set_location(c_proc, 130);

  FOR l_req_input IN csr_set_mandatory_inputs (l_element.element_type_id) LOOP
    -- first, check if the mandatory input value was explicitly
    -- set above,  do nothing in this case
    hr_utility.set_location(c_proc, 140);

    FOR l_counter IN 1..l_num_ev LOOP

       IF (l_req_input.input_name = l_iv_names_tbl(l_counter)) THEN
          NULL;
       ELSE
          -- then the input value was not previously set by one of the
          -- process_inputs called in process_elements
          hr_utility.set_location(c_proc, 150);
          l_num_ev := l_num_ev + 1;

          l_iv_tbl(l_num_ev)            := l_req_input.input_value_id;
          l_iv_names_tbl(l_num_ev)      := l_req_input.input_name;
          l_ev_tbl(l_num_ev)            := l_req_input.default_value;
       END IF;

    END LOOP;
  END LOOP;

  hr_utility.set_location(c_proc, 160);

  pay_bal_adjust.adjust_balance(p_batch_id              => p_payroll_action_id,
                                p_assignment_id         => p_assignment_id,
                                p_element_link_id       => l_ele_link_id,
                                p_num_entry_values      => l_num_ev,
                                p_entry_value_tbl       => l_ev_tbl,
                                p_input_value_id_tbl    => l_iv_tbl,
                                p_balance_adj_cost_flag => p_balance_adj_costing_flag);

END process_element;


FUNCTION derive_jd_geocode(
  p_assignment_id IN NUMBER,
  p_state_abbrev  IN VARCHAR2 DEFAULT NULL,
  p_county_name   IN VARCHAR2 DEFAULT NULL,
  p_city_name     IN VARCHAR2 DEFAULT NULL,
  p_zip_code      IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS

  c_proc          VARCHAR2(100)   := 'derive_jd_geocode';

  CURSOR csr_state_code IS
    SELECT  state_code
    FROM    PAY_US_STATES
    WHERE   state_abbrev = p_state_abbrev
    ;

  CURSOR csr_county_code IS
    SELECT  cn.state_code,
            cn.county_code
    FROM    PAY_US_COUNTIES         cn,
            PAY_US_STATES           s
    WHERE   cn.county_name          = p_county_name
    and     cn.state_code           = s.state_code
    and     s.state_abbrev          = p_state_abbrev
    ;


  -- cursors to compare the location provided with the location of
  -- the employee's assignment
  CURSOR csr_chk_state IS
    SELECT 'PASS'
    FROM    PAY_US_EMP_STATE_TAX_RULES st,
	    PAY_US_STATES pus
    WHERE   st.assignment_id        = p_assignment_id
    and     st.state_code           = pus.state_code
    and	    pus.state_abbrev        = p_state_abbrev
    ;

  CURSOR csr_chk_local (x_jd VARCHAR2) IS
    SELECT 'PASS'
    FROM    PAY_US_EMP_CITY_TAX_RULES
    WHERE   assignment_id           = p_assignment_id
    and     jurisdiction_code       = x_jd
    UNION
    SELECT 'PASS'
    FROM    PAY_US_EMP_COUNTY_TAX_RULES
    WHERE   assignment_id           = p_assignment_id
    and     jurisdiction_code       = x_jd
    ;

  l_geocode       VARCHAR2(11)    := '00-000-0000';
  l_county_code   VARCHAR2(4)     := '000'        ;
  l_state_code    VARCHAR2(2)     := '00'         ;
  l_valid_for_asg VARCHAR2(4)     := 'FAIL'       ;

BEGIN

  IF (p_city_name IS NOT NULL AND p_zip_code IS NOT NULL) THEN
    hr_utility.set_location(c_proc, 10);
    l_geocode := hr_us_ff_udfs.addr_val(
                p_state_abbrev => p_state_abbrev,
                p_county_name  => p_county_name,
                p_city_name    => p_city_name,
                p_zip_code     => p_zip_code );

    OPEN csr_chk_local(l_geocode);
    FETCH csr_chk_local INTO l_valid_for_asg;
    CLOSE csr_chk_local;

    IF (l_valid_for_asg = 'FAIL') THEN
      hr_utility.set_location(c_proc, 15);
      hr_utility.set_message(801, 'PY_51133_TXADJ_INVALID_CITY');
      hr_utility.raise_error;
    END IF;

  ELSIF (p_county_name IS NOT NULL AND p_state_abbrev IS NOT NULL) THEN
    hr_utility.set_location(c_proc, 20);
    OPEN csr_county_code;
    FETCH csr_county_code INTO l_state_code, l_county_code;
    CLOSE csr_county_code;
    l_geocode := l_state_code||'-'||l_county_code||'-0000';

    OPEN csr_chk_local(l_geocode);
    FETCH csr_chk_local INTO l_valid_for_asg;
    CLOSE csr_chk_local;

    IF (l_valid_for_asg = 'FAIL') THEN
      hr_utility.set_location(c_proc, 25);
      hr_utility.set_message(801, 'PY_51133_TXADJ_INVALID_CITY');
      hr_utility.raise_error;
    END IF;

  ELSIF (p_county_name IS NULL AND p_state_abbrev IS NOT NULL) THEN
    hr_utility.set_location(c_proc, 30);
    OPEN csr_state_code;
    FETCH csr_state_code INTO l_state_code;
    CLOSE csr_state_code;
    l_geocode := l_state_code||'-000-0000';

    OPEN csr_chk_state;
    FETCH csr_chk_state INTO l_valid_for_asg;
    CLOSE csr_chk_state;

    IF (l_valid_for_asg = 'FAIL') THEN
      hr_utility.set_location(c_proc, 25);
      hr_utility.set_message(801, 'PY_51133_TXADJ_INVALID_CITY');
      hr_utility.raise_error;
    END IF;

  ELSE
    l_geocode := '00-000-0000';

  END IF;

  Return (l_geocode);

END derive_jd_geocode;



FUNCTION taxable_balance(
  p_tax_bal_name        IN      VARCHAR2,
  p_ee_or_er            IN      VARCHAR2,
  p_tax_unit_id         IN      NUMBER,
  p_assignment_id       IN      NUMBER,
  p_adjustment_date     IN      DATE,
  p_geocode             IN      VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS

  c_proc          VARCHAR2(100)   := 'taxable_balance';

  l_return_bal       NUMBER;
  l_date	     DATE;
  l_asg_type         VARCHAR2(6);


  CURSOR  csr_get_endofyear IS
    SELECT to_date('31/12/' || TO_CHAR(p_adjustment_date, 'YYYY'), 'DD/MM/YYYY')
    FROM   SYS.DUAL
    ;

BEGIN
  /*
  ** find current balance for tax,
  ** assignment_id is used to find balance specific to a person,
  ** when calculating the adjustment amount up to the limit,
  ** the old TAXABLE balance is required
  */

  /*
  ** fetch last day of year, require end of year balance, not date effective balance
  */
  OPEN csr_get_endofyear;
  FETCH csr_get_endofyear INTO l_date;
  CLOSE csr_get_endofyear;

  IF g_tax_group <> 'NOT_ENTERED' and
     ( p_tax_bal_name = 'FUTA' or
       p_tax_bal_name = 'SS' )         THEN
     l_asg_type := 'PER';
--     l_asg_type := 'PER_TG';
  ELSE
     l_asg_type := 'PER';
  END IF;

  l_return_bal := pay_us_tax_bals_pkg.us_tax_balance(
			p_tax_balance_category => 'TAXABLE',
			p_tax_type             => p_tax_bal_name,
			p_ee_or_er             => p_ee_or_er,
			p_time_type            => 'YTD',
			p_asg_type             => l_asg_type,
			p_gre_id_context       => p_tax_unit_id,
			p_jd_context           => p_geocode,
			p_assignment_action_id => NULL,
			p_assignment_id        => p_assignment_id,
			p_virtual_date         => l_date);

  Return(l_return_bal);

END taxable_balance;



FUNCTION tax_exists (p_jd_code VARCHAR2, p_tax_type VARCHAR2,
                     p_adj_date DATE)
RETURN VARCHAR2 IS

   l_exists        VARCHAR2(1) := 'N';

   CURSOR sdi_er_exists IS
     SELECT 'Y'
       FROM pay_us_state_tax_info_f
      WHERE state_code = SUBSTR(p_jd_code, 1, 2)
        AND sdi_er_wage_limit IS NOT NULL
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR sdi_ee_exists IS
     SELECT 'Y'
       FROM pay_us_state_tax_info_f
      WHERE state_code = SUBSTR(p_jd_code, 1, 2)
        AND sdi_ee_wage_limit IS NOT NULL
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR sdi1_ee_exists IS
     SELECT 'Y'
       FROM pay_us_state_tax_info_f
      WHERE state_code = SUBSTR(p_jd_code, 1, 2)
        AND STA_INFORMATION21 IS NOT NULL
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR sui_er_exists is
     SELECT 'Y'
       FROM pay_us_state_tax_info_f
      WHERE state_code = substr(p_jd_code, 1, 2)
        AND sui_er_wage_limit IS NOT NULL
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR sui_ee_exists is
     SELECT 'Y'
       FROM pay_us_state_tax_info_f
      WHERE state_code = substr(p_jd_code, 1, 2)
        AND sui_ee_wage_limit IS NOT NULL
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR sit_exists is
     SELECT sit_exists
       FROM pay_us_state_tax_info_f
      WHERE state_code = substr(p_jd_code, 1, 2)
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR county_exists is
     SELECT county_tax
       FROM pay_us_county_tax_info_f
      WHERE jurisdiction_code = substr(p_jd_code, 1, 7)||'0000'
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR city_exists is
     SELECT city_tax
       FROM pay_us_city_tax_info_f
      WHERE jurisdiction_code = p_jd_code
        AND p_adj_date BETWEEN effective_start_date AND effective_end_date;

BEGIN

   IF (p_tax_type = 'SUI_ER') THEN
     OPEN sui_er_exists;
     FETCH sui_er_exists INTO l_exists;
     CLOSE sui_er_exists;

   ELSIF (p_tax_type = 'SUI_EE') THEN
     OPEN sui_ee_exists;
     FETCH sui_ee_exists INTO l_exists;
     CLOSE sui_ee_exists;

   ELSIF (p_tax_type = 'SDI_ER') THEN
     OPEN sdi_er_exists;
     FETCH sdi_er_exists INTO l_exists;
     CLOSE sdi_er_exists;

   ELSIF (p_tax_type = 'SDI_EE') THEN
     OPEN sdi_ee_exists;
     FETCH sdi_ee_exists INTO l_exists;
     CLOSE sdi_ee_exists;

   ELSIF (p_tax_type = 'SDI1_EE') THEN
     OPEN sdi1_ee_exists;
     FETCH sdi1_ee_exists INTO l_exists;
     CLOSE sdi1_ee_exists;

   ELSIF (p_tax_type = 'SIT') THEN
     OPEN sit_exists;
     FETCH sit_exists INTO l_exists;
     CLOSE sit_exists;

   ELSIF (p_tax_type = 'CITY') THEN
     OPEN city_exists;
     FETCH city_exists INTO l_exists;
     CLOSE city_exists;

   ELSIF (p_tax_type = 'COUNTY') THEN
     OPEN county_exists;
     FETCH county_exists INTO l_exists;
     CLOSE county_exists;

   ELSE
      NULL;
   END IF;

   RETURN l_exists;
END tax_exists;



PROCEDURE create_tax_balance_adjustment(
  p_validate              IN BOOLEAN      DEFAULT FALSE,
  p_adjustment_date       IN DATE,
  p_business_group_name   IN VARCHAR2,
  p_assignment_number     IN VARCHAR2,
  p_tax_unit_id           IN VARCHAR2,
  p_consolidation_set     IN VARCHAR2,
  p_earning_element_type  IN VARCHAR2     DEFAULT NULL,
  p_gross_amount          IN NUMBER       DEFAULT 0,
  p_net_amount            IN NUMBER       DEFAULT 0,
  p_FIT                   IN NUMBER       DEFAULT 0,
  p_FIT_THIRD             IN VARCHAR2     DEFAULT NULL,
  p_SS                    IN NUMBER       DEFAULT 0,
  p_Medicare              IN NUMBER       DEFAULT 0,
  p_SIT                   IN NUMBER       DEFAULT 0,
  p_SUI                   IN NUMBER       DEFAULT 0,
  p_SDI                   IN NUMBER       DEFAULT 0,
  p_SDI1                  IN NUMBER       DEFAULT 0,
  p_County                IN NUMBER       DEFAULT 0,
  p_City                  IN NUMBER       DEFAULT 0,
  p_city_name             IN VARCHAR2     DEFAULT NULL,
  p_state_abbrev          IN VARCHAR2     DEFAULT NULL,
  p_county_name           IN VARCHAR2     DEFAULT NULL,
  p_zip_code              IN VARCHAR2     DEFAULT NULL,
  p_balance_adj_costing_flag                  IN VARCHAR2     DEFAULT NULL,
  p_balance_adj_prepay_flag IN VARCHAR2   DEFAULT 'N',
  p_futa_er               IN NUMBER       DEFAULT 0,
  p_sui_er                IN NUMBER       DEFAULT 0,
  p_sdi_er                IN NUMBER       DEFAULT 0,
  p_sch_dist_wh_ee        IN NUMBER       DEFAULT 0,
  p_sch_dist_jur          IN VARCHAR2     DEFAULT NULL,
  p_payroll_action_id     OUT NOCOPY NUMBER,
  p_create_warning        OUT NOCOPY BOOLEAN)
  IS

  c_proc  VARCHAR2(100) := 'create_tax_balance_adjustment';

  l_bg_id                       NUMBER;
  l_consolidation_set_id        NUMBER;
  l_assignment_id               NUMBER;
  l_payroll_id                  NUMBER;
  l_payroll_action_id           NUMBER;

  l_jd_entered                  VARCHAR2(11) := '00-000-0000';
  l_jd_level_entered            NUMBER       := 1;
  l_jd_level_needed             NUMBER;

  l_primary_asg_state           VARCHAR2(2);
  l_create_warning              BOOLEAN;

  l_counter                     NUMBER;
  l_grp_key                     pay_payroll_actions.legislative_parameters%TYPE;

  l_effective_start_date        DATE;
  l_effective_end_date          DATE;
  l_element_entry_id            NUMBER;
  l_fed_tax_exempt              VARCHAR2(1);
  l_futa_tax_exempt             VARCHAR2(1);
  l_medicare_tax_exempt         VARCHAR2(1);
  l_ss_tax_exempt               VARCHAR2(1);
  l_sit_exempt                  VARCHAR2(1);
  l_sdi_exempt                  VARCHAR2(1);
  l_sdi1_exempt                 VARCHAR2(1);
  l_sui_exempt                  VARCHAR2(1);
  l_cnt_exempt                  VARCHAR2(1);
  l_cnt_sd_exempt               VARCHAR2(1);
  l_cty_exempt                  VARCHAR2(1);
  l_cty_sd_exempt               VARCHAR2(1);

-- Bug 4188782
  l_element_classification varchar2(100);

cursor get_element_details (p_element_type in varchar2,p_bg_id in number) is
    SELECT c.classification_name
      FROM PAY_ELEMENT_CLASSIFICATIONS    c,
           PAY_ELEMENT_TYPES_F            e,
           hr_organization_information    hoi
     WHERE e.classification_id    = c.classification_id
       AND hoi.organization_id = p_bg_id
	   AND e.element_name      = p_element_type
       AND (e.business_group_id   = p_bg_id
              OR e.business_group_id IS NULL)
       AND hoi.org_information_context = 'Business Group Information'
       AND c.legislation_code = hoi.org_information9;
------------------------


  CURSOR csr_sdi_check IS

/*     SELECT region_2              primary_asg_state
     FROM  HR_LOCATIONS          loc,
           PER_ASSIGNMENTS_F      asg,
           PER_BUSINESS_GROUPS    bg
    -- Bug fix 1398865. Ensures one row is returned
     WHERE  asg.assignment_number  = p_assignment_number
     and    asg.business_group_id = bg.business_group_id
     and    bg.name ||''        = p_business_group_name
     and    asg.effective_start_date <= p_adjustment_date
     AND    asg.effective_end_date >= trunc(p_adjustment_date,'Y')
     and    asg.primary_flag      = 'Y'
     and    asg.location_id        = loc.location_id
     and    loc.region_2          = p_state_abbrev;
 */
     SELECT decode(nvl(asg.work_at_home, 'N'),
                  'N' , loc.region_2,
                        addr.region_2)               primary_asg_state
     FROM  HR_LOCATIONS          loc,
           PER_ASSIGNMENTS_F      asg,
           PER_BUSINESS_GROUPS    bg,
           PER_ADDRESSES          addr
    -- Bug fix 1398865. Ensures one row is returned
     WHERE  asg.assignment_number  = p_assignment_number
     and    asg.business_group_id = bg.business_group_id
     and    bg.name ||''        = p_business_group_name
     and    asg.effective_start_date <= p_adjustment_date
     AND    asg.effective_end_date >= trunc(p_adjustment_date,'Y')
     and    asg.primary_flag      = 'Y'
     and    asg.location_id        = loc.location_id
--     and    loc.region_2          = p_state_abbrev,
     and    asg.person_id         = addr.person_id
     and    addr.primary_flag     = 'Y'
     and    p_adjustment_date between addr.date_from and
               nvl(addr.date_to,to_date('31-12-4712','dd-mm-yyyy'));

     CURSOR c_get_tax_group  IS
       select decode(hoi.org_information5,
                       NULL,'NOT_ENTERED',
                       hoi.org_information5)
       from hr_organization_information hoi
       where hoi.organization_id = p_tax_unit_id
       and hoi.org_information_context = 'Federal Tax Rules'
       ;



  CURSOR csr_sui_geocode  IS
    SELECT sui_jurisdiction_code,
           pus.state_abbrev,
           fed.fit_exempt,
           fed.futa_tax_exempt,
           fed.medicare_tax_exempt,
           fed.ss_tax_exempt
    FROM   pay_us_emp_fed_tax_rules_f  fed,
           PER_ASSIGNMENTS_F   a,
           PER_BUSINESS_GROUPS  bg,
           pay_us_states        pus
    WHERE  fed.assignment_id   = a.assignment_id
    and    a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date between fed.effective_start_date
                          and fed.effective_end_date
    and    p_adjustment_date BETWEEN
                  a.effective_start_date and a.effective_end_date
    and    fed.sui_state_code = pus.state_code
    ;

    Cursor c_get_futa_self_adjust_method
    IS
    select hl.meaning
    from hr_organization_information hoi,
         hr_lookups hl
    where hoi.organization_id = p_tax_unit_id
    and   hoi.org_information_context = 'Federal Tax Rules'
    and   hoi.org_information3 = hl.LOOKUP_CODE
    and   hl.lookup_type = 'US_SELF_ADJUST_METHOD';

    Cursor c_get_ss_self_adjust_method
    IS
    select hl.meaning
    from hr_organization_information hoi,
         hr_lookups hl
    where hoi.organization_id = p_tax_unit_id
    and   hoi.org_information_context = 'Federal Tax Rules'
    and   hoi.org_information1 = hl.LOOKUP_CODE
    and   hl.lookup_type = 'US_SELF_ADJUST_METHOD';

    Cursor c_get_medi_self_adjust_method
    IS
    select hl.meaning
    from hr_organization_information hoi,
         hr_lookups hl
    where hoi.organization_id = p_tax_unit_id
    and   hoi.org_information_context = 'Federal Tax Rules'
    and   hoi.org_information2 = hl.LOOKUP_CODE
    and   hl.lookup_type = 'MEDI_SELF_ADJ_CALC_METHOD';

    Cursor c_get_sdi_self_adjust_method
    IS
    select hl.meaning
    from hr_organization_information hoi,
         hr_lookups hl
    where hoi.organization_id = p_tax_unit_id
    and   hoi.org_information_context = 'State Tax Rules'
    and   hoi.org_information1 = p_state_abbrev
    and   hoi.org_information5 = hl.LOOKUP_CODE
    and   hl.lookup_type = 'US_SELF_ADJUST_METHOD';

    Cursor c_get_sdi1_self_adjust_method
    IS
    select hl.meaning
    from hr_organization_information hoi,
         hr_lookups hl
    where hoi.organization_id = p_tax_unit_id
    and   hoi.org_information_context = 'State Tax Rules2'
    and   hoi.org_information1 = p_state_abbrev
    and   hoi.org_information5 = hl.LOOKUP_CODE
    and   hl.lookup_type = 'US_SELF_ADJUST_METHOD';

    Cursor c_get_sui_self_adjust_method
    IS
    select hl.meaning
    from hr_organization_information hoi,
         hr_lookups hl
    where hoi.organization_id = p_tax_unit_id
    and   hoi.org_information_context = 'State Tax Rules'
    and   hoi.org_information1 = p_state_abbrev
    and   hoi.org_information4 = hl.LOOKUP_CODE  --bug 3887144
  --  and   hoi.org_information5 = hl.LOOKUP_CODE
    and   hl.lookup_type = 'US_SELF_ADJUST_METHOD';


  CURSOR csr_sit_exempt (cp_jurisdiction_code IN VARCHAR2)
  IS
    SELECT sta.sit_exempt,
           sta.sdi_exempt,
           NVL(sta.STA_INFORMATION5,'N'),
           sta.sui_exempt
    FROM   pay_us_emp_state_tax_rules_f  sta,
           PER_ASSIGNMENTS_F   a,
           PER_BUSINESS_GROUPS  bg,
           pay_us_states        pus
    WHERE  sta.assignment_id   = a.assignment_id
    and    a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date between sta.effective_start_date
                          and sta.effective_end_date
    and    p_adjustment_date BETWEEN
                  a.effective_start_date and a.effective_end_date
    and    sta.jurisdiction_code = (substr(cp_jurisdiction_code,0,2) || '-000-0000')
    ;

  CURSOR csr_county_exempt (cp_jurisdiction_code IN VARCHAR2)
  IS
    SELECT cnt.lit_exempt,
           cnt.sd_exempt
    FROM   pay_us_emp_county_tax_rules_f  cnt,
           PER_ASSIGNMENTS_F   a,
           PER_BUSINESS_GROUPS  bg,
           pay_us_states        pus
    WHERE  cnt.assignment_id   = a.assignment_id
    and    a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date between cnt.effective_start_date
                          and cnt.effective_end_date
    and    p_adjustment_date BETWEEN
                  a.effective_start_date and a.effective_end_date
    and    cnt.jurisdiction_code = (substr(cp_jurisdiction_code,0,6) || '-0000')
    ;

  CURSOR csr_city_exempt (cp_jurisdiction_code IN VARCHAR2)
  IS
    SELECT cty.lit_exempt,
           cty.sd_exempt
    FROM   pay_us_emp_city_tax_rules_f  cty,
           PER_ASSIGNMENTS_F   a,
           PER_BUSINESS_GROUPS  bg,
           pay_us_states        pus
    WHERE  cty.assignment_id   = a.assignment_id
    and    a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date between cty.effective_start_date
                          and cty.effective_end_date
    and    p_adjustment_date BETWEEN
                  a.effective_start_date and a.effective_end_date
    and    cty.jurisdiction_code = cp_jurisdiction_code
    ;

   -- local copy of the tax withhelds,
  -- by copying the values to local variables,
  -- we avoid defining parameters as IN/OUT variables
  l_gross_amount                NUMBER := NVL(p_gross_amount, 0);
  l_net_amount                  NUMBER := NVL(p_net_amount, 0);
  l_fit                         NUMBER := NVL(p_fit, 0);
  l_ss                          NUMBER := NVL(p_ss, 0);
  l_medicare                    NUMBER := NVL(p_medicare, 0);
  l_sit                         NUMBER := NVL(p_sit, 0);
  l_sui_ee                      NUMBER := NVL(p_sui, 0);
  l_sdi_ee                      NUMBER := NVL(p_sdi, 0);
  l_sdi1_ee                     NUMBER := NVL(p_sdi1, 0);
  l_city                        NUMBER := NVL(p_city, 0);
  l_county                      NUMBER := NVL(p_county, 0);
  l_total_taxes_withheld        NUMBER;
  l_fit_third                   VARCHAR2(5) := NVL(p_FIT_THIRD, 'NO');

/** sbilling **/
  l_futa_er                     NUMBER := NVL(p_futa_er, 0);
  l_sui_er                      NUMBER := NVL(p_sui_er, 0);
  l_sdi_er                      NUMBER := NVL(p_sdi_er, 0);
  l_sch_dist_wh_ee              NUMBER := NVL(p_sch_dist_wh_ee, 0);
  l_sch_dist_jur                VARCHAR2(10) := NVL(p_sch_dist_jur, '');


BEGIN

  SAVEPOINT create_tax_bal_adjustment;

  -- insert a row INTO fnd_session if there isn't one
  BEGIN
     INSERT INTO fnd_sessions(session_id, effective_date)
     SELECT USERENV('sessionid'), SYSDATE
       FROM DUAL
      WHERE NOT EXISTS (SELECT '1'
                          FROM fnd_sessions
                         WHERE session_id = USERENV('sessionid'));

  END;

  -- get assignment_id and business_group_id based on assignment number
  -- and business group name.
  BEGIN
    hr_utility.set_location(c_proc, 5);
    SELECT a.assignment_id,
           a.business_group_id,
           a.payroll_id
    INTO   l_assignment_id,
           l_bg_id,
           l_payroll_id
    FROM   per_business_groups bg,
           per_assignments_f   a
    WHERE  a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date BETWEEN
                a.effective_start_date AND a.effective_end_date
    /*Added for bug 7692482*/
    and a.assignment_type='E'
    ;
    EXCEPTION
       WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
          hr_utility.set_message(801, 'PY_51135_TXADJ_ASG_NOT_FOUND');
          hr_utility.raise_error;
  END;

  -- get assignment derived jurisdiction geocode for state,county,city,zip code
  l_jd_entered := derive_jd_geocode(p_assignment_id => l_assignment_id,
                                    p_state_abbrev  => p_state_abbrev,
                                    p_county_name   => p_county_name,
                                    p_city_name     => p_city_name,
                                    p_zip_code      => p_zip_code );

  /** sbilling **/
  /*
  ** get limits for tax, should fire once, copy variables INTO globals
  */
--  IF (g_futa_wage_limit = 0) THEN
    fetch_wage_limits(p_adjustment_date,
                      p_state_abbrev,
                      g_futa_wage_limit,
                      g_ss_ee_wage_limit,  g_ss_er_wage_limit,
                      g_sdi_ee_wage_limit, g_sdi1_ee_wage_limit,
                      g_sdi_er_wage_limit, g_sui_ee_wage_limit,
                      g_sui_er_wage_limit);

--  END IF;

  -- get tax self adjust menthod  for taxes FUTA, SS, MEDICARE, SUI, SDI--
  Open c_get_futa_self_adjust_method;
  fetch c_get_futa_self_adjust_method
        into g_futa_sa_method;
  if c_get_futa_self_adjust_method%NOTFOUND THEN
     g_futa_sa_method := 'Not Entered';
  end if;
  close c_get_futa_self_adjust_method;

  Open c_get_ss_self_adjust_method;
  fetch c_get_ss_self_adjust_method
        into g_ss_sa_method;
  if c_get_ss_self_adjust_method%NOTFOUND THEN
     g_ss_sa_method := 'Not Entered';
  end if;
  close c_get_ss_self_adjust_method;

  Open c_get_medi_self_adjust_method;
  fetch c_get_medi_self_adjust_method
        into g_medicare_sa_method;
  if c_get_medi_self_adjust_method%NOTFOUND THEN
     g_medicare_sa_method := 'Not Entered';
  end if;
  close c_get_medi_self_adjust_method;

  Open c_get_sdi_self_adjust_method;
  fetch c_get_sdi_self_adjust_method
        into g_sdi_sa_method;
  if c_get_sdi_self_adjust_method%NOTFOUND THEN
     g_sdi_sa_method := 'Not Entered';
  end if;
  close c_get_sdi_self_adjust_method;

  Open c_get_sdi1_self_adjust_method;
  fetch c_get_sdi1_self_adjust_method
        into g_sdi1_sa_method;
  if c_get_sdi1_self_adjust_method%NOTFOUND THEN
     g_sdi1_sa_method := 'Not Entered';
  end if;
  close c_get_sdi1_self_adjust_method;


  Open c_get_sui_self_adjust_method;
  fetch c_get_sui_self_adjust_method
        into g_sui_sa_method;
  if c_get_sui_self_adjust_method%NOTFOUND THEN
     g_sui_sa_method := 'Not Entered';
  end if;
  close c_get_sui_self_adjust_method;

  open c_get_tax_group;
  fetch c_get_tax_group
        into g_tax_group;
  if c_get_tax_group%NOTFOUND THEN
     g_tax_group := 'NOT_ENTERED';
  end if;
  close c_get_tax_group;

  -- basic error checking
  -- 1.  check that Gross = Net + Taxes

  IF (l_gross_amount <> 0) THEN
    /*
    ** stub - do the ER components require validation,
    **        l_futa_er + l_sui_er + l_sdi_er + l_sch_dist_wh_ee
    */
    l_total_taxes_withheld := l_fit + l_ss + l_medicare + l_sit +
                              l_sui_ee + l_sdi_ee + l_sdi1_ee + l_county + l_city +
                              l_sch_dist_wh_ee;

     IF (l_gross_amount <> l_net_amount + l_total_taxes_withheld) THEN
        hr_utility.set_message(801, 'PY_51134_TXADJ_TAX_NET_TOT');
        hr_utility.raise_error;
     END IF;

  END IF;


  -- 2.  check that if an earnings element is provided if Gross is non-zero

  IF (l_gross_amount <> 0 AND p_earning_element_type IS NULL) THEN
        hr_utility.set_message(801, 'PY_51140_TXADJ_EARN_ELE_REQ');
        hr_utility.raise_error;
  END IF;


  -- 3.  check that SIT = 0 for Alaska, Florida, Nevada, New Hampshire, South Dakota,
  --     Tennessee, Texas, Washington, Wyoming, and the Virgin Islands

  IF ((l_sit <> 0)  AND
    (tax_exists(l_jd_entered, 'SIT', p_adjustment_date) = 'N')) THEN
       hr_utility.set_message(801, 'PY_51141_TXADJ_SIT_EXEMPT');
       hr_utility.raise_error;
  END IF;

/* bug 1608907 */
  IF ((l_county <> 0)  AND
    (tax_exists(l_jd_entered, 'COUNTY', p_adjustment_date) = 'N')) THEN
       hr_utility.set_message(801, 'PY_50980_TXADJ_COUNTY_EXEMPT');
       hr_utility.raise_error;
  END IF;

  IF ((l_city <> 0)  AND
    (tax_exists(l_jd_entered, 'CITY', p_adjustment_date) = 'N')) THEN
       hr_utility.set_message(801, 'PY_50981_TAXADJ_CITY_EXEMPT');
       hr_utility.raise_error;
  END IF;

/* bug 1608907 */

  -- 4.  check that SDI = 0 for all states but California, Hawaii, New Jersey, New York,
  --     Puerto Rico, Rhode  Island
  --
  -- first, need to ensure that the JD passed in is/was the primary assignment state at the
  -- time of the adjustment,
  -- this is because VERTEX calculations for SDI only occur for the primary work location,
  -- if the JD passed in is not the primary work location,
  -- then ensuing VERTEX calculations will not reflect the balance adjustments

  IF ( l_sdi_ee <> 0 or l_sdi1_ee <> 0or l_sdi_er <> 0) THEN
   OPEN csr_sdi_check;
   FETCH csr_sdi_check INTO l_primary_asg_state;

   IF csr_sdi_check%NOTFOUND THEN
      CLOSE csr_sdi_check;
      hr_utility.set_message(801, 'PY_51327_TXADJ_SDI_JD');
      hr_utility.raise_error;
    END IF;

    CLOSE csr_sdi_check;

  END IF;

  IF ( l_sdi_ee <> 0) THEN
    --IF (p_state_abbrev NOT IN ('CA', 'HI', 'NJ', 'NY', 'RI')) THEN
    IF (tax_exists(l_jd_entered, 'SDI_EE', p_adjustment_date) = 'N') THEN
      hr_utility.set_message(801, 'PY_51142_TXADJ_SDI_EXEMPT');
      hr_utility.raise_error;
    END IF;

  END IF;

  IF ( l_sdi1_ee <> 0) THEN
    --IF (p_state_abbrev NOT IN ('CA', 'HI', 'NJ', 'NY', 'RI')) THEN
    IF (tax_exists(l_jd_entered, 'SDI1_EE', p_adjustment_date) = 'N') THEN
      hr_utility.set_message(801, 'PY_51142_TXADJ_SDI_EXEMPT');
      hr_utility.raise_error;
    END IF;

  END IF;

  IF ( l_sdi_er <> 0) THEN
    --IF (p_state_abbrev NOT IN ('NJ', 'NY')) THEN
    IF (tax_exists(l_jd_entered, 'SDI_ER', p_adjustment_date) = 'N') THEN
      hr_utility.set_message(801, 'PY_51142_TXADJ_SDI_EXEMPT');
      hr_utility.raise_error;
    END IF;

  END IF;

  -- 5.  check SUI (EE) Withheld = 0 for all states unless the SUI state is
  --     in ('AK', 'NJ', 'PA')

  OPEN  csr_sui_geocode;
  FETCH csr_sui_geocode
  INTO  g_sui_jd,
        g_sui_state_code,
        l_fed_tax_exempt,
        l_futa_tax_exempt,
        l_medicare_tax_exempt,
        l_ss_tax_exempt;
  CLOSE csr_sui_geocode;

  OPEN  csr_sit_exempt (cp_jurisdiction_code => l_jd_entered);
  FETCH csr_sit_exempt
  INTO  l_sit_exempt,
        l_sdi_exempt,
        l_sdi1_exempt,
        l_sui_exempt;
  IF  csr_sit_exempt%NOTFOUND THEN
      l_sit_exempt := 'N';
      l_sdi_exempt := 'N';
      l_sdi1_exempt := 'N';
      l_sui_exempt := 'N';
  END IF;
  CLOSE csr_sit_exempt;

  OPEN  csr_county_exempt (cp_jurisdiction_code => l_jd_entered);
  FETCH csr_county_exempt
  INTO  l_cnt_exempt,
        l_cnt_sd_exempt;
  IF  csr_county_exempt%NOTFOUND THEN
      l_cnt_exempt := 'N';
      l_cnt_sd_exempt := 'N';
  END IF;
  CLOSE csr_county_exempt;

  OPEN  csr_city_exempt (cp_jurisdiction_code => l_jd_entered);
  FETCH csr_city_exempt
  INTO  l_cty_exempt,
        l_cty_sd_exempt;
  IF  csr_city_exempt%NOTFOUND THEN
      l_cty_exempt := 'N';
      l_cty_sd_exempt := 'N';
  END IF;
  CLOSE csr_city_exempt;

  IF (l_sui_ee <> 0) THEN

    /*
    ** if the assignment is not in 'AK', 'NJ', 'PA' then SUI_EE does not apply,
    ** if the state found for the assignment (CA) <> the state from the
    ** assignment (NJ) then SUI_EE does not apply
    */
    IF (tax_exists(l_jd_entered, 'SUI_EE', p_adjustment_date) = 'N') OR
       (g_sui_state_code <> p_state_abbrev) THEN
        hr_utility.set_message(801, 'PY_51328_TXADJ_SUI_EXEMPT');
        hr_utility.raise_error;
    END IF;

  END IF;

  BEGIN
     hr_utility.set_location(c_proc, 10);
     SELECT consolidation_set_id
     INTO   l_consolidation_set_id
     FROM   PAY_CONSOLIDATION_SETS
     WHERE  consolidation_set_name = p_consolidation_set
     and    business_group_id      = l_bg_id
     ;
     EXCEPTION
       WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
         hr_utility.set_message(801, 'PY_51136_TXADJ_CONSET_NOT_FND');
         hr_utility.raise_error;
  END;

  l_jd_entered := derive_jd_geocode(p_assignment_id => l_assignment_id,
                                    p_state_abbrev  => p_state_abbrev,
                                    p_county_name   => p_county_name,
                                    p_city_name     => p_city_name,
                                    p_zip_code      => p_zip_code );

/** sbilling */
  /*
  ** put the old taxable balances (before any BA processing) INTO globals,
  ** required for subsequent excess processing
  */
  g_medicare_ee_taxable := taxable_balance('MEDICARE', 'EE', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, NULL);

  g_medicare_er_taxable := taxable_balance('MEDICARE', 'ER', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, NULL);

  g_futa_taxable := taxable_balance('FUTA', 'ER', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, NULL);

  g_ss_ee_taxable := taxable_balance('SS', 'EE', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, NULL);

  g_ss_er_taxable := taxable_balance('SS', 'ER', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, NULL);

  /*
  ** the SUI/SDI balances require a JD code to derive the balance for a
  ** particular state
  */
  g_sdi_ee_taxable := taxable_balance('SDI', 'EE', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, l_jd_entered);

  g_sdi1_ee_taxable := taxable_balance('SDI1', 'EE', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, l_jd_entered);

  g_sdi_er_taxable := taxable_balance('SDI', 'ER', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, l_jd_entered);

  g_sui_ee_taxable := taxable_balance('SUI', 'EE', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, l_jd_entered);

  g_sui_er_taxable := taxable_balance('SUI', 'ER', p_tax_unit_id, l_assignment_id,
                                         p_adjustment_date, l_jd_entered);


  -- set global
  g_city_jd             := l_jd_entered;
  g_state_jd            := Substr(l_jd_entered, 1, 2) || '-000-0000';
  g_county_jd           := Substr(l_jd_entered, 1, 6) || '-0000';
  g_sch_dist_jur        := l_sch_dist_jur;
  g_classification_id   := NULL;
  g_earnings_category   := NULL;
  g_classification      := NULL;


  -- more error checking

  -- check the level of l_jd_entered to see if all taxes entered
  -- are applicable for the jurisdiction entered
  hr_utility.set_location(c_proc, 15);

 IF (l_city <> 0) THEN  -- jd level needed is for a city   --Bug3697701 --Removed the condition
    l_jd_level_needed := 4;                                                --OR l_gross_amount <> 0 from IF stmt.

  ELSIF (l_county <> 0) THEN
    l_jd_level_needed := 3;

  ELSIF (l_sit <> 0 OR l_sui_ee <> 0 OR l_sdi_ee <> 0) THEN
    l_jd_level_needed := 2;

  ELSIF (l_fit <> 0 OR l_ss <> 0 OR l_medicare <> 0) THEN
    l_jd_level_needed := 1;

  END IF;


  IF (l_jd_entered = g_fed_jd) THEN
    l_jd_level_entered := 1;

  ELSIF (l_jd_entered = g_state_jd) THEN
    l_jd_level_entered := 2;

  ELSIF (l_jd_entered = g_county_jd) THEN
    l_jd_level_entered := 3;

  ELSE                                  -- jd level entered is for a city
    l_jd_level_entered := 4;

  END IF;


  -- now compare the level of jd entered against the level required
  IF (l_jd_level_needed > l_jd_level_entered) THEN
    hr_utility.set_location(c_proc, 20);
    hr_utility.set_message(801, 'PY_50015_TXADJ_JD_INSUFF');
    hr_utility.raise_error;
  END IF;


  -- main processing
  hr_utility.set_location(c_proc, 30);

  -- first call routine to create payroll_action_id, we will only need
  -- one for entire tax balance adjustment process
  l_payroll_action_id := pay_bal_adjust.init_batch(p_payroll_id => l_payroll_id,
                                                   p_batch_mode => 'NO_COMMIT',
                                                   p_effective_date => p_adjustment_date,
                                                   p_consolidation_set_id => l_consolidation_set_id,
                                                   p_prepay_flag => p_balance_adj_prepay_flag);


-- 4188782
open get_element_details (p_earning_element_type,l_bg_id);
fetch get_element_details into l_element_classification;
close get_element_details;

  IF (l_gross_amount <> 0)
     and (l_element_classification = 'Supplemental Earnings'
          or l_element_classification = 'Imputed Earnings') THEN

         process_element(p_assignment_id        => l_assignment_id,
                         p_consolidation_set_id => l_consolidation_set_id,
                         p_element_type         => 'FSP_SUBJECT',
                         p_abbrev_element_type  => 'FSP',
                         p_bg_id                => l_bg_id,
                         p_adjustment_date      => p_adjustment_date,
                         p_earn_amount          => l_gross_amount,
                         p_adj_amount           => 0,
                         p_jurisdiction         => g_fed_jd,
                         p_payroll_action_id    => l_payroll_action_id,
                         p_tax_unit_id          => p_tax_unit_id,
                         p_balance_adj_costing_flag => p_balance_adj_costing_flag);

 /* Bug 7362837 added call to populate the SIT NON AGGREGATE balance */

          process_element(p_assignment_id        => l_assignment_id,
                          p_consolidation_set_id => l_consolidation_set_id,
                          p_element_type         => 'SIT_WK_NON_AGGREGATE_RED_SUBJ_WHABLE',
                          p_abbrev_element_type  => 'SWNAGG',
                          p_bg_id                => l_bg_id,
                          p_adjustment_date      => p_adjustment_date,
                          p_earn_amount          => l_gross_amount,
                          p_adj_amount           => 0,
                          p_jurisdiction         => g_state_jd,
                          p_payroll_action_id    => l_payroll_action_id,
                          p_tax_unit_id          => p_tax_unit_id,
                          p_balance_adj_costing_flag => p_balance_adj_costing_flag);

          process_element(p_assignment_id        => l_assignment_id,
                          p_consolidation_set_id => l_consolidation_set_id,
                          p_element_type         => 'FIT_NON_AGGREGATE_RED_SUBJ_WHABLE',
                          p_abbrev_element_type  => 'FNAGG',
                          p_bg_id                => l_bg_id,
                          p_adjustment_date      => p_adjustment_date,
                          p_earn_amount          => l_gross_amount,
                          p_adj_amount           => 0,
                          p_jurisdiction         => g_fed_jd,
                          p_payroll_action_id    => l_payroll_action_id,
                          p_tax_unit_id          => p_tax_unit_id,
                          p_balance_adj_costing_flag => p_balance_adj_costing_flag);

  END IF;
------------------------------

  IF (l_gross_amount <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => p_earning_element_type,
                    p_abbrev_element_type  => Substr(p_earning_element_type, 1, 11),
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => l_gross_amount,
                    p_jurisdiction         => l_jd_entered,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag => p_balance_adj_costing_flag);
  END IF;

  IF (l_fit <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'FIT',
                    p_abbrev_element_type  => 'FIT',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => l_fit,
                    p_jurisdiction         => g_fed_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    IF (l_fit_third = 'YES') THEN
      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'FIT 3rd Party',
                      p_abbrev_element_type  => '3F',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => l_gross_amount,
                      p_adj_amount           => l_fit,
                      p_jurisdiction         => g_fed_jd,
                      p_payroll_action_id    => l_payroll_action_id,
                      p_tax_unit_id          => p_tax_unit_id,
                      p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
    END IF;
  END IF;

  IF (l_ss <> 0) and (g_ss_sa_method <> 'Bypass Collection') THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'SS_EE',
                    p_abbrev_element_type  => 'SS',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => NULL,
                    p_adj_amount           => l_ss,
                    p_jurisdiction         => g_fed_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'SS_ER',
                    p_abbrev_element_type  => 'SER',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => NULL,
                    p_adj_amount           => l_ss,
                    p_jurisdiction         => g_fed_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
  END IF;

  IF (l_medicare <> 0) and (g_medicare_sa_method <> 'Bypass Calculations')THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'Medicare_EE',
                    p_abbrev_element_type  => 'Med',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => 0,
                    p_adj_amount           => l_medicare,
                    p_jurisdiction         => g_fed_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'Medicare_ER',
                    p_abbrev_element_type  => 'MER',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => 0,
                    p_adj_amount           => l_medicare,
                    p_jurisdiction         => g_fed_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
  END IF;

  IF (l_futa_er <> 0 and g_futa_sa_method <> 'Bypass Collection' ) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'FUTA',
                    p_abbrev_element_type  => 'FTA',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => 0,
                    p_adj_amount           => l_futa_er,
                    p_jurisdiction         => g_fed_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
  END IF;

  IF (l_sit <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'SIT_WK',
                    p_abbrev_element_type  => 'SITK',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => l_sit,
                    p_jurisdiction         => g_state_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
  END IF;


/** sbilling **/
  /*
  ** new tax element to be processed, use SIT_WK as a template
  */
  IF (l_sch_dist_wh_ee <> 0) THEN

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'County_SC_WK',
                    p_abbrev_element_type  => 'CsWK',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => l_sch_dist_wh_ee,
                    p_jurisdiction         => l_sch_dist_jur,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
  END IF;



  IF (l_city <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'City_WK',
                    p_abbrev_element_type  => 'CtyK',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => l_city,
                    p_jurisdiction         => g_city_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
  END IF;

  IF (l_county <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'County_WK',
                    p_abbrev_element_type  => 'CntyK',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => l_county,
                    p_jurisdiction         => g_county_jd,
                    p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                    p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
  END IF;

  -- subject balances are adjusted if there were any earnings
  IF (l_gross_amount <> 0) THEN
    -- SD1

    /*
    ** for Medicare_ER and SS_ER the ER adjustments amounts should equal the EE
    ** adjustment amounts, thus l_medicare and l_ss can be used
    */
    if g_medicare_sa_method <> 'Bypass Calculations'
    and  l_medicare_tax_exempt <> 'Y' then
        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'Medicare_ER',
                        p_abbrev_element_type  => 'MER',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => 0,
                        p_jurisdiction         => g_fed_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                        p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'Medicare_EE',
                        p_abbrev_element_type  => 'Med',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => 0,
                        p_jurisdiction         => g_fed_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                        p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    end if;


    if g_ss_sa_method <> 'Bypass Collection'
    and l_ss_tax_exempt <> 'Y' then

        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'SS_ER',
                        p_abbrev_element_type  => 'SER',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => 0,
                        p_jurisdiction         => g_fed_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                        p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'SS_EE',
                        p_abbrev_element_type  => 'SS',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => 0,
                        p_jurisdiction         => g_fed_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                        p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    end if;

    if g_futa_sa_method <> 'Bypass Collection'
    and l_futa_tax_exempt <> 'Y' then

        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'FUTA',
                        p_abbrev_element_type  => 'FTA',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => 0,
                        p_jurisdiction         => g_fed_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                        p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    end if;


    IF (tax_exists(l_jd_entered, 'SIT', p_adjustment_date) = 'Y') THEN
hr_utility.trace('before process_element with SIT_SUBJECT_WK '||TO_CHAR(l_sit));
      process_element(p_assignment_id          => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'SIT_SUBJECT_WK',
                        p_abbrev_element_type  => 'SITSubK',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => l_sit,
                        p_jurisdiction         => g_state_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);
    END IF;

    IF (tax_exists(l_jd_entered, 'CITY', p_adjustment_date) = 'Y') THEN
      process_element(p_assignment_id        => l_assignment_id,
                       p_consolidation_set_id => l_consolidation_set_id,
                       p_element_type         => 'City_SUBJECT_WK',
                       p_abbrev_element_type  => 'CtySubK',
                       p_bg_id                => l_bg_id,
                       p_adjustment_date      => p_adjustment_date,
                       p_earn_amount          => l_gross_amount,
                       p_adj_amount           => l_city,
                       p_jurisdiction         => g_city_jd,
                       p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                       p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    END IF;

    IF (tax_exists(l_jd_entered, 'COUNTY', p_adjustment_date) = 'Y') THEN

      process_element(p_assignment_id        => l_assignment_id,
                       p_consolidation_set_id => l_consolidation_set_id,
                       p_element_type         => 'County_SUBJECT_WK',
                       p_abbrev_element_type  => 'CntySubK',
                       p_bg_id                => l_bg_id,
                       p_adjustment_date      => p_adjustment_date,
                       p_earn_amount          => l_gross_amount,
                       p_adj_amount           => l_county,
                       p_jurisdiction         => g_county_jd,
                       p_payroll_action_id    => l_payroll_action_id,
                    p_tax_unit_id          => p_tax_unit_id,
                       p_balance_adj_costing_flag                 => p_balance_adj_costing_flag);

    END IF;

    IF nvl(p_sch_dist_jur,NULL) is not NULL THEN
       process_element(p_assignment_id        => l_assignment_id,
                       p_consolidation_set_id => l_consolidation_set_id,
                       p_element_type        => 'School_SUBJECT_WK',
                       p_abbrev_element_type  => 'SchlSubK',
                       p_bg_id                => l_bg_id,
                       p_adjustment_date      => p_adjustment_date,
                       p_earn_amount          => l_gross_amount,
                       p_adj_amount          => 0,
                       p_jurisdiction        => l_sch_dist_jur,
                       p_payroll_action_id    => l_payroll_action_id,
                       p_tax_unit_id          => p_tax_unit_id,
                       p_balance_adj_costing_flag => p_balance_adj_costing_flag);

    END IF;

  END IF;  -- (l_gross_amount <> 0)

  -- only Alaska, New Jersey and Pennsylvania have SUI_EE in addition
  -- to SUI_ER,
  -- may also want to check that if the jurisdiction is the SUI jurisdiction,
  -- only then create the SUI SUBJECT EE and ER

-- sd 15/5
  IF (tax_exists(l_jd_entered, 'SUI_EE', p_adjustment_date) = 'Y') THEN
    IF (p_state_abbrev = g_sui_state_code) THEN

      IF (l_gross_amount <> 0) THEN

        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'SUI_SUBJECT_EE',
                        p_abbrev_element_type  => 'SUISubE',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => l_sui_ee,
                        p_jurisdiction         => g_sui_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                        p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag
                                               => p_balance_adj_costing_flag);

         IF  l_sui_exempt <> 'Y'
         and g_sui_sa_method <> 'Bypass Collection'  THEN
            process_element(p_assignment_id        => l_assignment_id,
                            p_consolidation_set_id => l_consolidation_set_id,
                            p_element_type         => 'SUI_EE',
                            p_abbrev_element_type  => 'SUIE',
                            p_bg_id                => l_bg_id,
                            p_adjustment_date      => p_adjustment_date,
                            p_earn_amount          => l_gross_amount,
                            p_adj_amount           => 0,
                            p_jurisdiction         => g_sui_jd,
                            p_payroll_action_id    => l_payroll_action_id,
                            p_tax_unit_id          => p_tax_unit_id,
                            p_balance_adj_costing_flag
                                                   => p_balance_adj_costing_flag);
         END IF; /* l_sui_exempt */

      END IF; /* l_gross_amount */
      IF ( l_sui_ee <> 0
           and g_sui_sa_method <> 'Bypass Collection')  THEN

        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'SUI_EE',
                        p_abbrev_element_type  => 'SUIE',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => 0,
                        p_adj_amount           => l_sui_ee,
                        p_jurisdiction         => g_sui_jd,
                        p_payroll_action_id    => l_payroll_action_id,
                        p_tax_unit_id          => p_tax_unit_id,
                        p_balance_adj_costing_flag
                                               => p_balance_adj_costing_flag);
     END IF; /* l_sui_ee */
    END IF; /* state_abbrev */
  END IF; /* tax exists */

  -- all states have SUI_ER
  IF (p_state_abbrev = g_sui_state_code) THEN
    IF (l_gross_amount <> 0) THEN

      process_element(p_assignment_id         => l_assignment_id,
                      p_consolidation_set_id  => l_consolidation_set_id,
                      p_element_type          => 'SUI_SUBJECT_ER',
                      p_abbrev_element_type   => 'SUISubR',
                      p_bg_id                 => l_bg_id,
                      p_adjustment_date       => p_adjustment_date,
                      p_earn_amount           => l_gross_amount,
                      p_adj_amount            => l_sui_ee,
                      p_jurisdiction          => g_sui_jd,
                      p_payroll_action_id     => l_payroll_action_id,
                      p_tax_unit_id             => p_tax_unit_id,
                      p_balance_adj_costing_flag
                                              => p_balance_adj_costing_flag);

       IF  l_sui_exempt <> 'Y'
       and g_sui_sa_method <> 'Bypass Collection' THEN
          process_element(p_assignment_id         => l_assignment_id,
                          p_consolidation_set_id  => l_consolidation_set_id,
                          p_element_type          => 'SUI_ER',
                          p_abbrev_element_type   => 'SUIR',
                          p_bg_id                 => l_bg_id,
                          p_adjustment_date       => p_adjustment_date,
                          p_earn_amount           => l_gross_amount,
                          p_adj_amount            => 0,
                          p_jurisdiction          => g_sui_jd,
                          p_payroll_action_id     => l_payroll_action_id,
                          p_tax_unit_id           => p_tax_unit_id,
                          p_balance_adj_costing_flag
                                                  => p_balance_adj_costing_flag);
       END IF; /* l_sui_exempt */
    END IF; /* l_gross_amount */

    IF  ( l_sui_er <> 0
           and g_sui_sa_method <> 'Bypass Collection') THEN
      process_element(p_assignment_id         => l_assignment_id,
                      p_consolidation_set_id  => l_consolidation_set_id,
                      p_element_type          => 'SUI_ER',
                      p_abbrev_element_type   => 'SUIR',
                      p_bg_id                 => l_bg_id,
                      p_adjustment_date       => p_adjustment_date,
                      p_earn_amount           => 0,
/** sbilling **/
                      p_adj_amount            => l_sui_er,
                      p_jurisdiction          => g_sui_jd,
                      p_payroll_action_id     => l_payroll_action_id,
                      p_tax_unit_id           => p_tax_unit_id,
                      p_balance_adj_costing_flag
                                              => p_balance_adj_costing_flag);
     END IF; /* l_sui_er */
   END IF; /* state_abrev */

  -- only Hawaii, New Jersey, Puerto Rico have SDI_ER
  IF (tax_exists(l_jd_entered, 'SDI_ER', p_adjustment_date) = 'Y') THEN

    IF (l_gross_amount <> 0) THEN

      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'SDI_SUBJECT_ER',
                      p_abbrev_element_type  => 'SDISubR',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => l_gross_amount,
                      p_adj_amount           => l_sdi_ee,
                      p_jurisdiction         => g_state_jd,
                      p_payroll_action_id    => l_payroll_action_id,
                      p_tax_unit_id          => p_tax_unit_id,
                      p_balance_adj_costing_flag
                                             => p_balance_adj_costing_flag);

        IF  l_sdi_exempt  <> 'Y'
        and g_sdi_sa_method <> 'Bypass Collection' THEN

          process_element(p_assignment_id        => l_assignment_id,
                          p_consolidation_set_id => l_consolidation_set_id,
                          p_element_type         => 'SDI_ER',
                          p_abbrev_element_type  => 'SDIR',
                          p_bg_id                => l_bg_id,
                          p_adjustment_date      => p_adjustment_date,
                          p_earn_amount          => l_gross_amount,
                          p_adj_amount           => 0,
                          p_jurisdiction         => g_state_jd,
                          p_payroll_action_id    => l_payroll_action_id,
                          p_tax_unit_id          => p_tax_unit_id,
                          p_balance_adj_costing_flag
                                                 => p_balance_adj_costing_flag);
        END IF; /* if l_sdi_exempt */

    END IF;

    IF ( l_sdi_er <> 0
         and g_sdi_sa_method <> 'Bypass Collection') THEN

      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'SDI_ER',
                      p_abbrev_element_type  => 'SDIR',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => 0,
                      p_adj_amount           => l_sdi_er,
                      p_jurisdiction         => g_state_jd,
                      p_payroll_action_id    => l_payroll_action_id,
                      p_tax_unit_id          => p_tax_unit_id,
                      p_balance_adj_costing_flag
                                             => p_balance_adj_costing_flag);
    END IF; /* if l_sdi_er */

  END IF; /*  if tax exists  */

  -- only California, Hawaii, New Jersey, New York, Rhode Island,
  -- and Puerto Rico have SDI_EE

  IF (tax_exists(l_jd_entered, 'SDI_EE', p_adjustment_date) = 'Y') THEN

    IF (l_gross_amount <> 0) THEN
      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'SDI_SUBJECT_EE',
                      p_abbrev_element_type  => 'SDISubE',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => l_gross_amount,
                      p_adj_amount           => l_sdi_ee,
                      p_jurisdiction         => g_state_jd,
                      p_payroll_action_id    => l_payroll_action_id,
                      p_tax_unit_id          => p_tax_unit_id,
                      p_balance_adj_costing_flag
                                             => p_balance_adj_costing_flag);

      IF  l_sdi_exempt <> 'Y'
      AND g_sdi_sa_method <> 'Bypass Collection'  THEN

           process_element(p_assignment_id        => l_assignment_id,
                          p_consolidation_set_id => l_consolidation_set_id,
                          p_element_type         => 'SDI_EE',
                          p_abbrev_element_type  => 'SDIE',
                          p_bg_id                => l_bg_id,
                          p_adjustment_date      => p_adjustment_date,
                          p_earn_amount          => l_gross_amount,
                          p_adj_amount           => 0,
                          p_jurisdiction         => g_state_jd,
                          p_payroll_action_id    => l_payroll_action_id,
                          p_tax_unit_id          => p_tax_unit_id,
                          p_balance_adj_costing_flag
                                                 => p_balance_adj_costing_flag);

      END IF; /* l_sdi_exempt */

   END IF; /* l_gross-amount */

   IF ( l_sdi_ee <> 0
         and g_sdi_sa_method <> 'Bypass Collection')  THEN
      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'SDI_EE',
                      p_abbrev_element_type  => 'SDIE',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => 0,
                      p_adj_amount           => l_sdi_ee,
                      p_jurisdiction         => g_state_jd,
                      p_payroll_action_id    => l_payroll_action_id,
                      p_tax_unit_id          => p_tax_unit_id,
                      p_balance_adj_costing_flag
                                             => p_balance_adj_costing_flag);
    END IF;

  END IF; /* if tax exists */

  IF (tax_exists(l_jd_entered, 'SDI1_EE', p_adjustment_date) = 'Y') THEN

    IF (l_gross_amount <> 0) THEN

      IF  l_sdi1_exempt <> 'Y'
      AND g_sdi1_sa_method <> 'Bypass Collection'  THEN

           process_element(p_assignment_id        => l_assignment_id,
                          p_consolidation_set_id => l_consolidation_set_id,
                          p_element_type         => 'SDI1_EE',
                          p_abbrev_element_type  => 'SDI1E',
                          p_bg_id                => l_bg_id,
                          p_adjustment_date      => p_adjustment_date,
                          p_earn_amount          => l_gross_amount,
                          p_adj_amount           => 0,
                          p_jurisdiction         => g_state_jd,
                          p_payroll_action_id    => l_payroll_action_id,
                          p_tax_unit_id          => p_tax_unit_id,
                          p_balance_adj_costing_flag
                                                 => p_balance_adj_costing_flag);

      END IF; /* l_sdi_exempt */

   END IF; /* l_gross-amount */

   IF ( l_sdi1_ee <> 0
         and g_sdi1_sa_method <> 'Bypass Collection')  THEN
      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'SDI1_EE',
                      p_abbrev_element_type  => 'SDI1E',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => 0,
                      p_adj_amount           => l_sdi1_ee,
                      p_jurisdiction         => g_state_jd,
                      p_payroll_action_id    => l_payroll_action_id,
                      p_tax_unit_id          => p_tax_unit_id,
                      p_balance_adj_costing_flag
                                             => p_balance_adj_costing_flag);
    END IF;

  END IF; /* if tax exists */

  -- set some of the return out parameters
  p_payroll_action_id := l_payroll_action_id;

  IF hr_utility.check_warning THEN
     l_create_warning       := TRUE;
     hr_utility.clear_warning;
  END IF;

  IF(p_validate) THEN
      RAISE hr_api.validate_enabled;
  END IF;

  hr_utility.trace('Finished Routine, all adjustments commited');
  hr_utility.trace('Payroll_action_id = '||TO_CHAR(l_payroll_action_id));

  pay_bal_adjust.process_batch(p_payroll_action_id);


EXCEPTION
   WHEN hr_api.validate_enabled THEN
   --
   -- As the Validate_Enabled exception has been raised
   -- we must rollback to the savepoint
   --
   ROLLBACK TO create_tax_bal_adjustment;
   --
   -- Only set output warning arguments
   -- (Any key or derived arguments must be set to NULL
   -- when validation only mode is being used.)
   --
   p_payroll_action_id     := NULL;
   p_create_warning        := l_create_warning;
   hr_utility.trace('Validate Enabled, no commits are made');

WHEN OTHERS THEN
   -- Unexpected error detected.
   ROLLBACK TO create_tax_bal_adjustment;
   RAISE;

END create_tax_balance_adjustment;

END pay_us_tax_bals_adj_api;

/
