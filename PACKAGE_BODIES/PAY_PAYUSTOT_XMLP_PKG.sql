--------------------------------------------------------
--  DDL for Package Body PAY_PAYUSTOT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYUSTOT_XMLP_PKG" AS
/* $Header: PAYUSTOTB.pls 120.0 2008/01/07 11:56:49 srikrish noship $ */
  FUNCTION beforereport RETURN boolean IS
  BEGIN

    --hr_standard.event('BEFORE REPORT');
    -- Commented by Raj Starts
    -- p_start_date := TRUNC(p_end_date,   'Year');
    -- cp_state_status := pay_us_payroll_utils.check_balance_status(p_start_date,   p_business_group_id,   'GRE_TOTALS_FEDERAL');
    -- cp_fed_status := pay_us_payroll_utils.check_balance_status(p_start_date,   p_business_group_id,   'GRE_TOTALS_STATE');
    -- Commented by Raj Ends

    p_start_date_m := TRUNC(p_end_date,   'Year');
    cp_state_status := pay_us_payroll_utils.check_balance_status(p_start_date_m,   p_business_group_id,   'GRE_TOTALS_FEDERAL');
    cp_fed_status := pay_us_payroll_utils.check_balance_status(p_start_date_m,   p_business_group_id,   'GRE_TOTALS_STATE');

    IF cp_state_status = 'Y' OR cp_fed_status = 'Y' THEN
      pay_balance_pkg.set_context('DATE_EARNED',   fnd_date.date_to_canonical(p_end_date));
      pay_balance_pkg.set_context('BALANCE_DATE',   fnd_date.date_to_canonical(p_end_date));
      pay_us_balance_view_pkg.set_session_var('GROUP_RB_REPORT',   'TRUE');
      pay_us_balance_view_pkg.set_session_var('REPORT_TYPE',   'W2');
      -- Commented by Raj Starts
      --pay_us_balance_view_pkg.set_session_var('GROUP_RB_SDATE',   p_start_date);
      -- Commented by Raj Ends
      pay_us_balance_view_pkg.set_session_var('GROUP_RB_SDATE',   p_start_date_m);
      pay_us_balance_view_pkg.set_session_var('GROUP_RB_EDATE',   p_end_date);
    END IF;

    DECLARE trace VARCHAR2(30) := '';
    BEGIN

      p_session_date := p_end_date;
      c_business_group_name := hr_reports.get_business_group(p_business_group_id);

      IF p_tax_unit_id IS NULL THEN
        c_tax_unit_name := 'ALL';
      ELSE
        c_tax_unit_name := hr_us_reports.get_tax_unit(p_tax_unit_id);
      END IF;

      SELECT UPPER(parameter_value)
      INTO trace
      FROM pay_action_parameters
      WHERE parameter_name = 'TRACE';

      IF trace <> 'N' THEN

        /*srw.do_sql('alter session set SQL_TRACE TRUE');null;*/ EXECUTE IMMEDIATE 'alter session set SQL_TRACE TRUE';

      END IF;

    EXCEPTION
    WHEN no_data_found THEN
      NULL;
    END;

    RETURN(TRUE);
  END;

  FUNCTION cf_fed_gross_wagesformula(gre_id IN NUMBER) RETURN NUMBER IS l_value1 NUMBER;
  l_value2 NUMBER;
  l_value3 NUMBER;
  l_value4 NUMBER;
  l_value5 NUMBER;
  l_value6 NUMBER;
  l_value7 NUMBER;
  l_value8 NUMBER;
  l_value9 NUMBER;
  l_value10 NUMBER;
  CURSOR federal_balance_value IS
  SELECT d_tax_type,
    d_tax_classification,
    d_wage_classification,
    d_wage_otd_value,
    d_tax_otd_value
  FROM pay_us_federal_tax_bal_gre_v
  WHERE d_balance_set_name LIKE 'GRE_TOTALS_FED_YTD'
   AND d_tax_unit_id = gre_id;

  l_tax_type VARCHAR2(240);
  l_tax_classification VARCHAR2(240);
  l_wage_classification VARCHAR2(240);
  l_tax_otd_val NUMBER;
  l_wage_otd_value NUMBER;

  BEGIN

    IF cp_fed_status = 'Y' THEN

      OPEN federal_balance_value;
      LOOP
        FETCH federal_balance_value
        INTO l_tax_type,
          l_tax_classification,
          l_wage_classification,
          l_wage_otd_value,
          l_tax_otd_val;
        EXIT
      WHEN federal_balance_value % NOTFOUND;

      IF l_tax_type = 'FIT'
       AND(l_tax_classification = 'WITHHELD' OR l_wage_classification = 'REDUCED_SUBJ_WHABLE') THEN
        cp_fit_withheld := nvl(l_tax_otd_val,   0);
        cp_fed_others := nvl(l_wage_otd_value,   0);

        ELSIF l_tax_type = 'SS'
         AND(l_tax_classification = 'WITHHELD' OR l_wage_classification = 'TAXABLE') THEN
          cp_ss_ee_withheld := nvl(l_tax_otd_val,   0);
          cp_ss_ee_taxable := nvl(l_wage_otd_value,   0);

          ELSIF l_tax_type = 'MEDICARE'
           AND(l_tax_classification = 'WITHHELD' OR l_wage_classification = 'TAXABLE') THEN
            cp_medicare_ee_withheld := nvl(l_tax_otd_val,   0);
            cp_medicare_ee_taxable := nvl(l_wage_otd_value,   0);

            ELSIF l_tax_type = 'GROSS_EARNINGS'
             AND l_tax_classification = 'NONE' THEN
              l_value4 := nvl(l_tax_otd_val,   0);

            END IF;

          END LOOP;

          CLOSE federal_balance_value;

        ELSE
          pay_us_taxbal_view_pkg.us_gp_multiple_gre_ytd(p_tax_unit_id => gre_id,   p_effective_date => p_end_date,   p_balance_name1 => 'Pre Tax Deductions',   p_balance_name2 => 'FIT Non W2 Pre Tax Dedns',
	  p_balance_name3 => 'FIT Withheld',   p_balance_name4 => 'Gross Earnings',   p_balance_name5 => 'Medicare EE Taxable',   p_balance_name6 => 'Medicare EE Withheld',   p_balance_name7 => 'Regular Earnings',
	  p_balance_name8 => 'SS EE Taxable',   p_balance_name9 => 'SS EE Withheld',   p_balance_name10 => NULL,   p_value1 => l_value1,   p_value2 => l_value2,   p_value3 => l_value3,   p_value4 => l_value4,
	  p_value5 => l_value5,   p_value6 => l_value6,   p_value7 => l_value7,   p_value8 => l_value8,   p_value9 => l_value9,   p_value10 => l_value10);

          cp_pre_tax_deductions := l_value1;
          cp_fit_non_w2_pre_tax_dedns := l_value2;
          cp_fwt_regular_earnings := l_value7;

          cp_fit_withheld := l_value3;
          cp_medicare_ee_taxable := l_value5;
          cp_medicare_ee_withheld := l_value6;
          cp_ss_ee_taxable := l_value8;
          cp_ss_ee_withheld := l_value9;

        END IF;

        RETURN l_value4;
      END;

      FUNCTION cf_fed_wages_tips_otherformula(gre_id IN NUMBER) RETURN NUMBER IS

       l_balance NUMBER;
      l_value1 NUMBER;
      l_value2 NUMBER;
      l_value3 NUMBER;
      l_value4 NUMBER;
      l_value5 NUMBER;
      BEGIN

        IF cp_fed_status = 'Y' THEN
          l_balance := nvl(cp_fed_others,   0);
        ELSE
          pay_us_taxbal_view_pkg.us_gp_subject_to_tax_gre_ytd(p_balance_name1 => 'Supplemental Earnings for NWFIT',   p_balance_name2 => 'Supplemental Earnings for FIT',   p_balance_name3 => 'Pre Tax Deductions for FIT',
	  p_balance_name4 => NULL,   p_balance_name5 => NULL,   p_effective_date => p_end_date,   p_tax_unit_id => gre_id,   p_value1 => l_value1,   p_value2 => l_value2,   p_value3 => l_value3,
	  p_value4 => l_value4,   p_value5 => l_value5);

          cp_fwt_supp_earn_nwfit := l_value1;
          cp_fwt_supp_earn_fit := l_value2;
          cp_pre_tax_deductions_for_fit := l_value3;

          l_balance := cp_fwt_supp_earn_nwfit + cp_fwt_regular_earnings + cp_fwt_supp_earn_fit -(cp_pre_tax_deductions -cp_pre_tax_deductions_for_fit -cp_fit_non_w2_pre_tax_dedns);
        END IF;

        RETURN(l_balance);
      END;

      FUNCTION cf_state_gross_wagesformula(gre_id IN NUMBER,   state_code IN VARCHAR2,   state IN VARCHAR2) RETURN NUMBER IS l_balance NUMBER;
      l_value1 NUMBER;
      l_value2 NUMBER;
      l_value3 NUMBER;
      l_value4 NUMBER;
      l_value5 NUMBER;
      l_value6 NUMBER;
      l_value7 NUMBER;

      CURSOR state_balance_value IS
      SELECT DISTINCT d_tax_classification,
        d_wage_classification,
        d_tax_otd_value,
        d_wage_otd_value
      FROM pay_us_state_tax_bal_gre_v
      WHERE d_balance_set_name = 'GRE_TOTALS_STATE_YTD'
       AND d_tax_unit_id = gre_id
       AND SUBSTR(d_state_code,   1,   2) = state_code
       AND d_tax_type = 'SIT';

      l_tax_classification VARCHAR2(240);
      l_wage_classification VARCHAR2(240);
      l_tax_otd_val NUMBER;
      l_wage_otd_value NUMBER;

      BEGIN

        cp_sit_ee_withheld := 0;
        cp_state_wages_tips_other := 0;

        IF cp_state_status = 'Y' THEN

          OPEN state_balance_value;
          LOOP
            FETCH state_balance_value
            INTO l_tax_classification,
              l_wage_classification,
              l_tax_otd_val,
              l_wage_otd_value;
            EXIT
          WHEN state_balance_value % NOTFOUND;

          IF l_tax_classification = 'GROSS' THEN
            l_value2 := nvl(l_tax_otd_val,   0);
            ELSIF(l_tax_classification = 'WITHHELD' OR l_wage_classification = 'REDUCED_SUBJ_WHABLE') THEN
              cp_sit_ee_withheld := nvl(l_tax_otd_val,   0);
              cp_state_wages_tips_other := nvl(l_wage_otd_value,   0);
            END IF;

          END LOOP;

          CLOSE state_balance_value;
        ELSE

          IF pay_us_tax_info_pkg.get_sit_exist(p_state_abbrev => state,   p_date => p_end_date) = FALSE THEN
            l_value2 := 0;
            cp_sit_ee_withheld := 0;
            cp_state_wages_tips_other := 0;
          ELSE
            pay_us_taxbal_view_pkg.us_gp_gre_jd_ytd(p_balance_name1 => 'SIT Withheld',   p_balance_name2 => 'SIT Gross',   p_balance_name3 => 'SIT Subj Whable',   p_balance_name4 => 'SIT Pre Tax Redns',
	    p_balance_name5 => NULL,   p_balance_name6 => NULL,   p_balance_name7 => 'SIT Subj NWhable',   p_effective_date => p_end_date,   p_tax_unit_id => gre_id,   p_state_code => state_code,   p_value1 => l_value1,
	    p_value2 => l_value2,   p_value3 => l_value3,   p_value4 => l_value4,   p_value5 => l_value5,   p_value6 => l_value6,   p_value7 => l_value7);

            cp_sit_ee_withheld := l_value1;
            cp_state_wages_tips_other := l_value3 + l_value7 -l_value4;
          END IF;

        END IF;

        RETURN(l_value2);
      END;

      FUNCTION gre_tax_balance(p_business_group_id IN NUMBER,   p_gre_org_id IN NUMBER,   p_def_bal_id IN NUMBER,   p_start_date IN DATE,   p_end_date IN DATE) RETURN NUMBER IS

       l_balance_total NUMBER := 0;

      CURSOR asg_cur IS
      SELECT paf.person_id,
        paf.assignment_id,
        paaf.assignment_action_id
      FROM per_assignments_f paf,
        pay_assignment_actions paaf,
        pay_payroll_actions ppa,
        hr_soft_coding_keyflex hsck
      WHERE(ppa.effective_date BETWEEN p_start_date
       AND p_end_date)
       AND ppa.payroll_action_id = paaf.payroll_action_id
       AND paaf.assignment_id = paf.assignment_id
       AND paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
       AND hsck.segment1 = p_gre_org_id
       AND paf.business_group_id = p_business_group_id;

      BEGIN

        pay_balance_pkg.set_context('TAX_UNIT_ID',   to_char(p_gre_org_id));

        FOR asgc IN asg_cur
        LOOP

          l_balance_total := l_balance_total + pay_balance_pkg.get_value(p_def_bal_id,   asgc.assignment_action_id,   FALSE);

        END LOOP;

        RETURN l_balance_total;

      END;

      FUNCTION cf_1formula(gre_id IN NUMBER,   state IN VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        DECLARE l_sui_ein VARCHAR2(20);
        BEGIN

          SELECT sein.org_information3
          INTO l_sui_ein
          FROM hr_organization_information sein
          WHERE sein.organization_id = gre_id
           AND sein.org_information1 = state
           AND sein.org_information_context = 'State Tax Rules';

          cp_state_tax_unit := l_sui_ein;

          RETURN cp_state_tax_unit;

        EXCEPTION
        WHEN no_data_found THEN
          RETURN 'No State EIN';
        END;
        RETURN NULL;
      END;

      FUNCTION cp_fit_withheldformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_medicare_ee_taxableformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_medicare_ee_withheldformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_ss_ee_taxableformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_ss_ee_withheldformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_def_comp_401kformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_regular_earningsformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_section_125formula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_fwt_supp_earn_nwfitformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_fwt_supp_earn_fitformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_def_comp_401k_for_fitformul RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_state_wages_tips_otherformu RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cp_sit_ee_withheldformula RETURN NUMBER IS
      BEGIN
        NULL;
        RETURN NULL;
      END;

      FUNCTION cf_message_lineformula(cf_fed_gross_wages IN NUMBER) RETURN VARCHAR2 IS ret_val VARCHAR2(100) := ' ';

      BEGIN

        IF cf_fed_gross_wages = 0 THEN
          ret_val := '**** No Wages paid during the period reported ****';
        ELSE
          ret_val := NULL;
        END IF;

        RETURN ret_val;

      END;

      FUNCTION afterreport RETURN boolean IS
      BEGIN

        --hr_standard.event('AFTER REPORT');
        RETURN(TRUE);
      END;

      --Functions to refer Oracle report placeholders--

      FUNCTION cp_fed_others_p RETURN NUMBER IS
      BEGIN
        RETURN cp_fed_others;
      END;
      FUNCTION cp_fwt_supp_earn_nwfit_p RETURN NUMBER IS
      BEGIN
        RETURN cp_fwt_supp_earn_nwfit;
      END;
      FUNCTION cp_fwt_supp_earn_fit_p RETURN NUMBER IS
      BEGIN
        RETURN cp_fwt_supp_earn_fit;
      END;
      FUNCTION cp_pre_tax_deductions_for_p RETURN NUMBER IS
      BEGIN
        RETURN cp_pre_tax_deductions_for_fit;
      END;
      FUNCTION cp_fit_non_w2_pre_tax_dedns_p RETURN NUMBER IS
      BEGIN
        RETURN cp_fit_non_w2_pre_tax_dedns;
      END;
      FUNCTION cp_fwt_regular_earnings_p RETURN NUMBER IS
      BEGIN
        RETURN cp_fwt_regular_earnings;
      END;
      FUNCTION cp_pre_tax_deductions_p RETURN NUMBER IS
      BEGIN
        RETURN cp_pre_tax_deductions;
      END;
      FUNCTION cp_fit_withheld_p RETURN NUMBER IS
      BEGIN
        RETURN cp_fit_withheld;
      END;
      FUNCTION cp_ss_ee_taxable_p RETURN NUMBER IS
      BEGIN
        RETURN cp_ss_ee_taxable;
      END;
      FUNCTION cp_ss_ee_withheld_p RETURN NUMBER IS
      BEGIN
        RETURN cp_ss_ee_withheld;
      END;
      FUNCTION cp_medicare_ee_taxable_p RETURN NUMBER IS
      BEGIN
        RETURN cp_medicare_ee_taxable;
      END;
      FUNCTION cp_medicare_ee_with_p RETURN NUMBER IS
      BEGIN
        RETURN cp_medicare_ee_withheld;
      END;
      FUNCTION cp_state_wages_tips_other_p RETURN NUMBER IS
      BEGIN
        RETURN cp_state_wages_tips_other;
      END;
      FUNCTION cp_sit_ee_withheld_p RETURN NUMBER IS
      BEGIN
        RETURN cp_sit_ee_withheld;
      END;
      FUNCTION c_business_group_name_p RETURN VARCHAR2 IS
      BEGIN
        RETURN c_business_group_name;
      END;
      FUNCTION c_report_subtitle_p RETURN VARCHAR2 IS
      BEGIN
        RETURN c_report_subtitle;
      END;
      FUNCTION c_tax_unit_name_p RETURN VARCHAR2 IS
      BEGIN
        RETURN c_tax_unit_name;
      END;
      FUNCTION cp_state_tax_unit_p RETURN VARCHAR2 IS
      BEGIN
        RETURN cp_state_tax_unit;
      END;
      FUNCTION cp_state_status_p RETURN VARCHAR2 IS
      BEGIN
        RETURN cp_state_status;
      END;
      FUNCTION cp_fed_status_p RETURN VARCHAR2 IS
      BEGIN
        RETURN cp_fed_status;
      END;
    END PAY_PAYUSTOT_XMLP_PKG;

/
