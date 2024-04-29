--------------------------------------------------------
--  DDL for Package Body PAY_MX_TRR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_TRR_PKG" AS
/* $Header: pymxtrr.pkb 120.7.12010000.7 2010/03/12 07:46:25 sjawid ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, IN      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_mx_trr_pkg

    Description : This package is used by the Payroll Tax Remittance Report
                  AND Payroll Tax Remittance XML Report

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    01-Dec-2004 ssmukher   115.0            Created.
    10-Dec-2004 kthirmiy   115.1            changed to encoding="UTF-8"
    25-Feb-2005 kthirmiy   115.2   4208324  corrected the social security quota
                                            ER.
    28-Feb-2005 kthirmiy   115.3   4212591  Sum the Ins type soc sec quota AND
                                            show as soc sec quota EE AND ER
                                            total .
    12-Apr-2005 kthirmiy   115.4   4288436  Added the logic to show state
                                            earning details.
    18-Apr-2005 kthirmiy   115.5   4309627  Added IF condtion to check state
                                            earning table count is > 0.
    26-Apr-2005 kthirmiy   115.6   4322395, corrected tag to DTD FROM CTD
                                   4324839  corrected IN the fetch_define_bal
    03-May-2005 kthirmiy   115.7   4341243  changed to show state_name instead
                                            of state_code at the parameters
                                            display section
    04-May-2005 kthirmiy   115.8            Corrected tag to
                                                 ST_STATE_DETAILS_SUBJ_DTD
                                            FROM ST_STATE_DETAILS_SUBJ_CTD.
    11-May-2005 kthirmiy   115.9   4355490  added code to calculate AND show the
                                            state tax withheld for chihuahua.
    13-May-2005 kthirmiy   115.10  4355490  moved the calc logic at state level
                                            state tax withheld shows only at
                                            state AND Legal Employer level for
                                            chihauhau.
    19-May-2005 kthirmiy   115.11  4380947  Added a new tag
                                            SHOW_STATE_DETAILS_FLAG to
                                            conditionally display state earnings
    29-Jul-2005 kthirmiy   115.12  4526042  Chihuahua state tax calculation
                                            marginal rate IN user table is
                                            stored as a percentage so changed
                                            percentage rate divided by 100
    19-Dec-2005 kthirmiy   115.13           Increased wait time to 2400 secs to
                                            finish
                                            the XML report process
                                            Added hr_mx_utility.get_IANA_charset
                                            to get the charset encoding
                                            dynamically.
    13-Jan-2005 kthirmiy   115.14           modified fetch_active_assg_act to
                                            get the assignment action id.
                                            Added p_gre_id IN the CURSOR
                                            get_states_for_legal_emp
                                            to fix RGIS Tar 15658700.600
    23-Mar-2006 vpandya    115.15  4864237  No balance call IF function
                                            fetch_active_assg_act returns 0 for
                                            assignment action id. Also changed
                                            cursors get_soc_sec_quota_details,
                                            get_states_for_legal_emp and
                                            get_gres_within_state for
                                            performance.
    25-Apr-2006 vpandya    115.16  5179412  Changed parameters in call XMLReport
                                            Publisher(XDOREPPB). Switch value
                                            between argument2 and 3. Passing
                                            applicatio short name instead ID.
    30-Jun-2006 vpandya    115.17  5236202  Changed parameters in call XMLReport
                                            Publisher(XDOREPPB). Switch value
                                            application id instead appl short
                                            name for argument2 as per Jackie
                                            XDO team.
    30-May-2007 vpandya    115.18  5976541  Changed populate_plsql_table.
                                            Fetching data in varchar variables
                                            get_soc_sec_quota_details cursor
                                            and it will be converted to number.
    05-Jan-2009 sjawid     115.22  7565304  moved the calc logic at state level
                                            state tax withheld shows only at
                                            state AND Legal Employer level for
                                            Queretaro. The state tax exemption
					    logic implemented at TRR level.
    24-Apr-2009 vvijayk2   115.24  7660624  Increased the size of the variable
                                            l_convert_data and l_xml_string to
					    VARCHAR2 (250).
   ****************************************************************************/

   --
   -- < PRIVATE GLOBALS > ---------------------------------------------------
   --

   g_package          VARCHAR2(100)   ;

   -- flag to write the debug messages IN the concurrent program log file
   g_concurrent_flag      VARCHAR2(1)  ;

   -- flag to write the debug messages IN the trace file
   g_debug_flag           VARCHAR2(1)  ;

  /*****************************************************************************
   Name      : msg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
  *****************************************************************************/

  PROCEDURE msg(p_text  VARCHAR2)
  IS
  --
  BEGIN
    -- Write to the concurrent request log
    fnd_file.put_line(fnd_file.log, p_text);

  END msg;

  /*****************************************************************************
   Name      : dbg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
               IF debuggging is enabled
  *****************************************************************************/
  PROCEDURE dbg(p_text  VARCHAR2) IS

  BEGIN

   IF (g_debug_flag = 'Y') THEN

     IF (g_concurrent_flag = 'Y') THEN

        -- Write to the concurrent request log
        fnd_file.put_line(fnd_file.log, p_text);

     ELSE

         -- Use HR trace
         hr_utility.trace(p_text);

     END IF;

   END IF;

  END dbg;



  /*****************************************************************************
   Name      : fetch_define_bal
   Purpose   : Function to fetch the Defined Balance Id for a particular
               Suffix like MTD,QTD,YTD
  *****************************************************************************/
  FUNCTION fetch_define_bal (p_bal_name IN VARCHAR2,
                             p_data_suffix IN VARCHAR2) RETURN NUMBER
  IS

  CURSOR get_def_bal( c_bal_name    VARCHAR2
                     ,c_data_suffix VARCHAR2) IS
    SELECT pdb.defined_balance_id def_bal
    FROM   pay_defined_balances pdb,
           pay_balance_dimensions pbd,
           pay_balance_types pbt
    WHERE  pbt.balance_type_id            = pdb.balance_type_id
      AND  pbd.balance_dimension_id       = pdb.balance_dimension_id
      AND  pbd.database_item_suffix       = c_data_suffix
      AND  pbt.balance_name               = c_bal_name
      AND  nvl(pdb.legislation_code,'MX') = 'MX';

    l_return NUMBER;

  BEGIN

      OPEN  get_def_bal(p_bal_name,p_data_suffix);
      FETCH get_def_bal INTO l_return;
      cLOSE get_def_bal;

      RETURN (l_return);

  END fetch_define_bal;

  /*****************************************************************************
   Name      : fetch_active_assg_act
   Purpose   : Function to fetch Max Assignment Action id for a GRE
  *****************************************************************************/
  FUNCTION fetch_active_assg_act ( p_business_group_id  IN NUMBER
                                  ,p_tax_unit_id        IN NUMBER
                                  ,p_start_date_earned  IN date
                                  ,p_end_date_earned    IN date )
  RETURN NUMBER IS

    CURSOR fetch_assg_act ( c_business_group_id  IN NUMBER
                           ,c_tax_unit_id        IN NUMBER
                           ,c_start_date_earned  IN date
                           ,c_end_date_earned    IN date ) IS
      SELECT max(paa.assignment_action_id)
        FROM pay_consolidation_sets pcs,
             pay_payroll_actions ppa,
             pay_assignment_actions paa
       WHERE pcs.business_group_id    = c_business_group_id
         AND ppa.payroll_action_id    = paa.payroll_action_id
         AND ppa.consolidation_set_id = pcs.consolidation_set_id + 0
         AND paa.tax_unit_id          = c_tax_unit_id
         AND ppa.business_group_id+0  = c_business_group_id
         AND ppa.action_type          IN ('R', 'Q', 'B', 'V', 'I')
         AND paa.action_status        = 'C'
         AND ppa.effective_date  BETWEEN c_start_date_earned
                                     AND c_end_date_earned;

    l_assg  NUMBER(10);
  BEGIN

    l_assg := 0;

    OPEN  fetch_assg_act(p_business_group_id
                        ,p_tax_unit_id
                        ,p_start_date_earned
                        ,p_end_date_earned);
    FETCH fetch_assg_act INTO l_assg;
    CLOSE fetch_assg_act;

    RETURN (l_assg);

  END fetch_active_assg_act;

  /*****************************************************************************
   Name      : get_yesno_value
   Purpose   : Function to get the lookup value
  *****************************************************************************/
  FUNCTION get_yesno_value (p_lookup_value IN VARCHAR2)
  RETURN VARCHAR2 IS

    CURSOR get_yesno(c_lookup_value IN VARCHAR2) IS
    SELECT meaning
      FROM hr_lookups
     WHERE lookup_type = 'YES_NO'
       AND lookup_code = c_lookup_value ;

    l_meaning  VARCHAR2(10);

  BEGIN
     l_meaning := '';
     -- Commenting the below code because of Translational Issue refer Bug No:7353201
     /*OPEN  get_yesno(p_lookup_value) ;
     FETCH get_yesno INTO l_meaning ;
     CLOSE get_yesno ;*/

     IF p_lookup_value = 'Y'
      THEN l_meaning := 'Yes';
     ELSE
      l_meaning := 'No';
     END IF;

     RETURN l_meaning ;

  END get_yesno_value;


  /*****************************************************************************
   Name      : get_dimension_desc
   Purpose   : Function to get dimension description
  *****************************************************************************/
  FUNCTION get_dimension_desc (p_value IN VARCHAR2)
  RETURN VARCHAR2 IS

    CURSOR get_dim_desc(c_value IN VARCHAR2) IS
      SELECT decode(c_value,'CTD', ffv.description,
             substr( ffv.description,
                     instr(ffv.DESCRIPTION,'Period Date Range AND ')+
                     length('Period Date Range AND ') ))
        FROM fnd_flex_values_vl ffv,
             fnd_flex_value_sets ffs
       WHERE ffs.flex_value_set_name = 'PAY_MX_TRR_DIMENSION'
         AND ffv.flex_value_set_id   = ffs.flex_value_set_id
         AND ffv.flex_value          = c_value ;

    l_desc  VARCHAR2(100);

  BEGIN

     l_desc :='';

     OPEN  get_dim_desc(p_value) ;
     FETCH get_dim_desc INTO l_desc;
     CLOSE get_dim_desc ;

     RETURN l_desc ;

  END get_dimension_desc;


  /****************************************************************************
   Name      : insert_xml_plsql_table
   Purpose   : Procedure for inserting data intO the PL/SQL table
  *****************************************************************************/
  PROCEDURE insert_xml_plsql_table( p_xml_data       IN OUT NOCOPY xml_data,
                                    p_tag_name       IN VARCHAR2,
                                    p_tag_value      IN VARCHAR2,
                                    p_tag_type       IN CHAR,
                                    p_tag_value_type IN CHAR) IS
  BEGIN
      l_counter:= p_xml_data.count + 1 ;

      p_xml_data(l_counter).tag_name  := p_tag_name;

      IF p_tag_value_type = 'P' THEN

         p_xml_data(l_counter).tag_value := to_char(to_number(p_tag_value),
                                                       '99990.900');

      ELSIF p_tag_value_type = 'B' THEN

         p_xml_data(l_counter).tag_value := to_char(to_number(p_tag_value),
                                                       '9999990.90');

      ELSE

         p_xml_data(l_counter).tag_value := p_tag_value;

      END IF;

      p_xml_data(l_counter).tag_type  := p_tag_type;

  END insert_xml_plsql_table;



  /*****************************************************************************
   Name      : populate_plsql_table
   Purpose   : Procedure to populate the balance data IN the plsql table
               - Initialize state AND legal employer level totals
               - Get defined balance Id for
                  Gross Earnings   GRE_PYDATE


  *****************************************************************************/
  PROCEDURE populate_plsql_table
                   ( p_start_date_earned   IN DATE,
                     p_end_date_earned     IN DATE,
                     p_legal_employer_id   IN NUMBER,
                     p_state_code          IN VARCHAR2,
                     p_gre_id              IN NUMBER,
                     p_show_isr            IN VARCHAR2,
                     p_show_soc_security   IN VARCHAR2,
                     p_show_state          IN VARCHAR2,
                     p_dimension           IN VARCHAR2,
                     p_business_group_id   IN NUMBER,
                     p_xml_data            IN OUT NOCOPY XML_DATA ) IS

    -- CURSOR to get legal employer details
    CURSOR get_legal_employer_details (p_legal_employer_id NUMBER) IS
      SELECT hoi.org_information1 legal_employer_name,
             hoi.org_information2 RFC_ID
        FROM hr_organization_units hou,
             hr_organization_information hoi
       WHERE hoi.organization_id         = hou.organization_id
         AND hoi.org_information_context = 'MX_TAX_REGISTRATION'
         AND hoi.organization_id         = p_legal_employer_id ;

    -- CURSOR to get gre details
    CURSOR get_gre_details (p_gre_id  NUMBER) IS
      SELECT hou.name GRE_Name,
             hoi.org_information1 ss_id
        FROM hr_organization_units hou,
             hr_organization_information hoi
       WHERE hou.organization_id         = hoi.organization_id
         AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
         AND hoi.organization_id         = p_gre_id;

    -- CURSOR to get state earnings details
    CURSOR get_state_details (p_state VARCHAR2) IS
      SELECT pay_ac_utility.get_balance_name(pbt.balance_type_id) balance_name
            ,pay_ac_utility.get_bal_reporting_name(pbt.balance_type_id) rep_name
        FROM pay_balance_types pbt,
             pay_defined_balances pdb,
             pay_balance_attributes pba,
             pay_bal_attribute_definitions pbad
       WHERE pbad.attribute_name    LIKE 'Tax Remittance%'
         AND pbad.business_group_id IS NULL
         AND pbad.legislation_code  = 'MX'
         AND pba.attribute_id       = pbad.attribute_id
         AND pdb.defined_balance_id = pba.defined_balance_id
         AND pdb.balance_type_id    = pbt.balance_type_id
         AND pdb.balance_type_id    = pbt.balance_type_id
         AND RTRIM(SUBSTR(pbad.attribute_name,
                   INSTR(pbad.attribute_name,'Tax Remittance for ')+
                   LENGTH('Tax Remittance for '))) =
                         NVL(p_state, RTRIM(substr(pbad.attribute_name,
                         INSTR(pbad.attribute_name,'Tax Remittance for ')+
                         LENGTH('Tax Remittance for '))));

    -- CURSOR to get soc sec quota details
    CURSOR get_soc_sec_quota_details (p_effective_date IN DATE) IS
      SELECT pbt.balance_name,
             pbt.reporting_name,
             rtrim(substr(pbt.balance_name,1,
                         (length(pbt.balance_name)-3))) bal_name,
             rtrim(substr(pbt.balance_name,
                          length(pbt.balance_name)-1)) ee_or_er,
             pli.legislation_info4 soc_sec_tax_pct_ee,
             pli.legislation_info5 soc_sec_tax_pct_er
        FROM pay_balance_types pbt,
             pay_defined_balances pdb,
             pay_balance_attributes pba,
             pay_bal_attribute_definitions pbad,
             pay_mx_legislation_info_f pli,
             fnd_lookup_values hrl
       WHERE pbad.attribute_name       LIKE 'Social Security Quota%'
         AND pbad.business_group_id    IS NULL
         AND pbad.legislation_code     = 'MX'
         AND pbt.business_group_id     IS NULL
         AND pbt.legislation_code      = 'MX'
         AND pba.attribute_id          = pbad.attribute_id
         AND pdb.defined_balance_id    = pba.defined_balance_id
         AND pdb.balance_type_id       = pbt.balance_type_id
         AND hrl.lookup_type           = 'MX_INSURANCE_TYPES'
         AND hrl.language              = 'US'
         AND pli.legislation_info_type = 'MX Social Security Information'
         AND pli.legislation_info1     = hrl.lookup_code
         AND hrl.meaning               = substr(pbt.balance_name, 1,
                                         (length(pbt.balance_name)-3))
         AND p_effective_date    BETWEEN pli.effective_start_date
                                     AND pli.effective_end_date
         AND p_effective_date    BETWEEN hrl.start_date_active
                                     AND nvl(hrl.end_date_active,
                                         TO_DATE('12/31/4712', 'MM/DD/YYYY'))
       ORDER BY to_number(pli.legislation_info6);

   -- Cursor to fetch the distinct States with IN a Legal Employer
   CURSOR  get_states_for_legal_emp ( p_business_group_id IN NUMBER,
                                      p_legal_employer_id IN NUMBER,
                                      p_state_code        IN VARCHAR2,
                                      p_gre_id            IN NUMBER) IS
     SELECT DISTINCT pmx.state state_code,
                     pmx.state_name state_name
       FROM per_mx_gres_legal_employer_v pmx
      WHERE pmx.business_group_id = p_business_group_id
        AND pmx.legal_employer_id = p_legal_employer_id
         AND pmx.legal_employer_id = p_legal_employer_id
         AND (( p_state_code IS NULL ) OR (  p_state_code IS NOT NULL and
                p_state_code = pmx.state))
         AND (( p_gre_id IS NULL ) OR (  p_gre_id IS NOT NULL and
                p_gre_id = pmx.tax_unit_id));

    -- CURSOR to get gres within state
    CURSOR  get_gres_within_state ( p_business_group_id IN NUMBER,
                                    p_legal_employer_id IN NUMBER,
                                    p_gre_id            IN NUMBER,
                                    p_state             IN VARCHAR2) IS
      SELECT pmx.tax_unit_id tax_unit_id,
             pmx.gre_name gre_name,
             pmx.ss_id
        FROM per_mx_gres_legal_employer_v pmx
       WHERE pmx.business_group_id = p_business_group_id
         AND pmx.legal_employer_id = p_legal_employer_id
         AND (( p_state IS NULL ) OR (  p_state IS NOT NULL and
                p_state = pmx.state))
         AND (( p_gre_id IS NULL ) OR (  p_gre_id IS NOT NULL and
                p_gre_id = pmx.tax_unit_id));

    -- CURSOR to get state name
    CURSOR get_st_name (p_state_code  IN VARCHAR2) IS
      SELECT fcl.meaning
        FROM fnd_common_lookups fcl
       WHERE fcl.lookup_type='MX_STATE'
         AND fcl.lookup_code=p_state_code ;


    TYPE soc_sec_detail_tab IS RECORD ( balance_name       VARCHAR2(50),
                                        soc_sec_tax_pct_ee NUMBER,
                                        soc_sec_tax_pct_er NUMBER,
                                        soc_sec_ee_ctd_id  NUMBER,
                                        soc_sec_ee_dtd_id  NUMBER,
                                        soc_sec_er_ctd_id  NUMBER,
                                        soc_sec_er_dtd_id  NUMBER,
                                        soc_sec_quo_ee_ctd NUMBER,
                                        soc_sec_quo_ee_dtd NUMBER,
                                        soc_sec_quo_er_ctd NUMBER,
                                        soc_sec_quo_er_dtd NUMBER);

    TYPE tot_soc_sec_detail_tab IS RECORD ( balance_name       VARCHAR2(50),
                                            soc_sec_quo_ee_ctd NUMBER,
                                            soc_sec_quo_ee_dtd NUMBER,
                                            soc_sec_quo_er_ctd NUMBER,
                                            soc_sec_quo_er_dtd NUMBER);

    TYPE state_earnings_detail_tab IS RECORD (
                                      balance_name          VARCHAR2(50),
                                      state_earnings_ctd_id NUMBER,
                                      state_earnings_dtd_id NUMBER);


    TYPE tot_state_earnings_detail_tab IS RECORD (
                                       balance_name             VARCHAR2(50),
                                       state_earnings_ctd_value NUMBER,
                                       state_earnings_dtd_value NUMBER);


    TYPE soc_sec_detail IS TABLE OF  soc_sec_detail_tab
           INDEX BY BINARY_INTEGER;

    TYPE tot_soc_sec_detail IS TABLE OF  tot_soc_sec_detail_tab
           INDEX BY BINARY_INTEGER;

    TYPE state_earnings_detail IS TABLE OF  state_earnings_detail_tab
           INDEX BY BINARY_INTEGEr;

    TYPE tot_state_earnings_detail IS TABLE OF  tot_state_earnings_detail_tab
           INDEX BY BINARY_INTEGER;


      soc_sec_det_tab        soc_sec_detail;

      st_soc_sec_det_tab     tot_soc_sec_detail;

      le_soc_sec_det_tab     tot_soc_sec_detail;

      state_earnings         state_earnings_detail ;
      st_state_earnings      tot_state_earnings_detail ;


      xml_total_tab          xml_data;
      l_counter1             NUMBER;
      l_legal_employer_name  VARCHAR2(100);
      l_RFC_code             VARCHAR2(50);
      l_gre_param            VARCHAR2(50);
      l_gre_name             VARCHAR2(100);
      l_ss_id                VARCHAR2(20);
      l_gre                  VARCHAR2(100);
      l_def_bal              NUMBER(9);
      l_prev_state           VARCHAR2(50);
      l_prev_gre             VARCHAR2(50);
      l_state                VARCHAR2(5);
      l_state_name           VARCHAR2(50);
      l_st_name              VARCHAR2(50);
      l_tax_unit_id          NUMBER(10);
      l_ee_or_er             VARCHAR2(20);
      l_soc_sec_tax_per_ee   NUMBER;
      l_soc_sec_tax_per_er   NUMBER;
      l_bal_name             VARCHAR2(100);
      l_balance_name         VARCHAR2(100);
      l_prev_bal_name        VARCHAR2(100);
      lv_soc_sec_tax_per_ee  VARCHAR2(100);
      lv_soc_sec_tax_per_er  VARCHAR2(100);

      l_report_name          VARCHAR2(100);
      l_bal_id               NUMBER(9);
      l_state_heading        VARCHAR2(100);
      l_exit_status          NUMBER(1);

      /* Variables to store the State Total Gross Earning values */
      l_gross_subj_ctd       NUMBER;
      l_gross_subj_dtd       NUMBER;
      l_st_gross_sub_ctd     NUMBER;
      l_st_gross_sub_dtd     NUMBER;

      /* Variables to store the State Total For ISR values */
      l_ctd_db_item_suffix       VARCHAR2(10);
      l_database_suffix          VARCHAR2(20);
      l_dim_database_item_suffix VARCHAR2(20);
      l_isr_witheld_ctd          NUMBER;
      l_isr_witheld_dtd          NUMBER;
      l_isr_subj_ctd             NUMBER;
      l_isr_subj_dtd             NUMBER;

      l_st_isr_witheld_ctd   NUMBER;
      l_st_isr_witheld_dtd   NUMBER;
      l_st_isr_subj_ctd      NUMBER;
      l_st_isr_subj_dtd      NUMBER;

      /* Variables  to store the Social Security Values */

      l_ss_ee_ctd   NUMBER ;
      l_ss_er_ctd   NUMBER ;
      l_ss_ee_dtd   NUMBER ;
      l_ss_er_dtd   NUMBER ;

      l_soc_sec_ee_ctd  NUMBER;
      l_soc_sec_ee_dtd  NUMBER;
      l_soc_sec_er_ctd  NUMBER;
      l_soc_sec_er_dtd  NUMBER;
      l_soc_sec_tot_ctd NUMBER;
      l_soc_sec_tot_dtd NUMBER;

      l_st_soc_sec_ee_ctd  NUMBER;
      l_st_soc_sec_ee_dtd  NUMBER;
      l_st_soc_sec_er_ctd  NUMBER;
      l_st_soc_sec_er_dtd  NUMBER;
      l_st_soc_sec_tot_ctd NUMBER;
      l_st_soc_sec_tot_dtd NUMBER;

      /* Variables to store the State Tax  values */

      l_st_witheld_ctd     NUMBER;
      l_st_subj_ctd        NUMBER;
      l_st_witheld_dtd     NUMBER;
      l_st_subj_dtd        NUMBER;

      l_st_st_witheld_ctd  NUMBER;
      l_st_st_witheld_dtd  NUMBER;
      l_st_st_subj_ctd     NUMBER;
      l_st_st_subj_dtd     NUMBER;

      /* Variables to store the State Chihuahua rates */

      l_fixed_rate     NUMBER;
      l_marginal_rate  NUMBER;
      l_lower_bound    NUMBER;

      /* Variables to store the State Queretaro Values*/
      l_rate            NUMBER;
      lv_rate           VARCHAR2(20);
      l_dummy           NUMBER;
      l_leg_info        CHAR(1);
      l_min_wage        NUMBER;
      l_rate_type       VARCHAR2(20);
      l_st_st_exemption NUMBER;

      /* Variables to store the State Earnings Values */
      l_state_earning_name     VARCHAR2(100);
      l_st_earn_ctd_def_bal_id NUMBER;
      l_st_earn_dtd_def_bal_id NUMBER;

      l_st_earn_ctd_value      NUMBER;
      l_st_earn_dtd_value      NUMBER;


      /* Variables to store the Social Security Quota Values */
      l_ins_type_ctd_id     NUMBER(10);
      l_ins_type_dtd_id     NUMBER(10);
      l_soc_sec_quo_ee_ctd  NUMBER;
      l_soc_sec_quo_ee_dtd  NUMBER;
      l_soc_sec_quo_er_ctd  NUMBER;
      l_soc_sec_quo_er_dtd  NUMBER;

      l_st_soc_sec_quo_ee_ctd  NUMBER;
      l_st_soc_sec_quo_ee_dtd  NUMBER;
      l_st_soc_sec_quo_er_ctd  NUMBER;
      l_st_soc_sec_quo_er_dtd  NUMBER;

      /* Variables to store Legal Employer Values */
      l_lt_gross_sub_ctd     NUMBER;
      l_lt_gross_sub_dtd     NUMBER;

      l_lt_isr_witheld_ctd   NUMBER;
      l_lt_isr_witheld_dtd   NUMBER;
      l_lt_isr_subj_ctd      NUMBER;
      l_lt_isr_subj_dtd      NUMBER;

      l_lt_soc_sec_ee_ctd   NUMBER;
      l_lt_soc_sec_ee_dtd   NUMBER;
      l_lt_soc_sec_er_ctd   NUMBER;
      l_lt_soc_sec_er_dtd   NUMBER;
      l_lt_soc_sec_tot_ctd  NUMBER;
      l_lt_soc_sec_tot_dtd  NUMBER;

      l_lt_st_witheld_ctd   NUMBER;
      l_lt_st_witheld_dtd   NUMBER;
      l_lt_st_subj_ctd      NUMBER;
      l_lt_st_subj_dtd      NUMBER;

      l_lt_soc_sec_tax_per_ee  NUMBER;
      l_lt_soc_sec_tax_per_er  NUMBER;
      l_lt_soc_sec_quo_ee_ctd  NUMBER;
      l_lt_soc_sec_quo_ee_dtd  NUMBER;
      l_lt_soc_sec_quo_er_ctd  NUMBER;
      l_lt_soc_sec_quo_er_dtd  NUMBER;


      l_procedure_name         VARCHAR2(100);
      l_error_message          VARCHAR2(200);
      l_step                   NUMBER;

      l_gross_ctd_def_bal_id     NUMBER;
      l_gross_dtd_def_bal_id     NUMBER;

      l_isr_withheld_ctd_def_bal_id NUMBER;
      l_isr_subj_ctd_def_bal_id     NUMBER;
      l_isr_withheld_dtd_def_bal_id NUMBER;
      l_isr_subj_dtd_def_bal_id     NUMBER;

      l_st_withheld_ctd_def_bal_id  NUMBER;
      l_st_subj_ctd_def_bal_id      NUMBER;
      l_st_withheld_dtd_def_bal_id  NUMBER;
      l_st_subj_dtd_def_bal_id      NUMBER;


      l_ss_ee_ctd_def_bal_id NUMBER;
      l_ss_er_ctd_def_bal_id NUMBER;
      l_ss_ee_dtd_def_bal_id NUMBER;
      l_ss_er_dtd_def_bal_id NUMBER;

      l_assignment_act  NUMBER;
      l_show            VARCHAR2(10);
      i                 NUMBER;

  BEGIN

     l_procedure_name     := '.populate_plsql_table';

     dbg('Entering Populate plsql Table .........');
     dbg('Initializing Local variables');

     l_counter := 0;
     l_counter1 := 0;
     l_exit_status := 0;

     l_prev_bal_name := null;

     l_st_soc_sec_quo_ee_ctd  := 0;
     l_st_soc_sec_quo_ee_dtd  := 0;
     l_st_soc_sec_quo_er_ctd  := 0;
     l_st_soc_sec_quo_er_dtd  := 0;

     /* Initializing the Legal Employer Variables */

     l_lt_gross_sub_ctd     := 0;
     l_lt_gross_sub_dtd     := 0;
     l_lt_isr_witheld_ctd   := 0;
     l_lt_isr_witheld_dtd   := 0;
     l_lt_isr_subj_ctd      := 0;
     l_lt_isr_subj_dtd      := 0;

     l_lt_soc_sec_ee_ctd   := 0;
     l_lt_soc_sec_ee_dtd   := 0;
     l_lt_soc_sec_er_ctd   := 0;
     l_lt_soc_sec_er_dtd   := 0;
     l_lt_soc_sec_tot_ctd  := 0;
     l_lt_soc_sec_tot_dtd  := 0;

     l_lt_st_witheld_ctd   := 0;
     l_lt_st_witheld_dtd   := 0;
     l_lt_st_subj_ctd      := 0;
     l_lt_st_subj_dtd      := 0;

     -- database item suffix for CTD is

     l_database_suffix := '_GRE_PYDATE';

     -- From the parameter p_dimension get the dimension database_item_suffix

     IF p_dimension <> 'CTD' THEN

        IF p_dimension = 'MONTH' THEN

             l_dim_database_item_suffix := '_GRE_MTD';

        ELSIF p_dimension = 'QTD' THEN

              l_dim_database_item_suffix := '_GRE_QTD';

        ELSIF p_dimension ='YTD' THEN

           l_dim_database_item_suffix := '_GRE_YTD';

        END IF;

    ELSE

      l_dim_database_item_suffix := null ;

    END IF;

    dbg('Get the Defined balance Ids');
    l_step := 1;
    hr_utility.set_location(g_package || l_procedure_name, 10);

    -- Get the defined balance Id for Gross Earnings AND GRE_PYDATE

    l_gross_ctd_def_bal_id := fetch_define_bal ('Gross Earnings',
                                                l_database_suffix );

    dbg('Gross Earnings '|| l_database_suffix || ' : '||l_gross_ctd_def_bal_id);
    l_step := 2;
    hr_utility.set_location(g_package || l_procedure_name, 20);

    -- Get the defined balance Id for Gross Earnings AND dimension

    l_gross_dtd_def_bal_id := NULL ;

    IF l_dim_database_item_suffix IS NOT NULL THEN

       l_gross_dtd_def_bal_id := fetch_define_bal ('Gross Earnings',
                                                   l_dim_database_item_suffix );

    END IF;

    dbg('Gross Earnings ' || l_dim_database_item_suffix || ' : '||
         l_gross_dtd_def_bal_id);


    IF p_show_isr = 'Y' THEN

       l_step := 3;
       hr_utility.set_location(g_package || l_procedure_name, 30);

       -- Get defined balance Id for ISR WIthheld AND ISR Subject

       l_isr_withheld_ctd_def_bal_id := fetch_define_bal ('ISR Withheld',
                                                          l_database_suffix );

       l_isr_subj_ctd_def_bal_id     := fetch_define_bal ('ISR Subject',
                                                          l_database_suffix );

       l_isr_withheld_dtd_def_bal_id := NULL ;
       l_isr_subj_dtd_def_bal_id     := NULL ;

       IF l_dim_database_item_suffix is not null THEN

          l_step := 4;
          hr_utility.set_location(g_package || l_procedure_name, 40);

          l_isr_withheld_dtd_def_bal_id := fetch_define_bal ('ISR Withheld',
                                               l_dim_database_item_suffix );
          l_isr_subj_dtd_def_bal_id     := fetch_define_bal ('ISR Subject',
                                               l_dim_database_item_suffix );

       END IF;

     END IF;

     dbg('ISR Withheld ' || l_database_suffix || ' : '||
                            l_isr_withheld_ctd_def_bal_id);
     dbg('ISR Subject  ' || l_database_suffix || ' : '||
                            l_isr_subj_ctd_def_bal_id);
     dbg('ISR Withheld ' || l_dim_database_item_suffix || ' : '||
                            l_isr_withheld_dtd_def_bal_id);
     dbg('ISR Subject  ' || l_dim_database_item_suffix || ' : '||
                            l_isr_subj_dtd_def_bal_id);

     IF p_show_soc_security = 'Y' THEN

        -- Get defined balance Id for Social Security Quota EE
        --   AND Social Security Quota ER

        l_step := 5;
        hr_utility.set_location(g_package || l_procedure_name, 50);

        l_ss_ee_ctd_def_bal_id := fetch_define_bal ('Social Security Quota EE',
                                                    l_database_suffix );
        l_ss_er_ctd_def_bal_id := fetch_define_bal ('Social Security Quota ER',
                                                    l_database_suffix );

        l_ss_ee_dtd_def_bal_id := NULL;
        l_ss_er_dtd_def_bal_id := NULL;

        IF l_dim_database_item_suffix is not null THEN
           l_step := 6;
           hr_utility.set_location(g_package || l_procedure_name, 60);

           l_ss_ee_dtd_def_bal_id := fetch_define_bal('Social Security Quota EE'
                                               ,l_dim_database_item_suffix );
           l_ss_er_dtd_def_bal_id := fetch_define_bal('Social Security Quota ER'
                                               ,l_dim_database_item_suffix );
        END IF;

       dbg('Social Security Quota EE ' || l_database_suffix || ' : ' ||
                                          l_ss_ee_ctd_def_bal_id);
       dbg('Social Security Quota ER ' || l_database_suffix || ' : ' ||
                                          l_ss_er_ctd_def_bal_id);
       dbg('Social Security Quota EE ' || l_dim_database_item_suffix || ' : ' ||
                                          l_ss_ee_dtd_def_bal_id);
       dbg('Social Security Quota ER ' || l_dim_database_item_suffix || ' : ' ||
                                          l_ss_er_dtd_def_bal_id);


       dbg('Get Social Security Insurance Types ');
       l_step := 7;
       hr_utility.set_location(g_package || l_procedure_name, 70);

       -- get the social security ins types

       OPEN get_soc_sec_quota_details(p_start_date_earned);

       LOOP

          hr_utility.trace('IN LOOP...');

          FETCH get_soc_sec_quota_details INTO
                                  l_bal_name,     -- with EE or ER at the end
                                  l_report_name,  -- same as l_bal_name
                                  l_balance_name, -- without EE or ER
                                  l_ee_or_er,
                                  lv_soc_sec_tax_per_ee,
                                  lv_soc_sec_tax_per_er;

          EXIT WHEN get_soc_sec_quota_details%notfound;

          hr_utility.trace('l_prev_bal_name: ' ||nvl(l_prev_bal_name,'NULL'));
          hr_utility.trace('l_balance_name: ' ||l_balance_name);
          hr_utility.trace('lv_soc_sec_tax_per_ee: ' ||lv_soc_sec_tax_per_ee);
          hr_utility.trace('lv_soc_sec_tax_per_er: ' ||lv_soc_sec_tax_per_er);

          l_soc_sec_tax_per_ee :=
                fnd_number.canonical_to_number(lv_soc_sec_tax_per_ee);

          hr_utility.trace('l_soc_sec_tax_per_ee: ' ||l_soc_sec_tax_per_ee);

          l_soc_sec_tax_per_er :=
                fnd_number.canonical_to_number(lv_soc_sec_tax_per_er);

          hr_utility.trace('l_soc_sec_tax_per_er: ' ||l_soc_sec_tax_per_er);

          IF ( l_prev_bal_name IS NULL OR l_prev_bal_name <> l_balance_name )
          THEN

             l_counter1:= l_counter1+ 1;

             hr_utility.trace('l_counter1: ' ||l_counter1);
             dbg('The Counter value '||l_counter1);
             dbg('The Balance Name '||l_balance_name);
             dbg('The Balance Name '||l_bal_name);

             hr_utility.trace('l_bal_name: ' ||l_bal_name);

             soc_sec_det_tab(l_counter1).balance_name := l_balance_name;
             soc_sec_det_tab(l_counter1).soc_sec_tax_pct_ee :=
                                                 l_soc_sec_tax_per_ee;
             soc_sec_det_tab(l_counter1).soc_sec_tax_pct_er :=
                                                 l_soc_sec_tax_per_er;

             l_prev_bal_name := l_balance_name;

          END IF;

          IF l_prev_bal_name = l_balance_name THEN

             hr_utility.trace('Balances are same: ');
             hr_utility.trace('l_bal_name: '||l_bal_name);
             hr_utility.trace('l_database_suffix: '||l_database_suffix);

             l_ins_type_ctd_id := fetch_define_bal (l_bal_name,
                                                    l_database_suffix );

             hr_utility.trace('l_ins_type_ctd_id: '||
                               l_ins_type_ctd_id);

             hr_utility.trace('l_dim_database_item_suffix: '||
                               l_dim_database_item_suffix);

             IF l_dim_database_item_suffix IS NOT NULL THEN

                l_ins_type_dtd_id := fetch_define_bal (l_bal_name,
                                                    l_dim_database_item_suffix);
                hr_utility.trace('l_ins_type_dtd_id: '||
                                  l_ins_type_dtd_id);
             END IF;

             hr_utility.trace('l_ee_or_er: '||l_ee_or_er);

             IF l_ee_or_er ='EE' THEN

                soc_sec_det_tab(l_counter1).soc_sec_ee_ctd_id :=
                                                       l_ins_type_ctd_id;

                dbg('soc_sec_det_tab(l_counter1).soc_sec_ee_ctd_id: '||
                     soc_sec_det_tab(l_counter1).soc_sec_ee_ctd_id);

                soc_sec_det_tab(l_counter1).soc_sec_ee_dtd_id :=
                                                       l_ins_type_dtd_id;

                dbg('soc_sec_det_tab(l_counter1).soc_sec_ee_dtd_id: '||
                     soc_sec_det_tab(l_counter1).soc_sec_ee_dtd_id);

             ELSE

                soc_sec_det_tab(l_counter1).soc_sec_er_ctd_id :=
                                                       l_ins_type_ctd_id;

                dbg('Else soc_sec_det_tab(l_counter1).soc_sec_er_ctd_id: '||
                          soc_sec_det_tab(l_counter1).soc_sec_er_ctd_id);

                soc_sec_det_tab(l_counter1).soc_sec_er_dtd_id :=
                                                       l_ins_type_dtd_id;

                dbg('Else soc_sec_det_tab(l_counter1).soc_sec_er_dtd_id: '||
                          soc_sec_det_tab(l_counter1).soc_sec_er_dtd_id);

             END IF;

           END IF;

       END LOOP;

        dbg('The value of the PLSQl table counter '||l_counter1);
        l_step := 8;
        hr_utility.set_location(g_package || l_procedure_name, 80);

        FOR m IN 1 ..soc_sec_det_tab.count LOOP

            dbg(soc_sec_det_tab(m).balance_name ||' '||
                soc_sec_det_tab(m).soc_sec_tax_pct_ee||' '||
                soc_sec_det_tab(m).soc_sec_tax_pct_er);

            dbg(' EE CTD id ' || soc_sec_det_tab(m).soc_sec_ee_ctd_id ||' '||
                ' ER CTD id ' || soc_sec_det_tab(m).soc_sec_er_ctd_id ||' '||
                ' EE DTD id ' || soc_sec_det_tab(m).soc_sec_ee_dtd_id ||' '||
                ' ER DTD id ' || soc_sec_det_tab(m).soc_sec_er_dtd_id  );

        END LOOP;


     END IF;  -- p_show_soc_security

     IF p_show_state = 'Y' THEN

       hr_utility.set_location(g_package || l_procedure_name, 85);

       -- Get defined balance Id for Employer State Tax WIthheld AND
       --                            Employer State Tax Subject

       l_st_withheld_ctd_def_bal_id :=
            fetch_define_bal ('Employer State Tax Withheld',l_database_suffix );
       l_st_subj_ctd_def_bal_id     :=
            fetch_define_bal ('Employer State Tax Subject' ,l_database_suffix );

       l_st_withheld_dtd_def_bal_id := NULL;
       l_st_subj_dtd_def_bal_id     := NULL;

       IF l_dim_database_item_suffix IS NOT NULL THEN

          l_st_withheld_dtd_def_bal_id :=
                            fetch_define_bal('Employer State Tax Withheld',
                                              l_dim_database_item_suffix );
          l_st_subj_dtd_def_bal_id     :=
                            fetch_define_bal('Employer State Tax Subject' ,
                                              l_dim_database_item_suffix );

       END IF;

       dbg('Employer State Tax Withheld ' || l_database_suffix || ' : '||
                                             l_st_withheld_ctd_def_bal_id);
       dbg('Employer State Tax Subject  ' || l_database_suffix || ' : '||
                                             l_st_subj_ctd_def_bal_id);
       dbg('Employer State Tax Withheld ' || l_dim_database_item_suffix || ' : '                                          || l_st_withheld_dtd_def_bal_id);
       dbg('Employer State Tax Subject  ' || l_dim_database_item_suffix || ' : '                                          || l_st_subj_dtd_def_bal_id);


     END IF; -- p_show_state

     l_step := 9;
     hr_utility.set_location(g_package || l_procedure_name, 90);

     dbg('Get Legal Employer Name ');

     OPEN  get_legal_employer_details(p_legal_employer_id);
     FETCH get_legal_employer_details INTO l_legal_employer_name,l_RFC_code ;
     CLOSE get_legal_employer_details;

     dbg('Legal Employer Name : '||l_legal_employer_name);
     dbg('Legal Employer Id   : '||p_legal_employer_id);
     dbg('RFC Id              : '||l_RFC_code);

     IF p_gre_id IS NOT NULL THEN

        OPEN  get_gre_details(p_gre_id);
        FETCH get_gre_details INTO l_gre_param,l_ss_id;
        CLOSE get_gre_details;

     ELSE

         dbg('The Gre value is all');
         l_gre_param  :='All';

     END IF;

     IF p_state_code IS NOT NULL THEN

        OPEN  get_st_name(p_state_code);
        FETCH get_st_name INTO l_st_name;
        CLOSE get_st_name;

     ELSE

         dbg('The State value is All');
         l_st_name  :='All';

     END IF;

     dbg('GRE Name : '||l_gre_param);
     dbg('GRE Id   : '||p_gre_id);
     dbg('SS Id    : '||l_ss_id);
     dbg('State    : '||l_st_name);

     /*    Initialize pl/sql table  */
     insert_xml_plsql_table( p_xml_data,'TRR',NULL,'T','C');

     dbg('Insert parameters to plsql table ');

     l_step := 10;
     hr_utility.set_location(g_package || l_procedure_name, 100);

     /* insert parameter records IN pl/sql table */

     insert_xml_plsql_table( p_xml_data,'START_DATE_EARNED',
                      to_char(p_start_date_earned,'DD-MON-YYYY'),'D','C');
     insert_xml_plsql_table( p_xml_data,'END_DATE_EARNED',
                      to_char(p_end_date_earned,'DD-MON-YYYY'),'D','C');
     insert_xml_plsql_table( p_xml_data,'LEGAL_EMPLOYER_NAME',
                      l_legal_employer_name,'D','C');
     insert_xml_plsql_table( p_xml_data,'GRE_PARAMETER',l_gre_param,'D','C');
     insert_xml_plsql_table( p_xml_data,'STATE_PARAMETER',l_st_name,'D','C');
     insert_xml_plsql_table( p_xml_data,'SHOW_FEDERAL',
                      get_yesno_value(p_show_isr),'D','C');
     insert_xml_plsql_table( p_xml_data,'SHOW_SOCIAL_SECURITY',
                      get_yesno_value(p_show_soc_security),'D','C');
     insert_xml_plsql_table( p_xml_data,'SHOW_STATE',
                      get_yesno_value(p_show_state),'D','C');
     insert_xml_plsql_table( p_xml_data,'DIMENSION',
                      get_dimension_desc(p_dimension),'D','C');
     insert_xml_plsql_table(p_xml_data,'RFC_ID',l_RFC_code,'D','C');

     IF p_dimension = 'CTD' THEN

        insert_xml_plsql_table( p_xml_data,'SHOW_DIMENSION','No','D','C');

     ELSE

        insert_xml_plsql_table( p_xml_data,'SHOW_DIMENSION','Yes','D','C');

     END IF;

     l_step := 11;
     hr_utility.set_location(g_package || l_procedure_name, 110);

     FOR   l_cnt1 IN get_states_for_legal_emp(p_business_group_id,
                                              p_legal_employer_id,
                                              p_state_code,p_gre_id)
     LOOP

        l_state := l_cnt1.state_code;
        l_state_name := l_cnt1.state_name;

        dbg('Processing State   : '||l_state ||' ' ||l_state_name);

        -- Initialize state level balances
        l_st_gross_sub_ctd  := 0;
        l_st_gross_sub_dtd  := 0;

        l_st_isr_witheld_ctd := 0;
        l_st_isr_witheld_dtd := 0;
        l_st_isr_subj_ctd    := 0;
        l_st_isr_subj_dtd    := 0;

        l_st_st_witheld_ctd := 0;
        l_st_st_witheld_dtd := 0;
        l_st_st_subj_ctd    := 0;
        l_st_st_subj_dtd    := 0;

        l_st_soc_sec_ee_ctd  := 0;
        l_st_soc_sec_ee_dtd  := 0;
        l_st_soc_sec_er_ctd  := 0;
        l_st_soc_sec_er_dtd  := 0;
        l_st_soc_sec_tot_ctd := 0;
        l_st_soc_sec_tot_dtd := 0;

        insert_xml_plsql_table( p_xml_data,'STATE',NULL,'T','C');
        insert_xml_plsql_table( p_xml_data,'STATE_NAME',l_state_name,'D','C');

        --
        -- get state specific earning details AND get the ctd and
        -- dtd defined balance id
        --

        IF p_show_state = 'Y' THEN

           -- initialize the plsql table
           state_earnings.delete ;

           i := 0  ;
           FOR  l_cnt10 IN get_state_details(l_state_name)
           LOOP

             l_state_earning_name     := l_cnt10.balance_name ;
             l_st_earn_ctd_def_bal_id := fetch_define_bal(l_state_earning_name,
                                                          l_database_suffix );
             l_st_earn_dtd_def_bal_id := null ;

             IF l_dim_database_item_suffix IS NOT NULL THEN
                l_st_earn_dtd_def_bal_id :=
                                   fetch_define_bal(l_state_earning_name,
                                                    l_dim_database_item_suffix);
             END IF ;

             i := i + 1 ;
             state_earnings(i).balance_name          :=
                                                  l_cnt10.balance_name;
             state_earnings(i).state_earnings_ctd_id :=
                                                  l_st_earn_ctd_def_bal_id;
             state_earnings(i).state_earnings_dtd_id :=
                                                  l_st_earn_dtd_def_bal_id;

             dbg( 'State Earning  :' || state_earnings(i).balance_name );
             dbg( 'ctd def bal id :' || l_st_earn_ctd_def_bal_id );
             dbg( 'dtd def bal id :' || l_st_earn_dtd_def_bal_id  );

            END LOOP ;

        END IF ;

        -- state_earnings records exists THEN set to Yes otherwise No
        -- This will be used IN the template to print the
        -- state_earnings details or not

        IF state_earnings.count > 0 THEN
           insert_xml_plsql_table( p_xml_data,'SHOW_STATE_DETAILS_FLAG',
                                              'Yes','D','C');
        ELSE
           insert_xml_plsql_table( p_xml_data,'SHOW_STATE_DETAILS_FLAG',
                                              'No','D','C');
        END IF;

        FOR l_cnt2 IN get_gres_within_state (p_business_group_id
                                            ,p_legal_employer_id
                                            ,p_gre_id
                                            ,l_state)
        LOOP

          BEGIN

           l_tax_unit_id := l_cnt2.tax_unit_id;
           l_gre_name    := l_cnt2.gre_name;
           l_ss_id       := l_cnt2.ss_id ;

           dbg('Processing GRE '||l_gre_name ||' Tax Unit Id '||
                                  l_tax_unit_id || ' IN state '||l_state);

           -- Initialize GRE level balances
           l_gross_subj_ctd    := 0;
           l_gross_subj_dtd    := 0;

           l_isr_witheld_ctd  := 0;
           l_isr_witheld_dtd  := 0;
           l_isr_subj_ctd     := 0;
           l_isr_subj_dtd     := 0;

           l_st_witheld_ctd  := 0;
           l_st_witheld_dtd  := 0;
           l_st_subj_ctd     := 0;
           l_st_subj_dtd     := 0;

           l_soc_sec_ee_ctd  := 0;
           l_soc_sec_ee_dtd  := 0;
           l_soc_sec_er_ctd  := 0;
           l_soc_sec_er_dtd  := 0;
           l_soc_sec_tot_ctd := 0;
           l_soc_sec_tot_dtd := 0;


           l_soc_sec_quo_ee_ctd  := 0;
           l_soc_sec_quo_ee_dtd  := 0;
           l_soc_sec_quo_er_ctd  := 0;
           l_soc_sec_quo_er_dtd  := 0;

           dbg(' SS ID'||l_ss_id);

           l_assignment_act      := fetch_active_assg_act(p_business_group_id
                                                         ,l_tax_unit_id
                                                         ,p_start_date_earned
                                                         ,p_end_date_earned);

           dbg('The Assignment Action Id ' ||l_assignment_act);

           insert_xml_plsql_table( p_xml_data,'GRE',NULL,'T','C');
           insert_xml_plsql_table( p_xml_data,'GRE_NAME',l_gre_name,'D','C');
           insert_xml_plsql_table( p_xml_data,'SOCIAL_SECURITY_ID',l_ss_id,
                                                                    'D','C');

              /* Setting the Context for the Balances to be Fetched */
           pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
           pay_balance_pkg.set_context('DATE_EARNED',
                               to_char(p_end_date_earned,'YYYY/MM/DD'));
           pay_balance_pkg.set_context('BALANCE_DATE',
                               to_char(p_start_date_earned,'YYYY/MM/DD'));

           dbg('Get Gross Earnings Balances');

           IF l_assignment_act <> 0 THEN
              l_gross_subj_ctd := pay_balance_pkg.get_value(
                              p_assignment_action_id =>l_assignment_act,
                              p_defined_balance_id   =>l_gross_ctd_def_bal_id);
           END IF;


           IF l_gross_dtd_def_bal_id IS NOT NULL THEN

              IF l_assignment_act <> 0 THEN

                 l_gross_subj_dtd := pay_balance_pkg.get_value(
                              p_assignment_action_id =>l_assignment_act,
                              p_defined_balance_id   =>l_gross_dtd_def_bal_id);

              END IF;

           END IF;

           dbg('The CTD value for Gross earnings '||l_gross_subj_ctd);
           dbg('The DTD value for Gross earnings '||l_gross_subj_dtd);

           -- insert Gross Earnings records to plsql table
           insert_xml_plsql_table( p_xml_data,'GROSS_EARNINGS',NULL,'T','C');
           insert_xml_plsql_table( p_xml_data,'GROSS_SUBJ_CTD',l_gross_subj_ctd,
                                              'D','B');

           IF p_dimension <> 'CTD' THEN

              insert_xml_plsql_table( p_xml_data,'GROSS_SUBJ_DTD',
                                                 l_gross_subj_dtd,'D','B');

           END IF;

           insert_xml_plsql_table( p_xml_data,'/GROSS_EARNINGS',NULL,'T','C');

           -- Add to state totals AND gross total

           l_st_gross_sub_ctd  := l_st_gross_sub_ctd  + l_gross_subj_ctd;
           l_st_gross_sub_dtd  := l_st_gross_sub_dtd + l_gross_subj_dtd;

            IF p_show_isr = 'Y' THEN

              dbg('Get ISR Tax Balance');

              IF l_assignment_act <> 0 THEN
                 l_isr_witheld_ctd := pay_balance_pkg.get_value(
                        p_assignment_action_id =>l_assignment_act,
                        p_defined_balance_id   =>l_isr_withheld_ctd_def_bal_id);

                  l_isr_subj_ctd := pay_balance_pkg.get_value(
                       p_assignment_action_id =>l_assignment_act,
                       p_defined_balance_id   =>l_isr_subj_ctd_def_bal_id);
              END IF;

              IF l_isr_withheld_dtd_def_bal_id is not null AND
                 l_isr_subj_dtd_def_bal_id is not null THEN

                 IF l_assignment_act <> 0 THEN

                    l_isr_witheld_dtd := pay_balance_pkg.get_value(
                       p_assignment_action_id =>l_assignment_act,
                       p_defined_balance_id   =>l_isr_withheld_dtd_def_bal_id);

                    l_isr_subj_dtd := pay_balance_pkg.get_value(
                       p_assignment_action_id =>l_assignment_act,
                       p_defined_balance_id   =>l_isr_subj_dtd_def_bal_id);

                 END IF;

              END IF;

               dbg('The cTD value for ISR withheld '||l_isr_witheld_ctd);
               dbg('The cTD value for ISR Subject  '||l_isr_subj_ctd);

               dbg('The DTD value for ISR withheld '||l_isr_witheld_dtd);
               dbg('The DTD value for ISR Subject  '||l_isr_subj_dtd);

               -- insert ISR balance records to plsql table
               insert_xml_plsql_table( p_xml_data,'ISR',NULL,'T','C');
               insert_xml_plsql_table( p_xml_data,'ISR_WITHHELD_CTD',
                                       l_isr_witheld_ctd,'D','B');
               insert_xml_plsql_table( p_xml_data,'ISR_SUBJ_CTD',l_isr_subj_ctd,
                                       'D','B');

               IF p_dimension <>'CTD' THEN

                  insert_xml_plsql_table( p_xml_data,'ISR_WITHHELD_DTD',
                                          l_isr_witheld_dtd,'D','B');
                  insert_xml_plsql_table( p_xml_data,'ISR_SUBJ_DTD',
                                          l_isr_subj_dtd,'D','B');

               END IF;


               insert_xml_plsql_table( p_xml_data,'/ISR',NULL,'T','C');

               -- Add to state totals AND gross total
               l_st_isr_witheld_ctd := l_st_isr_witheld_ctd + l_isr_witheld_ctd;
               l_st_isr_witheld_dtd := l_st_isr_witheld_dtd + l_isr_witheld_dtd;
               l_st_isr_subj_ctd    := l_st_isr_subj_ctd    + l_isr_subj_ctd;
               l_st_isr_subj_dtd    := l_st_isr_subj_dtd    + l_isr_subj_dtd;

         END IF;

         IF p_show_soc_security = 'Y' THEN

            l_soc_sec_ee_ctd  := 0 ;
            l_soc_sec_er_ctd  := 0 ;
            l_soc_sec_ee_dtd  := 0 ;
            l_soc_sec_er_dtd  := 0 ;


            dbg('Get Social Security Quota Balances');

            FOR l_cnt5 IN soc_sec_det_tab.FIRST .. soc_sec_det_tab.LAST
            LOOP

               l_ss_ee_ctd := 0 ;
               l_ss_er_ctd := 0 ;
               l_ss_ee_dtd := 0 ;
               l_ss_er_dtd := 0 ;

               dbg('l_cnt5' || l_cnt5 );
               dbg('Soc Sec Ins Type: '||soc_sec_det_tab(l_cnt5).balance_name);

               IF l_assignment_act <> 0 THEN
                  l_ss_ee_ctd  := pay_balance_pkg.get_value(
                       p_assignment_action_id =>l_assignment_act,
                       p_defined_balance_id   =>
                                 soc_sec_det_tab(l_cnt5).soc_sec_ee_ctd_id);

                  l_ss_er_ctd  := pay_balance_pkg.get_value(
                       p_assignment_action_id =>l_assignment_act,
                       p_defined_balance_id   =>
                                 soc_sec_det_tab(l_cnt5).soc_sec_er_ctd_id);
               END IF;

               IF p_dimension <> 'CTD' THEN

                  IF l_assignment_act <> 0 THEN

                     l_ss_ee_dtd  := pay_balance_pkg.get_value(
                          p_assignment_action_id =>l_assignment_act,
                          p_defined_balance_id   =>
                                    soc_sec_det_tab(l_cnt5).soc_sec_ee_dtd_id);
                     l_ss_er_dtd  := pay_balance_pkg.get_value(
                          p_assignment_action_id =>l_assignment_act,
                          p_defined_balance_id   =>
                                    soc_sec_det_tab(l_cnt5).soc_sec_er_dtd_id);

                  END IF;

               END IF;

               soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd  := l_ss_ee_ctd ;
               soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd  := l_ss_er_ctd ;
               soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd  := l_ss_ee_dtd ;
               soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd  := l_ss_er_dtd ;

               IF UPPER(soc_sec_det_tab(l_cnt5).balance_name) <>'INFONAVIT' THEN

                  l_soc_sec_ee_ctd  := l_soc_sec_ee_ctd + l_ss_ee_ctd ;
                  l_soc_sec_er_ctd  := l_soc_sec_er_ctd + l_ss_er_ctd ;
                  l_soc_sec_ee_dtd  := l_soc_sec_ee_dtd + l_ss_ee_dtd ;
                  l_soc_sec_er_dtd  := l_soc_sec_er_dtd + l_ss_er_dtd ;

               END IF;


            END loop;

             dbg('The CTD value for Social Security Quota EE '||
                                                          l_soc_sec_ee_ctd);
             dbg('The cTD value for Social Security Quota ER '||
                                                          l_soc_sec_er_ctd);
             dbg('The DTD value for Social Security Quota EE '||
                                                          l_soc_sec_ee_dtd);
             dbg('The DTD value for Social Security Quota ER '||
                                                          l_soc_sec_er_dtd);


             l_soc_sec_tot_ctd := l_soc_sec_ee_ctd + l_soc_sec_er_ctd ;
             l_soc_sec_tot_dtd := l_soc_sec_ee_dtd + l_soc_sec_er_dtd ;


             insert_xml_plsql_table( p_xml_data,'SOCIAL_SECURITY',NULL,'T','C');
             insert_xml_plsql_table( p_xml_data,'SOC_SEC_EE_CTD',
                                                 l_soc_sec_ee_ctd,'D','B');
             insert_xml_plsql_table( p_xml_data,'SOC_SEC_ER_CTD',
                                                 l_soc_sec_er_ctd,'D','B');
             insert_xml_plsql_table( p_xml_data,'SOC_SEC_TOTAL_CTD',
                                                 l_soc_sec_tot_ctd,'D','B');

             IF p_dimension <> 'CTD' THEN
                insert_xml_plsql_table( p_xml_data,'SOC_SEC_EE_DTD',
                                                 l_soc_sec_ee_dtd,'D','B');
                insert_xml_plsql_table( p_xml_data,'SOC_SEC_ER_DTD',
                                                 l_soc_sec_er_dtd,'D','B');
                insert_xml_plsql_table( p_xml_data,'SOC_SEC_TOTAL_DTD',
                                                 l_soc_sec_tot_dtd,'D','B');
             END IF ;

             insert_xml_plsql_table(p_xml_data,'/SOCIAL_SECURITY',NULL,'T','C');

             dbg('The current value of the Counter is '||p_xml_data.count);

             l_st_soc_sec_ee_ctd  := l_st_soc_sec_ee_ctd + l_soc_sec_ee_ctd;
             l_st_soc_sec_er_ctd  := l_st_soc_sec_er_ctd + l_soc_sec_er_ctd;
             l_st_soc_sec_ee_dtd  := l_st_soc_sec_ee_dtd + l_soc_sec_ee_dtd ;
             l_st_soc_sec_er_dtd  := l_st_soc_sec_er_dtd + l_soc_sec_er_dtd;
             l_st_soc_sec_tot_ctd := l_st_soc_sec_tot_ctd + l_soc_sec_tot_ctd;
             l_st_soc_sec_tot_dtd := l_st_soc_sec_tot_dtd + l_soc_sec_tot_dtd;

          END IF;


           IF p_show_state = 'Y' THEN

            --get the state tax withheld AND subject

               l_st_witheld_ctd := 0 ;
               l_st_subj_ctd    := 0 ;
               l_st_witheld_dtd := 0 ;
               l_st_subj_dtd    := 0 ;

               IF l_st_withheld_ctd_def_bal_id IS NOT NULL THEN /*7687079*/

                  IF l_assignment_act <> 0 THEN

                     l_st_subj_ctd := pay_balance_pkg.get_value(
                           p_assignment_action_id =>l_assignment_act,
                           p_defined_balance_id   =>l_st_subj_ctd_def_bal_id);

                  END IF;

               END IF;

               IF l_state  <> 'CHIH' THEN

                  IF l_st_withheld_ctd_def_bal_id IS NOT NULL THEN

                     IF l_assignment_act <> 0 THEN

                        l_st_witheld_ctd := pay_balance_pkg.get_value(
                         p_assignment_action_id =>l_assignment_act,
                         p_defined_balance_id   =>l_st_withheld_ctd_def_bal_id);

                     END IF;

                  END IF;

               ELSE

                  l_st_witheld_ctd := 0 ;

               END IF;

               dbg('State tax withheld ctd ' || to_char(l_st_witheld_ctd) ) ;

               IF l_st_withheld_dtd_def_bal_id IS NOT NULL AND
                  l_st_subj_dtd_def_bal_id IS NOT NULL THEN

                  IF l_assignment_act <> 0 THEN

                     l_st_subj_dtd := pay_balance_pkg.get_value(
                          p_assignment_action_id =>l_assignment_act,
                          p_defined_balance_id   =>l_st_subj_dtd_def_bal_id);

                  END IF;

                  IF l_state  <> 'CHIH' THEN

                     IF l_assignment_act <> 0 THEN

                        l_st_witheld_dtd := pay_balance_pkg.get_value(
                         p_assignment_action_id =>l_assignment_act,
                         p_defined_balance_id   =>l_st_withheld_dtd_def_bal_id);

                     END IF;

                  ELSE

                     l_st_witheld_dtd := 0 ;

                  END IF;

                  dbg('State tax withheld dtd ' || to_char(l_st_witheld_dtd) ) ;

               END IF;

               dbg('The cTD value for Employer State Tax withheld '||
                                                             l_st_witheld_ctd);
               dbg('The cTD value for Employer State Tax Subject  '||
                                                             l_st_subj_ctd);
               dbg('The DTD value for Employer State Tax withheld '||
                                                             l_st_witheld_dtd);
               dbg('The DTD value for Employer State Tax Subject  '||
                                                             l_st_subj_dtd);

               -- insert ISR balance records to plsql table
               insert_xml_plsql_table( p_xml_data,'STATE_TAX',NULL,'T','C');

	       IF l_state = 'QRO' THEN  /*7565304*/
               insert_xml_plsql_table( p_xml_data,'STATE_WITHHELD_CTD',
                                                   0,'D','B');
               ELSE
               insert_xml_plsql_table( p_xml_data,'STATE_WITHHELD_CTD',
                                                   l_st_witheld_ctd,'D','B');
               END IF;
	       insert_xml_plsql_table( p_xml_data,'STATE_SUBJ_CTD',
                                                   l_st_subj_ctd,'D','B');

               IF p_dimension <>'CTD' THEN

                  IF l_state ='QRO' then /*7565304*/
                  insert_xml_plsql_table( p_xml_data,'STATE_WITHHELD_DTD',
                                                   0,'D','B');
                  ELSE
                  insert_xml_plsql_table( p_xml_data,'STATE_WITHHELD_DTD',
                                                   l_st_witheld_dtd,'D','B');
                  END IF;

                  insert_xml_plsql_table( p_xml_data,'STATE_SUBJ_DTD',
                                                   l_st_subj_dtd,'D','B');

               END IF;


               insert_xml_plsql_table( p_xml_data,'/STATE_TAX',NULL,'T','C');

               dbg('Before adding to State totals ');

               -- Add to state totals AND gross total
               l_st_st_witheld_ctd  := l_st_st_witheld_ctd + l_st_witheld_ctd;
               l_st_st_witheld_dtd  := l_st_st_witheld_dtd + l_st_witheld_dtd;
               l_st_st_subj_ctd     := l_st_st_subj_ctd    + l_st_subj_ctd;
               l_st_st_subj_dtd     := l_st_st_subj_dtd    + l_st_subj_dtd;

            --get state earnings details

            dbg('After adding to State totals ');
            dbg('The value of The PLSQL counter for state_earnings table is '||
                      state_earnings.count);

            IF state_earnings.count > 0 THEN

            FOR l_cnt50 IN state_earnings.FIRST .. state_earnings.LAST
            LOOP

              dbg('State Earning  : '|| state_earnings(l_cnt50).balance_name );

              l_st_earn_ctd_value  := 0 ;
              l_st_earn_dtd_value  := 0 ;

              IF state_earnings(l_cnt50).state_earnings_ctd_id IS NOT NULL THEN

                 IF l_assignment_act <> 0 THEN

                    l_st_earn_ctd_value  := pay_balance_pkg.get_value(
                         p_assignment_action_id =>l_assignment_act,
                         p_defined_balance_id   =>
                             state_earnings(l_cnt50).state_earnings_ctd_id);

                 END IF;

              END IF;

              IF p_dimension <> 'CTD' THEN

                 IF state_earnings(l_cnt50).state_earnings_dtd_id IS NOT NULL
                 THEN

                    IF l_assignment_act <> 0 THEN

                       l_st_earn_dtd_value  := pay_balance_pkg.get_value(
                         p_assignment_action_id =>l_assignment_act,
                         p_defined_balance_id   =>
                           state_earnings(l_cnt50).state_earnings_dtd_id);

                    END IF;

                 END IF;

              END IF;

              dbg('The CTD value  '||l_st_earn_ctd_value);
              dbg('The DTD value  '||l_st_earn_dtd_value);

              insert_xml_plsql_table( p_xml_data,'STATE_DETAILS',NULL,'T','C');
              insert_xml_plsql_table( p_xml_data,'STATE_DETAILS_NAME',
                               state_earnings(l_cnt50).balance_name,'D','C');
              insert_xml_plsql_table( p_xml_data,'STATE_DETAILS_SUBJ_CTD',
                               l_st_earn_ctd_value,'D','B');
              IF p_dimension <> 'CTD' THEN
                 insert_xml_plsql_table( p_xml_data,'STATE_DETAILS_SUBJ_DTD',
                               l_st_earn_dtd_value,'D','B');
              END IF;
              insert_xml_plsql_table( p_xml_data,'/STATE_DETAILS',NULL,'T','C');
              --
              -- Add the total to state level balance
              --
              st_state_earnings(l_cnt50).balance_name :=
                                         state_earnings(l_cnt50).balance_name ;
              st_state_earnings(l_cnt50).state_earnings_ctd_value :=
                 nvl(st_state_earnings(l_cnt50).state_earnings_ctd_value,0) +
                 l_st_earn_ctd_value ;
              st_state_earnings(l_cnt50).state_earnings_dtd_value :=
                 nvl(st_state_earnings(l_cnt50).state_earnings_dtd_value,0) +
                 l_st_earn_dtd_value ;

            END LOOP ;

            END IF;

           END IF;

          IF p_show_soc_security = 'Y' THEN

            dbg('The value of The PLSQL counter for Social '||
                 soc_sec_det_tab.count);

            FOR l_cnt5 IN soc_sec_det_tab.FIRST .. soc_sec_det_tab.LAST
            LOOP

                dbg('counter ' || l_cnt5 );
                dbg('Soc Sec Ins Type is '||
                         soc_sec_det_tab(l_cnt5).balance_name);

                dbg('The CTD value for EE '||
                         soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd );
                dbg('The CTD value for ER '||
                         soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd );
                dbg('The DTD value for EE '||
                         soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd );
                dbg('The DTD value for ER '||
                         soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd );

                insert_xml_plsql_table( p_xml_data,'SOCIAL_SECURITY_QUOTA',
                                        NULL,'T','C');
                insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS',
                                 soc_sec_det_tab(l_cnt5).balance_name,'D','C');
                insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS_EE_PCT',
                           soc_sec_det_tab(l_cnt5).soc_sec_tax_pct_ee,'D','P');

                IF soc_sec_det_tab(l_cnt5).balance_name = 'Work Risk Incident'
                THEN

                   -- For Work Risk Employer pcts get the wrip FROM GRE
                   dbg('Before Calling get_wrip to get the workrisk premium');
                   dbg('Business group id ' ||p_business_group_id);
                   dbg('Tax Unit id ' ||l_tax_unit_id);

                   insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS_ER_PCT',
                              hr_mx_utility.get_wrip(p_business_group_id,
                                                l_tax_unit_id),'D','P');
                   dbg('After Calling get_wrip to get the workrisk premium');

                ELSE

                   insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS_ER_PCT',
                          soc_sec_det_tab(l_cnt5).soc_sec_tax_pct_er,'D','P');

                END IF;

                insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS_EE_CTD',
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd,'D','B');
                insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS_ER_CTD',
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd,'D','B');

                IF p_dimension <> 'CTD' THEN

                   insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS_EE_DTD',
                          soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd,'D','B');
                   insert_xml_plsql_table( p_xml_data,'SOC_SEC_INS_ER_DTD',
                          soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd,'D','B');

                END IF;

                insert_xml_plsql_table( p_xml_data,'/SOCIAL_SECURITY_QUOTA',
                          NULL,'T','C');

                --
                -- Add the total to state level balance
                --

                st_soc_sec_det_tab(l_cnt5).balance_name :=
                          soc_sec_det_tab(l_cnt5).balance_name ;
                st_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd :=
                          nvl(st_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd,0) +
                          soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd;

                st_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd :=
                       nvl(st_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd,0) +
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd;

                st_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd :=
                       nvl(st_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd,0) +
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd;

                st_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd :=
                       nvl(st_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd,0) +
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd;

                --
                -- Add the total to legal employer level balance
                --

                le_soc_sec_det_tab(l_cnt5).balance_name :=
                       soc_sec_det_tab(l_cnt5).balance_name ;
                le_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd :=
                       nvl(le_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd,0) +
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd;

                le_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd :=
                       nvl(le_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd,0) +
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd;

                le_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd :=
                       nvl(le_soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd,0) +
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd;

                le_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd :=
                       nvl(le_soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd,0) +
                       soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd;

                -- reset values

                soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_ctd := 0 ;
                soc_sec_det_tab(l_cnt5).soc_sec_quo_er_ctd := 0 ;
                soc_sec_det_tab(l_cnt5).soc_sec_quo_ee_dtd := 0 ;
                soc_sec_det_tab(l_cnt5).soc_sec_quo_er_dtd := 0 ;

            END LOOP;

          END IF; /*  End of p_show_soc_security = 'Y' */


        insert_xml_plsql_table( p_xml_data,'/GRE',NULL,'T','C');

      END;

     END LOOP; /*End Loop for the Second Cursor fetch next GRE within a State */

     dbg('Adding up the Total for Legal Employer ' ) ;

     /* Adding up the Total for the Legal Employer */
     l_lt_gross_sub_ctd     := l_lt_gross_sub_ctd   + l_st_gross_sub_ctd;
     l_lt_gross_sub_dtd     := l_lt_gross_sub_dtd  + l_st_gross_sub_dtd;
     l_lt_isr_witheld_ctd   := l_lt_isr_witheld_ctd + l_st_isr_witheld_ctd ;
     l_lt_isr_witheld_dtd   := l_lt_isr_witheld_dtd  + l_st_isr_witheld_dtd;
     l_lt_isr_subj_ctd      := l_lt_isr_subj_ctd + l_st_isr_subj_ctd ;
     l_lt_isr_subj_dtd      := l_lt_isr_subj_dtd + l_st_isr_subj_dtd ;


     l_lt_st_subj_ctd      := l_lt_st_subj_ctd + l_st_st_subj_ctd ;
     l_lt_st_subj_dtd      := l_lt_st_subj_dtd + l_st_st_subj_dtd ;

     IF l_state  = 'CHIH' THEN

        -- calculate the withheld for state tax chihuahua FROM the user table
        -- use fix rate, marginal rate AND lower bound columns
        -- calculate state tax withheld for ctd

        IF l_st_st_subj_ctd > 0 THEN

           l_fixed_rate     := 0 ;
           l_marginal_rate  := 0 ;
           l_lower_bound    := 0 ;

           -- calculate based on the subject earnings
           -- get the fixed rate

           dbg('Get Fixed Rate');
           dbg('Table Name - STATE_TAX_RATES_CHIH');
           dbg('Col   Name - Fixed Rate');
           dbg('Row   value ' || to_char(l_st_st_subj_ctd) ) ;
           dbg('effective date ' || to_char(p_end_date_earned) ) ;

           l_fixed_rate := hruserdt.get_table_value(
                             p_bus_group_id   => p_business_group_id,
                             p_table_name     => 'STATE_TAX_RATES_CHIH',
                             p_col_name       => 'Fixed Rate',
                             p_row_value      => l_st_st_subj_ctd,
                             p_effective_date => p_end_date_earned);

           dbg('Fixed Rate ' || to_char(l_fixed_rate) ) ;
           -- get the marginal rate
           dbg('Get Marginal Rate');
           dbg('Table Name - STATE_TAX_RATES_CHIH');
           dbg('Col   Name - Marginal Rate');
           dbg('Row   value ' || to_char(l_st_st_subj_ctd) ) ;
           dbg('effective date ' || to_char(p_end_date_earned) ) ;

           l_marginal_rate := hruserdt.get_table_value(
                             p_bus_group_id   => p_business_group_id,
                             p_table_name     => 'STATE_TAX_RATES_CHIH',
                             p_col_name       => 'Marginal Rate',
                             p_row_value      => l_st_st_subj_ctd,
                             p_effective_date => p_end_date_earned);

           dbg('Marginal Rate ' || to_char(l_marginal_rate) ) ;
           -- get the Lower Bound
           dbg('Get Lower Bound');
           dbg('Table Name - STATE_TAX_RATES_CHIH');
           dbg('Col   Name - Lower Bound');
           dbg('Row   value ' || to_char(l_st_st_subj_ctd) ) ;
           dbg('effective date ' || to_char(p_end_date_earned) ) ;

           l_lower_bound := hruserdt.get_table_value(
                             p_bus_group_id   => p_business_group_id,
                             p_table_name     => 'STATE_TAX_RATES_CHIH',
                             p_col_name       => 'Lower Bound',
                             p_row_value      => l_st_st_subj_ctd,
                             p_effective_date => p_end_date_earned);

                     dbg('Lower Bound ' || to_char(l_lower_bound) ) ;
              /* bug fix 4526042 */
           l_st_st_witheld_ctd := l_fixed_rate +
                ( (l_st_st_subj_ctd - l_lower_bound) * l_marginal_rate / 100 );

        ELSE

           l_st_st_witheld_ctd := 0 ;

        END IF ;

        -- state tax withheld for dtd

        l_fixed_rate     := 0 ;
        l_marginal_rate  := 0 ;
        l_lower_bound    := 0 ;

        IF l_st_st_subj_dtd > 0 THEN

           -- calculate based on the subject earnings
           -- get the fixed rate

           dbg('Get Fixed Rate');
           dbg('Table Name - STATE_TAX_RATES_CHIH');
           dbg('Col   Name - Fixed Rate');
           dbg('Row   value ' || to_char(l_st_st_subj_dtd) ) ;
           dbg('effective date ' || to_char(p_end_date_earned) ) ;

           l_fixed_rate := hruserdt.get_table_value(
                             p_bus_group_id   => p_business_group_id,
                             p_table_name     => 'STATE_TAX_RATES_CHIH',
                             p_col_name       => 'Fixed Rate',
                             p_row_value      => l_st_st_subj_dtd,
                             p_effective_date => p_end_date_earned);

           dbg('Fixed Rate ' || to_char(l_fixed_rate) ) ;
           -- get the marginal rate
           dbg('Get Marginal Rate');
           dbg('Table Name - STATE_TAX_RATES_CHIH');
           dbg('Col   Name - Marginal Rate');
           dbg('Row   value ' || to_char(l_st_st_subj_dtd) ) ;
           dbg('effective date ' || to_char(p_end_date_earned) ) ;

           l_marginal_rate := hruserdt.get_table_value(
                             p_bus_group_id   => p_business_group_id,
                             p_table_name     => 'STATE_TAX_RATES_CHIH',
                             p_col_name       => 'Marginal Rate',
                             p_row_value      => l_st_st_subj_dtd,
                             p_effective_date => p_end_date_earned);

            dbg('Marginal Rate ' || to_char(l_marginal_rate) ) ;
            -- get the Lower Bound
            dbg('Get Lower Bound');
            dbg('Table Name - STATE_TAX_RATES_CHIH');
            dbg('Col   Name - Lower Bound');
            dbg('Row   value ' || to_char(l_st_st_subj_dtd) ) ;
            dbg('effective date ' || to_char(p_end_date_earned) ) ;

            l_lower_bound := hruserdt.get_table_value(
                             p_bus_group_id   => p_business_group_id,
                             p_table_name     => 'STATE_TAX_RATES_CHIH',
                             p_col_name       => 'Lower Bound',
                             p_row_value      => l_st_st_subj_dtd,
                             p_effective_date => p_end_date_earned);

            dbg('Lower Bound ' || to_char(l_lower_bound) ) ;
              /* bug fix 4526042 */
            l_st_st_witheld_dtd := l_fixed_rate +
                 ( (l_st_st_subj_dtd - l_lower_bound) * l_marginal_rate / 100 );

         ELSE

            l_st_st_witheld_dtd := 0 ;

         END IF;

     END IF; --  l_state

     /* 7565304 */
     IF l_state  = 'QRO' THEN

      l_rate:=0;
      l_dummy:=0;
      l_leg_info:='N';
      l_min_wage:=0;
      l_rate_type:='FLAT_RATE';
      l_st_st_exemption:=0;

      /* Bug:9451129 Modified code to avoid char to number conversion error
         when number format is 10.000,00 */

      l_dummy:= pay_mx_tax_functions.get_mx_tax_info(
                p_business_group_id
                ,l_tax_unit_id
                ,p_end_date_earned
                ,l_state
                ,'MX State Tax Rate'
                ,l_rate_type
                ,lv_rate
                ,l_leg_info
                ,l_leg_info
                ,l_leg_info
                ,l_leg_info );

      dbg('lv_rate '||lv_rate) ;
      l_rate :=fnd_number.canonical_to_number(lv_rate);

         /* Bug:9451129  pay_mx_tax_functions.get_min_wage changed to
         pay_mx_utility.get_min_wage to avoid char to number conversion error
         when number format is 10.000,00 */

         l_min_wage:= pay_mx_utility.get_min_wage(
                   p_end_date_earned,
                   l_leg_info,
                   'C' );

          dbg('l_min_wage '||l_min_wage);
               l_st_st_exemption :=((l_min_wage*8)*
                              ((p_end_date_earned - p_start_date_earned)+1)) * l_rate/100;
        -- calculate state tax withheld for ctd

        IF l_st_st_witheld_ctd > 0 THEN
        l_st_st_witheld_ctd := l_st_st_witheld_ctd - l_st_st_exemption;

           IF l_st_st_witheld_ctd < 0 THEN
            l_st_st_witheld_ctd := 0 ;
           END IF;

        ELSE

           l_st_st_witheld_ctd := 0 ;
        END IF;
        IF l_st_st_subj_dtd > 0 THEN

         -- calculate state tax withheld for dtd

        l_st_st_witheld_dtd := l_st_st_witheld_dtd - l_st_st_exemption;

           IF l_st_st_witheld_dtd < 0 THEN
            l_st_st_witheld_dtd := 0 ;
           END IF;

         ELSE

            l_st_st_witheld_dtd := 0 ;

         END IF;
     END IF; /*l_state  = 'QRO'*/

     l_lt_st_witheld_ctd   := l_lt_st_witheld_ctd + l_st_st_witheld_ctd ;
     l_lt_st_witheld_dtd   := l_lt_st_witheld_dtd + l_st_st_witheld_dtd;


     l_lt_soc_sec_ee_ctd   := l_lt_soc_sec_ee_ctd + l_st_soc_sec_ee_ctd;
     l_lt_soc_sec_ee_dtd   := l_lt_soc_sec_ee_dtd + l_st_soc_sec_ee_dtd;
     l_lt_soc_sec_er_ctd   := l_lt_soc_sec_er_ctd + l_st_soc_sec_er_ctd;
     l_lt_soc_sec_er_dtd   := l_lt_soc_sec_er_dtd + l_st_soc_sec_er_dtd;
     l_lt_soc_sec_tot_ctd  := l_lt_soc_sec_tot_ctd + l_st_soc_sec_tot_ctd ;
     l_lt_soc_sec_tot_dtd  := l_lt_soc_sec_tot_dtd + l_st_soc_sec_tot_dtd ;


     /* writing the State Level Details */
     dbg('Writing State Level Details ' ) ;

     l_state_heading := 'State Total Report All GREs for '|| l_state_name;

     dbg('Writing State Level Details ....... 1' ) ;

     insert_xml_plsql_table( p_xml_data,'STATE_TOTAL',NULL,'T','C');

     dbg('Writing State Level Details ........ 2 ' ) ;

     insert_xml_plsql_table( p_xml_data,'STATE_TOTAL_HEAD',l_state_heading,
                             'D','C');

     dbg('Writing State Level Gross Subject CTD Details ' ) ;

     insert_xml_plsql_table( p_xml_data,'ST_GROSS',NULL,'T','C');
     insert_xml_plsql_table( p_xml_data,'ST_GROSS_SUBJ_CTD',l_st_gross_sub_ctd,
                             'D','B');

     dbg('Writing State Level Gross Subject DTD Details ' ) ;

     IF p_dimension <> 'CTD' THEN

        insert_xml_plsql_table( p_xml_data,'ST_GROSS_SUBJ_DTD',
                                l_st_gross_sub_dtd,'D','B');

     END IF;

     insert_xml_plsql_table( p_xml_data,'/ST_GROSS',NULL,'T','C');

     dbg('Writing State Level ISR Details ' ) ;

     IF p_show_isr = 'Y' THEN

        insert_xml_plsql_table( p_xml_data,'ST_ISR',NULL,'T','C');
        insert_xml_plsql_table( p_xml_data,'ST_ISR_WITHHELD_CTD',
                                l_st_isr_witheld_ctd,'D','B');
        insert_xml_plsql_table( p_xml_data,'ST_ISR_SUBJ_CTD',
                                l_st_isr_subj_ctd,'D','B');

        IF p_dimension <> 'CTD' THEN

           insert_xml_plsql_table( p_xml_data,'ST_ISR_WITHHELD_DTD',
                                   l_st_isr_witheld_dtd,'D','B');
           insert_xml_plsql_table( p_xml_data,'ST_ISR_SUBJ_DTD',
                                   l_st_isr_subj_dtd,'D','B');

        END IF;

        insert_xml_plsql_table( p_xml_data,'/ST_ISR',NULL,'T','C');

     END IF;

     IF p_show_soc_security = 'Y' THEN

        dbg('Writing State Level Social Security Details ' ) ;

        insert_xml_plsql_table( p_xml_data,'ST_SOCIAL_SECURITY',NULL,'T','C');
        insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_EE_CTD',
                                l_st_soc_sec_ee_ctd,'D','B');
        insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_ER_CTD',
                                l_st_soc_sec_er_ctd,'D','B');
        insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_TOTAL_CTD',
                                l_st_soc_sec_tot_ctd,'D','B');

        IF p_dimension <> 'CTD' THEN

           insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_EE_DTD',
                                   l_st_soc_sec_ee_dtd,'D','B');
           insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_ER_DTD',
                                   l_st_soc_sec_er_dtd,'D','B');
           insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_TOTAL_DTD',
                                   l_st_soc_sec_tot_dtd,'D','B');

        END IF;

        insert_xml_plsql_table( p_xml_data,'/ST_SOCIAL_SECURITY',NULL,'T','C');

      END IF;

      IF p_show_state = 'Y' THEN

         -- write state tax subject AND withheld
        dbg('Writing State Level state Details ' ) ;

        insert_xml_plsql_table( p_xml_data,'ST_STATE_TAX',NULL,'T','C');
        insert_xml_plsql_table( p_xml_data,'ST_STATE_WITHHELD_CTD',
                                l_st_st_witheld_ctd,'D','B');
        insert_xml_plsql_table( p_xml_data,'ST_STATE_SUBJ_CTD',
                                l_st_st_subj_ctd,'D','B');

        IF p_dimension <> 'CTD' THEN

           insert_xml_plsql_table( p_xml_data,'ST_STATE_WITHHELD_DTD',
                                   l_st_st_witheld_dtd,'D','B');
           insert_xml_plsql_table( p_xml_data,'ST_STATE_SUBJ_DTD',
                                   l_st_st_subj_dtd,'D','B');

        END IF;

        insert_xml_plsql_table( p_xml_data,'/ST_STATE_TAX',NULL,'T','C');

        dbg('The value of The PLSQL counter for st_state_earnings table is '||
                st_state_earnings.count);
        IF st_state_earnings.count > 0 THEN

         -- write state level totals for state earnings

         FOR m IN 1 .. st_state_earnings.COUNT
         LOOP
            insert_xml_plsql_table( p_xml_data,'ST_STATE_DETAILS',NULL,'T','C');
            insert_xml_plsql_table( p_xml_data,'ST_STATE_DETAILS_NAME',
                      st_state_earnings(m).balance_name,'D','C');
            insert_xml_plsql_table( p_xml_data,'ST_STATE_DETAILS_SUBJ_CTD',
                      st_state_earnings(m).state_earnings_ctd_value,'D','B');

            IF p_dimension <> 'CTD' THEN

               insert_xml_plsql_table( p_xml_data,'ST_STATE_DETAILS_SUBJ_DTD',
                      st_state_earnings(m).state_earnings_dtd_value,'D','B');

            END IF;

            insert_xml_plsql_table(p_xml_data,'/ST_STATE_DETAILS',NULL,'T','C');

          END LOOP;

         END IF;

      END IF;

      IF p_show_soc_security = 'Y' THEN

         FOR m IN 1 .. st_soc_sec_det_tab.COUNT
         LOOP

            insert_xml_plsql_table( p_xml_data,'ST_SOCIAL_SECURITY_QUOTA',NULL,
                                    'T','C');
            insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_INS',
                                    st_soc_sec_det_tab(m).balance_name,'D','C');
            insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_INS_EE_CTD',
                                    st_soc_sec_det_tab(m).soc_sec_quo_ee_ctd,
                                    'D','B');
            insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_INS_ER_CTD',
                                    st_soc_sec_det_tab(m).soc_sec_quo_er_ctd,
                                    'D','B');

            IF p_dimension <> 'CTD' THEN

               insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_INS_EE_DTD',
                                    st_soc_sec_det_tab(m).soc_sec_quo_ee_dtd,
                                    'D','B');
               insert_xml_plsql_table( p_xml_data,'ST_SOC_SEC_INS_ER_DTD',
                                    st_soc_sec_det_tab(m).soc_sec_quo_er_dtd,
                                    'D','B');

            END IF;

            insert_xml_plsql_table( p_xml_data,'/ST_SOCIAL_SECURITY_QUOTA',
                                    NULL,'T','C');
          END LOOP;

      END IF;

      insert_xml_plsql_table( p_xml_data,'/STATE_TOTAL',NULL,'T','C');
      insert_xml_plsql_table( p_xml_data,'/STATE',NULL,'T','C');

      dbg('Initializing state level social security insurance type balances');

     -- initialize state level soc security ins type balances
     IF p_show_soc_security = 'Y' THEN

        FOR cnt IN 1 .. st_soc_sec_det_tab.LAST
        LOOP

           st_soc_sec_det_tab(cnt).balance_name       := '';
           st_soc_sec_det_tab(cnt).soc_sec_quo_ee_ctd := 0 ;
           st_soc_sec_det_tab(cnt).soc_sec_quo_er_ctd := 0 ;
           st_soc_sec_det_tab(cnt).soc_sec_quo_ee_dtd := 0 ;
           st_soc_sec_det_tab(cnt).soc_sec_quo_er_dtd := 0 ;

        END loop ;

     END IF;

     -- initialize state level earning details

     IF p_show_state = 'Y' THEN

        dbg('The value of The PLSQL counter for st_state_earnings table is '||
                st_state_earnings.count);

        IF st_state_earnings.count > 0 THEN

           FOR cnt IN 1 .. st_state_earnings.LAST
           LOOP

             st_state_earnings(cnt).balance_name             := '';
             st_state_earnings(cnt).state_earnings_ctd_value := 0 ;
             st_state_earnings(cnt).state_earnings_dtd_value := 0 ;

           END loop ;

        END IF ;

     END IF;

    END LOOP;  /* For the Outer Distinct State Loop */

    l_step := 12;
    hr_utility.set_location(g_package || l_procedure_name, 120);

    /* Writing the Legal Employer Level Totals into the PL/SQL data */
    /*  Legal Employer Gross Earning Data */

    dbg('Printing the Legal Employer Details');

    insert_xml_plsql_table( p_xml_data,'LEGAL_EMPLOYER_TOTAL',NULL,'T','C');
    insert_xml_plsql_table( p_xml_data,'LE_TOTAL_HEAD',
                            'Legal Employer Total Report','D','C');
    insert_xml_plsql_table( p_xml_data,'LE_GROSS',NULL,'T','C');
    insert_xml_plsql_table( p_xml_data,'LE_GROSS_SUBJ_CTD',
                            l_lt_gross_sub_ctd,'D','B');

    IF p_dimension <> 'CTD' THEN

       insert_xml_plsql_table( p_xml_data,'LE_GROSS_SUBJ_DTD',
                               l_lt_gross_sub_dtd,'D','B');

    END IF;

    insert_xml_plsql_table( p_xml_data,'/LE_GROSS',NULL,'T','C');

    IF p_show_isr = 'Y' THEN

       /* Legal Employer ISR data */
       insert_xml_plsql_table( p_xml_data,'LE_ISR',NULL,'T','C');
       insert_xml_plsql_table( p_xml_data,'LE_ISR_WITHHELD_CTD',
                               l_lt_isr_witheld_ctd,'D','B');
       insert_xml_plsql_table( p_xml_data,'LE_ISR_SUBJ_CTD',
                               l_lt_isr_subj_ctd,'D','B');

       IF p_dimension <>'CTD' THEN
          insert_xml_plsql_table( p_xml_data,'LE_ISR_WITHHELD_DTD',
                                  l_lt_isr_witheld_dtd,'D','B');
          insert_xml_plsql_table( p_xml_data,'LE_ISR_SUBJ_DTD',
                                  l_lt_isr_subj_dtd,'D','B');
       END IF;

       insert_xml_plsql_table( p_xml_data,'/LE_ISR',NULL,'T','C');

    END IF;

    IF p_show_soc_security ='Y' THEN

       /* Legal Employer Social Security Data */
       insert_xml_plsql_table( p_xml_data,'LE_SOCIAL_SECURITY',NULL,'T','C');
       insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_EE_CTD',
                               l_lt_soc_sec_ee_ctd,'D','B');
       insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_ER_CTD',
                               l_lt_soc_sec_er_ctd,'D','B');
       insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_TOTAL_CTD',
                               l_lt_soc_sec_tot_ctd,'D','B');

       IF p_dimension <> 'CTD' THEN

          insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_EE_DTD',
                               l_lt_soc_sec_ee_dtd,'D','B');
          insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_ER_DTD',
                               l_lt_soc_sec_er_dtd,'D','B');
          insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_TOTAL_DTD',
                               l_lt_soc_sec_tot_dtd,'D','B');

       END IF;

       insert_xml_plsql_table( p_xml_data,'/LE_SOCIAL_SECURITY',NULL,'T','C');

    END IF ;


    IF p_show_state ='Y' THEN

       -- write legal employer level state tax subject AND withheld

       insert_xml_plsql_table( p_xml_data,'LE_STATE_TAX',NULL,'T','C');
       insert_xml_plsql_table( p_xml_data,'LE_STATE_WITHHELD_CTD',
                               l_lt_st_witheld_ctd,'D','B');
       insert_xml_plsql_table( p_xml_data,'LE_STATE_SUBJ_CTD',
                               l_lt_st_subj_ctd,'D','B');

       IF p_dimension <> 'CTD' THEN

          insert_xml_plsql_table( p_xml_data,'LE_STATE_WITHHELD_DTD',
                               l_lt_st_witheld_dtd,'D','B');
          insert_xml_plsql_table( p_xml_data,'LE_STATE_SUBJ_DTD',
                               l_lt_st_subj_dtd,'D','B');

       END IF;

       insert_xml_plsql_table( p_xml_data,'/LE_STATE_TAX',NULL,'T','C');

    END IF;

    IF p_show_soc_security = 'Y' THEN

       l_step := 13;
       hr_utility.set_location(g_package || l_procedure_name, 130);

       /*  Legal Employer social security Quota details */

       FOR m IN 1 .. le_soc_sec_det_tab.COUNT
       LOOP
         insert_xml_plsql_table( p_xml_data,'LE_SOCIAL_SECURITY_QUOTA',
                                 NULL,'T','C');
         insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_INS',
                                 le_soc_sec_det_tab(m).balance_name,'D','C');
         insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_INS_EE_CTD',
                                 le_soc_sec_det_tab(m).soc_sec_quo_ee_ctd,
                                 'D','B');
         insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_INS_ER_CTD',
                                 le_soc_sec_det_tab(m).soc_sec_quo_er_ctd,
                                 'D','B');

         IF p_dimension <> 'CTD' THEN

            insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_INS_EE_DTD',
                                    le_soc_sec_det_tab(m).soc_sec_quo_ee_dtd,
                                    'D','B');
            insert_xml_plsql_table( p_xml_data,'LE_SOC_SEC_INS_ER_DTD',
                                    le_soc_sec_det_tab(m).soc_sec_quo_er_dtd,
                                    'D','B');

         END IF;

         insert_xml_plsql_table( p_xml_data,'/LE_SOCIAL_SECURITY_QUOTA',
                                 NULL,'T','C');
       END loop;

    END IF;

    insert_xml_plsql_table( p_xml_data,'/LEGAL_EMPLOYER_TOTAL',NULL,'T','C');
    insert_xml_plsql_table( p_xml_data,'/TRR',NULL,'T','C');

    dbg('Exiting Populate plsql table.........');

    EXCEPTION
     when others THEN
       l_error_message := 'Error at step ' || l_step || ' IN ' ||
                            g_package || l_procedure_name;
       dbg(l_error_message || '-' || sqlerrm);
       hr_utility.raise_error;

  END populate_plsql_table ;

  /*****************************************************************************
   Name      : convert_into_xml
   Purpose   : function to convert the data into an XML String
  *****************************************************************************/

  FUNCTION convert_into_xml( p_name  IN VARCHAR2,
                                 p_value IN VARCHAR2,
                               p_type  IN char)
  RETURN VARCHAR2 IS

    l_convert_data VARCHAR2(250);

  BEGIN

    IF p_type = 'D' THEN

       l_convert_data := '<'||p_name||'>'||p_value||'</'||p_name||'>';

    ELSE

       l_convert_data := '<'||p_name||'>';

    END IF;

    RETURN(l_convert_data);

  END convert_into_xml;


  /*****************************************************************************
   Name      : populate_trr_report
   Purpose   :
  *****************************************************************************/
  PROCEDURE populate_trr_report
           ( errbuf               OUT NOCOPY VARCHAR2,
             retcode              OUT NOCOPY NUMBER,
             p_business_group_id  IN NUMBER,
             p_start_date_earned  IN VARCHAR2,
             p_end_date_earned    IN VARCHAR2,
             p_legal_employer_id  IN NUMBER,
             p_state_code         IN VARCHAR2,
             p_gre_id             IN NUMBER,
             p_show_isr           IN VARCHAR2,
             p_show_soc_security  IN VARCHAR2,
             p_show_state         IN VARCHAR2,
             p_dimension          IN VARCHAR2,
             p_session_date       IN VARCHAR2) IS

     xml_data_table   xml_data;
     l_xml_string     VARCHAR2(250);

     l_procedure_name VARCHAR2(100);
     l_error_message  VARCHAR2(200);
     l_step           NUMBER;
     m                NUMBER;

   BEGIN

      g_package            := 'pay_mx_trr_pkg'  ;
      g_debug_flag         := 'Y' ;

--      g_concurrent_flag    := 'Y' ;

      l_procedure_name     := '.populate_trr_report';
      dbg('Entering Populate TRR Report .........');

      dbg('Parameters');
      dbg('Business Group Id     : '||p_business_group_id);
      dbg('Starting Date Earned  : '||p_start_date_earned);
      dbg('Ending Date Date      : '||p_end_date_earned);
      dbg('Legal Employer Id     : '||p_legal_employer_id);
      dbg('State                 : '||p_state_code);
      dbg('Gre Id                : '||p_gre_id);
      dbg('ISR Tax               : '||p_show_isr);
      dbg('Social Security Tax   : '||p_show_soc_security);
      dbg('State Tax             : '||p_show_state);
      dbg('Dimension             : '||p_dimension);
      dbg('Session Date          : '||p_session_date);

      insert into fnd_sessions
      (session_id, effective_date)
       SELECT userenv('sessionid'),fnd_date.canonical_to_date(p_session_date)
       FROM sys.dual
       WHERE not exists
        (SELECT 1
           FROM   fnd_sessions fs
           WHERE  fs.session_id = userenv('sessionid')) ;

      l_step := 1;
      hr_utility.set_location(g_package || l_procedure_name, 10);
      dbg('Calling Populate plsql table');

      populate_plsql_table(fnd_date.canonical_to_date(p_start_date_earned) ,
                           fnd_date.canonical_to_date(p_end_date_earned)   ,
                           p_legal_employer_id  ,
                           p_state_code         ,
                           p_gre_id             ,
                           p_show_isr           ,
                           p_show_soc_security  ,
                           p_show_state         ,
                           p_dimension          ,
                           p_business_group_id  ,
                           xml_data_table );

      dbg('After Populate PlSql table procedure');

      l_step := 2;
      hr_utility.set_location(g_package || l_procedure_name, 20);

      dbg('The total records IN PLsql Table is  '||xml_data_table.count);

      FOR m IN 1 ..xml_data_table.COUNT LOOP

          dbg(xml_data_table(m).tag_name ||' '||
                xml_data_table(m).tag_type||' '||xml_data_table(m).tag_value);

      END LOOP;

      -- Write XML header line
      dbg('Write XML header line');

      l_step := 3;
      hr_utility.set_location(g_package || l_procedure_name, 30);

      -- FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0" encoding="UTF-8" ?>');

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0" encoding="' ||
                                 hr_mx_utility.get_IANA_charset || '"?>' ) ;

      l_step := 4;
      hr_utility.set_location(g_package || l_procedure_name, 40);

      -- Write XML data FROM plsql table
      dbg('Convert AND Write XML data IN the output file');

      FOR l IN 1 .. xml_data_table.COUNT
      LOOP

        l_xml_string := convert_into_xml(xml_data_table(l).tag_name,
                                         xml_data_table(l).tag_value,
                                         xml_data_table(l).tag_type);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_xml_string);

      END LOOP ;


      l_step := 5;
      hr_utility.set_location(g_package || l_procedure_name, 50);

      dbg('cleaning up the plsql table');

      xml_data_table.delete;

      dbg('Exiting Populate TRR Report .........');

  END populate_trr_report ; --End for the Procedure Body populate_trr_report


  /*****************************************************************************
   Name      : trr_report_wrapper
   Purpose   :
  *****************************************************************************/
  PROCEDURE trr_report_wrapper
                  (  errbuf                OUT NOCOPY VARCHAR2,
                     retcode               OUT NOCOPY NUMBER,
                     p_business_group_id   IN NUMBER,
                     p_start_date_earned   IN VARCHAR2,
                     p_end_date_earned     IN VARCHAR2,
                     p_legal_employer_id   IN NUMBER,
                     p_state_code          IN VARCHAR2,
                     p_gre_id              IN NUMBER,
                     p_show_isr            IN VARCHAR2,
                     p_show_soc_security   IN VARCHAR2,
                     p_show_state          IN VARCHAR2,
                     p_dimension           IN VARCHAR2,
                     p_template            IN VARCHAR2,
                     p_template_locale     IN VARCHAR2,
                     p_session_date        IN VARCHAR2
                 ) IS

     l_req_id        NUMBER;
     l_req_id2       NUMBER;
     l_program       VARCHAR2(100);
     l_err_msg       VARCHAR2(240);
     l_wait_outcome  BOOLEAN;
     l_phase         VARCHAR2(80);
     l_status        VARCHAR2(80);
     l_dev_phase     VARCHAR2(80);
     l_dev_status    VARCHAR2(80);
     l_message       VARCHAR2(80);
     l_errbuf        VARCHAR2(240);

     l_procedure_name        VARCHAR2(100);
     l_error_message         VARCHAR2(200);
     l_step                  NUMBER;

/* adding a new variable. */
     l_arg1_result VARCHAR2(10);
     l_arg7_result VARCHAR2(10);

    CURSOR get_l_arg1_result IS
    SELECT XDO_CP_DATA_SECURITY_PKG.GET_CONCURRENT_REQUEST_IDS FROM DUAL;

    CURSOR get_l_arg7_result IS
    select template_type_code from xdo_templates_vl where template_code = p_template and application_short_name = (select application_short_name from fnd_application_vl where application_id = 801);

    BEGIN

      g_package            := 'pay_mx_trr_pkg'  ;

      g_debug_flag          := 'Y' ;
--      g_concurrent_flag     := 'Y' ;

      l_procedure_name     := '.trr_report_wrapper';

      dbg('Entering TRR Report wrapper.........');
      dbg('Parameters');
      dbg('Business Group Id     : '||p_business_group_id);
      dbg('Starting Date Earned  : '||p_start_date_earned);
      dbg('Ending Date Date      : '||p_end_date_earned);
      dbg('Legal Employer Id     : '||p_legal_employer_id);
      dbg('State                 : '||p_state_code);
      dbg('Gre Id                : '||p_gre_id);
      dbg('ISR Tax               : '||p_show_isr);
      dbg('Social Security Tax   : '||p_show_soc_security);
      dbg('State Tax             : '||p_show_state);
      dbg('Dimension             : '||p_dimension);
      dbg('Template              : '||p_template);
      dbg('Template Locale       : '||p_template_locale);
      dbg('Session Date          : '||p_session_date);

      dbg('Submitting concurrent request for Payroll Tax Remittance Report');

      l_step := 1;
      hr_utility.set_location(g_package || l_procedure_name, 10);

      l_program := 'PYMXTRRXML';
      l_req_id := Fnd_request.submit_request(
                    application    => 'PAY',
                    program        => l_program,
                    argument1      => p_business_group_id,
                    argument2      => p_start_date_earned,
                    argument3      => p_end_date_earned,
                    argument4      => p_legal_employer_id,
                    argument5      => p_state_code,
                    argument6      => p_gre_id,
                    argument7      => p_show_isr,
                    argument8      => p_show_soc_security,
                    argument9      => p_show_state,
                    argument10     => p_dimension,
                    argument11     => p_session_date );

     dbg('Request Id for Payroll Tax Remittance Report is '||l_req_id);

     If l_req_id = 0 THEN

        fnd_message.retrieve(l_errbuf);
        dbg('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
        hr_utility.raise_error;

     ELSE

        dbg('Waiting for the First Request to get complete');
        COMMIT;
        dbg('Commited the First Request');

        l_step := 2;
        hr_utility.set_location(g_package || l_procedure_name, 20);

        l_wait_outcome := fnd_concurrent.WAIT_FOR_REQUEST(
                             request_id     => l_req_id,
                             interval       => 15,
                             max_wait       => 2400,  -- 180,
                             phase          => l_phase,
                             status         => l_status,
                             dev_phase      => l_dev_phase,
                             dev_status     => l_dev_status,
                             message        => l_message);
     END IF;

     dbg('status is '||l_status);
     dbg('The status of Development Phase is '||l_dev_phase);
     dbg('dev status is '||l_dev_status);

    /* argument3 hard coded as 801
       need to take FROM by setting the l_req_id
       SELECT FCP.APPLICATION_ID
       FROM FND_CONCURRENT_PROGRAMS FCP,FND_CONCURRENT_REQUESTS R
       WHERE FCP.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID AND
       R.REQUEST_ID = :$FLEX$.XDO_REPORT_REQUEST_ID
    */

     IF  l_req_id > 0 AND l_dev_phase ='COMPLETE' THEN

         dbg('Submitting XML Report Publisher concurrent request');

         l_step := 3;
         hr_utility.set_location(g_package || l_procedure_name, 30);

         l_program := 'XDOREPPB';

 /* assigning the argument1 value to l_sql_arg1 */
	 OPEN  get_l_arg1_result;
         FETCH get_l_arg1_result INTO l_arg1_result;
         CLOSE get_l_arg1_result;
/* assigning the argument7 value to l_sql_arg7 */
         OPEN  get_l_arg7_result;
         FETCH get_l_arg7_result INTO l_arg7_result;
         CLOSE get_l_arg7_result;

         l_req_id2 := fnd_request.submit_request(
                                  application    => 'XDO',
                                  program        => l_program,
                                  argument1     => l_arg1_result,
				  argument2     => l_req_id,
                                  argument3     => 801, --'PAY',
                                  argument4     => p_template,
                                  argument5     => p_template_locale,
                                  argument6     => 'N',
                                  argument7     => l_arg7_result,
                                  argument8     => 'PDF');
     ELSE

         fnd_message.retrieve(l_errbuf);
         dbg('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);

     END IF;

     IF l_req_id2 > 0 THEN

        Commit;

     ELSE

        fnd_message.retrieve(l_errbuf);
        dbg('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
        -- Will Raise an User Defined Error

     END IF;

  dbg('Exiting TRR Report wrapper.........');

  EXCEPTION
   when others THEN
      l_error_message := 'Error at step ' || l_step || ' IN ' ||
                           g_package || l_procedure_name;
      dbg(l_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  End trr_report_wrapper ; -- End Of Procedure TRR_Report_wrapper

--begin
--hr_utility.trace_on (null, 'MXTRR');

END pay_mx_trr_pkg; -- End Of Package Body

/
