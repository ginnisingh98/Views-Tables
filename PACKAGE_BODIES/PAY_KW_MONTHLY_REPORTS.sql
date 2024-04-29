--------------------------------------------------------
--  DDL for Package Body PAY_KW_MONTHLY_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_MONTHLY_REPORTS" AS
/* $Header: pykwmonr.pkb 120.10.12010000.15 2019/03/19 13:51:49 somdhar ship $ */

  lg_format_mask varchar2(50);
  g_report_old      VARCHAR2(10);
  PROCEDURE set_currency_mask
    (p_business_group_id IN NUMBER) IS
    /* Cursor to retrieve Currency */
    CURSOR csr_currency IS
    SELECT org_information10
    FROM   hr_organization_information
    WHERE  organization_id = p_business_group_id
    AND    org_information_context = 'Business Group Information';
    l_currency VARCHAR2(40);
  BEGIN
    OPEN csr_currency;
    FETCH csr_currency into l_currency;
    CLOSE csr_currency;
    lg_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);
  END set_currency_mask;


  PROCEDURE report166
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,p_arrears                 NUMBER DEFAULT 0
    ,p_arrears2                NUMBER DEFAULT 0  /* changes in 166 - Aug 2012 Bug 14704605  */
    ,p_arrears3                NUMBER DEFAULT 0
/*Bug 17495527 (Kuwait Report 166)  changes start */
    ,p_arrears6                NUMBER DEFAULT 0
/*Bug 17495527 (Kuwait Report 166)  changes end */
    ,p_not_in_rep_167          NUMBER DEFAULT 0
    ,p_add_supp_insu_1997      NUMBER DEFAULT 0
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
    AS

    l_local_nationality   VARCHAR2(80);

    /*Cursor for fetching Employer SSN*/
    CURSOR csr_employer_ssn IS
    SELECT LPAD(org_information4,9,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';

    /*Cursor for fetching Employer Name*/
    CURSOR csr_employer_name IS
    SELECT name
    FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'KW'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    l_employer_name            hr_organization_units.name%TYPE;
    l_employer_ssn             NUMBER;
    l_basic_si_base_id         NUMBER;
    l_supp_si_base_id          NUMBER;
    l_ee_basic_si_id           NUMBER;
    l_er_basic_si_id           NUMBER;
    l_ee_supp_si_id            NUMBER;
    l_er_supp_si_id            NUMBER;
/*Bug 17495527 (Kuwait Report 166)  changes start */
    l_ee_ui_id              NUMBER;
    l_er_ui_id              NUMBER;
/*Bug 17495527 (Kuwait Report 166)  changes end */
    l_add_si_id                NUMBER;
    l_ee_pf_id                 NUMBER;
    l_er_pf_id                 NUMBER;
    l_basic_si_base_val        NUMBER;
    l_supp_si_base_val         NUMBER;
    l_ee_basic_si_val          NUMBER;
    l_er_basic_si_val          NUMBER;
    l_ee_supp_si_val           NUMBER;
    l_er_supp_si_val           NUMBER;
/*Bug 17495527 (Kuwait Report 166)  changes start */
    l_ee_ui_val                NUMBER;
    l_er_ui_val                NUMBER;
    l_tot_ui_val               NUMBER;
/*Bug 17495527 (Kuwait Report 166)  changes end */
    l_add_si_val               NUMBER;
    l_pf_val                   NUMBER;
    l_ee_pf_val                NUMBER;
    l_er_pf_val                NUMBER;
    l_input_date               VARCHAR2(30);
    l_effective_date           DATE;
    l_curr_date                VARCHAR2(30);
    l_file_name1               VARCHAR2(50);
    l_total_amount             NUMBER;
    l_ee_b                     NUMBER;
    l_ee_s                     NUMBER;
    l_er_b                     NUMBER;
    l_er_s                     NUMBER;
    l_tot_pf_val               NUMBER;
    l_tot_basic_val            NUMBER;
    l_tot_supp_val             NUMBER;

    l_fm_total_amount          VARCHAR2(50);
    l_fm_ee_b                  VARCHAR2(50);
    l_fm_ee_s                  VARCHAR2(50);
    l_fm_er_b                  VARCHAR2(50);
    l_fm_er_s                  VARCHAR2(50);
    l_fm_basic_si_base_val     VARCHAR2(50);
    l_fm_supp_si_base_val      VARCHAR2(50);
    l_fm_ee_basic_si_val       VARCHAR2(50);
    l_fm_er_basic_si_val       VARCHAR2(50);
    l_fm_ee_supp_si_val        VARCHAR2(50);
    l_fm_er_supp_si_val        VARCHAR2(50);
/*Bug 17495527 (Kuwait Report 166)  changes start */
    l_fm_ee_ui_val             VARCHAR2(50);
    l_fm_er_ui_val             VARCHAR2(50);
/*Bug 17495527 (Kuwait Report 166)  changes end */
    l_fm_add_si_val            VARCHAR2(50);
    l_fm_ee_pf_val             VARCHAR2(50);
    l_fm_er_pf_val             VARCHAR2(50);
    l_fm_arrears               VARCHAR2(50);
    l_fm_arrears2               VARCHAR2(50);
    l_fm_arrears3               VARCHAR2(50);
    l_fm_arrears4               VARCHAR2(50);
    l_fm_arrears5               VARCHAR2(50);
/*Bug 17495527 (Kuwait Report 166)  changes start */
    l_fm_arrears6               VARCHAR2(50);
    l_fm_tot_ui_val            VARCHAR2(50);
/*Bug 17495527 (Kuwait Report 166)  changes end */
    l_fm_tot_pf_val             VARCHAR2(50);
    l_fm_tot_basic_val          VARCHAR2(50);
    l_fm_tot_supp_val           VARCHAR2(50);
    l_fm_add_si_val_tot         VARCHAR2(50);
    l_fm_arrears4_tot           VARCHAR2(50);
    l_fm_arrears5_tot           VARCHAR2(50);

    l_effective_month          VARCHAR2(50);

    l_ee_b_arr_id              NUMBER;
    l_ee_s_arr_id              NUMBER;
    l_add_arr_id               NUMBER;

  BEGIN
    l_fm_total_amount          := NULL;
    l_fm_ee_b                  := NULL;
    l_fm_ee_s                  := NULL;
    l_fm_er_b                  := NULL;
    l_fm_er_s                  := NULL;
    l_fm_basic_si_base_val     := NULL;
    l_fm_supp_si_base_val      := NULL;
    l_fm_ee_basic_si_val       := NULL;
    l_fm_er_basic_si_val       := NULL;
    l_fm_ee_supp_si_val        := NULL;
    l_fm_er_supp_si_val        := NULL;
/*Bug 17495527 (Kuwait Report 166)  changes start */
    l_fm_ee_ui_val             := NULL;
    l_fm_er_ui_val             := NULL;
/*Bug 17495527 (Kuwait Report 166)  changes end */
    l_fm_add_si_val            := NULL;
    l_fm_ee_pf_val             := NULL;
    l_fm_er_pf_val             := NULL;
    l_fm_arrears               := NULL;
    l_fm_arrears2               := NULL;
    l_fm_arrears3               := NULL;
    l_fm_arrears4               := NULL;
    l_fm_arrears5               := NULL;
/*Bug 17495527 (Kuwait Report 166)  changes start */
    l_fm_arrears6               := NULL;
    l_fm_tot_ui_val             := NULL;
/*Bug 17495527 (Kuwait Report 166)  changes end */
    l_fm_tot_pf_val             := NULL;
    l_fm_tot_basic_val          := NULL;
    l_fm_tot_supp_val           := NULL;
    l_fm_add_si_val_tot         := NULL;
    l_fm_arrears4_tot           := NULL;
    l_fm_arrears5_tot           := NULL;


    set_currency_mask(p_business_group_id);
    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    /*l_eff_term_date := to_date('28-'||to_char(l_effective_date,'MM-YYYY'),'DD-MM-YYYY');*/
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    l_local_nationality := NULL;
    BEGIN
fnd_file.put_line(fnd_file.LOG,'Entering KW166 ' ||'  10');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears ' ||l_fm_arrears||'  11');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears2 ' ||l_fm_arrears2||'  11');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears3 ' ||l_fm_arrears3||'  11');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears4 ' ||l_fm_arrears4||'  11');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears5 ' ||l_fm_arrears5||'  11');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears6 ' ||l_fm_arrears6||'  11');
      SELECT org_information1
      INTO l_local_nationality
      FROM hr_organization_information
      WHERE org_information_context = 'KW_BG_DETAILS'
      AND organization_id = p_business_group_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_local_nationality := NULL;
    END;

    -- To clear the PL/SQL Table values.
    vXMLTable.DELETE;
    vCtr := 1;
    hr_utility.set_location('Entering report166 ',10);

    l_effective_month := hr_general.decode_lookup('KW_GREGORIAN_MONTH', p_effective_month);

    vXMLTable(vCtr).TagName := 'R166-MONTH';
    vXMLTable(vCtr).TagValue := l_effective_month;
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R166-YEAR';
    vXMLTable(vCtr).TagValue := p_effective_year;
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R166-G-YYYY';
    vXMLTable(vCtr).TagValue := TO_CHAR(sysdate,'YYYY');
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R166-G-MM';
    vXMLTable(vCtr).TagValue := TO_CHAR(sysdate,'MM');
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R166-G-DD';
    vXMLTable(vCtr).TagValue := TO_CHAR(sysdate,'DD');
    vctr := vctr + 1;

    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;
fnd_file.put_line(fnd_file.LOG,'l_employer_ssn ' ||l_employer_ssn||'  20');
    vXMLTable(vCtr).TagName := 'R166-SSN';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,1,9);
    vctr := vctr + 1;
/*
    vXMLTable(vCtr).TagName := 'R166-SSN-1';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,1,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-2';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,2,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-3';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,3,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-4';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,4,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-5';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,5,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-6';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,6,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-7';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,7,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-8';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,8,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-SSN-9';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,9,1);
    vctr := vctr + 1;
*/
    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;
fnd_file.put_line(fnd_file.LOG,'l_employer_name ' ||l_employer_name||'  30');
    vXMLTable(vCtr).TagName := 'R166-NAME';
    vXMLTable(vCtr).TagValue := l_employer_name;
    vctr := vctr + 1;

    l_basic_si_base_id := 0;
    l_supp_si_base_id := 0;
    l_ee_basic_si_id := 0;
    l_er_basic_si_id := 0;
    l_ee_supp_si_id := 0;
    l_er_supp_si_id := 0;
/*Bug 17495527 (Kuwait Report 166)  changes start*/
    l_ee_ui_id := 0;
    l_er_ui_id := 0;
/*Bug 17495527 (Kuwait Report 166)  changes end*/
    l_add_si_id := 0;
    l_ee_pf_id := 0;
    l_er_pf_id := 0;

    l_ee_b_arr_id := 0;
    l_ee_s_arr_id := 0;
    l_add_arr_id := 0;

    /*Fetch Defined Balance Id*/
    OPEN csr_get_def_bal_id('BASIC_SOCIAL_INSURANCE_BASE_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_basic_si_base_id;    -- R166-B-BASE-D
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('SUPPLEMENTARY_SOCIAL_INSURANCE_BASE_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_supp_si_base_id;     -- R166-S-BASE-D
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('EMPLOYEE_BASIC_SOCIAL_INSURANCE_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_ee_basic_si_id;      -- R166-EE-B-D  l_ee_b_arr_id + ( basic_si_val  - ((basic_si_val)/(basic_si_val+supp_si_val))*pf_val)
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('EMPLOYER_BASIC_SOCIAL_INSURANCE_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_er_basic_si_id;      -- R166-ER-B-D
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('EMPLOYEE_SUPPLEMENTARY_SOCIAL_INSURANCE_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_ee_supp_si_id;       -- R166-EE-S-D  l_ee_s_arr_id + ( supp_si_val  - ((supp_si_val)/(basic_si_val+supp_si_val))*pf_val)
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('EMPLOYER_SUPPLEMENTARY_SOCIAL_INSURANCE_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_er_supp_si_id;       -- R166-ER-S-D
    CLOSE csr_get_def_bal_id;

/*Bug 17495527 (Kuwait Report 166)  changes start */
    OPEN csr_get_def_bal_id('EMPLOYEE_UNEMPLOYMENT_FUND_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_ee_ui_id;       -- R166-EE-UI-D
    CLOSE csr_get_def_bal_id;
fnd_file.put_line(fnd_file.LOG,'l_ee_ui_id ' ||l_ee_ui_id||'  40');

    OPEN csr_get_def_bal_id('EMPLOYER_UNEMPLOYMENT_FUND_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_er_ui_id;       -- R166-ER-UI-D
    CLOSE csr_get_def_bal_id;
fnd_file.put_line(fnd_file.LOG,'l_er_ui_id ' ||l_er_ui_id||'  40');
/*Bug 17495527 (Kuwait Report 166)  changes end */

    OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_add_si_id;           -- R166-A-S-D-TOT  ( l_add_si_id + l_add_arr_id)
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('EMPLOYEE_PENSION_FUND_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_ee_pf_id;            -- R166-EE-PF-D
    CLOSE csr_get_def_bal_id;
fnd_file.put_line(fnd_file.LOG,'l_ee_pf_id ' ||l_ee_pf_id||'  40');

    OPEN csr_get_def_bal_id('EMPLOYER_PENSION_FUND_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_er_pf_id;            -- R166-ER-PF-D
    CLOSE csr_get_def_bal_id;
fnd_file.put_line(fnd_file.LOG,'l_er_pf_id ' ||l_er_pf_id||'  40');


    OPEN csr_get_def_bal_id('EMPLOYEE_BASIC_SOCIAL_INSURANCE_ARREARS_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_ee_b_arr_id;         -- upside
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('EMPLOYEE_SUPPLEMENTARY_SOCIAL_INSURANCE_ARREARS_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_ee_s_arr_id;         -- upside
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ARREARS_EMPLOYER_MONTH');
    FETCH csr_get_def_bal_id INTO l_add_arr_id;          -- upside
    CLOSE csr_get_def_bal_id;



    /*Set Contexts and then fetch the balance values*/
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(l_effective_date));
    pay_balance_pkg.set_context('TAX_UNIT_ID', p_employer_id);
    l_basic_si_base_val := pay_balance_pkg.get_value(l_basic_si_base_id,NULL);
    l_fm_basic_si_base_val := to_char(l_basic_si_base_val,lg_format_mask);

    vXMLTable(vCtr).TagName := 'R166-B-BASE-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_basic_si_base_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_basic_si_base_val,1,length(l_fm_basic_si_base_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-B-BASE-F';
    --vXMLTable(vCtr).TagValue := l_basic_si_base_val - TRUNC(l_basic_si_base_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_basic_si_base_val,length(l_fm_basic_si_base_val)-2);
    vctr := vctr + 1;

    l_supp_si_base_val := pay_balance_pkg.get_value(l_supp_si_base_id,NULL);
    l_fm_supp_si_base_val := to_char(l_supp_si_base_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-S-BASE-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_supp_si_base_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_supp_si_base_val,1,length(l_fm_supp_si_base_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-S-BASE-F';
    --vXMLTable(vCtr).TagValue := l_supp_si_base_val - TRUNC(l_supp_si_base_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_supp_si_base_val,length(l_fm_supp_si_base_val)-2);
    vctr := vctr + 1;

/*Bug 17495527 (Kuwait Report 166)  changes start */
    l_ee_ui_val := pay_balance_pkg.get_value(l_ee_ui_id,NULL);
fnd_file.put_line(fnd_file.LOG,'l_ee_ui_val ' ||l_ee_ui_val||'  45');
    l_fm_ee_ui_val := to_char(l_ee_ui_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-EE-UI-D';
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_ui_val,1,length(l_fm_ee_ui_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-EE-UI-F';
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_ui_val,length(l_fm_ee_ui_val)-2);
    vctr := vctr + 1;

    l_er_ui_val := pay_balance_pkg.get_value(l_er_ui_id,NULL);
fnd_file.put_line(fnd_file.LOG,'l_er_ui_val ' ||l_er_ui_val||'  45');
    l_fm_er_ui_val := to_char(l_er_ui_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-ER-UI-D';
    vXMLTable(vCtr).TagValue := substr(l_fm_er_ui_val,1,length(l_fm_er_ui_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-ER-UI-F';
    vXMLTable(vCtr).TagValue := substr(l_fm_er_ui_val,length(l_fm_er_ui_val)-2);
    vctr := vctr + 1;

    l_tot_ui_val := l_ee_ui_val + l_er_ui_val;
    l_fm_tot_ui_val := to_char(l_tot_ui_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-TOT-UI-D';
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_ui_val,1,length(l_fm_tot_ui_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-TOT-UI-F';
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_ui_val,length(l_fm_tot_ui_val)-2);
    vctr := vctr + 1;
/*Bug 17495527 (Kuwait Report 166)  changes end */


    l_ee_pf_val := pay_balance_pkg.get_value(l_ee_pf_id,NULL);
fnd_file.put_line(fnd_file.LOG,'l_ee_pf_val ' ||l_ee_pf_val||'  45');
    l_fm_ee_pf_val := to_char(l_ee_pf_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-EE-PF-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_pf_val,1,length(l_fm_ee_pf_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-EE-PF-F';
    --vXMLTable(vCtr).TagValue := l_ee_pf_val - TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_pf_val,length(l_fm_ee_pf_val)-2);
    vctr := vctr + 1;

    l_er_pf_val := pay_balance_pkg.get_value(l_er_pf_id,NULL);
fnd_file.put_line(fnd_file.LOG,'l_er_pf_val ' ||l_er_pf_val||'  45');
    l_fm_er_pf_val := to_char(l_er_pf_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-ER-PF-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_er_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_er_pf_val,1,length(l_fm_er_pf_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-ER-PF-F';
    --vXMLTable(vCtr).TagValue := l_er_pf_val - TRUNC(l_er_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_er_pf_val,length(l_fm_er_pf_val)-2);
    vctr := vctr + 1;

      /* added for Oct 2012 report 166 changes  Bug 14704605 */

    l_tot_pf_val := l_ee_pf_val + l_er_pf_val;
    l_fm_tot_pf_val := to_char(l_tot_pf_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-TOT-PF-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_pf_val,1,length(l_fm_tot_pf_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-TOT-PF-F';
    --vXMLTable(vCtr).TagValue := l_ee_pf_val - TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_pf_val,length(l_fm_tot_pf_val)-2);
    vctr := vctr + 1;

     /* end 2012 */

    /*l_ee_basic_si_val := pay_balance_pkg.get_value(l_ee_basic_si_id,NULL);
    l_ee_supp_si_val := pay_balance_pkg.get_value(l_ee_supp_si_id,NULL);*/

    l_ee_basic_si_val := pay_balance_pkg.get_value(l_ee_basic_si_id,NULL) + pay_balance_pkg.get_value(l_ee_b_arr_id,NULL);
    l_ee_supp_si_val := pay_balance_pkg.get_value(l_ee_supp_si_id,NULL) + pay_balance_pkg.get_value(l_ee_s_arr_id,NULL);
fnd_file.put_line(fnd_file.LOG,'l_ee_basic_si_val ' ||l_ee_basic_si_val||'  45');
fnd_file.put_line(fnd_file.LOG,'l_ee_supp_si_val ' ||l_ee_supp_si_val||'  45');
    IF l_ee_basic_si_val <> 0 THEN
      l_ee_b := l_ee_basic_si_val - ((l_ee_basic_si_val/(l_ee_basic_si_val+l_ee_supp_si_val))*(l_ee_pf_val+l_ee_ui_val));
    ELSE
      l_ee_b := 0;
    END IF;
    IF l_ee_supp_si_val <> 0 THEN
      l_ee_s := l_ee_supp_si_val - ((l_ee_supp_si_val/(l_ee_basic_si_val+l_ee_supp_si_val))*(l_ee_pf_val+l_ee_ui_val));
    ELSE
      l_ee_s := 0;
    END IF;

    l_fm_ee_b := to_char(l_ee_b,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-EE-B-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_ee_b);
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_b,1,length(l_fm_ee_b)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-EE-B-F';
    --vXMLTable(vCtr).TagValue := (l_ee_b) - TRUNC(l_ee_b);
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_b,length(l_fm_ee_b)-2);
    vctr := vctr + 1;

    l_fm_ee_s := to_char(l_ee_s,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-EE-S-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_ee_s);
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_s,1,length(l_fm_ee_s)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-EE-S-F';
    --vXMLTable(vCtr).TagValue := l_ee_s - TRUNC(l_ee_s);
    vXMLTable(vCtr).TagValue := substr(l_fm_ee_s,length(l_fm_ee_s)-2);
    vctr := vctr + 1;

    l_er_basic_si_val := pay_balance_pkg.get_value(l_er_basic_si_id,NULL);
    l_er_supp_si_val := pay_balance_pkg.get_value(l_er_supp_si_id,NULL);

    IF l_er_basic_si_val <> 0 THEN
      l_er_b := l_er_basic_si_val - ((l_er_basic_si_val/(l_er_basic_si_val+l_er_supp_si_val))*(l_er_pf_val+l_er_ui_val));
    ELSE
      l_er_b := 0;
    END IF;
    IF  l_er_supp_si_val <> 0 THEN
      l_er_s := l_er_supp_si_val - ((l_er_supp_si_val/(l_er_basic_si_val+l_er_supp_si_val))*(l_er_pf_val+l_er_ui_val));
    ELSE
      l_er_s := 0;
    END IF;

    l_fm_er_b := to_char(l_er_b,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-ER-B-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_er_b);
    vXMLTable(vCtr).TagValue := substr(l_fm_er_b,1,length(l_fm_er_b)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-ER-B-F';
    --vXMLTable(vCtr).TagValue := l_er_b - TRUNC(l_er_b);
    vXMLTable(vCtr).TagValue := substr(l_fm_er_b,length(l_fm_er_b)-2);
    vctr := vctr + 1;

    l_fm_er_s := to_char(l_er_s,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-ER-S-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_er_s);
    vXMLTable(vCtr).TagValue := substr(l_fm_er_s,1,length(l_fm_er_s)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-ER-S-F';
    --vXMLTable(vCtr).TagValue := l_er_s - TRUNC(l_er_s);
    vXMLTable(vCtr).TagValue := substr(l_fm_er_s,length(l_fm_er_s)-2);
    vctr := vctr + 1;

      /* added for Oct 2012 report 166 changes Bug 14704605 */

    l_tot_basic_val := l_ee_b + l_er_b ;
    l_fm_tot_basic_val := to_char(l_tot_basic_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-TOT-BASIC-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_basic_val,1,length(l_fm_tot_basic_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-TOT-BASIC-F';
    --vXMLTable(vCtr).TagValue := l_ee_pf_val - TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_basic_val,length(l_fm_tot_basic_val)-2);
    vctr := vctr + 1;

    l_tot_supp_val := l_ee_s + l_er_s ;
    l_fm_tot_supp_val := to_char(l_tot_supp_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-TOT-SUPP-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_supp_val,1,length(l_fm_tot_supp_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-TOT-SUPP-F';
    --vXMLTable(vCtr).TagValue := l_ee_pf_val - TRUNC(l_ee_pf_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_tot_supp_val,length(l_fm_tot_supp_val)-2);
    vctr := vctr + 1;

    /* end 2012 */

    l_add_si_val := pay_balance_pkg.get_value(l_add_si_id,NULL) + pay_balance_pkg.get_value(l_add_arr_id,NULL);


    /*Code added to sum the total of Report167 as per the enhancement to Report167*/
    DECLARE
      CURSOR csr_get_assacts IS
      SELECT distinct asg.assignment_id
                    ,paa.assignment_action_id
      FROM   per_all_assignments_f asg  /*per_assignments_f asg*/
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_all_people_f ppf   /*per_people_f ppf*/
      WHERE  asg.assignment_id = paa.assignment_id
      AND    asg.person_id = ppf.person_id
      AND    ppf.nationality = l_local_nationality
      AND    paa.payroll_action_id = ppa.payroll_action_id
      AND    ppa.action_type in ('R','Q')
      AND    ppa.action_status = 'C'
      AND    paa.action_status IN ('C','S') --10375683
      AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
      AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
      AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
      AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
      AND    hscl.segment1 = to_char(p_employer_id);
      rec_get_assacts csr_get_assacts%ROWTYPE;
	l_deduction_amt    NUMBER;
	l_tot_deduction    NUMBER;
    BEGIN
      l_deduction_amt := 0;
      l_tot_deduction := 0;
      OPEN csr_get_assacts;
      LOOP
        FETCH csr_get_assacts INTO rec_get_assacts;
        EXIT WHEN csr_get_assacts%NOTFOUND;
        l_deduction_amt := 0;
        SELECT NVL(SUM(rrv.RESULT_VALUE),0)
        INTO   l_deduction_amt
        FROM   pay_element_entries_f  pee
                     ,pay_run_results  prr
                     ,pay_run_result_values  rrv
                     ,pay_input_values_f piv
        WHERE  rrv.RUN_RESULT_ID = prr.RUN_RESULT_ID
        AND    prr.assignment_action_id = rec_get_assacts.assignment_action_id
        AND    prr.element_entry_id = pee.element_entry_id
        AND    pee.assignment_id = rec_get_assacts.assignment_id
        AND    TRUNC(l_effective_date,'MM')  between trunc(pee.effective_start_date,'MM') and nvl(pee.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
        AND    pee.entry_information3 is not null
        AND    pee.entry_information3 IN ('71','65','72','999','82','73','85')
        AND    rrv.result_value IS NOT NULL
        AND    rrv.input_value_id = piv.input_value_id
        AND    piv.name = 'Pay Value'
        AND    prr.element_type_id = piv.element_type_id
        AND    pee.element_type_id = piv.element_type_id
        AND    TRUNC(l_effective_date,'MM')  between trunc(piv.effective_start_date,'MM') and nvl(piv.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'));
        l_tot_deduction := l_tot_deduction + l_deduction_amt;
      END LOOP;
    CLOSE csr_get_assacts;
    IF p_effective_year >= '2006' THEN
      l_add_si_val := 0;
    ELSE
      l_tot_deduction := 0;
    END IF;
    l_add_si_val := l_add_si_val + l_tot_deduction;
  END;


/*
    l_fm_add_si_val := to_char(l_add_si_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-A-S-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_add_si_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_add_si_val,1,length(l_fm_add_si_val)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-A-S-F';
    --vXMLTable(vCtr).TagValue := l_add_si_val - TRUNC(l_add_si_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_add_si_val,length(l_fm_add_si_val)-2);
    vctr := vctr + 1;
*/
    /* added 2012 */
      l_fm_add_si_val_tot := to_char(l_add_si_val,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-A-S-D-TOT';
    --vXMLTable(vCtr).TagValue := TRUNC(l_add_si_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_add_si_val_tot,1,length(l_fm_add_si_val_tot)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-A-S-F-TOT';
    --vXMLTable(vCtr).TagValue := l_add_si_val - TRUNC(l_add_si_val);
    vXMLTable(vCtr).TagValue := substr(l_fm_add_si_val_tot,length(l_fm_add_si_val_tot)-2);
    vctr := vctr + 1;

    l_fm_arrears := to_char(p_arrears,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-OTH-D';
    --vXMLTable(vCtr).TagValue := TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears,1,length(l_fm_arrears)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-F';
    --vXMLTable(vCtr).TagValue := p_arrears - TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears,length(l_fm_arrears)-2);
    vctr := vctr + 1;


/* added 2012 */

    /* following added for Oct 2012 166 report changes  Bug 14704605 */
    -- ,p_arrears2                NUMBER DEFAULT 0  /* changes in 166 - Aug 2012 */
   -- ,p_arrears3                NUMBER DEFAULT 0
  --  ,p_not_in_rep_167          NUMBER DEFAULT 0
  --  ,p_add_supp_insu_1997      NUMBER DEFAULT 0

        l_fm_arrears2 := to_char(p_arrears2,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-OTH-2-D';
    --vXMLTable(vCtr).TagValue := TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears2,1,length(l_fm_arrears2)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-2-F';
    --vXMLTable(vCtr).TagValue := p_arrears - TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears2,length(l_fm_arrears2)-2);
    vctr := vctr + 1;

        l_fm_arrears3 := to_char(p_arrears3,lg_format_mask);
fnd_file.put_line(fnd_file.LOG,'p_arrears3 ' ||p_arrears3||'  55');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears3 ' ||l_fm_arrears3||'  55');
    vXMLTable(vCtr).TagName := 'R166-OTH-3-D';
    --vXMLTable(vCtr).TagValue := TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears3,1,length(l_fm_arrears3)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-3-F';
    --vXMLTable(vCtr).TagValue := p_arrears - TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears3,length(l_fm_arrears3)-2);
    vctr := vctr + 1;

        l_fm_arrears6 := to_char(p_arrears6,lg_format_mask);
fnd_file.put_line(fnd_file.LOG,'p_arrears6 ' ||p_arrears6||'  55');
fnd_file.put_line(fnd_file.LOG,'l_fm_arrears6 ' ||l_fm_arrears6||'  55');
    vXMLTable(vCtr).TagName := 'R166-OTH-6-D';
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears6,1,length(l_fm_arrears6)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-6-F';
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears6,length(l_fm_arrears6)-2);
    vctr := vctr + 1;
/*
        l_fm_arrears4 := to_char(p_not_in_rep_167,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-OTH-4-D';
    --vXMLTable(vCtr).TagValue := TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears4,1,length(l_fm_arrears4)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-4-F';
    --vXMLTable(vCtr).TagValue := p_arrears - TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears4,length(l_fm_arrears4)-2);
    vctr := vctr + 1;

        l_fm_arrears5 := to_char(p_add_supp_insu_1997,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-OTH-5-D';
    --vXMLTable(vCtr).TagValue := TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears5,1,length(l_fm_arrears5)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-5-F';
    --vXMLTable(vCtr).TagValue := p_arrears - TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears5,length(l_fm_arrears5)-2);
    vctr := vctr + 1;
*/
         l_fm_arrears4_tot := to_char(p_not_in_rep_167,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-OTH-4-D-TOT';
    --vXMLTable(vCtr).TagValue := TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears4_tot,1,length(l_fm_arrears4_tot)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-4-F-TOT';
    --vXMLTable(vCtr).TagValue := p_arrears - TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears4_tot,length(l_fm_arrears4_tot)-2);
    vctr := vctr + 1;

      l_fm_arrears5_tot := to_char(p_add_supp_insu_1997,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-OTH-5-D-TOT';
    --vXMLTable(vCtr).TagValue := TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears5_tot,1,length(l_fm_arrears5_tot)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-OTH-5-F-TOT';
    --vXMLTable(vCtr).TagValue := p_arrears - TRUNC(p_arrears);
    vXMLTable(vCtr).TagValue := substr(l_fm_arrears5_tot,length(l_fm_arrears5_tot)-2);
    vctr := vctr + 1;

    /* end 2012 */


    /*l_total_amount := l_ee_basic_si_val + l_er_basic_si_val + l_ee_supp_si_val + l_er_supp_si_val + l_add_si_val + l_pf_val;*/
--    l_total_amount := l_ee_b + l_er_b + l_ee_s + l_er_s + l_add_si_val + l_ee_pf_val + l_er_pf_val;
    l_total_amount := l_ee_basic_si_val + l_er_basic_si_val + l_ee_supp_si_val + l_er_supp_si_val + l_add_si_val + NVL(p_arrears,0)
                         + NVL(p_arrears2,0) + NVL(p_arrears3,0) + NVL(p_arrears6,0) +NVL(p_not_in_rep_167,0) +NVL(p_add_supp_insu_1997,0);  -- added for aug 2012 bug 14704605
    l_fm_total_amount := to_char(l_total_amount,lg_format_mask);
    vXMLTable(vCtr).TagName := 'R166-TOT-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_total_amount);
    vXMLTable(vCtr).TagValue := substr(l_fm_total_amount,1,length(l_fm_total_amount)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-TOT-F';
fnd_file.put_line(fnd_file.LOG,'l_fm_total_amount ' ||l_fm_total_amount||'  50');
    --vXMLTable(vCtr).TagValue := l_total_amount - TRUNC(l_total_amount);
    vXMLTable(vCtr).TagValue := substr(l_fm_total_amount,length(l_fm_total_amount)-2);
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R166-TOT1-D';
    --vXMLTable(vCtr).TagValue := TRUNC(l_total_amount);
    vXMLTable(vCtr).TagValue := substr(l_fm_total_amount,1,length(l_fm_total_amount)-4);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R166-TOT1-F';
    --vXMLTable(vCtr).TagValue := l_total_amount - TRUNC(l_total_amount);
    vXMLTable(vCtr).TagValue := substr(l_fm_total_amount,length(l_fm_total_amount)-2);
    vctr := vctr + 1;


    hr_utility.set_location('Finished creating xml data for Procedure report166 ',20);

fnd_file.put_line(fnd_file.LOG,'Entering WritetoCLOB ' ||'  60');
    WritetoCLOB ( l_xfdf_blob );

EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;

  END report166;
------------------------------------------------------------------------------------

  PROCEDURE report167
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
    --,p_output_fname OUT NOCOPY VARCHAR2)
   AS


    l_effective_date           DATE;
    l_local_nationality       VARCHAR2(80);
    l_user_format             VARCHAR2(80);

    /*Cursor for fetching Employer SSN*/
    CURSOR csr_employer_ssn IS
    SELECT LPAD(org_information4,9,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';

    /*Cursor for fetching Employer Name*/
    CURSOR csr_employer_name IS
    SELECT name
    FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'KW'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    /*Cursor for fetching list of employees*/
    CURSOR csr_get_emp IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,hscl.segment2
    FROM   per_assignments_f asg   /*per_all_assignments_f asg*/
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f ppf   /*per_all_people_f ppf*/
    WHERE  asg.assignment_id = paa.assignment_id
    AND    asg.person_id = ppf.person_id
    AND    ppf.nationality = l_local_nationality
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S') --10375683
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id);
    rec_get_emp        csr_get_emp%ROWTYPE;

    /*Cursor for fetching employee name*/
    /*CURSOR csr_get_emp_name(p_person_id NUMBER) IS
    SELECT --SUBSTR(full_name,1,30)
           hr_person_name.get_person_name
           (p_person_id
           ,l_effective_date
           ,'DISPLAY_NAME'
           ,l_user_format)
    FROM   per_people_f ppf   --per_all_people_f ppf
    WHERE  person_id = p_person_id
    AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
    rec_get_emp_name   csr_get_emp_name%ROWTYPE;*/

    TYPE asi_emp_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,ssn                       NUMBER
    ,full_name                 VARCHAR2(240)
    ,asi_value                 NUMBER);
    TYPE asi_emp_rec_table IS TABLE OF asi_emp_rec INDEX BY BINARY_INTEGER;
    t_asi_emp_rec   asi_emp_rec_table;


    l_employer_name            hr_organization_units.name%TYPE;
    l_employer_ssn             NUMBER;
    l_add_si_id                NUMBER;
    l_add_si_arr_id            NUMBER;
    l_add_si_val               NUMBER;
    l_input_date               VARCHAR2(30);
    l_curr_date                VARCHAR2(30);
    l_full_name            per_all_people_f.full_name%TYPE;
    l_total_amount             NUMBER;
    i                          NUMBER;
    j                          NUMBER;
    l_count                    NUMBER;

    l_xfdf_string              CLOB;
    l_str1                     varchar2(240);
    l_str2                     varchar2(240);
    l_str3                     varchar2(240);
    l_str4                     varchar2(240);
    l_str5                     varchar2(240);
    l_str6                     varchar2(240);
    l_str7                     varchar2(240);
    l_str8                     varchar2(240);
    l_str9                     varchar2(240);
    l_str10                    varchar2(240);
    l_str_ser                  varchar2(240);
    l_str_er_name              varchar2(240);
    l_str_er_ssn_9             varchar2(240);
    l_str_er_ssn_8             varchar2(240);
    l_str_er_ssn_7             varchar2(240);
    l_str_er_ssn_6             varchar2(240);
    l_str_er_ssn_5             varchar2(240);
    l_str_er_ssn_4             varchar2(240);
    l_str_er_ssn_3             varchar2(240);
    l_str_er_ssn_2             varchar2(240);
    l_str_er_ssn_1             varchar2(240);
    l_str_er_ssn_0             varchar2(240);
    l_str_er_ssn_0a            varchar2(240);
    l_str_month                varchar2(240);
    l_str_year                 varchar2(240);
    l_str_total_af             varchar2(240);
    l_str_total_ad             varchar2(240);
    l_str_total_f              varchar2(240);
    l_str_total_d              varchar2(240);

    l_asi_processed            NUMBER;
    l_effective_month          VARCHAR2(50);

    l_fm_asi_value             VARCHAR2(50);
    l_fm_total_value           VARCHAR2(50);


  BEGIN
    g_report_old := 'Y';
    set_currency_mask(p_business_group_id);
    l_fm_asi_value := NULL;
    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    /*l_eff_term_date := to_date('28-'||to_char(l_effective_date,'MM-YYYY'),'DD-MM-YYYY');*/
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    l_user_format := NVL(FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT'),'G');
    l_local_nationality := NULL;
    BEGIN
      SELECT org_information1
      INTO l_local_nationality
      FROM hr_organization_information
      WHERE org_information_context = 'KW_BG_DETAILS'
      AND organization_id = p_business_group_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_local_nationality := NULL;
    END;

    -- To clear the PL/SQL Table values.
    hr_utility.set_location('Entering report167_old ',10);

    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    l_effective_month := hr_general.decode_lookup('KW_GREGORIAN_MONTH', p_effective_month);

    l_str1 := '<NAME>'||'<![CDATA['||l_employer_name||']]>'||'</NAME>'; /* Bug No : 8299900 */
    l_str2 := '<SSN-1>'||SUBSTR(l_employer_ssn,1,1)||'</SSN-1>';
    l_str3 := '<SSN-2>'||SUBSTR(l_employer_ssn,2,1)||'</SSN-2>';
    l_str4 := '<SSN-3>'||SUBSTR(l_employer_ssn,3,1)||'</SSN-3>';
    l_str5 := '<SSN-4>'||SUBSTR(l_employer_ssn,4,1)||'</SSN-4>';
    l_str6 := '<SSN-5>'||SUBSTR(l_employer_ssn,5,1)||'</SSN-5>';
    l_str7 := '<SSN-6>'||SUBSTR(l_employer_ssn,6,1)||'</SSN-6>';
    l_str8 := '<SSN-7>'||SUBSTR(l_employer_ssn,7,1)||'</SSN-7>';
    l_str9 := '<SSN-8>'||SUBSTR(l_employer_ssn,8,1)||'</SSN-8>';
    l_str10 := '<SSN-9>'||SUBSTR(l_employer_ssn,9,1)||'</SSN-9>';
    l_str_month := '<MONTH>'||l_effective_month||'</MONTH>';
    l_str_year := '<YEAR>'||p_effective_year||'</YEAR>';

    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);

    l_add_si_id := 0;
    l_add_si_arr_id := 0;

    /*Fetch Defined Balance Id*/
    OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_def_bal_id INTO l_add_si_id;
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ARREARS_ASG_RUN');
    FETCH csr_get_def_bal_id INTO l_add_si_arr_id;
    CLOSE csr_get_def_bal_id;

    /*Set Contexts and then fetch the balance values*/
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(l_effective_date));
    l_total_amount := 0;
    l_add_si_val := 0;
    i := 0;

    OPEN csr_get_emp;
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      l_add_si_val := 0;
      l_add_si_val := pay_balance_pkg.get_value(l_add_si_id,rec_get_emp.assignment_action_id)  +
                      pay_balance_pkg.get_value(l_add_si_arr_id,rec_get_emp.assignment_action_id);
      IF l_add_si_val > 0 THEN

        i := i + 1;
        l_full_name := NULL;
        /*OPEN csr_get_emp_name(rec_get_emp.person_id);
        FETCH csr_get_emp_name INTO l_full_name;
        CLOSE csr_get_emp_name;*/
        l_full_name := hr_person_name.get_person_name
                       (p_person_id       => rec_get_emp.person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);

        t_asi_emp_rec(i).person_id := rec_get_emp.person_id;
        t_asi_emp_rec(i).assignment_action_id := rec_get_emp.assignment_action_id;
        t_asi_emp_rec(i).full_name := l_full_name;
        t_asi_emp_rec(i).ssn := rec_get_emp.segment2;
        t_asi_emp_rec(i).asi_value := l_add_si_val;

      END IF;
    END LOOP;
    CLOSE csr_get_emp;

    j := 1;
      dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');
      dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
      l_str_er_name := '<NAME>'||'<![CDATA['||l_employer_name||']]>'||'</NAME>'; /* Bug No : 8299900 */
      l_str_er_ssn_9 := '<SSN-9>'||SUBSTR(l_employer_ssn,9,1)||'</SSN-9>';
      l_str_er_ssn_8 := '<SSN-8>'||SUBSTR(l_employer_ssn,8,1)||'</SSN-8>';
      l_str_er_ssn_7 := '<SSN-7>'||SUBSTR(l_employer_ssn,7,1)||'</SSN-7>';
      l_str_er_ssn_6 := '<SSN-6>'||SUBSTR(l_employer_ssn,6,1)||'</SSN-6>';
      l_str_er_ssn_5 := '<SSN-5>'||SUBSTR(l_employer_ssn,5,1)||'</SSN-5>';
      l_str_er_ssn_4 := '<SSN-4>'||SUBSTR(l_employer_ssn,4,1)||'</SSN-4>';
      l_str_er_ssn_3 := '<SSN-3>'||SUBSTR(l_employer_ssn,3,1)||'</SSN-3>';
      l_str_er_ssn_2 := '<SSN-2>'||SUBSTR(l_employer_ssn,2,1)||'</SSN-2>';
      l_str_er_ssn_1 := '<SSN-1>'||SUBSTR(l_employer_ssn,1,1)||'</SSN-1>';
      l_str_er_ssn_0 := '<SSN-0>'||'0'||'</SSN-0>';
      l_str_er_ssn_0a := '<SSN-0A>'||'0'||'</SSN-0A>';
      l_str_month := '<MONTH>'||l_effective_month||'</MONTH>';
      l_str_year := '<YEAR>'||p_effective_year||'</YEAR>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_9), l_str_er_ssn_9);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_8), l_str_er_ssn_8);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_7), l_str_er_ssn_7);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_6), l_str_er_ssn_6);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_5), l_str_er_ssn_5);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_4), l_str_er_ssn_4);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_3), l_str_er_ssn_3);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_2), l_str_er_ssn_2);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_1), l_str_er_ssn_1);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0), l_str_er_ssn_0);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0a), l_str_er_ssn_0a);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_month), l_str_month);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);
      --dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
    IF i > 0  THEN
      l_asi_processed := 0;
    ELSE
      l_asi_processed := 1;
      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
    END IF;

    WHILE l_asi_processed  <> 1 LOOP

    --Writing data for new employees
    l_count := 0;
    IF j > 10 THEN
      l_str_total_ad := '<ASI-TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</ASI-TOT-D>';
      l_str_total_af := '<ASI-TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</ASI-TOT-F>';
      l_str_total_d := '<TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</TOT-D>';
      l_str_total_f := '<TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</TOT-F>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ad), l_str_total_ad);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_af), l_str_total_af);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_d), l_str_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_f), l_str_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');

      dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
      l_str_er_name := '<NAME>'||'<![CDATA['||l_employer_name||']]>'||'</NAME>'; /* Bug No : 8299900 */
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_9), l_str_er_ssn_9);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_8), l_str_er_ssn_8);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_7), l_str_er_ssn_7);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_6), l_str_er_ssn_6);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_5), l_str_er_ssn_5);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_4), l_str_er_ssn_4);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_3), l_str_er_ssn_3);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_2), l_str_er_ssn_2);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_1), l_str_er_ssn_1);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0), l_str_er_ssn_0);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0a), l_str_er_ssn_0a);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_month), l_str_month);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);
    END IF;


    WHILE j <= i LOOP

      l_count := l_count+1;

      l_fm_asi_value := to_char(t_asi_emp_rec(j).asi_value,lg_format_mask);
      l_str_ser := '<SER-'||l_count||'>'||j||'</SER-'||l_count||'>';
      l_str4 := '<EMPLOYEE-NAME-'||l_count||'>'||substr(t_asi_emp_rec(j).full_name,1,30)||'</EMPLOYEE-NAME-'||l_count||'>';
      l_str5 := '<EMPLOYEE-SSN-'||l_count||'>'||t_asi_emp_rec(j).ssn||'</EMPLOYEE-SSN-'||l_count||'>';
      l_str6 := '<ASI-D-'||l_count||'>'||substr(l_fm_asi_value,1,length(l_fm_asi_value)-4)||'</ASI-D-'||l_count||'>';
      l_str7 := '<ASI-F-'||l_count||'>'||substr(l_fm_asi_value,length(l_fm_asi_value)-2)||'</ASI-F-'||l_count||'>';
      l_str8 := '<TOT-D-'||l_count||'>'||substr(l_fm_asi_value,1,length(l_fm_asi_value)-4)||'</TOT-D-'||l_count||'>';
      l_str9 := '<TOT-F-'||l_count||'>'||substr(l_fm_asi_value,length(l_fm_asi_value)-2)||'</TOT-F-'||l_count||'>';

      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ser), l_str_ser);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str8), l_str8);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
      --dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');

      l_total_amount := l_total_amount + t_asi_emp_rec(j).asi_value;
      l_fm_total_value := to_char(l_total_amount,lg_format_mask);

      j := j + 1;
      IF j > i THEN
        l_asi_processed := 1;
      END IF;

      IF l_count = 10 THEN
        EXIT;
      END IF;

    END LOOP;

  END LOOP;
    IF i > 0 THEN
      l_str_total_ad := '<ASI-TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</ASI-TOT-D>';
      l_str_total_af := '<ASI-TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</ASI-TOT-F>';
      l_str_total_d := '<TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</TOT-D>';
      l_str_total_f := '<TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</TOT-F>';
      l_str10 := '</EMP-REC>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ad), l_str_total_ad);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_af), l_str_total_af);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_d), l_str_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_f), l_str_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str10), l_str10);
    END IF;

    dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');

    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);

    hr_utility.set_location('Finished creating xml data for Procedure report167 ',20);

EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;

  END report167;

-------------------------------------------------------------------------------------------

  PROCEDURE report167_2006
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
    --,p_output_fname OUT NOCOPY VARCHAR2)
   AS


    l_effective_date           DATE;
    l_local_nationality       VARCHAR2(80);
    l_user_format             VARCHAR2(80);

    /*Cursor for fetching Employer SSN*/
    CURSOR csr_employer_ssn IS
    SELECT LPAD(org_information4,9,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';

    /*Cursor for fetching Employer Name*/
    CURSOR csr_employer_name IS
    SELECT name
    FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'KW'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    /*Cursor for fetching list of employees*/
    CURSOR csr_get_emp IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,hscl.segment2
                    ,asg.assignment_id
    FROM   per_assignments_f asg   /*per_all_assignments_f asg*/
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f ppf   /*per_all_people_f ppf*/
    WHERE  asg.assignment_id = paa.assignment_id
    AND    asg.person_id = ppf.person_id
    AND    ppf.nationality = l_local_nationality
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')  --10375683
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id);
    rec_get_emp        csr_get_emp%ROWTYPE;

    /*Cursor for fetching employee name*/
    /*CURSOR csr_get_emp_name(p_person_id NUMBER) IS
    SELECT --SUBSTR(full_name,1,30)
           hr_person_name.get_person_name
           (p_person_id
           ,l_effective_date
           ,'DISPLAY_NAME'
           ,l_user_format)
    FROM   per_people_f ppf   --per_all_people_f ppf
    WHERE  person_id = p_person_id
    AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
    rec_get_emp_name   csr_get_emp_name%ROWTYPE;*/

    /*Cursor for fetching deduction values*/
    CURSOR csr_get_ded_value(p_deduction_code VARCHAR2) IS
        SELECT NVL(SUM(rrv.RESULT_VALUE),0)
        FROM   pay_element_entries_f  pee
                     ,pay_run_results  prr
                     ,pay_run_result_values  rrv
                     ,pay_input_values_f piv
        WHERE  rrv.RUN_RESULT_ID = prr.RUN_RESULT_ID
        AND    prr.assignment_action_id = rec_get_emp.assignment_action_id
        AND    prr.element_entry_id = pee.element_entry_id
        AND    pee.assignment_id = rec_get_emp.assignment_id
        AND    TRUNC(l_effective_date,'MM')  between trunc(pee.effective_start_date,'MM') and nvl(pee.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
        AND    pee.entry_information3 is not null
        AND    pee.entry_information3 IN (p_deduction_code)
         /*( SELECT i.value
          FROM   pay_user_column_instances_f i
                 ,pay_user_rows_f r
                 ,pay_user_columns c
                 ,pay_user_tables t
          WHERE  (i.legislation_code = 'KW' AND i.business_group_id IS NULL)
          AND    (r.legislation_code = 'KW' AND r.business_group_id IS NULL)
          AND    c.legislation_code = 'KW'
          AND    t.legislation_code = 'KW'
          AND    UPPER(t.user_table_name) = UPPER('KW_DEDUCTION_MAPPING')
          AND    t.user_table_id = r.user_table_id
          AND    t.user_table_id = c.user_table_id
          AND    r.row_low_range_or_name = p_deduction_code
          AND    r.user_row_id = i.user_row_id
          AND    UPPER(c.user_column_name) = UPPER('DEDUCTION_TYPE')
          AND    c.user_column_id = i.user_column_id
          AND    TRUNC(l_effective_date,'MM') BETWEEN r.effective_start_date AND r.effective_end_date
          AND    TRUNC(l_effective_date,'MM') BETWEEN i.effective_start_date AND i.effective_end_date
          )*/
        AND    rrv.result_value IS NOT NULL
        AND    rrv.input_value_id = piv.input_value_id
        AND    piv.name = 'Pay Value'
        AND    prr.element_type_id = piv.element_type_id
        AND    pee.element_type_id = piv.element_type_id
        AND    TRUNC(l_effective_date,'MM')  between trunc(piv.effective_start_date,'MM') and nvl(piv.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'));

    /* Cursor for fetching Employer's Address */
    CURSOR csr_get_address IS
    SELECT  address_line_1 || decode(address_line_2,null,null,',') || address_line_2 || decode(postal_code,null,null,',')|| postal_code
    FROM     hr_locations hl
                   , hr_organization_units hou   /*hr_all_organization_units hou*/
    WHERE   hl.location_id = hou.location_id
    AND        hou.organization_id = p_employer_id;

    l_emp_address       VARCHAR2(1000);


    TYPE asi_emp_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,ssn                       NUMBER
    ,full_name                 VARCHAR2(240)
    ,asi_value                 NUMBER
    ,jps_b_value             NUMBER
    ,ul_b_value               NUMBER
    ,ci_b_value               NUMBER
    ,ua_b_value              NUMBER
    ,jps_c_value             NUMBER
    ,ci_c_value               NUMBER
    ,ua_c_value              NUMBER
    ,emp_tot_value         NUMBER);
    TYPE asi_emp_rec_table IS TABLE OF asi_emp_rec INDEX BY BINARY_INTEGER;
    t_asi_emp_rec   asi_emp_rec_table;


    l_employer_name            hr_organization_units.name%TYPE;
    l_employer_ssn             NUMBER;
    l_add_si_id                NUMBER;
    l_add_si_arr_id            NUMBER;
    l_add_si_val               NUMBER;
    l_input_date               VARCHAR2(30);
    l_curr_date                VARCHAR2(30);
    l_full_name            per_all_people_f.full_name%TYPE;
    l_total_amount             NUMBER;
    i                          NUMBER;
    j                          NUMBER;
    l_count                    NUMBER;

    l_xfdf_string              CLOB;
    l_str1                     varchar2(240);
    l_str2                     varchar2(240);
    l_str3                     varchar2(240);
    l_str4                     varchar2(240);
    l_str5                     varchar2(240);
    l_str6                     varchar2(240);
    l_str7                     varchar2(240);
    l_str8                     varchar2(240);
    l_str9                     varchar2(240);
    l_str10                    varchar2(240);
    l_str11                    varchar2(240);
    l_str12                    varchar2(240);
    l_str13                    varchar2(240);
    l_str14                    varchar2(240);
    l_str_ser                  varchar2(240);
    l_str_er_name              varchar2(240);
    l_str_er_ssn_9             varchar2(240);
    l_str_er_ssn_8             varchar2(240);
    l_str_er_ssn_7             varchar2(240);
    l_str_er_ssn_6             varchar2(240);
    l_str_er_ssn_5             varchar2(240);
    l_str_er_ssn_4             varchar2(240);
    l_str_er_ssn_3             varchar2(240);
    l_str_er_ssn_2             varchar2(240);
    l_str_er_ssn_1             varchar2(240);
    l_str_er_ssn_0             varchar2(240);
    l_str_er_ssn_0a            varchar2(240);
    l_str_month                varchar2(240);
    l_str_year                 varchar2(240);
    l_str_total_af             varchar2(240);
    l_str_total_ad             varchar2(240);
    l_str_total_f              varchar2(240);
    l_str_total_d              varchar2(240);

    l_str_er_addr              varchar2(1000);
    l_str_er_ssn               varchar2(240);

    l_asi_processed            NUMBER;
    l_effective_month          VARCHAR2(50);

    l_fm_asi_value             VARCHAR2(50);
    l_fm_total_value           VARCHAR2(50);

    l_fm_jps_b_value             VARCHAR2(50);
    l_fm_ul_b_value             VARCHAR2(50);
    l_fm_ci_b_value             VARCHAR2(50);
    l_fm_ua_b_value             VARCHAR2(50);
    l_fm_jps_c_value             VARCHAR2(50);
    l_fm_ci_c_value             VARCHAR2(50);
    l_fm_ua_c_value             VARCHAR2(50);
    l_fm_emp_total_value           VARCHAR2(50);

    l_jps_b_val               NUMBER;
    l_ul_b_val                NUMBER;
    l_ci_b_val               NUMBER;
    l_ua_b_val               NUMBER;
    l_jps_c_val               NUMBER;
    l_ci_c_val               NUMBER;
    l_ua_c_val               NUMBER;
    l_emp_tot_val        NUMBER;

    l_str_rep_yyyy      VARCHAR2(20);
    l_str_rep_mm       VARCHAR2(20);
    l_str_rep_dd        VARCHAR2(20);

  BEGIN
    g_report_old := 'N';
    set_currency_mask(p_business_group_id);
    l_fm_asi_value := NULL;
    l_fm_jps_b_value := NULL;
    l_fm_ul_b_value := NULL;
    l_fm_ci_b_value := NULL;
    l_fm_ua_b_value := NULL;
    l_fm_jps_c_value := NULL;
    l_fm_ci_c_value := NULL;
    l_fm_ua_c_value := NULL;

    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    /*l_eff_term_date := to_date('28-'||to_char(l_effective_date,'MM-YYYY'),'DD-MM-YYYY');*/
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    l_user_format := NVL(FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT'),'G');
    l_local_nationality := NULL;
    BEGIN
      SELECT org_information1
      INTO l_local_nationality
      FROM hr_organization_information
      WHERE org_information_context = 'KW_BG_DETAILS'
      AND organization_id = p_business_group_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_local_nationality := NULL;
    END;

    -- To clear the PL/SQL Table values.
    hr_utility.set_location('Entering report167 ',10);

    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    /*Fetch Employer Address*/
    OPEN csr_get_address;
    FETCH csr_get_address INTO l_emp_address;
    CLOSE csr_get_address;

    l_effective_month := hr_general.decode_lookup('KW_GREGORIAN_MONTH', p_effective_month);

    l_str1 := '<NAME>'||'<![CDATA['||l_employer_name||']]>'||'</NAME>'; /* Bug No : 8299900 */
    /**************l_str2 := '<SSN-1>'||SUBSTR(l_employer_ssn,1,1)||'</SSN-1>';
    l_str3 := '<SSN-2>'||SUBSTR(l_employer_ssn,2,1)||'</SSN-2>';
    l_str4 := '<SSN-3>'||SUBSTR(l_employer_ssn,3,1)||'</SSN-3>';
    l_str5 := '<SSN-4>'||SUBSTR(l_employer_ssn,4,1)||'</SSN-4>';
    l_str6 := '<SSN-5>'||SUBSTR(l_employer_ssn,5,1)||'</SSN-5>';
    l_str7 := '<SSN-6>'||SUBSTR(l_employer_ssn,6,1)||'</SSN-6>';
    l_str8 := '<SSN-7>'||SUBSTR(l_employer_ssn,7,1)||'</SSN-7>';
    l_str9 := '<SSN-8>'||SUBSTR(l_employer_ssn,8,1)||'</SSN-8>';
    l_str10 := '<SSN-9>'||SUBSTR(l_employer_ssn,9,1)||'</SSN-9>';************/

    l_str2 := '<ADDRESS>'||(l_emp_address)||'</ADDRESS>';
    l_str3 := '<EMPLOYER-SSN>'||(l_employer_ssn)||'</EMPLOYER-SSN>';
    l_str_month := '<Month>'||l_effective_month||'</Month>';
    l_str_year := '<Year>'||p_effective_year||'</Year>';

    l_str_rep_yyyy := '<YYYY>'||TO_CHAR(SYSDATE,'YYYY')||'</YYYY>';
    l_str_rep_mm := '<MM>'||TO_CHAR(SYSDATE,'MM')||'</MM>';
    l_str_rep_dd := '<DD>'||TO_CHAR(SYSDATE,'DD')||'</DD>';

    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);

    l_add_si_id := 0;
    l_add_si_arr_id := 0;

    /*Fetch Defined Balance Id*/
    /*Following code not required as per enhancement to 167*/
    /*OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_def_bal_id INTO l_add_si_id;
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ARREARS_ASG_RUN');
    FETCH csr_get_def_bal_id INTO l_add_si_arr_id;
    CLOSE csr_get_def_bal_id;*/

    /*Set Contexts and then fetch the balance values*/
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(l_effective_date));
    l_total_amount := 0;
    l_add_si_val := 0;
    i := 0;

    OPEN csr_get_emp;
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      l_add_si_val := 0;
      /*l_add_si_val := pay_balance_pkg.get_value(l_add_si_id,rec_get_emp.assignment_action_id)  +
                      pay_balance_pkg.get_value(l_add_si_arr_id,rec_get_emp.assignment_action_id);*/
      l_emp_tot_val := 0;
      l_jps_b_val := 0;
      l_ul_b_val := 0;
      l_ci_b_val := 0;
      l_ua_b_val := 0;
      l_jps_c_val := 0;
      l_ci_c_val := 0;
      l_ua_c_val := 0;
      /*Fetch value for Joint Past Services:Basic */
      OPEN csr_get_ded_value('71');
      FETCH csr_get_ded_value INTO l_jps_b_val;
      CLOSE csr_get_ded_value;
      /*Fetch value for Unpaid Leave:Basic */
      OPEN csr_get_ded_value('65');
      FETCH csr_get_ded_value INTO l_ul_b_val;
      CLOSE csr_get_ded_value;
      /*Fetch value for Commutation Installments:Basic */
      OPEN csr_get_ded_value('72');
      FETCH csr_get_ded_value INTO l_ci_b_val;
      CLOSE csr_get_ded_value;
      /*Fetch value for Undue Amounts:Basic */
      OPEN csr_get_ded_value('999');
      FETCH csr_get_ded_value INTO l_ua_b_val;
      CLOSE csr_get_ded_value;
      /*Fetch value for Joint Past Services:Complementary */
      OPEN csr_get_ded_value('82');
      FETCH csr_get_ded_value INTO l_jps_c_val;
      CLOSE csr_get_ded_value;
      /*Fetch value for Commutation Installments:Complamantary */
      OPEN csr_get_ded_value('73');
      FETCH csr_get_ded_value INTO l_ci_c_val;
      CLOSE csr_get_ded_value;
      /*Fetch value for Undue Amounts:Complementary */
      OPEN csr_get_ded_value('85');
      FETCH csr_get_ded_value INTO l_ua_c_val;
      CLOSE csr_get_ded_value;
      l_emp_tot_val := l_jps_b_val + l_ul_b_val + l_ci_b_val + l_ua_b_val + l_jps_c_val + l_ci_c_val + l_ua_c_val;
      IF (NVL(l_emp_tot_val,0) > 0) THEN

        i := i + 1;
        l_full_name := NULL;
        /*OPEN csr_get_emp_name(rec_get_emp.person_id);
        FETCH csr_get_emp_name INTO l_full_name;
        CLOSE csr_get_emp_name;*/
        l_full_name := hr_person_name.get_person_name
                       (p_person_id       => rec_get_emp.person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);

        t_asi_emp_rec(i).person_id := rec_get_emp.person_id;
        t_asi_emp_rec(i).assignment_action_id := rec_get_emp.assignment_action_id;
        t_asi_emp_rec(i).full_name := l_full_name;
        t_asi_emp_rec(i).ssn := rec_get_emp.segment2;
        --t_asi_emp_rec(i).asi_value := l_add_si_val;
        t_asi_emp_rec(i).jps_b_value := l_jps_b_val;
        t_asi_emp_rec(i).ul_b_value := l_ul_b_val;
        t_asi_emp_rec(i).ci_b_value := l_ci_b_val;
        t_asi_emp_rec(i).ua_b_value := l_ua_b_val;
        t_asi_emp_rec(i).jps_c_value := l_jps_c_val;
        t_asi_emp_rec(i).ci_c_value := l_ci_c_val;
        t_asi_emp_rec(i).ua_c_value := l_ua_c_val;
        t_asi_emp_rec(i).emp_tot_value := l_emp_tot_val;

      END IF;
    END LOOP;
    CLOSE csr_get_emp;

    j := 1;
      dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');
      dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
      l_str_er_name := '<NAME>'||'<![CDATA['||l_employer_name||']]>'||'</NAME>'; /* Bug No : 8299900 */
      /**********l_str_er_ssn_9 := '<SSN-9>'||SUBSTR(l_employer_ssn,9,1)||'</SSN-9>';
      l_str_er_ssn_8 := '<SSN-8>'||SUBSTR(l_employer_ssn,8,1)||'</SSN-8>';
      l_str_er_ssn_7 := '<SSN-7>'||SUBSTR(l_employer_ssn,7,1)||'</SSN-7>';
      l_str_er_ssn_6 := '<SSN-6>'||SUBSTR(l_employer_ssn,6,1)||'</SSN-6>';
      l_str_er_ssn_5 := '<SSN-5>'||SUBSTR(l_employer_ssn,5,1)||'</SSN-5>';
      l_str_er_ssn_4 := '<SSN-4>'||SUBSTR(l_employer_ssn,4,1)||'</SSN-4>';
      l_str_er_ssn_3 := '<SSN-3>'||SUBSTR(l_employer_ssn,3,1)||'</SSN-3>';
      l_str_er_ssn_2 := '<SSN-2>'||SUBSTR(l_employer_ssn,2,1)||'</SSN-2>';
      l_str_er_ssn_1 := '<SSN-1>'||SUBSTR(l_employer_ssn,1,1)||'</SSN-1>';
      l_str_er_ssn_0 := '<SSN-0>'||'0'||'</SSN-0>';
      l_str_er_ssn_0a := '<SSN-0A>'||'0'||'</SSN-0A>';************/

      l_str_er_addr := '<ADDRESS>'||(l_emp_address)||'</ADDRESS>';
      l_str_er_ssn := '<EMPLOYER-SSN>'||(l_employer_ssn)||'</EMPLOYER-SSN>';

      l_str_month := '<Month>'||l_effective_month||'</Month>';
      l_str_year := '<Year>'||p_effective_year||'</Year>';

      l_str_rep_yyyy := '<YYYY>'||TO_CHAR(SYSDATE,'YYYY')||'</YYYY>';
      l_str_rep_mm := '<MM>'||TO_CHAR(SYSDATE,'MM')||'</MM>';
      l_str_rep_dd := '<DD>'||TO_CHAR(SYSDATE,'DD')||'</DD>';

      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      /********dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_9), l_str_er_ssn_9);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_8), l_str_er_ssn_8);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_7), l_str_er_ssn_7);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_6), l_str_er_ssn_6);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_5), l_str_er_ssn_5);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_4), l_str_er_ssn_4);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_3), l_str_er_ssn_3);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_2), l_str_er_ssn_2);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_1), l_str_er_ssn_1);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0), l_str_er_ssn_0);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0a), l_str_er_ssn_0a);**********/

     dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_addr), l_str_er_addr);
     dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn), l_str_er_ssn);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_month), l_str_month);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);

      dbms_lob.writeAppend( l_xfdf_string, length(l_str_rep_yyyy), l_str_rep_yyyy);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_rep_mm), l_str_rep_mm);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_rep_dd), l_str_rep_dd);

      --dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
    IF i > 0  THEN
      l_asi_processed := 0;
    ELSE
      l_asi_processed := 1;
      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
    END IF;

    WHILE l_asi_processed  <> 1 LOOP

    --Writing data for new employees
    l_count := 0;
    IF j > 9 THEN
      /*****************l_str_total_ad := '<ASI-TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</ASI-TOT-D>';
      l_str_total_af := '<ASI-TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</ASI-TOT-F>';******************/
      l_str_total_d := '<TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</TOT-D>';
      l_str_total_f := '<TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</TOT-F>';
      /*dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ad), l_str_total_ad);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_af), l_str_total_af);*/
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_d), l_str_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_f), l_str_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');

      dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
      l_str_er_name := '<NAME>'||'<![CDATA['||l_employer_name||']]>'||'</NAME>'; /* Bug No : 8299900 */
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      /******dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_9), l_str_er_ssn_9);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_8), l_str_er_ssn_8);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_7), l_str_er_ssn_7);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_6), l_str_er_ssn_6);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_5), l_str_er_ssn_5);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_4), l_str_er_ssn_4);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_3), l_str_er_ssn_3);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_2), l_str_er_ssn_2);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_1), l_str_er_ssn_1);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0), l_str_er_ssn_0);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn_0a), l_str_er_ssn_0a);********/

     dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_addr), l_str_er_addr);
     dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn), l_str_er_ssn);

      dbms_lob.writeAppend( l_xfdf_string, length(l_str_month), l_str_month);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);

      dbms_lob.writeAppend( l_xfdf_string, length(l_str_rep_yyyy), l_str_rep_yyyy);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_rep_mm), l_str_rep_mm);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_rep_dd), l_str_rep_dd);
    END IF;


    WHILE j <= i LOOP

      l_count := l_count+1;

      --l_fm_asi_value := to_char(t_asi_emp_rec(j).asi_value,lg_format_mask);
      l_fm_jps_b_value := to_char(t_asi_emp_rec(j).jps_b_value,lg_format_mask);
      l_fm_ul_b_value := to_char(t_asi_emp_rec(j).ul_b_value,lg_format_mask);
      l_fm_ci_b_value := to_char(t_asi_emp_rec(j).ci_b_value,lg_format_mask);
      l_fm_ua_b_value := to_char(t_asi_emp_rec(j).ua_b_value,lg_format_mask);
      l_fm_jps_c_value := to_char(t_asi_emp_rec(j).jps_c_value,lg_format_mask);
      l_fm_ci_c_value := to_char(t_asi_emp_rec(j).ci_c_value,lg_format_mask);
      l_fm_ua_c_value := to_char(t_asi_emp_rec(j).ua_c_value,lg_format_mask);
      l_fm_emp_total_value := to_char(t_asi_emp_rec(j).emp_tot_value,lg_format_mask);

      l_str_ser := '<SER-'||l_count||'>'||j||'</SER-'||l_count||'>';
      l_str4 := '<EMPLOYEE-NAME-'||l_count||'>'||substr(t_asi_emp_rec(j).full_name,1,30)||'</EMPLOYEE-NAME-'||l_count||'>';
      l_str5 := '<EMPLOYEE-SSN-'||l_count||'>'||t_asi_emp_rec(j).ssn||'</EMPLOYEE-SSN-'||l_count||'>';
      /******************l_str6 := '<ASI-D-'||l_count||'>'||substr(l_fm_asi_value,1,length(l_fm_asi_value)-4)||'</ASI-D-'||l_count||'>';
      l_str7 := '<ASI-F-'||l_count||'>'||substr(l_fm_asi_value,length(l_fm_asi_value)-2)||'</ASI-F-'||l_count||'>';******************/

      l_str6 := '<JPS-B-'||l_count||'>'||(l_fm_jps_b_value)||'</JPS-B-'||l_count||'>';
      l_str7 := '<UL-B-'||l_count||'>'||(l_fm_ul_b_value)||'</UL-B-'||l_count||'>';
      l_str8 := '<CI-B-'||l_count||'>'||(l_fm_ci_b_value)||'</CI-B-'||l_count||'>';
      l_str9 := '<UA-B-'||l_count||'>'||(l_fm_ua_b_value)||'</UA-B-'||l_count||'>';
      l_str10 := '<JPS-C-'||l_count||'>'||(l_fm_jps_c_value)||'</JPS-C-'||l_count||'>';
      l_str11 := '<CI-C-'||l_count||'>'||(l_fm_ci_c_value)||'</CI-C-'||l_count||'>';
      l_str12 := '<UA-C-'||l_count||'>'||(l_fm_ua_c_value)||'</UA-C-'||l_count||'>';

     /********* l_str13 := '<TOT-D-'||l_count||'>'||substr(l_fm_asi_value,1,length(l_fm_asi_value)-4)||'</TOT-D-'||l_count||'>';
      l_str14 := '<TOT-F-'||l_count||'>'||substr(l_fm_asi_value,length(l_fm_asi_value)-2)||'</TOT-F-'||l_count||'>';*********/

      l_str13 := '<TOT-D-'||l_count||'>'||substr(l_fm_emp_total_value,1,length(l_fm_emp_total_value)-4)||'</TOT-D-'||l_count||'>';
      l_str14 := '<TOT-F-'||l_count||'>'||substr(l_fm_emp_total_value,length(l_fm_emp_total_value)-2)||'</TOT-F-'||l_count||'>';

      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ser), l_str_ser);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str8), l_str8);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str10), l_str10);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str11), l_str11);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str12), l_str12);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str13), l_str13);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str14), l_str14);
      --dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');

      l_total_amount := l_total_amount + t_asi_emp_rec(j).emp_tot_value;
      l_fm_total_value := to_char(l_total_amount,lg_format_mask);

      j := j + 1;
      IF j > i THEN
        l_asi_processed := 1;
      END IF;

      IF l_count = 9 THEN
        EXIT;
      END IF;

    END LOOP;

  END LOOP;
    IF i > 0 THEN
     /*********************** l_str_total_ad := '<ASI-TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</ASI-TOT-D>';
      l_str_total_af := '<ASI-TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</ASI-TOT-F>';*************************/
      l_str_total_d := '<TOT-D>'||substr(l_fm_total_value,1,length(l_fm_total_value)-4)||'</TOT-D>';
      l_str_total_f := '<TOT-F>'||substr(l_fm_total_value,length(l_fm_total_value)-2)||'</TOT-F>';
      l_str10 := '</EMP-REC>';
      /*********************dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ad), l_str_total_ad);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_af), l_str_total_af);**************************/
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_d), l_str_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_f), l_str_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str10), l_str10);
    END IF;

    dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');

    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);

    hr_utility.set_location('Finished creating xml data for Procedure report167 ',20);

EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;

  END report167_2006;
-------------------------------------------------------------------------------------------

 PROCEDURE report168
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS

    l_effective_date           DATE;
    l_user_format              VARCHAR2(80);
    TYPE new_assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,date_start                DATE);
    TYPE t_new_assact_table IS TABLE OF new_assact_rec INDEX BY BINARY_INTEGER;
    t_new_store_assact   t_new_assact_table;

    TYPE ter_assact_rec IS RECORD
    (person_id                  NUMBER
    ,assignment_action_id       NUMBER
    ,actual_termination_date    DATE
    ,date_earned                DATE);
    TYPE t_ter_assact_table IS TABLE OF ter_assact_rec INDEX BY BINARY_INTEGER;
    t_ter_store_assact   t_ter_assact_table;

    TYPE cha_assact_rec IS RECORD
    (person_id                  NUMBER
    ,assignment_action_id       NUMBER
    ,date_earned                DATE
    ,changed_salary             NUMBER
    ,assignment_id	       NUMBER);
    TYPE t_cha_assact_table IS TABLE OF cha_assact_rec INDEX BY BINARY_INTEGER;
    t_cha_store_assact   t_cha_assact_table;

 /*   TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_id	       NUMBER
    ,assignment_action_id      NUMBER);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;
 */

    /*Cursor for fetching Employer SSN*/
    CURSOR csr_employer_ssn IS
    SELECT LPAD(org_information4,9,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';

    /*Cursor for fetching Employer Name*/
    CURSOR csr_employer_name IS
    SELECT name
    FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'KW'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    l_local_nationality         VARCHAR2(80);

    /*Cursor for fetching list of new employees*/
    CURSOR csr_get_new_emp IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,pos.date_start
    FROM   per_assignments_f asg  /*per_all_assignments_f asg*/
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f ppf /*per_all_people_f ppf*/
    WHERE  asg.assignment_id = paa.assignment_id
    AND    asg.person_id = ppf.person_id
    AND    ppf.nationality = l_local_nationality
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')  --10375683
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') <> TRUNC(l_effective_date, 'MM')
    AND    trunc(pos.date_start, 'MM') = trunc(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id);
    rec_get_new_emp        csr_get_new_emp%ROWTYPE;


    /*Cursor for fetching list of terminated employees*/
    CURSOR csr_get_ter_emp IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,pos.actual_termination_date
                    ,ppa.date_earned
    FROM   per_assignments_f asg   /*per_all_assignments_f asg*/
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f  ppf  /*per_all_people_f ppf*/
    WHERE  asg.assignment_id = paa.assignment_id
    AND    asg.person_id = ppf.person_id
    AND    ppf.nationality = l_local_nationality
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')  --10375683
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id);
    rec_get_ter_emp        csr_get_ter_emp%ROWTYPE;

    /*Cursor for fetching effective date of salary change*/
    CURSOR csr_get_salary_date (p_person_id NUMBER) IS
    SELECT date_earned, paa.assignment_action_id
    FROM   per_assignments_f asg  /*per_all_assignments_f asg*/
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,per_periods_of_service pos
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')  --10375683
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(ppa.date_earned, 'MM') < TRUNC(l_effective_date, 'MM')
    AND    asg.person_id = p_person_id
    order by date_earned desc;
    rec_get_salary_date     csr_get_salary_date%ROWTYPE;

    /*Cursor for fetching list of employees who are neither new nor terminated*/
    CURSOR csr_get_cha_emp IS
    SELECT distinct asg.person_id
                     ,asg.assignment_id
                    ,paa.assignment_action_id
                    ,date_earned
    FROM   per_assignments_f asg  /*per_all_assignments_f asg*/
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f ppf   /*per_all_people_f ppf*/
    WHERE  asg.assignment_id = paa.assignment_id
    AND    asg.person_id = ppf.person_id
    AND    ppf.nationality = l_local_nationality
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')  --10375683
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(pos.date_start, 'MM') <> trunc(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') <> TRUNC(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') >= TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id);
    rec_get_cha_emp        csr_get_cha_emp%ROWTYPE;


    /*Cursor for fetching employee name*/
    CURSOR csr_get_emp_name(p_person_id NUMBER) IS
    SELECT /*full_name
           hr_person_name.get_person_name
           (p_person_id
           ,l_effective_date
           ,'DISPLAY_NAME'
           ,l_user_format)*/
            national_identifier
    FROM   per_people_f ppf  /*per_all_people_f ppf*/
    WHERE  person_id = p_person_id
    AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
    rec_get_emp_name   csr_get_emp_name%ROWTYPE;


    /* Cursor for fetching Defined balance ids from Org EIT for Social Allowance  Oct 2012*/
        CURSOR csr_get_def_bal_ids (l_emp_id number) IS
        SELECT  ORG_INFORMATION1
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_emp_id
        AND	org_information_context = 'KW_SI_DETAILS';


     /* Cursor to fetch assignment_action_id corresponding to first_date_earned to calculate social allowance Oct 2012*/
    CURSOR csr_get_assact_one (l_assignment_id number,l_date date) IS
    select paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')  --10375683
    and	 trunc(ppa.date_earned,'MM') = trunc(l_date,'MM') ;


        /*Cursor for fetching list of employees*/
 /*   CURSOR csr_get_emp (l_employer_id number, l_date date , l_nat varchar2) IS
    SELECT distinct asg.person_id
    		    ,asg.assignment_id
                    ,paa.assignment_action_id
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status in ('C','S')  --10375683
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.nationality = l_nat;
    rec_get_emp        csr_get_emp%ROWTYPE;
*/



    l_employer_name            hr_organization_units.name%TYPE;
    l_employer_ssn             NUMBER;
    l_subject_si_id            NUMBER;
    l_subject_si_val           NUMBER;
    l_input_date               VARCHAR2(30);
    l_full_name                per_all_people_f.full_name%TYPE;
    l_civil_id                 per_all_people_f.national_identifier%TYPE;
    l_salary_effective_date    DATE;
    l_diff_exist               NUMBER := 0;
    l_prev_salary              NUMBER;
    l_new_count                NUMBER;
    l_new_exist                NUMBER;
    l_recordS_exist            NUMBER;
    i                          NUMBER; /*For new employees*/
    j                          NUMBER; /*For new employees*/
    k                          NUMBER; /*For terminated employees*/
    l                          NUMBER; /*For terminated employees*/
    m                          NUMBER; /*For changed employees*/
    n                          NUMBER; /*For changed employees*/
    l_all_processed            NUMBER;
    l_new_processed            NUMBER;
    l_ter_processed            NUMBER;
    l_cha_processed            NUMBER;

    l_fm_subject_si_val        VARCHAR2(50) := NULL;
    l_fm_changed_salary        VARCHAR2(50) := NULL;
    l_effective_month          VARCHAR2(50);
    l_social_id number;
    l_first_date_earned date;
    l_assact_one number;
    l_first_social	number(15,3);
    l_fm_l_first_social varchar2(100);
    l_changed_sal number;

  BEGIN
  --  hr_utility.trace_on(null,'BPK');
  --  hr_utility.set_location('entering 168',10);

    set_currency_mask(p_business_group_id);
    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    /*l_eff_term_date := to_date('28-'||to_char(l_effective_date,'MM-YYYY'),'DD-MM-YYYY');*/

        hr_utility.set_location('l_input_date '|| l_input_date,20);
            hr_utility.set_location('l_effective_date'|| l_effective_date,30);

    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    l_user_format := NVL(FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT'),'G');
    l_local_nationality := NULL;
    BEGIN
      SELECT org_information1
      INTO l_local_nationality
      FROM hr_organization_information
      WHERE org_information_context = 'KW_BG_DETAILS'
      AND organization_id = p_business_group_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_local_nationality := NULL;
    END;

    -- To clear the PL/SQL Table values.
    vXMLTable.DELETE;
    vCtr := 1;
    hr_utility.set_location('Entering report168 ',10);

    l_effective_month := hr_general.decode_lookup('KW_GREGORIAN_MONTH', p_effective_month);

    vXMLTable(vCtr).TagName := 'R168-MONTH';
    vXMLTable(vCtr).TagValue := l_effective_month;
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R168-YEAR';
    vXMLTable(vCtr).TagValue := p_effective_year;
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R168-G-YYYY';
    vXMLTable(vCtr).TagValue := TO_CHAR(sysdate,'YYYY');
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R168-G-MM';
    vXMLTable(vCtr).TagValue := TO_CHAR(sysdate,'MM');
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'R168-G-DD';
    vXMLTable(vCtr).TagValue := TO_CHAR(sysdate,'DD');
    vctr := vctr + 1;

    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;

    vXMLTable(vCtr).TagName := 'R168-SSN-1';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,1,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-2';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,2,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-3';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,3,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-4';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,4,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-5';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,5,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-6';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,6,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-7';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,7,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-8';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,8,1);
    vctr := vctr + 1;
    vXMLTable(vCtr).TagName := 'R168-SSN-9';
    vXMLTable(vCtr).TagValue := SUBSTR(l_employer_ssn,9,1);
    vctr := vctr + 1;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    vXMLTable(vCtr).TagName := 'R168-NAME';
    vXMLTable(vCtr).TagValue := l_employer_name;
    vctr := vctr + 1;

    l_subject_si_id := 0;

    /*Fetch Defined Balance Id*/
    OPEN csr_get_def_bal_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_def_bal_id INTO l_subject_si_id;
    CLOSE csr_get_def_bal_id;

/* Oct 2012  for fetching Social allowance */
    OPEN csr_get_def_bal_ids(p_employer_id);
    FETCH csr_get_def_bal_ids into l_social_id;
    CLOSE csr_get_def_bal_ids;

/*   OPEN csr_get_emp(p_employer_id , l_effective_date ,l_local_nationality);
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      i := i + 1;
      t_store_assact(i).person_id := rec_get_emp.person_id;
      t_store_assact(i).assignment_id := rec_get_emp.assignment_id;
      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
    END LOOP;
    CLOSE csr_get_emp;  */


  /*Set Contexts and then fetch the balance values*/
    l_subject_si_val := 0;

    i := 0;
    k := 0;
    m := 0;

    OPEN csr_get_new_emp;
    LOOP
      FETCH csr_get_new_emp INTO rec_get_new_emp;
      EXIT WHEN csr_get_new_emp%NOTFOUND;
      i := i + 1;
      t_new_store_assact(i).person_id := rec_get_new_emp.person_id;
      t_new_store_assact(i).assignment_action_id := rec_get_new_emp.assignment_action_id;
      t_new_store_assact(i).date_start := rec_get_new_emp.date_start;
    END LOOP;
    CLOSE csr_get_new_emp;

    OPEN csr_get_ter_emp;
    LOOP
      FETCH csr_get_ter_emp INTO rec_get_ter_emp;
      EXIT WHEN csr_get_ter_emp%NOTFOUND;
      k := k + 1;
      t_ter_store_assact(k).person_id := rec_get_ter_emp.person_id;
      t_ter_store_assact(k).assignment_action_id := rec_get_ter_emp.assignment_action_id;
      t_ter_store_assact(k).actual_termination_date := rec_get_ter_emp.actual_termination_date;
      t_ter_store_assact(k).date_earned := rec_get_ter_emp.date_earned;
    END LOOP;
    CLOSE csr_get_ter_emp;

    OPEN csr_get_cha_emp;
    LOOP
      FETCH csr_get_cha_emp INTO rec_get_cha_emp;
      EXIT WHEN csr_get_cha_emp%NOTFOUND;
      l_diff_exist := 0;
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,rec_get_cha_emp.assignment_action_id);
      l_salary_effective_date := rec_get_cha_emp.date_earned;
      OPEN csr_get_salary_date (rec_get_cha_emp.person_id);
      LOOP
        FETCH csr_get_salary_date INTO rec_get_salary_date;
        EXIT WHEN csr_get_salary_date%NOTFOUND;
        l_prev_salary := pay_balance_pkg.get_value(l_subject_si_id,rec_get_salary_date.assignment_action_id);
        IF l_prev_salary <> l_subject_si_val THEN
          l_diff_exist := 1;
          EXIT;
        END IF;
        EXIT;
      END LOOP;
      CLOSE csr_get_salary_date;
      IF l_diff_exist = 1 THEN
        m := m + 1;

        t_cha_store_assact(m).person_id := rec_get_cha_emp.person_id;
        t_cha_store_assact(m).assignment_action_id := rec_get_cha_emp.assignment_action_id;
        t_cha_store_assact(m).date_earned := rec_get_cha_emp.date_earned;
        t_cha_store_assact(m).changed_salary := l_subject_si_val;
        t_cha_store_assact(m).assignment_id := rec_get_cha_emp.assignment_id; -- oct 2012
      END IF;
    END LOOP;
    CLOSE csr_get_cha_emp;

    j := 1;
    l := 1;
    n := 1;
    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;
    IF k > 0  THEN
      l_ter_processed := 0;
    ELSE
      l_ter_processed := 1;
    END IF;
    IF m > 0  THEN
      l_cha_processed := 0;
    ELSE
      l_cha_processed := 1;
    END IF;

    l_all_processed := 0;
    WHILE l_all_processed  <> 1 LOOP

if l_effective_date <= to_date('30-09-2012','DD-MM-YYYY') then
    hr_utility.set_location('inside sep 2012 or less'|| l_effective_date,30);
   --Writing data for new employees
    l_new_count := 0;
    WHILE j <= i LOOP

      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_new_store_assact(j).assignment_action_id);
      l_civil_id := NULL;
      l_full_name := NULL;
      OPEN csr_get_emp_name(t_new_store_assact(j).person_id);
      FETCH csr_get_emp_name INTO /*l_full_name,*/ l_civil_id;
      CLOSE csr_get_emp_name;

      l_full_name := hr_person_name.get_person_name
                       (p_person_id       => t_new_store_assact(j).person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'FULL_NAME' --'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);

      l_new_count := l_new_count+1;

      l_fm_subject_si_val := to_char(l_subject_si_val,lg_format_mask);

      vXMLTable(vCtr).TagName := 'R168-N-SEQ-'||l_new_count;
      vXMLTable(vCtr).TagValue := j;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-NAME-'||l_new_count;
      vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,30);
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-CID-'||l_new_count;
      vXMLTable(vCtr).TagValue := l_civil_id;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-HIRE-'||l_new_count;
      vXMLTable(vCtr).TagValue := t_new_store_assact(j).date_start;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-SAL-D-'||l_new_count;
      --vXMLTable(vCtr).TagValue := TRUNC(l_subject_si_val);
      vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,1,length(l_fm_subject_si_val)-4);
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-SAL-F-'||l_new_count;
      --vXMLTable(vCtr).TagValue := l_subject_si_val - TRUNC(l_subject_si_val);
      vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,length(l_fm_subject_si_val)-2);
      vctr := vctr + 1;

      j := j + 1;
      IF j > i THEN
        l_new_processed := 1;
      END IF;

      IF l_new_count = 8 THEN
        EXIT;
      END IF;

    END LOOP;


    --Writing data for terminated employees
    l_new_count := 0;
    WHILE l <= k LOOP
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_ter_store_assact(l).assignment_action_id);
      l_civil_id := NULL;
      l_full_name := NULL;
      OPEN csr_get_emp_name(t_ter_store_assact(l).person_id);
      FETCH csr_get_emp_name INTO /*l_full_name,*/ l_civil_id;


      CLOSE csr_get_emp_name;
      l_full_name := hr_person_name.get_person_name
                       (p_person_id       => t_ter_store_assact(l).person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'FULL_NAME' --'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);


      l_new_count := l_new_count+1;

      l_fm_subject_si_val := to_char(l_subject_si_val,lg_format_mask);

      vXMLTable(vCtr).TagName := 'R168-T-SEQ-'||l_new_count;
      vXMLTable(vCtr).TagValue := l;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-TEE-NAME-'||l_new_count;
      vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,30);
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-TEE-CID-'||l_new_count;
      vXMLTable(vCtr).TagValue := l_civil_id;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-TEE-TER-'||l_new_count;
      vXMLTable(vCtr).TagValue := t_ter_store_assact(l).actual_termination_date;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-TEE-SAL-D-'||l_new_count;
      --vXMLTable(vCtr).TagValue := TRUNC(l_subject_si_val);
      vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,1,length(l_fm_subject_si_val)-4);
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-TEE-SAL-F-'||l_new_count;
      --vXMLTable(vCtr).TagValue := l_subject_si_val - TRUNC(l_subject_si_val);
      vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,length(l_fm_subject_si_val)-2);
      vctr := vctr + 1;

      l_salary_effective_date := t_ter_store_assact(l).date_earned;
      OPEN csr_get_salary_date (t_ter_store_assact(l).person_id);
      LOOP
        FETCH csr_get_salary_date INTO rec_get_salary_date;
        EXIT WHEN csr_get_salary_date%NOTFOUND;
        l_prev_salary := pay_balance_pkg.get_value(l_subject_si_id,rec_get_salary_date.assignment_action_id);
        IF l_prev_salary <> l_subject_si_val THEN
          EXIT;
        ELSE
           l_salary_effective_date := rec_get_salary_date.date_earned;
        END IF;
      END LOOP;
      CLOSE csr_get_salary_date;

      vXMLTable(vCtr).TagName := 'R168-TEE-SAL-DATE-'||l_new_count;
      vXMLTable(vCtr).TagValue := TRUNC(l_salary_effective_date);
      vctr := vctr + 1;

      l := l + 1;
      IF l > k THEN
        l_ter_processed := 1;
      END IF;
      IF l_new_count = 8 THEN
        EXIT;
      END IF;

    END LOOP;

      --Writing data for employees with changed salary
    l_new_count := 0;
    WHILE n <= m LOOP
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_cha_store_assact(n).assignment_action_id);
      l_civil_id := NULL;
      l_full_name := NULL;
      OPEN csr_get_emp_name(t_cha_store_assact(n).person_id);
      FETCH csr_get_emp_name INTO /*l_full_name,*/ l_civil_id;
      CLOSE csr_get_emp_name;
      l_full_name := hr_person_name.get_person_name
                       (p_person_id       => t_cha_store_assact(n).person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'FULL_NAME' --'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);


      l_new_count := l_new_count+1;

      l_fm_changed_salary := to_char(t_cha_store_assact(n).changed_salary,lg_format_mask);
      vXMLTable(vCtr).TagName := 'R168-C-SEQ-'||l_new_count;
      vXMLTable(vCtr).TagValue := n;
      vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-NAME-'||l_new_count;
        vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,30);
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-CID-'||l_new_count;
        vXMLTable(vCtr).TagValue := l_civil_id;
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-SAL-D-'||l_new_count;
        --vXMLTable(vCtr).TagValue := TRUNC(t_cha_store_assact(n).changed_salary);
        vXMLTable(vCtr).TagValue := substr(l_fm_changed_salary,1,length(l_fm_changed_salary)-4);
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-SAL-F-'||l_new_count;
        --vXMLTable(vCtr).TagValue := t_cha_store_assact(n).changed_salary - TRUNC(t_cha_store_assact(n).changed_salary);
        vXMLTable(vCtr).TagValue := substr(l_fm_changed_salary,length(l_fm_changed_salary)-2);
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-SAL-DATE-'||l_new_count;
        vXMLTable(vCtr).TagValue := TRUNC(t_cha_store_assact(n).date_earned);
        vctr := vctr + 1;

      n := n + 1;
      IF n > m THEN
        l_cha_processed := 1;
      END IF;
      IF l_new_count = 10 THEN
        EXIT;
      END IF;

    END LOOP;

else
   hr_utility.set_location('inside oct 2012 or more'|| l_effective_date,30);
    l_new_count := 0;
 --    WHILE j <= i or l <= k LOOP /*loop for both new and terminated sicne now we report both in a single table */
       while j <= i loop
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_new_store_assact(j).assignment_action_id);
      l_civil_id := NULL;
      l_full_name := NULL;

       hr_utility.set_location('l_subject_si_val'|| l_subject_si_val,30);

      OPEN csr_get_emp_name(t_new_store_assact(j).person_id);
      FETCH csr_get_emp_name INTO /*l_full_name,*/ l_civil_id;
      CLOSE csr_get_emp_name;

      hr_utility.set_location('l_civil_id'|| l_civil_id,30);

      l_full_name := hr_person_name.get_person_name
                       (p_person_id       => t_new_store_assact(j).person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'FULL_NAME' --'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);

     hr_utility.set_location('l_full_name'|| l_full_name,30);

      l_new_count := l_new_count+1;

      l_fm_subject_si_val := to_char(l_subject_si_val,lg_format_mask);

       hr_utility.set_location('l_fm_subject_si_val'|| l_fm_subject_si_val,30);

    --  vXMLTable(vCtr).TagName := 'R168-N-SEQ-'||l_new_count;
    --  vXMLTable(vCtr).TagValue := j;
    --  vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-NAME-'||l_new_count;
      vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,30);
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-CID-'||l_new_count;
      vXMLTable(vCtr).TagValue := l_civil_id;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-HIRE-'||l_new_count;
      vXMLTable(vCtr).TagValue := t_new_store_assact(j).date_start;
      vctr := vctr + 1;
    --   vXMLTable(vCtr).TagName := 'R168-NEE-SAL-D-'||l_new_count;
      --vXMLTable(vCtr).TagValue := TRUNC(l_subject_si_val);
    --  vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,1,length(l_fm_subject_si_val)-4);
    --  vctr := vctr + 1;
    --  vXMLTable(vCtr).TagName := 'R168-NEE-SAL-F-'||l_new_count;
      --vXMLTable(vCtr).TagValue := l_subject_si_val - TRUNC(l_subject_si_val);
    --  vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,length(l_fm_subject_si_val)-2);
    --  vctr := vctr + 1;

        j := j + 1;
        hr_utility.set_location('j'|| j,30);

      IF j > i THEN
        l_new_processed := 1;
        hr_utility.set_location('l_new_processed'|| l_new_processed,30);
      END IF;

       IF l_new_count = 4 THEN /* changed from 8 to 4 for the new template */
        EXIT;
      END IF;

      end loop;

   while l <= k LOOP

     IF l_new_count = 4 THEN /* changed from 8 to 4 for the new template */
        EXIT;
      END IF;

     l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_ter_store_assact(l).assignment_action_id);
      l_civil_id := NULL;
      l_full_name := NULL;

      OPEN csr_get_emp_name(t_ter_store_assact(l).person_id);
      FETCH csr_get_emp_name INTO /*l_full_name,*/  l_civil_id;
      CLOSE csr_get_emp_name;

      hr_utility.set_location('l_civil_id'|| l_civil_id,30);
      l_full_name := hr_person_name.get_person_name
                       (p_person_id       => t_ter_store_assact(l).person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'FULL_NAME' --'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);

     hr_utility.set_location('l_full_name'|| l_full_name,30);

      l_new_count := l_new_count+1;

      l_fm_subject_si_val := to_char(l_subject_si_val,lg_format_mask);


      hr_utility.set_location('l_subject_si_val'|| l_subject_si_val,30);

      hr_utility.set_location('l_fm_subject_si_val'|| l_fm_subject_si_val,30);

    /*  vXMLTable(vCtr).TagName := 'R168-T-SEQ-'||l_new_count;
      vXMLTable(vCtr).TagValue := l;
      vctr := vctr + 1;
    */
      vXMLTable(vCtr).TagName := 'R168-NEE-NAME-'||l_new_count; /* changed */
      vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,30);
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-NEE-CID-'||l_new_count; /* changed */
      vXMLTable(vCtr).TagValue := l_civil_id;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'R168-TEE-TER-'||l_new_count;
      vXMLTable(vCtr).TagValue := t_ter_store_assact(l).actual_termination_date;
      vctr := vctr + 1;
     -- vXMLTable(vCtr).TagName := 'R168-TEE-SAL-D-'||l_new_count;
      --vXMLTable(vCtr).TagValue := TRUNC(l_subject_si_val);
     -- vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,1,length(l_fm_subject_si_val)-4);
     -- vctr := vctr + 1;
    --  vXMLTable(vCtr).TagName := 'R168-TEE-SAL-F-'||l_new_count;
      --vXMLTable(vCtr).TagValue := l_subject_si_val - TRUNC(l_subject_si_val);
     -- vXMLTable(vCtr).TagValue := substr(l_fm_subject_si_val,length(l_fm_subject_si_val)-2);
     -- vctr := vctr + 1;

    /*  l_salary_effective_date := t_ter_store_assact(l).date_earned;
      OPEN csr_get_salary_date (t_ter_store_assact(l).person_id);
      LOOP
        FETCH csr_get_salary_date INTO rec_get_salary_date;
        EXIT WHEN csr_get_salary_date%NOTFOUND;
        l_prev_salary := pay_balance_pkg.get_value(l_subject_si_id,rec_get_salary_date.assignment_action_id);
        IF l_prev_salary <> l_subject_si_val THEN
          EXIT;
        ELSE
           l_salary_effective_date := rec_get_salary_date.date_earned;
        END IF;
      END LOOP;
      CLOSE csr_get_salary_date;


     hr_utility.set_location('l_salary_effective_date'|| l_salary_effective_date,30);

      vXMLTable(vCtr).TagName := 'R168-TEE-SAL-DATE-'||l_new_count;
      vXMLTable(vCtr).TagValue := TRUNC(l_salary_effective_date);
      vctr := vctr + 1;
     */

      l := l + 1;
      IF l > k THEN
        l_ter_processed := 1;
      END IF;
     end loop;

   --   IF l_new_count = 4 THEN /* changed from 8 to 4 for the new template */
  --      EXIT;
  --    END IF;

  --  END LOOP;

      --Writing data for employees with changed salary
    l_new_count := 0;
    WHILE n <= m LOOP
      hr_utility.set_location('BPK Writing data for employees with changed salary',30);
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_cha_store_assact(n).assignment_action_id);
      l_civil_id := NULL;
      l_full_name := NULL;
      l_assact_one := null;

        hr_utility.set_location('l_subject_si_val'|| l_subject_si_val,30);

      OPEN csr_get_emp_name(t_cha_store_assact(n).person_id);
      FETCH csr_get_emp_name INTO /*l_full_name,*/ l_civil_id;
      CLOSE csr_get_emp_name;
      l_full_name := hr_person_name.get_person_name
                       (p_person_id       => t_cha_store_assact(n).person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'FULL_NAME' --'DISPLAY_NAME'
                       ,p_user_format_choice => l_user_format);
      hr_utility.set_location('l_full_name'|| l_full_name,30);

       /* Get the assact id corresponding to the first_assact_date calculated above  Oct 2012 for report 168*/
      OPEN csr_get_assact_one (t_cha_store_assact(n).assignment_id,t_cha_store_assact(n).date_earned);
      FETCH csr_get_assact_one into l_assact_one;
      CLOSE csr_get_assact_one;
     hr_utility.set_location('l_social_id'|| l_social_id ,30);
     hr_utility.set_location('l_assact_one'|| l_assact_one ,30);
      If l_social_id is not null THEN
       	If l_assact_one is not null then
            l_first_social := pay_balance_pkg.get_value(l_social_id,l_assact_one);
	      Else
	     	l_first_social := 0;
	      End If;
      Else
        l_first_social := 0;
      End If;
      hr_utility.set_location('l_first_social'|| l_first_social ,30);
      l_new_count := l_new_count+1;
     hr_utility.set_location('t_cha_store_assact(n).changed_salary'|| t_cha_store_assact(n).changed_salary ,30);
     l_changed_sal := t_cha_store_assact(n).changed_salary - l_first_social;  /* salary = salary - Social Allowance */

  --     l_changed_sal := l_subject_si_val - l_first_social;

     hr_utility.set_location('l_changed_sal'|| l_changed_sal ,30);

       l_fm_l_first_social := to_char(l_first_social,lg_format_mask);  -- added for Oct 2012 report 168 change

 --     l_fm_changed_salary := to_char(t_cha_store_assact(n).changed_salary,lg_format_mask);
        l_fm_changed_salary := to_char(l_changed_sal,lg_format_mask);

      hr_utility.set_location('l_fm_l_first_social'|| l_fm_l_first_social ,30);

      hr_utility.set_location('l_fm_changed_salary'|| l_fm_changed_salary ,30);

     /* vXMLTable(vCtr).TagName := 'R168-C-SEQ-'||l_new_count;
      vXMLTable(vCtr).TagValue := n;
      vctr := vctr + 1;
     */
        vXMLTable(vCtr).TagName := 'R168-CEE-NAME-'||l_new_count;
        vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,30);
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-CID-'||l_new_count;
        vXMLTable(vCtr).TagValue := l_civil_id;
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-SAL-D-'||l_new_count;
        --vXMLTable(vCtr).TagValue := TRUNC(t_cha_store_assact(n).changed_salary);
        vXMLTable(vCtr).TagValue := substr(l_fm_changed_salary,1,length(l_fm_changed_salary)-4);
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-SAL-F-'||l_new_count;
        --vXMLTable(vCtr).TagValue := t_cha_store_assact(n).changed_salary - TRUNC(t_cha_store_assact(n).changed_salary);
        vXMLTable(vCtr).TagValue := substr(l_fm_changed_salary,length(l_fm_changed_salary)-2);
        vctr := vctr + 1;
        vXMLTable(vCtr).TagName := 'R168-CEE-SAL-DATE-'||l_new_count;
        vXMLTable(vCtr).TagValue := TRUNC(t_cha_store_assact(n).date_earned);
        vctr := vctr + 1;

/* added for Oct 2012 change */
      vXMLTable(vCtr).TagName := 'R168-CEE-SOC-ALLOW-D-'||l_new_count;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_first_social,1,length(l_fm_l_first_social)-4);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'R168-CEE-SOC-ALLOW-F-'||l_new_count;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_first_social,length(l_fm_l_first_social)-2);
      vctr := vctr + 1;


      n := n + 1;
      IF n > m THEN
        l_cha_processed := 1;
      END IF;
      IF l_new_count = 5 THEN /* changed from 10 to 5 */
        EXIT;
      END IF;

    END LOOP;

  end if;

hr_utility.set_location('out to page-break',30);

      vXMLTable(vCtr).TagName := 'PAGE-BK';
      vXMLTable(vCtr).TagValue := '    ';
      vctr := vctr + 1;

    IF l_ter_processed = 1 AND l_new_processed = 1 AND l_cha_processed = 1 THEN
      l_all_processed := 1;
    END IF;

    END LOOP;

    hr_utility.set_location('Finished creating xml data for Procedure report168 ',20);

    WritetoCLOB ( l_xfdf_blob );

EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;

  END report168;

 -------------------------------------------------------------------------------------------




----------------------------------------------
  PROCEDURE WritetoCLOB
    (p_xfdf_blob out nocopy blob)
  IS
    l_xfdf_string clob;
    l_str1 varchar2(1000);
    l_str2 varchar2(20);
    l_str3 varchar2(20);
    l_str4 varchar2(20);
    l_str5 varchar2(20);
    l_str6 varchar2(30);
    l_str7 varchar2(1000);
    l_str8 varchar2(240);
    l_str9 varchar2(240);
  BEGIN
    hr_utility.set_location('Entered Procedure Write to clob ',100);
    l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
      		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
      		 <fields> ' ;
    l_str2 := '<field name="';
    l_str3 := '">';
    l_str4 := '<value>' ;
    l_str5 := '</value> </field>' ;
    l_str6 := '</fields> </xfdf>';
    l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
	       <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       	       <fields>
       	       </fields> </xfdf>';
    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    if vXMLTable.COUNT > 0 then
      dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
      FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        l_str8 := vXMLTable(ctr_table).TagName;
        l_str9 := vXMLTable(ctr_table).TagValue;
        if (l_str9 is not null) then
	  /* Added CDATA to handle special characters Bug No:8299900 */
	  l_str9 := '<![CDATA['||l_str9||']]>';
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
	elsif (l_str9 is null and l_str8 is not null) then
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
	else
	  null;
	end if;
      END LOOP;
      dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
    else
      dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
    end if;
    DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,p_xfdf_blob);
fnd_file.put_line(fnd_file.LOG,'Finished Procedure Write to CLOB ,Before clob to blob ' ||'  80');
    hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
  EXCEPTION
    WHEN OTHERS then
      HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
      HR_UTILITY.RAISE_ERROR;
  END WritetoCLOB;
----------------------------------------------------------------
  Procedure  clob_to_blob
    (p_clob clob,
    p_blob IN OUT NOCOPY Blob)
  is
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);

    l_raw_buffer_len pls_integer;
    l_blob_offset    pls_integer := 1;

  begin
    l_buffer_len := 20000;
    hr_utility.set_location('Entered Procedure clob to blob',120);
    select userenv('LANGUAGE') into g_nls_db_char from dual;
    l_length_clob := dbms_lob.getlength(p_clob);
    l_offset := 1;
    while l_length_clob > 0 loop
      hr_utility.trace('l_length_clob '|| l_length_clob);
      if l_length_clob < l_buffer_len then
        l_chunk_len := l_length_clob;
      else
        l_chunk_len := l_buffer_len;
      end if;
      DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
      --l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
      l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
      l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char));

fnd_file.put_line(fnd_file.log, l_varchar_buffer);

      hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
      --dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
      dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
      l_blob_offset := l_blob_offset + l_raw_buffer_len;

      l_offset := l_offset + l_chunk_len;
      l_length_clob := l_length_clob - l_chunk_len;
      hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
    end loop;
    hr_utility.set_location('Finished Procedure clob to blob ',130);
  end clob_to_blob;

------------------------------------------------------------------
   Procedure fetch_pdf_blob
	(p_report in varchar2,
	 p_effective_month varchar2,
	 p_effective_year varchar2,
	 p_pdf_blob OUT NOCOPY blob)
  IS
  BEGIN
    IF (p_report='REPORT166') THEN
    /* Bug 9719231 */
     IF last_day(to_date('01-' || p_effective_month || '-' || p_effective_year,'DD-MM-YYYY')) between last_day(to_date('01-01-2005','DD-MM-YYYY')) and last_day(to_date('01-07-2010','DD-MM-YYYY')) then
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_R166_ar_KW.pdf'
                       and effective_start_date between to_date('01-01-2005','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );
     ELSIF last_day(to_date('01-' || p_effective_month || '-' || p_effective_year,'DD-MM-YYYY')) between last_day(to_date('01-08-2010','DD-MM-YYYY')) and last_day(to_date('01-09-2012','DD-MM-YYYY')) then
-- ELSE
   /* 2012 Oct 166 change Bug 14704605  */
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_166_10_ar_KW.pdf'
                       and effective_start_date between to_date('01-08-2010','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );

    ELSIF last_day(to_date('01-' || p_effective_month || '-' || p_effective_year,'DD-MM-YYYY')) between last_day(to_date('01-10-2012','DD-MM-YYYY')) and last_day(to_date('01-08-2013','DD-MM-YYYY')) then
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_166_12_ar_KW.pdf'
                       and effective_start_date between to_date('01-10-2012','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );

    ELSE
      Select file_data
      Into p_pdf_blob
      From xdo_lobs
      Where file_name like '%PAY_166_13_ar_KW.pdf'
      AND territory = 'KW';
--                       and effective_start_date between to_date('01-10-2012','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );

     END IF;
    ELSIF (p_report = 'REPORT167') THEN
      IF g_report_old = 'Y' THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAYR167_ar_KW.rtf'
                       and effective_start_date between to_date('01-01-2005','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );
      ELSE
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_167_06_ar_KW.rtf'
                       and effective_start_date between to_date('01-01-2006','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );
      END IF;

    ELSIF (p_report ='REPORT168') THEN
       IF last_day(to_date('01-' || p_effective_month || '-' || p_effective_year,'DD-MM-YYYY')) <= last_day(to_date('01-09-2012','DD-MM-YYYY')) then
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_R168_ar_KW.pdf'
                       and effective_start_date between to_date('01-01-2005','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );
     ELSE
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from per_gb_xdo_templates where file_name like '%PAY_168_12_ar_KW.pdf'
                       and effective_start_date between to_date('01-10-2012','DD-MM-YYYY') and to_date('31-12-4712','DD-MM-YYYY') );

     END IF;
    END IF;
  EXCEPTION
    when no_data_found then
      null;
  END fetch_pdf_blob;

 -------------------------------------------------------------------


PROCEDURE WritetoXML (
        p_request_id in number,
        p_report in varchar2,
        p_output_fname out nocopy varchar2)
IS
        p_l_fp UTL_FILE.FILE_TYPE;
        l_audit_log_dir varchar2(500);
        l_file_name varchar2(50);
        l_check_flag number;
BEGIN
        --l_audit_log_dir := '/sqlcom/outbound';
/*Msg in the temorary table*/
--insert into tstmsg values('Entered the procedure WritetoXML.');
        -----------------------------------------------------------------------------
        -- Writing into XML File
        -----------------------------------------------------------------------------
        -- Assigning the File name.
        l_file_name :=  to_char(p_request_id) || '.xml';
        -- Getting the Util file directory name.mostly it'll be /sqlcom/outbound )
        BEGIN
                SELECT value
                INTO l_audit_log_dir
                FROM v$parameter
                WHERE LOWER(name) = 'utl_file_dir';
                -- Check whether more than one util file directory is found
                IF INSTR(l_audit_log_dir,',') > 0 THEN
                   l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
                END IF;
        EXCEPTION
                when no_data_found then
              null;
        END;
        -- Find out whether the OS is MS or Unix based
        -- If it's greater than 0, it's unix based environment
        IF INSTR(l_audit_log_dir,'/') > 0 THEN
                p_output_fname := l_audit_log_dir || '/' || l_file_name;
        ELSE
        p_output_fname := l_audit_log_dir || '\' || l_file_name;
        END IF;
        -- getting Agency name
        p_l_fp := utl_file.fopen(l_audit_log_dir,l_file_name,'A');
        utl_file.put_line(p_l_fp,'<?xml version="1.0" encoding="UTF-8"?>');
        utl_file.put_line(p_l_fp,'<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">');
        -- Writing from and to dates
        utl_file.put_line(p_l_fp,'<fields>');
        -- Write the header fields to XML File.
        --WriteXMLvalues(p_l_fp,'P0_from_date',to_char(p_from_date,'dd') || ' ' || trim(to_char(p_from_date,'Month')) || ' ' || to_char(p_from_date,'yyyy') );
        --WriteXMLvalues(p_l_fp,'P0_to_date',to_char(p_to_date,'dd') || ' ' ||to_char(p_to_date,'Month') || ' ' || to_char(p_to_date,'yyyy') );
        -- Loop through PL/SQL Table and write the values into the XML File.
        -- Need to try FORALL instead of FOR
        IF vXMLTable.count >0 then

        FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
                WriteXMLvalues(p_l_fp,vXMLTable(ctr_table).TagName ,vXMLTable(ctr_table).TagValue);
        END LOOP;
        END IF;
        -- Write the end tag and close the XML File.
        utl_file.put_line(p_l_fp,'</fields>');
        utl_file.put_line(p_l_fp,'</xfdf>');
        utl_file.fclose(p_l_fp);
/*Msg in the temorary table*/
--insert into tstmsg values('Leaving the procedure WritetoXML.');
END WritetoXML;
PROCEDURE WriteXMLvalues( p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2) IS
BEGIN
        -- Writing XML Tag and values to XML File
--      utl_file.put_line(p_l_fp,'<' || p_tagname || '>' || p_value || '</' || p_tagname || '>'  );
        -- New Format XFDF
        utl_file.put_line(p_l_fp,'<field name="' || p_tagname || '">');
        utl_file.put_line(p_l_fp,'<value>' || p_value || '</value>'  );
        utl_file.put_line(p_l_fp,'</field>');
END WriteXMLvalues;



END pay_kw_monthly_reports;

/
