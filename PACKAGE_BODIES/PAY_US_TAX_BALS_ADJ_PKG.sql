--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_BALS_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_BALS_ADJ_PKG" AS
/* $Header: pyustxba.pkb 120.1 2005/10/05 03:57:22 sackumar noship $ */
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
/* --------------------------------------------------------------------------
  NAME
     pyustxba.pkb
  DESCRIPTION
     This package is used to create tax balance adjustments for the US
     localization of Oracle Payroll.
  NOTES

     The balances affected depend on whether Gross Amount has been entered
     or not:

     Gross Taxes    Subject Balances Withheld Balances
     ----- -----    ---------------- -----------------
     NULL  <> 0     N/A              Yes
     <>0   NULL     Yes              N/A
     <>0   <> 0     Yes              Yes.

     Subject balances are adjusted depending on the taxability rules
     for the work state.

  ----------------------------------------------------------------------------
  Version       Modified        Date            Description
  -------       --------        --------        ------------------------------
    0           S Panwar        23-OCT-1995      Created
   40.0         S Desai         17-Nov-1995      Initial arcs version.
   40.1         S Desai         20-Nov-1995      Use various user keys as
                                                 parameters rather than the
                                                 SYSTEM.keys.
   40.2         S Desai         22-Nov-1995      derive_jd_geocode added.
                                                 populate Supp Tax input
                                                 for FIT and SIT if earnings
                                                 is Supplemental.
   40.3         S Desai         29-Nov-1995      Use input value's default
                                                 value if available.
                                                 Defined messages used instead
                                                 of generic one. Check location
                                                 provided - i.e. it is a valid
                                                 work location.
   40.4         S Desai         08-Dec-1995      Check that the state is subject
                                                 to SIT/SUI_EE/SUI_ER/SDI_EE/SDI_ER.
   40.5         S Desai         11-Jan-1996      Removed extraneous underscore in
                                                 message name.  Bug 327502: SDI_ER and EE
                                                 for HI, NJ, PR; SDI_EE for CA, NY, RI
   40.6         S Desai         23-May-1996      Bug 331022: Taxable wages needed to be
                                                 adjusted.
                                                 Also changed:
                                                 - SUI taxes are adjusted in the SUI
                                                   jurisdiction, regardless of the the
                                                   jurisdiction passed.
                                                 - SDI taxes can only be withheld in the
                                                   primary work location.
                                                These changes were necessary because
                                                subsequent in payroll runs, VERTEX calcs.
                                                are only in SUI jd for SUI taxes AND
                                                primary work jd for SDI taxes.
  40.7         gpaytonm         01-JUL-96       Uncommented EXIT !!!!
  40.8         ramurthy         10-SEP-96       Added code to adjust the FIT
                                                Withheld by Third Party
                                                balance, in addition to
                                                feeding the FIT Withheld
                                                balance, if the p_FIT_THIRD
                                                flag is set.
  40.9         ramurthy         02-OCT-96       Fixed bug 405844.  Removed
                                                "or l_gross_amount <> 0" in
                                                steps 4 and 5 of procedure
                                                create_tax_balance_adjustment.

  40.15        ramurthy         14-OCT-96       Handled FIT 3rd Party
                                                different from FIT.

  40.16        ramurthy         14-OCT-96       Major changes.

  40.17        ramurthy                         Removed trace info.

  40.18        lwthomps         27-MAY-97       Arcsed in the wrong file.

  40.19        lwthomps         27-MAY-97       Arcsed in Version 40.17
                                                to fix the above mistake.

  40.20/110.1  lwthomps         27-AUG-97       W4 Datetrack.  Changed all
                                                references to tax records
                                                to use new datatracked table.


  110.2        sbilling         28-Apr-98       Added extra parameter p_cost to:
                                                - create_tax_balance_adjustment(),
                                                - process_element(),
                                                - create_adjustment()
                                                p_cost is used to pass the cost checkbox
                                                value to create_adjustment() so that
                                                pay_element_entries_f can be updated
                                                after the insert_element_entry() api

  110.3        sbilling         15-Jul-98       Major changes.  Added new function
					 	process_limits() to do limit
						processing on limit based taxes
						(eg. Medicare_EE/Medicare_ER).  The limits
						for taxes are fetched from the tables
						PAY_US_FEDERAL_TAX_INFO_F/
						PAY_US_STATE_TAX_INFO_F for federal
						and state taxes respectively.  Also
						added the extra fields:
						- futa_er
						- sui_er
						- sdi_er
						- sch_dist_wh_ee
						- sch_dist_jur
						to the corresponding form PAYWSTBA.
						These are used to handle the ER components
						of the adjustments and to allow school
						district adjustments to be made.  NB. The
						chosen school district's jurisdiction is
						passed down to
						create_tax_balance_adjustment() via the
						p_sch_dist_jur parameter.
						Also note, the taxable balances for all
						taxes where limit processing may apply are
						fetched before any limit processing is
						done.  The values are stored in global
						parameters.
         08-apr99    djoshi   Verfied and converted for Canonical
                              Complience of Date
         19-apr99    alogue   Fix to previous change.

 115.1   21-apr-99   scgrant  Multi-radix changes.
 115.7   07-JUL-99   RAMURTHY	Incorporated functional fixes
						from 10.7.
 115.8   19-AUG-99   KKAWOL   Support for date UOM 'D'. 'D_DDMONYY','D_DDMONYYYY'
                             'D_DDMMYY','D_DDMMYYYY','D_MMDDYY','D_MMDDYYYY' do
                              not exist any more.
 115.9   22-NOV-1999 MHANDA   Added fed_information_category = 401K
                              in the where clause for cursor for
                              pay_us_federal_tax_info_f.
 115.10  27-DEC-1999 tclewis modifed csr_chk_taxability to accept
                             jurisdiction code as a parameter.  This
                             fixes a problem with checkin the taxability
                             rules for city and county records.
                             I also added code the check state level
                             taxablility rules if no rows are returned
                             on the city or county level.
 115.11  15-feb-2000 tclewis bugs 983727 and 1151395.  Modified csr_sui_geocode
                             to check business_group_id on assignment record
                             so that only one row is returned (in the case of
                             multiple business groups).  Removed check of
                             gross_pay <> 0 when validating jurisdiction level
                             needed.  Added a check for a valid city jurisdiction
                             code before making an adjustment to the
                             city_subject_wk balance.
  112.12 24-MAY-2000 tclewis Implemented the tax_exists functionality for city
                             and county.  Also added a check for tax_exists
                             before processing elements city_subject_wk and
                             count_subbject_wk, when gross pay is greated than
                             0.

 115.16 13-sep-2000 irgonzal Bug Fix 1398865. Modified csr_sdi_check cursor
                             to check business_group_id on assignment record
                             to ensure only one row is returned when same
                             assignment number exist in different business groups.

 115.17 11-jan-2001 tclewis  bug fix 1569312.  SUI and SDI taxable were only
                             being adjusted when an adjustment abount was
                             entered for SUI / SDI liablity. I removed the
                             code (if statements) where we check if l_sui_er /
                             l_sdi_er (or ee) were eneterd before we process
                             the adjustment.
 115.18 05-OCT-2005 sackumar 4650486   Removed GSCC Errors and Warnings

   -------------------------------------------------------------------------- */

 -- global variables
 g_classification               VARCHAR2(80);
 g_earnings_category            VARCHAR2(30);
 g_classification_id            NUMBER;
 g_fed_jd                       VARCHAR2(11)    := '00-000-0000';
 g_state_jd                     VARCHAR2(11) := '00-000-0000';
 g_sui_jd                       VARCHAR2(11) := '00-000-0000';
 g_sui_state_code               VARCHAR2(2);
 g_county_jd                    VARCHAR2(11) := '00-000-0000';
 g_city_jd                      VARCHAR2(11) := '00-000-0000';
 g_dummy_varchar_tbl            hr_entry.varchar2_table;
 g_dummy_number_tbl             hr_entry.number_table;
 g_tax_type_tbl                 hr_entry.varchar2_table;
 g_tax_adj_pactid_tbl           hr_entry.number_table;
 g_pact_cntr                    NUMBER := 1;

 /* federal level 'balances' */
 g_medicare_ee_taxable          NUMBER := 0;
 g_medicare_er_taxable          NUMBER := 0;
 g_futa_taxable                 NUMBER := 0;
 g_ss_ee_taxable                NUMBER := 0;
 g_ss_er_taxable                NUMBER := 0;

 /* state level 'balances' */
 g_sdi_ee_taxable               NUMBER := 0;
 g_sdi_er_taxable               NUMBER := 0;
 g_sui_ee_taxable               NUMBER := 0;
 g_sui_er_taxable               NUMBER := 0;

 /* federal level 'limits' */
 g_futa_wage_limit              NUMBER := 0;
 g_ss_ee_wage_limit             NUMBER := 0;
 g_ss_er_wage_limit             NUMBER := 0;

 /* state level 'limits' */
 g_sdi_ee_wage_limit            NUMBER := 0;
 g_sdi_er_wage_limit            NUMBER := 0;
 g_sui_ee_wage_limit            NUMBER := 0;
 g_sui_er_wage_limit            NUMBER := 0;



PROCEDURE create_adjustment(
  p_adjustmnt_date       IN             DATE,
  p_assignment_id        IN             NUMBER,
  p_element_link_id      IN             NUMBER,
  p_consolidation_set_id IN             NUMBER,
  p_num_entry_values     IN OUT   nocopy      NUMBER,
  p_entry_value_tbl      IN OUT nocopy        hr_entry.varchar2_table,
  p_input_value_id_tbl   IN OUT nocopy        hr_entry.number_table,
  p_original_entry_id    IN             NUMBER,
  p_payroll_action_id    IN OUT nocopy        NUMBER,
  p_cost                 IN             VARCHAR2
) IS

   c_proc               VARCHAR2(100) := 'pay_us_tax_bals_adj_pkg.create_adjustment';

   -- variables used during the creation of a balance adjustment
   l_adjustment_date    DATE;
   l_dummy_date         DATE;
   l_dummy_number       NUMBER;
   l_element_entry_id   NUMBER;

BEGIN

  Hr_Utility.Trace('Entering '|| c_proc);

  -- set up adjustment date
  l_adjustment_date := p_adjustmnt_date;

  -- create balance adjustment element entry
  hr_entry_api.insert_element_entry(
   p_effective_start_date => l_adjustment_date,
   p_effective_end_date   => l_dummy_date,
   p_element_entry_id     => l_element_entry_id,
   p_assignment_id        => p_assignment_id,
   p_element_link_id      => p_element_link_id,
   p_creator_type         => 'B',  -- (B)alance Adjustment
   p_entry_type           => 'B',  -- (B)alance Adjustment
   p_num_entry_values     => p_num_entry_values,
   p_input_value_id_tbl   => p_input_value_id_tbl,
   p_entry_value_tbl      => p_entry_value_tbl );


  UPDATE  PAY_ELEMENT_ENTRIES_F
  SET     balance_adj_cost_flag = p_cost
  WHERE   element_entry_id = l_element_entry_id
  and     effective_start_date = l_adjustment_date
  and     effective_end_date = l_dummy_date
  ;


  -- reset the adjustment date
  -- NB. the elemnt entry API sets the adjustment
  -- date to be the first day of the period in which the adjustment was made
  l_adjustment_date := p_adjustmnt_date;


  -- apply the balance adjustment ie. create payroll action, create assignment
  -- action and resequence it as necessary
  hrassact.bal_adjust_actions(
         consetid       => p_consolidation_set_id,
         eentryid       => l_element_entry_id,
         effdate        => l_adjustment_date,
         act_type       => 'B',
         pyactid        => p_payroll_action_id,
         asactid        => l_dummy_number);

  IF (p_original_entry_id IS NOT NULL) THEN
     UPDATE PAY_RUN_RESULTS
     SET source_id = p_original_entry_id
     WHERE source_id = l_element_entry_id
     and source_type = 'E';
  END IF;

  Hr_Utility.Trace('Leaving pay_us_tax_bals_adj_pkg.create_adjustment');

END create_adjustment;



PROCEDURE private_trace(
  p_procedure_name      IN      VARCHAR2,
  p_msg_txt             IN      VARCHAR2) IS

BEGIN

   Hr_Utility.Trace('|' || p_procedure_name || '() : ' || p_msg_txt);

END private_trace;



PROCEDURE process_input(
  p_element_type        IN      VARCHAR2,
  p_element_type_id             NUMBER,
  p_iv_tbl              IN OUT nocopy hr_entry.number_table,
  p_iv_names_tbl        IN OUT nocopy hr_entry.varchar2_table,
  p_ev_tbl              IN OUT nocopy hr_entry.varchar2_table,
  p_bg_id                       NUMBER,
  p_adj_date                    DATE,
  p_input_name                  VARCHAR2,
  p_entry_value                 VARCHAR2,
  p_row                 IN OUT nocopy NUMBER) IS

  CURSOR csr_inputs(v_element_type_id NUMBER,
                    v_input_name      VARCHAR2) IS
    SELECT i.input_value_id
    FROM   PAY_INPUT_VALUES_F i
    WHERE  i.element_type_id    = v_element_type_id
    and    (i.business_group_id = p_bg_id
            or i.business_group_id IS NULL
           )
    and    i.name = v_input_name
    and    p_adj_date BETWEEN
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
    ;

  CURSOR  csr_chk_fed_taxability(v_tax_type VARCHAR2) IS
    SELECT 'Y'
    FROM   PAY_TAXABILITY_RULES
    WHERE  jurisdiction_code = g_fed_jd
    and    tax_category      = g_earnings_category
    and    tax_type          = v_tax_type
    and    classification_id = g_classification_id
    ;

  l_input_value_id      NUMBER;
  l_taxable             VARCHAR2(1)  := 'N';
  c_proc                VARCHAR2(100) := 'pay_us_tax_bals_adj_pkg.process_input';
  l_jurisdiction_code   VARCHAR2(11);

BEGIN
  Hr_Utility.Set_Location(c_proc, 10);

  OPEN csr_inputs (p_element_type_id, p_input_name);
  FETCH csr_inputs INTO l_input_value_id;
  CLOSE csr_inputs;

  IF (l_input_value_id IS NULL) THEN
    Hr_Utility.Set_Location(c_proc, 20);
    Hr_Utility.Trace('input_value_id not found for ' ||
                     p_input_name ||
                     ' for ele_type_id ' ||
                     To_Char(p_element_type_id));
    Hr_Utility.Set_Message(801, 'PY_50014_TXADJ_IV_ID_NOT_FOUND');
    Hr_Utility.Raise_Error;
  END IF;

  -- check taxability of the tax balance element
  Hr_Utility.Set_Location(c_proc, 30);

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

      Hr_Utility.Set_Location(c_proc, 40);

      IF (p_element_type IN ('SUI_EE', 'SUI_SUBJECT_EE',
                             'SUI_ER', 'SUI_SUBJECT_ER')) THEN
        Hr_Utility.Set_Location(c_proc, 41);
        OPEN  csr_chk_taxability ('SUI', g_state_jd );
        FETCH csr_chk_taxability INTO l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type IN ('Medicare_EE', 'Medicare_ER')) THEN
        Hr_Utility.Set_Location(c_proc, 42);
        OPEN  csr_chk_fed_taxability ('MEDICARE');
        FETCH csr_chk_fed_taxability INTO l_taxable;
        CLOSE csr_chk_fed_taxability;

      ELSIF (p_element_type IN ('SS_EE', 'SS_ER')) THEN
        Hr_Utility.Set_Location(c_proc, 43);
        OPEN  csr_chk_fed_taxability ('SS');
        FETCH csr_chk_fed_taxability INTO l_taxable;
        CLOSE csr_chk_fed_taxability;

      ELSIF (p_element_type IN ('FUTA')) THEN
        Hr_Utility.Set_Location(c_proc, 43);
        OPEN  csr_chk_fed_taxability ('FUTA');
        FETCH csr_chk_fed_taxability INTO l_taxable;
        CLOSE csr_chk_fed_taxability;

      ELSIF (p_element_type IN ('SDI_EE', 'SDI_SUBJECT_EE',
                                'SDI_ER', 'SDI_SUBJECT_ER')) THEN
        Hr_Utility.Set_Location(c_proc, 42);
        OPEN  csr_chk_taxability ('SDI', g_state_jd );
        FETCH csr_chk_taxability into l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type IN ('SIT_SUBJECT_WK')) THEN
        Hr_Utility.Set_Location(c_proc, 43);
        OPEN  csr_chk_taxability ('SIT', g_state_jd );
        FETCH csr_chk_taxability INTO l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type IN ('City_SUBJECT_WK')) THEN
        Hr_Utility.Set_Location(c_proc, 44);
        l_jurisdiction_code := substr(g_city_jd,1,3) || '000' || substr(g_city_jd,7,5);
        OPEN  csr_chk_taxability ('CITY', l_jurisdiction_code);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        IF csr_chk_taxability%NOTFOUND THEN
           CLOSE csr_chk_taxability;
           OPEN  csr_chk_taxability ('SIT', g_state_jd);
           FETCH csr_chk_taxability INTO l_taxable;
           CLOSE csr_chk_taxability;
        ELSE
           CLOSE csr_chk_taxability;
        END IF;

      ELSIF (p_element_type IN ('County_SUBJECT_WK')) THEN
        Hr_Utility.Set_Location(c_proc, 45);
        OPEN  csr_chk_taxability ('COUNTY', g_county_jd);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        IF csr_chk_taxability%NOTFOUND THEN
           CLOSE csr_chk_taxability;
           OPEN  csr_chk_taxability ('SIT', g_state_jd);
           FETCH csr_chk_taxability INTO l_taxable;
           CLOSE csr_chk_taxability;
        ELSE
           CLOSE csr_chk_taxability;
        END IF;

      END IF;

    ELSIF (p_input_name = 'Subj NWhable') THEN
           Hr_Utility.Set_Location(c_proc, 50);

      IF (p_element_type IN ('SIT_SUBJECT_WK')) THEN
        Hr_Utility.Set_Location(c_proc, 51);
        OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
        FETCH csr_chk_taxability INTO l_taxable;
        CLOSE csr_chk_taxability;

      ELSIF (p_element_type IN ('City_SUBJECT_WK')) THEN
        Hr_Utility.Set_Location(c_proc, 52);
        l_jurisdiction_code := substr(g_city_jd,1,3) || '000' || substr(g_city_jd,7,5);
        OPEN  csr_chk_taxability ('NW_CITY', l_jurisdiction_code);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        IF csr_chk_taxability%NOTFOUND THEN
           CLOSE csr_chk_taxability;
           OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
           FETCH csr_chk_taxability INTO l_taxable;
           CLOSE csr_chk_taxability;
        ELSE
           CLOSE csr_chk_taxability;
        END IF;

      ELSIF (p_element_type IN ('County_SUBJECT_WK')) THEN
        Hr_Utility.Set_Location(c_proc, 53);
        OPEN  csr_chk_taxability ('NW_COUNTY', g_county_jd);
        FETCH csr_chk_taxability INTO l_taxable;
        --  If the above query returns no rows then check the state level taxablility rule
        IF csr_chk_taxability%NOTFOUND THEN
           CLOSE csr_chk_taxability;
           OPEN  csr_chk_taxability ('NW_SIT', g_state_jd);
           FETCH csr_chk_taxability INTO l_taxable;
           CLOSE csr_chk_taxability;
        ELSE
           CLOSE csr_chk_taxability;
        END IF;

      END IF;

    ELSE
      Hr_Utility.Set_Location(c_proc, 60);
      -- otherwise we do not need to check taxability_rules
      -- in order to set the value of the input value,
      -- NB. that this step gets executed for tax elements like FIT, Medicare
      -- as well as Tax balance elements like SUI_SUBJECT_EE
      l_taxable := 'Y';
    END IF;

  ELSE
    -- an Earnings Element so no taxability rules
    Hr_Utility.Set_Location(c_proc, 70);

    l_taxable := 'Y';

  END IF;


  IF (l_taxable = 'Y') THEN
    Hr_Utility.Set_Location (c_proc, 200);
    Hr_Utility.Trace('row ' ||
                        To_Char(p_row) ||
                        ' inpvl_id>' ||
                        To_Char(l_input_value_id) ||
                        '< ' ||
                        p_input_name ||
                        '  ' ||
                        p_entry_value);

    p_iv_tbl(p_row)       := l_input_value_id;
    p_iv_names_tbl(p_row) := p_input_name;
    p_ev_tbl(p_row)       := p_entry_value;
    p_row                 := p_row + 1;  -- next row in plsql table
  END IF;

END process_input;



PROCEDURE fetch_wage_limits(
  p_effective_date      IN      DATE     DEFAULT NULL,
  p_state_abbrev        IN      VARCHAR2 DEFAULT NULL,
  p_futa_wage_limit     OUT  nocopy   NUMBER,
  p_ss_ee_wage_limit    OUT nocopy    NUMBER,
  p_ss_er_wage_limit    OUT  nocopy   NUMBER,
  p_sdi_ee_wage_limit   OUT nocopy    NUMBER,
  p_sdi_er_wage_limit   OUT  nocopy   NUMBER,
  p_sui_ee_wage_limit   OUT  nocopy   NUMBER,
  p_sui_er_wage_limit   OUT  nocopy   NUMBER) IS

  c_proc        VARCHAR2(100) := 'fetch_wage_limits';

  l_futa_wage_limit   NUMBER;
  l_ss_ee_wage_limit  NUMBER;
  l_ss_er_wage_limit  NUMBER;
  l_sdi_ee_wage_limit NUMBER;
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
            ti.sui_er_wage_limit
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
    l_sui_er_wage_limit;
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
    Hr_Utility.Set_Location(c_proc, 10);
    Hr_Utility.Set_Message(801, 'PY_50014_TXADJ_IV_ID_NOT_FOUND');
    Hr_Utility.Raise_Error;
  END IF;


  /*
  ** copy limits into return parameters
  */
  p_futa_wage_limit  := l_futa_wage_limit;
  p_ss_ee_wage_limit := l_ss_ee_wage_limit;
  p_ss_er_wage_limit := l_ss_er_wage_limit;
  p_sdi_ee_wage_limit := l_sdi_ee_wage_limit;
  p_sdi_er_wage_limit := l_sdi_er_wage_limit;
  p_sui_ee_wage_limit := l_sui_ee_wage_limit;
  p_sui_er_wage_limit := l_sui_er_wage_limit;

END fetch_wage_limits;



PROCEDURE process_limits(
  p_element_type        IN      VARCHAR2,
  p_earn_amount         IN      NUMBER,
  p_iv_tbl              IN      Hr_Entry.number_table,
  p_iv_names_tbl        IN      Hr_Entry.varchar2_table,
  p_ev_tbl              IN OUT nocopy  Hr_Entry.varchar2_table,
  p_num_ev              IN      NUMBER) IS

  c_proc         VARCHAR2(100) := 'process_limits';

  l_return_bal       VARCHAR2(30);
  l_adj_amt          NUMBER;
  l_excess           NUMBER;
  l_taxable_iv_pos   NUMBER := 0;
  l_old_taxable_bal  NUMBER;
  l_limit            NUMBER;

BEGIN

   Hr_Utility.Trace('|');
   private_trace(c_proc, p_element_type);
   Hr_Utility.Trace('|  ***** Start Dump *****');
   FOR l_i IN 1..(p_num_ev - 1) LOOP

     Hr_Utility.Trace('|    ' ||
                        To_Char(l_i) ||
                        ' ' ||
                        p_iv_names_tbl(l_i) ||
                        ' ' ||
                        To_Char(p_iv_tbl(l_i)) ||
                        ' ' ||
                        p_ev_tbl(l_i));

     FOR l_j IN 1..1000 LOOP
       NULL;
     END LOOP;

   END LOOP;
   Hr_Utility.Trace('|  ***** End Dump *****');


  /*
  ** find position of TAXABLE IV in tbl structure
  */
  FOR l_i IN 1..(p_num_ev - 1) LOOP

    IF (p_iv_names_tbl(l_i) = 'TAXABLE') THEN
      l_taxable_iv_pos := l_i;
    END IF;

  END LOOP;


  /*
  ** set up taxable balance and limit for limit processing
  */
  IF (p_element_type = 'Medicare_EE') THEN
    l_old_taxable_bal := g_medicare_ee_taxable;
    /*
    ** Medicare EE and ER should have an infinite limit,
    ** at a later stage a legislative limit may be defined,
    ** therefore set to an arbitary value (99,999,999),
    ** as used in PAY_US_STATE_TAX_INFO_F for NY
    */
    l_limit := 99999999;

  ELSIF (p_element_type = 'Medicare_ER') THEN
    l_old_taxable_bal := g_medicare_er_taxable;
    l_limit := 99999999;

  ELSIF (p_element_type = 'FUTA') THEN
    l_old_taxable_bal := g_futa_taxable;
    l_limit := g_futa_wage_limit;

  ELSIF (p_element_type = 'SS_EE') THEN
    l_old_taxable_bal := g_ss_ee_taxable;
    l_limit := g_ss_ee_wage_limit;

  ELSIF (p_element_type = 'SS_ER') THEN
    l_old_taxable_bal := g_ss_er_taxable;
    l_limit := g_ss_er_wage_limit;

  ELSIF (p_element_type = 'SDI_EE') THEN
    l_old_taxable_bal := g_sdi_ee_taxable;
    l_limit := g_sdi_ee_wage_limit;

  ELSIF (p_element_type = 'SDI_ER') THEN
    l_old_taxable_bal := g_sdi_er_taxable;
    l_limit := g_sdi_er_wage_limit;

  ELSIF (p_element_type = 'SUI_EE') THEN
    l_old_taxable_bal := g_sui_ee_taxable;
    l_limit := g_sui_ee_wage_limit;

  ELSIF (p_element_type = 'SUI_ER') THEN
    l_old_taxable_bal := g_sui_er_taxable;
    l_limit := g_sui_er_wage_limit;
  ELSE
    /** stub - find appropriate message **/
    Hr_Utility.Set_Location(c_proc, 10);
    Hr_Utility.Set_Message(801, 'PY_50014_TXADJ_IV_ID_NOT_FOUND');
    Hr_Utility.Raise_Error;

  END IF;


  /*
  ** generic block, applies to all limit processing
  */
  IF ((l_old_taxable_bal + p_earn_amount) < l_limit) THEN
    /*
    ** no limit exceeded,
    ** ok to make the balance adjustment,
    ** do nothing with EV amount of TAXABLE IV
    */
    private_trace(c_proc, 'OK to make BA without altering EV amount of TAXABLE IV');

  ELSIF (l_old_taxable_bal > l_limit) THEN
    /*
    ** taxable balance already exceeds limit,
    ** set EV amount of TAXABLE IV to 0,
    ** therefore the EV amount feeds Excess
    */
    private_trace(c_proc, 'limit exceeded, put EV amount of TAXABLE IV into excess');
    p_ev_tbl(l_taxable_iv_pos) := 0;

  ELSIF (l_old_taxable_bal + p_earn_amount > l_limit) THEN
    /*
    ** EV amount of TAXABLE IV will cause limit to be exceeded,
    ** set EV amount up to limit
    */
    l_adj_amt := l_limit - l_old_taxable_bal;

    private_trace(c_proc, 'EV amount of TAXABLE IV up to limit>' ||
                        To_Char(l_adj_amt) || '<');

    l_excess := (p_earn_amount + l_old_taxable_bal) - l_limit;


    /*
    ** excess displayed for information only
    */
    private_trace(c_proc, 'excess>' || To_Char(l_excess) || '<');


    /*
    ** modify EV amount of TAXABLE IV before BA processing,
    ** set EV amount up to limit, remainder goes into excess
    */
    p_ev_tbl(l_taxable_iv_pos) := fnd_number.number_to_canonical(l_adj_amt);

  END IF;

END process_limits;



PROCEDURE process_element(
  p_assignment_id             NUMBER,
  p_consolidation_set_id      NUMBER,
  p_element_type              VARCHAR2,
  p_abbrev_element_type       VARCHAR2,
  p_bg_id                     NUMBER,
  p_adjustment_date           DATE,
  p_earn_amount               NUMBER,
  p_adj_amount                NUMBER,
  p_jurisdiction              VARCHAR2,
  p_cost                      VARCHAR2) IS

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
    FROM   PAY_ELEMENT_CLASSIFICATIONS    c,
           PAY_ELEMENT_TYPES_F            e
    WHERE  e.element_name         = p_element_type
    and    (e.business_group_id   = p_bg_id
            or e.business_group_id IS NULL
           )
    and    e.classification_id    = c.classification_id
    and    p_adjustment_date BETWEEN
                effective_start_date AND effective_end_date
    ;

  CURSOR    csr_set_mandatory_inputs (v_element_type_id NUMBER) IS
    SELECT  i.name INPUT_NAME,
            i.input_value_id,
            Nvl(hr.meaning, NVL(i.default_value,
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
    FROM    HR_LOOKUPS            hr,
            PAY_INPUT_VALUES_F    i
    WHERE   i.element_type_id     = v_element_type_id
    and     i.mandatory_flag      = 'Y'
    and     i.default_value       = hr.lookup_code (+)
    and     i.lookup_type         = hr.lookup_type (+)
    and     i.name NOT IN ('Pay Value')
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

  Hr_Utility.Trace('Entering pay_us_tax_bals_adj_pkg.process_element');
  Hr_Utility.Set_Location(c_proc, 10);
  OPEN csr_element;
  FETCH csr_element INTO l_element;
  CLOSE csr_element;

  IF (l_element.element_type_id IS NULL) THEN
    Hr_Utility.Set_Location(c_proc, 20);
    Hr_Utility.Trace('Element does not exist: '||p_element_type);
    Hr_Utility.Set_Message(801, 'HR_6884_ELE_ENTRY_NO_ELEMENT');
    Hr_Utility.Raise_Error;
  END IF;

  Hr_Utility.Set_Location(c_proc, 30);
  l_ele_link_id := hr_entry_api.get_link(
                        p_assignment_id   => p_assignment_id,
                        p_element_type_id => l_element.element_type_id,
                        p_session_date    => p_adjustment_date);

  IF (l_ele_link_id IS NULL) THEN
    Hr_Utility.Set_Location(c_proc, 40);
    Hr_Utility.Trace('Link does not exist for element: '||p_element_type);
    Hr_Utility.Set_Message(801, 'PY_51132_TXADJ_LINK_MISSING');
    Hr_Utility.Set_Message_token ('ELEMENT', p_element_type);
    Hr_Utility.Raise_Error;
  END IF;


  -- initialize tables
  l_iv_names_tbl := g_dummy_varchar_tbl;
  l_iv_tbl       := g_dummy_number_tbl;
  l_ev_tbl       := g_dummy_varchar_tbl;
  l_num_ev       := 1;


  -- explicitly set the various input values,
  -- this clearly identifies which input values are expected and will cause failure
  -- if the input value has been deleted somehow
  Hr_Utility.Set_Location(c_proc, 50);

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
    Hr_Utility.Set_Location (c_proc, 60);
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

  ELSIF (p_element_type IN ('FIT 3rd Party')) THEN
    Hr_Utility.Set_Location (c_proc, 65);
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);

  ELSIF (p_element_type IN ('SS_EE', 'Medicare_EE')) THEN
    Hr_Utility.Set_Location(c_proc, 71);
    IF (p_adj_amount <> 0) THEN
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    END IF;

    Hr_Utility.Set_Location(c_proc, 72);
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'TAXABLE',      fnd_number.number_to_canonical(p_earn_amount), l_num_ev);

    /*
    ** cap the EV amount for the TAXABLE IV if necessary
    */
    process_limits(p_element_type, p_earn_amount, l_iv_tbl,
                l_iv_names_tbl, l_ev_tbl, l_num_ev);





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
    process_limits(p_element_type, p_earn_amount, l_iv_tbl,
                   l_iv_names_tbl, l_ev_tbl, l_num_ev);






  ELSIF (p_element_type IN ('SIT_WK')) THEN
    Hr_Utility.Set_Location(c_proc, 81);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    Hr_Utility.Set_Location(c_proc, 82);

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





/** sbilling **/
  /*
  ** new tax element to be processed, use SIT_WK as a template
  */
  ELSIF (p_element_type IN ('County_SC_WK')) THEN
    Hr_Utility.Set_Location(c_proc, 81);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    Hr_Utility.Set_Location(c_proc, 82);


    /*
    ** can't put the Gross for the BA into the Gross for the school district tax,
    ** County_SC_WK has no TAXABLE input
    */
    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);






  ELSIF (p_element_type IN ('SUI_EE', 'SDI_EE')) THEN
    Hr_Utility.Set_Location(c_proc, 91);

    IF (p_adj_amount <> 0) THEN
      process_input(p_element_type, l_element.element_type_id,
                    l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                    p_bg_id,        p_adjustment_date,
                    'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
      Hr_Utility.Set_Location(c_proc, 915);
    END IF;

    Hr_Utility.Set_Location(c_proc, 92);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'TAXABLE',      fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    Hr_Utility.Set_Location(c_proc, 93);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);

    /*
    ** cap the EV amount for the TAXABLE EV if necessary
    */
    process_limits(p_element_type, p_earn_amount, l_iv_tbl,
                   l_iv_names_tbl, l_ev_tbl, l_num_ev);







  ELSIF (p_element_type IN ('City_WK', 'County_WK')) THEN
    Hr_Utility.Set_Location(c_proc, 101);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Pay Value',    fnd_number.number_to_canonical(p_adj_amount),  l_num_ev);
    Hr_Utility.Set_Location(c_proc, 102);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);

  ELSIF (p_element_type IN ('SIT_SUBJECT_WK', 'City_SUBJECT_WK',
                            'County_SUBJECT_WK')) THEN
    Hr_Utility.Set_Location(c_proc, 111);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);
    Hr_Utility.Set_Location(c_proc, 112);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Gross',        fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    Hr_Utility.Set_Location(c_proc, 113);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Subj Whable',  fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    Hr_Utility.Set_Location(c_proc, 114);

    IF (g_classification IN ('Imputed Earnings',
                             'Supplemental Earnings')) THEN
      Hr_Utility.Set_Location(c_proc, 115);

      process_input (p_element_type, l_element.element_type_id,
                     l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                     p_bg_id,        p_adjustment_date,
                     'Subj NWhable', fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    END IF;

  ELSIF (p_element_type IN ('SDI_SUBJECT_EE', 'SDI_SUBJECT_ER',
                            'SUI_SUBJECT_EE', 'SUI_SUBJECT_ER')) THEN
    Hr_Utility.Set_Location(c_proc, 121);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Jurisdiction', p_jurisdiction,         l_num_ev);
    Hr_Utility.Set_Location(c_proc, 122);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Gross',        fnd_number.number_to_canonical(p_earn_amount), l_num_ev);
    Hr_Utility.Set_Location(c_proc, 123);

    process_input(p_element_type, l_element.element_type_id,
                  l_iv_tbl,       l_iv_names_tbl,         l_ev_tbl,
                  p_bg_id,        p_adjustment_date,
                  'Subj Whable',  fnd_number.number_to_canonical(p_earn_amount), l_num_ev);

  ELSIF (p_element_type IN ('SUI_ER', 'SDI_ER')) THEN
    Hr_Utility.Set_Location (c_proc, 124);


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
                   l_iv_names_tbl, l_ev_tbl, l_num_ev);
  END IF;

  -- because process_input will increment l_num_ev if it is successful
  l_num_ev := l_num_ev - 1;


  -- set mandatory input values,
  -- cannot set these to null, core package expects mandatory values to be entered
  Hr_Utility.Set_Location(c_proc, 130);

  FOR l_req_input IN csr_set_mandatory_inputs (l_element.element_type_id) LOOP
    -- first, check if the mandatory input value was explicitly
    -- set above,  do nothing in this case
    Hr_Utility.Set_Location(c_proc, 140);

    FOR l_counter IN 1..l_num_ev LOOP

       IF (l_req_input.input_name = l_iv_names_tbl(l_counter)) THEN
          NULL;
       ELSE
          -- then the input value was not previously set by one of the
          -- process_inputs called in process_elements
          Hr_Utility.Set_Location(c_proc, 150);
          l_num_ev := l_num_ev + 1;

          l_iv_tbl(l_num_ev)            := l_req_input.input_value_id;
          l_iv_names_tbl(l_num_ev)      := l_req_input.input_name;
          l_ev_tbl(l_num_ev)            := l_req_input.default_value;
       END IF;

    END LOOP;

  END LOOP;

  Hr_Utility.Set_Location(c_proc, 160);
  create_adjustment(
        p_adjustmnt_date        => p_adjustment_date,
        p_assignment_id         => p_assignment_id,
        p_element_link_id       => l_ele_link_id,
        p_consolidation_set_id  => p_consolidation_set_id,
        p_num_entry_values      => l_num_ev,
        p_entry_value_tbl       => l_ev_tbl,
        p_input_value_id_tbl    => l_iv_tbl,
        p_original_entry_id     => NULL,
        p_payroll_action_id     => l_payroll_action_id,
        p_cost  => p_cost);

   -- populate the payroll_actions table with the adjustment
   -- payroll_action_id
   Hr_Utility.Set_Location(c_proc, 200);
   Hr_Utility.Trace('Tax type= '||p_element_type ||
                    ' pactid = '||To_Char(l_payroll_action_id));
   g_tax_type_tbl(g_pact_cntr)          := p_abbrev_element_type;
   g_tax_adj_pactid_tbl(g_pact_cntr)    := l_payroll_action_id;
   g_pact_cntr                          := g_pact_cntr + 1;

   Hr_Utility.Trace('Leaving pay_us_tax_bals_adj_pkg.process_element');

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
    Hr_Utility.Set_Location(c_proc, 10);
    l_geocode := hr_us_ff_udfs.addr_val(
                p_state_abbrev => p_state_abbrev,
                p_county_name  => p_county_name,
                p_city_name    => p_city_name,
                p_zip_code     => p_zip_code );

    OPEN csr_chk_local(l_geocode);
    FETCH csr_chk_local INTO l_valid_for_asg;
    CLOSE csr_chk_local;

    IF (l_valid_for_asg = 'FAIL') THEN
      Hr_Utility.Set_Location(c_proc, 15);
      Hr_Utility.Trace('The city is not valid for the assignment');
      Hr_Utility.Set_Message(801, 'PY_51133_TXADJ_INVALID_CITY');
      Hr_Utility.Raise_Error;
    END IF;

  ELSIF (p_county_name IS NOT NULL AND p_state_abbrev IS NOT NULL) THEN
    Hr_Utility.Set_Location(c_proc, 20);
    OPEN csr_county_code;
    FETCH csr_county_code INTO l_state_code, l_county_code;
    CLOSE csr_county_code;
    l_geocode := l_state_code||'-'||l_county_code||'-0000';

    OPEN csr_chk_local(l_geocode);
    FETCH csr_chk_local INTO l_valid_for_asg;
    CLOSE csr_chk_local;

    IF (l_valid_for_asg = 'FAIL') THEN
      Hr_Utility.Set_Location(c_proc, 25);
      Hr_Utility.Trace('The county is not valid for the assignment');
      Hr_Utility.Set_Message(801, 'PY_51133_TXADJ_INVALID_CITY');
      Hr_Utility.Raise_Error;
    END IF;

  ELSIF (p_county_name IS NULL AND p_state_abbrev IS NOT NULL) THEN
    Hr_Utility.Set_Location(c_proc, 30);
    OPEN csr_state_code;
    FETCH csr_state_code INTO l_state_code;
    CLOSE csr_state_code;
    l_geocode := l_state_code||'-000-0000';

    OPEN csr_chk_state;
    FETCH csr_chk_state INTO l_valid_for_asg;
    CLOSE csr_chk_state;

    IF (l_valid_for_asg = 'FAIL') THEN
      Hr_Utility.Set_Location(c_proc, 25);
      Hr_Utility.Trace('The state is not valid for the assignment');
      Hr_Utility.Set_Message(801, 'PY_51133_TXADJ_INVALID_CITY');
      Hr_Utility.Raise_Error;
    END IF;

  ELSE
    l_geocode := '00-000-0000';

  END IF;

  Hr_Utility.Trace('|derived geocode>' || l_geocode || '<');
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

  l_return_bal := pay_us_tax_bals_pkg.us_tax_balance(
			p_tax_balance_category => 'TAXABLE',
			p_tax_type             => p_tax_bal_name,
			p_ee_or_er             => p_ee_or_er,
			p_time_type            => 'YTD',
			p_asg_type             => 'PER',
			p_gre_id_context       => p_tax_unit_id,
			p_jd_context           => p_geocode,
			p_assignment_action_id => NULL,
			p_assignment_id        => p_assignment_id,
			p_virtual_date         => l_date);

  private_trace(c_proc, p_tax_bal_name || ' ' || p_ee_or_er ||
                        ' TAXABLE>' || To_Char(l_return_bal) || '<');
  Return(l_return_bal);

END taxable_balance;

FUNCTION tax_exists (p_jd_code VARCHAR2, p_tax_type VARCHAR2,
                     p_adj_date DATE)
RETURN VARCHAR2 IS

l_exists        VARCHAR2(1) := 'N';

cursor sdi_er_exists is
select 'Y'
from pay_us_state_tax_info_f
where state_code = substr(p_jd_code, 1, 2)
and sdi_er_wage_limit IS NOT NULL
and p_adj_date between effective_start_date and effective_end_date;

cursor sdi_ee_exists is
select 'Y'
from pay_us_state_tax_info_f
where state_code = substr(p_jd_code, 1, 2)
and sdi_ee_wage_limit IS NOT NULL
and p_adj_date between effective_start_date and effective_end_date;

cursor sui_er_exists is
select 'Y'
from pay_us_state_tax_info_f
where state_code = substr(p_jd_code, 1, 2)
and sui_er_wage_limit IS NOT NULL
and p_adj_date between effective_start_date and effective_end_date;

cursor sui_ee_exists is
select 'Y'
from pay_us_state_tax_info_f
where state_code = substr(p_jd_code, 1, 2)
and sui_ee_wage_limit IS NOT NULL
and p_adj_date between effective_start_date and effective_end_date;

cursor sit_exists is
select sit_exists
from pay_us_state_tax_info_f
where state_code = substr(p_jd_code, 1, 2)
and p_adj_date between effective_start_date and effective_end_date;

cursor county_exists is
select county_tax
from pay_us_county_tax_info_f
where jurisdiction_code = substr(p_jd_code, 1, 7)||'0000'
and p_adj_date between effective_start_date and effective_end_date;

cursor city_exists is
select city_tax
from pay_us_city_tax_info_f
where jurisdiction_code = p_jd_code
and p_adj_date between effective_start_date and effective_end_date;

BEGIN

IF (p_tax_type = 'SUI_ER') THEN
open sui_er_exists;
fetch sui_er_exists into l_exists;
close sui_er_exists;

ELSIF (p_tax_type = 'SUI_EE') THEN
open sui_ee_exists;
fetch sui_ee_exists into l_exists;
close sui_ee_exists;

ELSIF (p_tax_type = 'SDI_ER') THEN
open sdi_er_exists;
fetch sdi_er_exists into l_exists;
close sdi_er_exists;

ELSIF (p_tax_type = 'SDI_EE') THEN
open sdi_ee_exists;
fetch sdi_ee_exists into l_exists;
close sdi_ee_exists;

ELSIF (p_tax_type = 'SIT') THEN
open sit_exists;
fetch sit_exists into l_exists;
close sit_exists;

ELSIF (p_tax_type = 'CITY') THEN
open city_exists;
fetch city_exists into l_exists;
close city_exists;

ELSIF (p_tax_type = 'COUNTY') THEN
open county_exists;
fetch county_exists into l_exists;
close county_exists;

ELSE
null;
END IF;

RETURN l_exists;
END tax_exists;

PROCEDURE create_tax_balance_adjustment(
  p_adjustment_date       DATE,
  p_business_group_name   VARCHAR2,
  p_assignment_number     VARCHAR2,
  p_tax_unit_id           NUMBER,
  p_consolidation_set     VARCHAR2,
  p_earning_element_type  VARCHAR2        DEFAULT NULL,
  p_gross_amount          NUMBER          DEFAULT 0,
  p_net_amount            NUMBER          DEFAULT 0,
  p_fit                   NUMBER          DEFAULT 0,
  p_fit_third             VARCHAR2        DEFAULT NULL,
  p_ss                    NUMBER          DEFAULT 0,
  p_medicare              NUMBER          DEFAULT 0,
  p_sit                   NUMBER          DEFAULT 0,
  p_sui                   NUMBER          DEFAULT 0,
  p_sdi                   NUMBER          DEFAULT 0,
  p_county                NUMBER          DEFAULT 0,
  p_city                  NUMBER          DEFAULT 0,
  p_city_name             VARCHAR2        DEFAULT NULL,
  p_state_abbrev          VARCHAR2        DEFAULT NULL,
  p_county_name           VARCHAR2        DEFAULT NULL,
  p_zip_code              VARCHAR2        DEFAULT NULL,
  p_cost                  VARCHAR2        DEFAULT NULL,
/** sbilling **/
  p_futa_er               NUMBER          DEFAULT 0,
  p_sui_er                NUMBER          DEFAULT 0,
  p_sdi_er                NUMBER          DEFAULT 0,
  p_sch_dist_wh_ee        NUMBER          DEFAULT 0,
  p_sch_dist_jur          VARCHAR2        DEFAULT NULL) IS

  c_proc  VARCHAR2(100) := 'create_tax_balance_adjustment';

  l_bg_id                       NUMBER;
  l_consolidation_set_id        NUMBER;
  l_assignment_id               NUMBER;

  l_jd_entered                  VARCHAR2(11) := '00-000-0000';
  l_jd_level_entered            NUMBER       := 1;
  l_jd_level_needed             NUMBER;

  l_primary_asg_state           VARCHAR2(2);

  l_counter                     NUMBER;
  l_grp_key                     pay_payroll_actions.legislative_parameters%TYPE;

  CURSOR csr_sdi_check IS
    SELECT region_2               primary_asg_state
    FROM   HR_LOCATIONS           loc,
           PER_ASSIGNMENTS_F      asg,
           PER_BUSINESS_GROUPS    bg      -- Bug fix 1398865. Ensures one row is returned
    WHERE  asg.assignment_number  = p_assignment_number
    and    asg.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date BETWEEN
                asg.effective_start_date AND asg.effective_end_date
    and    asg.primary_flag       = 'Y'
    and    asg.location_id        = loc.location_id
    ;

  CURSOR csr_sui_geocode  IS
    SELECT sui_jurisdiction_code,
           pus.state_abbrev
    FROM   PAY_US_EMP_FED_TAX_RULES_F  fed,
           PER_ASSIGNMENTS_F   a,
           PER_BUSINESS_GROUPS  bg,
           pay_us_states        pus
    WHERE  fed.assignment_id   = a.assignment_id
    and    a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date BETWEEN
		fed.effective_start_date AND fed.effective_end_date
    and    p_adjustment_date BETWEEN
		a.effective_start_date AND a.effective_end_date
    and    fed.sui_state_code = pus.state_code
    ;

  -- local copy of the tax withhelds,
  -- by copying the values to local variables,
  -- we avoid defining parameters as IN/OUT variables
  l_gross_amount                NUMBER;
  l_net_amount                  NUMBER;
  l_fit                         NUMBER;
  l_ss                          NUMBER;
  l_medicare                    NUMBER;
  l_sit                         NUMBER;
  l_sui_ee                      NUMBER;
  l_sdi_ee                      NUMBER;
  l_city                        NUMBER;
  l_county                      NUMBER;
  l_total_taxes_withheld        NUMBER;
  l_fit_third                   VARCHAR2(5);

/** sbilling **/
  l_futa_er                     NUMBER;
  l_sui_er                      NUMBER;
  l_sdi_er                      NUMBER;
  l_sch_dist_wh_ee              NUMBER;
  l_sch_dist_jur                VARCHAR2(10);


BEGIN
  --Hr_Utility.Trace_on(NULL, 'RANJANA');

  -- copy parameters to local variables and set to 0 if null
  l_gross_amount   := Nvl(p_gross_amount, 0);
  l_net_amount     := Nvl(p_net_amount, 0);
  l_fit            := Nvl(p_fit, 0);
  l_fit_third      := Nvl(p_FIT_THIRD, 'NO');
  l_ss             := Nvl(p_ss, 0);
  l_medicare       := Nvl(p_medicare, 0);
  l_sit            := Nvl(p_sit, 0);
  l_sdi_ee         := Nvl(p_sdi, 0);
  l_sui_ee         := Nvl(p_sui, 0);
  l_city           := Nvl(p_city, 0);
  l_county         := Nvl(p_county, 0);

  l_futa_er        := Nvl(p_futa_er, 0);
  l_sui_er         := Nvl(p_sui_er, 0);
  l_sdi_er         := Nvl(p_sdi_er, 0);
  l_sch_dist_wh_ee := Nvl(p_sch_dist_wh_ee, 0);
  l_sch_dist_jur   := Nvl(p_sch_dist_jur, '');

  BEGIN
    Hr_Utility.Set_Location(c_proc, 5);
    SELECT a.assignment_id,
           a.business_group_id
    INTO   l_assignment_id,
           l_bg_id
    FROM   PER_BUSINESS_GROUPS bg,
           PER_ASSIGNMENTS_F   a
    WHERE  a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date BETWEEN
                a.effective_start_date AND a.effective_end_date
    ;
    EXCEPTION
       WHEN NO_DATA_FOUND OR too_many_rows THEN
          Hr_Utility.Set_Message(801, 'PY_51135_TXADJ_ASG_NOT_FOUND');
          Hr_Utility.Raise_Error;
  END;


l_jd_entered := derive_jd_geocode(p_assignment_id => l_assignment_id,
                                    p_state_abbrev  => p_state_abbrev,
                                    p_county_name   => p_county_name,
                                    p_city_name     => p_city_name,
                                    p_zip_code      => p_zip_code );

/** sbilling **/
  /*
  ** get limits for tax, should fire once, copy variables into globals
  */
  IF (g_futa_wage_limit = 0) THEN
    fetch_wage_limits(p_adjustment_date,
                      p_state_abbrev,
                      g_futa_wage_limit,
                      g_ss_ee_wage_limit,  g_ss_er_wage_limit,
                      g_sdi_ee_wage_limit, g_sdi_er_wage_limit,
                      g_sui_ee_wage_limit, g_sui_er_wage_limit);

    private_trace(c_proc, 'g_futa_wage_limit>' || g_futa_wage_limit || '<');
    private_trace(c_proc, 'g_ss_ee_wage_limit>' || g_ss_ee_wage_limit || '<');
    private_trace(c_proc, 'g_ss_er_wage_limit>' || g_ss_er_wage_limit || '<');
    private_trace(c_proc, 'g_sdi_ee_wage_limit>' || g_sdi_ee_wage_limit || '<');
    private_trace(c_proc, 'g_sdi_er_wage_limit>' || g_sdi_er_wage_limit || '<');
    private_trace(c_proc, 'g_sui_ee_wage_limit>' || g_sui_ee_wage_limit || '<');
    private_trace(c_proc, 'g_sui_er_wage_limit>' || g_sui_er_wage_limit || '<');
  END IF;


  -- basic error checking
  -- 1.  check that Gross = Net + Taxes

  IF (l_gross_amount <> 0) THEN
    /*
    ** stub - do the ER components require validation,
    **        l_futa_er + l_sui_er + l_sdi_er + l_sch_dist_wh_ee
    */
    l_total_taxes_withheld := l_fit + l_ss + l_medicare + l_sit +
                              l_sui_ee + l_sdi_ee + l_county + l_city +
                              l_sch_dist_wh_ee;

     IF (l_gross_amount <> l_net_amount + l_total_taxes_withheld) THEN
        Hr_Utility.Set_Message(801, 'PY_51134_TXADJ_TAX_NET_TOT');
        Hr_Utility.Raise_Error;
     END IF;

  END IF;


  -- 2.  check that if an earnings element is provided if Gross is non-zero

  IF (l_gross_amount <> 0 AND p_earning_element_type IS NULL) THEN
        Hr_Utility.Set_Message(801, 'PY_51140_TXADJ_EARN_ELE_REQ');
        Hr_Utility.Raise_Error;
  END IF;


  -- 3.  check that SIT = 0 for Alaska, Florida, Nevada, New Hampshire, South Dakota,
  --     Tennessee, Texas, Washington, Wyoming, and the Virgin Islands

  IF ((l_sit <> 0 OR l_city <> 0 OR l_county <> 0)  AND
    --p_state_abbrev IN ('AK', 'FL', 'NV', 'NH', 'SD', 'TN', 'TX', 'WA', 'WY', 'VI')) THEN
    (tax_exists(l_jd_entered, 'SIT', p_adjustment_date) = 'N')) THEN
       Hr_Utility.Set_Message(801, 'PY_51141_TXADJ_SIT_EXEMPT');
       Hr_Utility.Raise_Error;
  END IF;

/* **** NOT USING JIT TABLES TO CHECK FOR CITY AND COUNTY TAXES YET **** */
/* Wait until the payroll run stops maintaining those balances, and users
   are able to clean up their data, before enforcing this through the
   Tax Balance Adjustment form.  Otherwise they will not be able to zero
   out corrupt balances.                                                 */

  IF ((l_county <> 0)  AND
    (tax_exists(l_jd_entered, 'COUNTY', p_adjustment_date) = 'N')) THEN
       Hr_Utility.Set_Message(801, 'PY_50980_TXADJ_COUNTY_EXEMPT');
       Hr_Utility.Raise_Error;
  END IF;

  IF ((l_city <> 0) AND
      (tax_exists(l_jd_entered, 'CITY', p_adjustment_date) = 'N')) THEN
       Hr_Utility.Set_Message(801, 'PY_50981_TXADJ_CITY_EXEMPT');
       Hr_Utility.Raise_Error;
  END IF;


  -- 4.  check that SDI = 0 for all states but California, Hawaii, New Jersey, New York,
  --     Puerto Rico, Rhode  Island
  --
  -- first, need to ensure that the JD passed in is/was the primary assignment state at the
  -- time of the adjustment,
  -- this is because VERTEX calculations for SDI only occur for the primary work location,
  -- if the JD passed in is not the primary work location,
  -- then ensuing VERTEX calculations will not reflect the balance adjustments

  IF ( l_sdi_ee <> 0 or l_sdi_er <> 0) THEN
    OPEN csr_sdi_check;
    FETCH csr_sdi_check INTO l_primary_asg_state;
    CLOSE csr_sdi_check;

    IF (l_primary_asg_state <> p_state_abbrev) THEN
      Hr_Utility.Set_Message(801, 'PY_51327_TXADJ_SDI_JD');
      Hr_Utility.Raise_Error;
    END IF;

  END IF;

  IF ( l_sdi_ee <> 0) THEN
    --IF (p_state_abbrev NOT IN ('CA', 'HI', 'NJ', 'NY', 'RI')) THEN
    IF (tax_exists(l_jd_entered, 'SDI_EE', p_adjustment_date) = 'N') THEN
      Hr_Utility.Set_Message(801, 'PY_51142_TXADJ_SDI_EXEMPT');
      Hr_Utility.Raise_Error;
    END IF;

  END IF;

  IF ( l_sdi_er <> 0) THEN
    --IF (p_state_abbrev NOT IN ('NJ', 'NY')) THEN
    IF (tax_exists(l_jd_entered, 'SDI_ER', p_adjustment_date) = 'N') THEN
      Hr_Utility.Set_Message(801, 'PY_51142_TXADJ_SDI_EXEMPT');
      Hr_Utility.Raise_Error;
    END IF;

  END IF;

  -- 5.  check SUI (EE) Withheld = 0 for all states unless the SUI state is
  --     in ('AK', 'NJ', 'PA')

  OPEN csr_sui_geocode;
  FETCH csr_sui_geocode INTO g_sui_jd, g_sui_state_code;
  CLOSE csr_sui_geocode;

  private_trace(c_proc, 'g_sui_jd>' || g_sui_jd || '< ' ||
                        'g_sui_state_code>' || g_sui_state_code || '<');

  IF (l_sui_ee <> 0) THEN

    /*
    ** if the assignment is not in 'AK', 'NJ', 'PA' then SUI_EE does not apply,
    ** if the state found for the assignment (CA) <> the state from the
    ** assignment (NJ) then SUI_EE does not apply
    */
    --IF (p_state_abbrev NOT IN ('AK', 'NJ')) OR

    IF (tax_exists(l_jd_entered, 'SUI_EE', p_adjustment_date) = 'N') OR
       (g_sui_state_code <> p_state_abbrev) THEN
        Hr_Utility.Set_Message(801, 'PY_51328_TXADJ_SUI_EXEMPT');
        Hr_Utility.Raise_Error;
    END IF;

  END IF;


  -- determine system keys
/*
  BEGIN
    Hr_Utility.Set_Location(c_proc, 5);
    SELECT a.assignment_id,
           a.business_group_id
    INTO   l_assignment_id,
           l_bg_id
    FROM   PER_BUSINESS_GROUPS bg,
           PER_ASSIGNMENTS_F   a
    WHERE  a.assignment_number = p_assignment_number
    and    a.business_group_id = bg.business_group_id
    and    bg.name ||''        = p_business_group_name
    and    p_adjustment_date BETWEEN
                a.effective_start_date AND a.effective_end_date
    ;
    EXCEPTION
       WHEN NO_DATA_FOUND OR too_many_rows THEN
          Hr_Utility.Set_Message(801, 'PY_51135_TXADJ_ASG_NOT_FOUND');
          Hr_Utility.Raise_Error;
  END;
*/

  Hr_Utility.Trace('|');
  private_trace(c_proc, 'taxable balances before any BAs');

  BEGIN
     Hr_Utility.Set_Location(c_proc, 10);
     SELECT consolidation_set_id
     INTO   l_consolidation_set_id
     FROM   PAY_CONSOLIDATION_SETS
     WHERE  consolidation_set_name = p_consolidation_set
     and    business_group_id      = l_bg_id
     ;
     EXCEPTION
       WHEN NO_DATA_FOUND OR too_many_rows THEN
         Hr_Utility.Set_Message(801, 'PY_51136_TXADJ_CONSET_NOT_FND');
         Hr_Utility.Raise_Error;
  END;

  l_jd_entered := derive_jd_geocode(p_assignment_id => l_assignment_id,
                                    p_state_abbrev  => p_state_abbrev,
                                    p_county_name   => p_county_name,
                                    p_city_name     => p_city_name,
                                    p_zip_code      => p_zip_code );

  private_trace(c_proc, 'l_jd_entered>' || l_jd_entered || '<');

/** sbilling */
  /*
  ** put the old taxable balances (before any BA processing) into globals,
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
  g_classification_id   := null;
  g_earnings_category   := null;
  g_classification      := null;
  g_pact_cntr           := 1;
  g_tax_type_tbl        := g_dummy_varchar_tbl;
  g_tax_adj_pactid_tbl  := g_dummy_number_tbl;


  -- more error checking

  -- check the level of l_jd_entered to see if all taxes entered
  -- are applicable for the jurisdiction entered
  Hr_Utility.Set_Location(c_proc, 15);

  IF (l_city <> 0 ) THEN  -- jd level needed is for a city
    l_jd_level_needed := 4;

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
    Hr_Utility.Set_Location(c_proc, 20);
    Hr_Utility.Trace('Jursidiction entered is insufficient for all taxes');
    Hr_Utility.Set_Message(801, 'PY_50015_TXADJ_JD_INSUFF');
    Hr_Utility.Raise_Error;
  END IF;


  -- main processing
  Hr_Utility.Set_Location(c_proc, 30);

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
                    p_cost                 => p_cost);
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
                    p_cost                 => p_cost);

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
                      p_cost                 => p_cost);
    END IF;
  END IF;

  IF (l_ss <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'SS_EE',
                    p_abbrev_element_type  => 'SS',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => NULL,
                    p_adj_amount           => l_ss,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'SS_ER',
                    p_abbrev_element_type  => 'SER',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => NULL,
                    p_adj_amount           => l_ss,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);
  END IF;

  IF (l_medicare <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'Medicare_EE',
                    p_abbrev_element_type  => 'Med',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => 0,
                    p_adj_amount           => l_medicare,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'Medicare_ER',
                    p_abbrev_element_type  => 'MER',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => 0,
                    p_adj_amount           => l_medicare,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);
  END IF;

  IF (l_futa_er <> 0) THEN
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'FUTA',
                    p_abbrev_element_type  => 'FTA',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => 0,
                    p_adj_amount           => l_futa_er,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);
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
                    p_cost                 => p_cost);
  END IF;


/** sbilling **/
  /*
  ** new tax element to be processed, use SIT_WK as a template
  */
  IF (l_sch_dist_wh_ee <> 0) THEN
    private_trace(c_proc, '  l_sch_dist_wh_ee>' || l_sch_dist_wh_ee ||
   			  '< l_sch_dist_jur>' || l_sch_dist_jur || '<');

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'County_SC_WK',
                    p_abbrev_element_type  => 'CsWK',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => l_sch_dist_wh_ee,
                    p_jurisdiction         => l_sch_dist_jur,
                    p_cost                 => p_cost);
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
                    p_cost                 => p_cost);
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
                    p_cost                 => p_cost);
  END IF;

  -- subject balances are adjusted if there were any earnings
  IF (l_gross_amount <> 0) THEN
    -- SD1

    /*
    ** for Medicare_ER and SS_ER the ER adjustments amounts should equal the EE
    ** adjustment amounts, thus l_medicare and l_ss can be used
    */
    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'Medicare_ER',
                    p_abbrev_element_type  => 'MER',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => 0,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'Medicare_EE',
                    p_abbrev_element_type  => 'Med',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => 0,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'SS_ER',
                    p_abbrev_element_type  => 'SER',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => 0,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'SS_EE',
                    p_abbrev_element_type  => 'SS',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => 0,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);

    process_element(p_assignment_id        => l_assignment_id,
                    p_consolidation_set_id => l_consolidation_set_id,
                    p_element_type         => 'FUTA',
                    p_abbrev_element_type  => 'FTA',
                    p_bg_id                => l_bg_id,
                    p_adjustment_date      => p_adjustment_date,
                    p_earn_amount          => l_gross_amount,
                    p_adj_amount           => 0,
                    p_jurisdiction         => g_fed_jd,
                    p_cost                 => p_cost);

      -- sd 15/5
--    IF (p_state_abbrev NOT IN ('AK', 'FL', 'NV', 'NH', 'SD', 'TN',
--                               'TX', 'WA', 'WY', 'VI')) THEN
    IF (tax_exists(l_jd_entered, 'SIT', p_adjustment_date) = 'Y') THEN
      process_element(p_assignment_id          => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'SIT_SUBJECT_WK',
                        p_abbrev_element_type  => 'SITSubK',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => l_sit,
                        p_jurisdiction         => g_state_jd,
                        p_cost                 => p_cost);

    END IF;

    IF (NVL(tax_exists(l_jd_entered, 'COUNTY', p_adjustment_date),'N') = 'Y') THEN

      process_element(p_assignment_id        => l_assignment_id,
                       p_consolidation_set_id => l_consolidation_set_id,
                       p_element_type         => 'County_SUBJECT_WK',
                       p_abbrev_element_type  => 'CntySubK',
                       p_bg_id                => l_bg_id,
                       p_adjustment_date      => p_adjustment_date,
                       p_earn_amount          => l_gross_amount,
                       p_adj_amount           => l_county,
                       p_jurisdiction         => g_county_jd,
                       p_cost                 => p_cost);
    END IF;

--
-- Check to see if we have a vaild geo-code for the city.  This code
-- was added to fix a problem with user defined cities.
--
    IF substr(g_city_jd,8,4) <> '0000' THEN
      IF (NVL(tax_exists(l_jd_entered, 'CITY', p_adjustment_date),'N') = 'Y') THEN
         process_element(p_assignment_id        => l_assignment_id,
                         p_consolidation_set_id => l_consolidation_set_id,
                         p_element_type         => 'City_SUBJECT_WK',
                         p_abbrev_element_type  => 'CtySubK',
                         p_bg_id                => l_bg_id,
                         p_adjustment_date      => p_adjustment_date,
                         p_earn_amount          => l_gross_amount,
                         p_adj_amount           => l_city,
                         p_jurisdiction         => g_city_jd,
                         p_cost                 => p_cost);
      END IF;
    END IF;
  END IF;  -- (l_gross_amount <> 0)

  -- only Alaska, New Jersey and Pennsylvania have SUI_EE in addition
  -- to SUI_ER,
  -- may also want to check that if the jurisdiction is the SUI jurisdiction,
  -- only then create the SUI SUBJECT EE and ER

-- sd 15/5
  --IF (p_state_abbrev IN ('AK', 'NJ')) THEN
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
                        p_cost                 => p_cost);

        process_element(p_assignment_id        => l_assignment_id,
                        p_consolidation_set_id => l_consolidation_set_id,
                        p_element_type         => 'SUI_EE',
                        p_abbrev_element_type  => 'SUIE',
                        p_bg_id                => l_bg_id,
                        p_adjustment_date      => p_adjustment_date,
                        p_earn_amount          => l_gross_amount,
                        p_adj_amount           => l_sui_ee,
                        p_jurisdiction         => g_sui_jd,
                        p_cost                 => p_cost);
      END IF;
    END IF;
  END IF;

  private_trace(c_proc, 'p_state_abbrev>' || p_state_abbrev || '< ' ||
                        'g_sui_state_code>' || g_sui_state_code || '<');

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
                      p_cost                  => p_cost);

      process_element(p_assignment_id         => l_assignment_id,
                      p_consolidation_set_id  => l_consolidation_set_id,
                      p_element_type          => 'SUI_ER',
                      p_abbrev_element_type   => 'SUIR',
                      p_bg_id                 => l_bg_id,
                      p_adjustment_date       => p_adjustment_date,
                      p_earn_amount           => l_gross_amount,
                      --p_adj_amount          => l_sui_ee,
/** sbilling **/
                      p_adj_amount            => l_sui_er,
                      p_jurisdiction          => g_sui_jd,
                      p_cost                  => p_cost);
     END IF;
   END IF;

  -- only Hawaii, New Jersey, Puerto Rico have SDI_ER
  --IF (p_state_abbrev IN ('NY', 'NJ')) THEN
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
                      p_cost                 => p_cost);

      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'SDI_ER',
                      p_abbrev_element_type  => 'SDIR',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => l_gross_amount,
                      --p_adj_amount         => l_sdi_ee,
/** sbilling **/
                      p_adj_amount           => l_sdi_er,
                      p_jurisdiction         => g_state_jd,
                      p_cost                 => p_cost);
    END IF;
  END IF;

  -- only California, Hawaii, New Jersey, New York, Rhode Island,
  -- and Puerto Rico have SDI_EE

  --IF (p_state_abbrev IN ('CA', 'NY', 'RI', 'HI', 'NJ')) THEN
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
                      p_cost                 => p_cost);

      process_element(p_assignment_id        => l_assignment_id,
                      p_consolidation_set_id => l_consolidation_set_id,
                      p_element_type         => 'SDI_EE',
                      p_abbrev_element_type  => 'SDIE',
                      p_bg_id                => l_bg_id,
                      p_adjustment_date      => p_adjustment_date,
                      p_earn_amount          => l_gross_amount,
                      p_adj_amount           => l_sdi_ee,
                      p_jurisdiction         => g_state_jd,
                      p_cost                 => p_cost);
    END IF;
  END IF;


  -- finally, group the payroll_actions by concatenating the tax type with
  -- the payroll_action
  g_pact_cntr := g_pact_cntr - 1;

  Hr_Utility.Set_Location (c_proc, 100);

  FOR l_counter in 1..g_pact_cntr LOOP

     /* l_grp_key := l_grp_key || g_tax_type_tbl(l_counter) ||
                To_Char(g_tax_adj_pactid_tbl(l_counter)) || ':'; */

     l_grp_key := g_tax_type_tbl(l_counter) ||
                  To_Char(g_tax_adj_pactid_tbl(l_counter)) || ':';

    UPDATE pay_payroll_actions
    SET    legislative_parameters = l_grp_key
    WHERE  payroll_action_id      = g_tax_adj_pactid_tbl(l_counter);

  END LOOP;

  Hr_Utility.Set_Location (c_proc, 120);

/*  FOR l_counter IN 1..g_pact_cntr LOOP

    UPDATE pay_payroll_actions
    SET    legislative_parameters = l_grp_key
    WHERE  payroll_action_id      = g_tax_adj_pactid_tbl(l_counter);

  END LOOP;
*/

END create_tax_balance_adjustment;

END pay_us_tax_bals_adj_pkg;

/
