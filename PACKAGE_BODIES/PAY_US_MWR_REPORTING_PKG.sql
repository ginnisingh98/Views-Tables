--------------------------------------------------------
--  DDL for Package Body PAY_US_MWR_REPORTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MWR_REPORTING_PKG" AS
/* $Header: pyusmwrp.pkb 120.3.12010000.3 2009/05/05 06:56:25 swamukhe ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_mwr_reporting_pkg

    Description : Generate Multi Worksite magnetic reports.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No   Description
    ----        ----     ------  -------  -----------
    8-FEB-2001 tclewis   115.0            Created.

    15-nov 2001 tclewis  115.7             Modified the check for
                                           IF l_archive_value = 0 THEN
                                           to also check to see it SIT_Exists
                                           for the jurisdiction (state) as
                                           (as of this time) there are 9 states that
                                           Have no income tax.  Hence, the archive value
                                           will be 0 and they are not included on the
                                           report.

    20-MAY-2002 tclewis  115.10            Modified the code to check the NEW archive items
                                           used for employee counts since Q 1 2002 SQWL's.

    24-DEC-2002 tclewis  115.11             Added NOCOPY 11.5.9 performance fixes.
    21-APR-2002 tclewis  115.12             Removed spectial code for OH and WY
                                            to NOT reducde Sui wages by pre tax.

    29-JAN-2004 ardsouza 115.14  3362257   Added date format mask for GSCC compliance.

    24-JUN-2004 rmonge   115.15  3711795   Added the following condition
                                         'and sta_information_category =
                                          'State tax limit rate info';
                                         to the query that retrieves the SIT tax
                                         exists in the Load_rpt_totals function.
                                         query= select psif.sit_exists
                                          into l_sit_exists...
                                          This query was returning multiple rows and
                                          the Multi Work Site report was failing.
    12-OCT-2004 rmonge   115.16  3909329   Changed/Modified the cursor
                                          'c_derive_wksite_estab due to performance problems.
    12-OCT-2004 rmonge   115.17            No changes.
    15-DEC-2004 rmonge   115.18  4047812   Modified c_derive_wksite_estab due to
                                           performance problems.
   14-MAR-2005 sackumar  115.19  4222032 Change in the Range Cursor removing redundant
							   use of bind Variable (:payroll_action_id)
   18-aug-2005 sackumar  115.20  3613544  changed the c_get_sui_code cursor introduce use_nl hint.

   18-aug-2006 schowta 115.21   5399921  added code fix to include the work at home employee count in load_rpt_totals
  /******************************************************************
  ** Package Local Variables
  ******************************************************************/
  gv_package varchar2(50) := 'pay_us_mwr_reporting_pkg';


  PROCEDURE get_payroll_action_info (
       p_payroll_action_id     in number,
       p_start_date           out NOCOPY date,
       p_end_date             out NOCOPY date,
       p_report_qualifier     out NOCOPY varchar2,
       p_report_type          out NOCOPY varchar2,
       p_report_category      out NOCOPY varchar2,
       p_business_group_id    out NOCOPY number)
  IS

    cursor c_payroll_action(cp_payroll_action_id in number) is
      select ppa.start_date
            ,ppa.effective_date
            ,ppa.business_group_id
            ,ppa.report_qualifier
            ,ppa.report_type
            ,ppa.report_category
            ,ppa.legislative_parameters
       from pay_payroll_actions ppa
      where payroll_action_id = cp_payroll_action_id;

    ld_start_date           DATE;
    ld_end_date             DATE;
    ln_business_group_id    NUMBER;
    lv_report_qualifier     VARCHAR2(30);
    lv_report_type          VARCHAR2(30);
    lv_report_category      VARCHAR2(30);
    lv_leg_parameter        VARCHAR2(300);

  BEGIN
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 10);

    open c_payroll_action(p_payroll_action_id);
    fetch c_payroll_action into
            ld_start_date, ld_end_date, ln_business_group_id,
            lv_report_qualifier, lv_report_type,
            lv_report_category, lv_leg_parameter;
    if c_payroll_action%notfound then
       hr_utility.set_location( gv_package || '.get_payroll_action_info',20);
       hr_utility.raise_error;
    end if;
    close c_payroll_action;
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 30);


    hr_utility.set_location(gv_package || '.get_payroll_action_info', 60);
    p_start_date           := ld_start_date;
    p_end_date             := ld_end_date;
    p_report_qualifier     := lv_report_qualifier;
    p_report_type          := lv_report_type;
    p_report_category      := lv_report_category;
    p_business_group_id    := ln_business_group_id;

    hr_utility.set_location(gv_package || '.get_payroll_action_info', 100);

  EXCEPTION
     WHEN OTHERS THEN
        p_start_date           := NULL;
        p_end_date             := NULL;
        p_report_qualifier     := NULL;
        p_report_type          := NULL;
        p_report_category      := NULL;
        p_business_group_id    := NULL;

  END get_payroll_action_info;


  /********************************************************
  ** Range Code: Multi Threading
  ********************************************************/
  PROCEDURE range_cursor ( p_payroll_action_id  in number
                          ,p_sql_string         out NOCOPY varchar2)
  IS

    lv_sql_string  varchar2(10000);

    ld_start_date           DATE;
    ld_end_date             DATE;
    ln_business_group_id    NUMBER;
    lv_report_qualifier     VARCHAR2(30);
    lv_report_type          VARCHAR2(30);
    lv_report_category      VARCHAR2(30);

    ln_tax_unit_id          NUMBER;
    ln_payroll_id           NUMBER;
    ln_consolidation_set_id NUMBER;

  BEGIN
    hr_utility.set_location(gv_package || '.range_code', 10);
    get_payroll_action_info (
             p_payroll_action_id
            ,ld_start_date
            ,ld_end_date
            ,lv_report_qualifier
            ,lv_report_type
            ,lv_report_category
            ,ln_business_group_id);
    hr_utility.set_location(gv_package || '.range_code', 20);

    lv_sql_string :=
        'select distinct paa.assignment_id
            from pay_assignment_actions  paa  -- SQWL assignment action
            , pay_payroll_actions   ppa
         where ppa.business_group_id  = ' || ln_business_group_id || '
           and  ppa.effective_date between to_date(''' || to_char(ld_start_date, 'dd-mon-yyyy')   || ''', ''dd-mon-yyyy'') --Bug 3362257
                                       and to_date(''' || to_char(ld_end_date, 'dd-mon-yyyy')   || ''', ''dd-mon-yyyy'') --Bug 3362257
           and ppa.action_type = ''X''
           and   ppa.report_type = ''SQWL''
           and ppa.action_status =''C''
           and ppa.payroll_action_id = paa.payroll_action_id
           and :payroll_action_id is not null
           order by paa.assignment_id
         ';

    p_sql_string := lv_sql_string;
    hr_utility.set_location(gv_package || '.range_code', 50);

  END range_cursor;

 /********************************************************
  ** Action Creation Code: Multi Threading
  ********************************************************/
  PROCEDURE action_creation( p_payroll_action_id in number
                            ,p_start_assignment  in number
                            ,p_end_assignment    in number
                            ,p_chunk             in number)

  IS

   cursor c_get_mwr_asg( cp_business_group_id    in number
                        ,cp_start_date           in date
                        ,cp_end_date             in date
                        ,cp_start_assignment_id  in number
                        ,cp_end_assignment_id    in number
                       ) is
        select paa.assignment_id,
               ppa.effective_date,
               paa.tax_unit_id,
               paa.assignment_action_id
            from pay_assignment_actions  paa  -- SQWL assignment action
            , pay_payroll_actions   ppa
         where ppa.business_group_id  = cp_business_group_id
           and  ppa.effective_date between cp_start_date
                                       and cp_end_date
           and ppa.action_type = 'X'
           and   ppa.report_type = 'SQWL'
           and ppa.action_status ='C'
           and ppa.payroll_action_id = paa.payroll_action_id
           and paa.assignment_id between cp_start_assignment_id
                                 and cp_end_assignment_id;

    ld_start_date           DATE;
    ld_end_date             DATE;
    ln_business_group_id    NUMBER;
    lv_report_qualifier     VARCHAR2(30);
    lv_report_type          VARCHAR2(30);
    lv_report_category      VARCHAR2(30);
    ln_tax_unit_id          NUMBER;
    ln_payroll_id           NUMBER;
    ln_consolidation_set_id NUMBER;

    /* Assignment Record Local Variables */
    ln_assignment_id        NUMBER;
    ld_effective_date       DATE;
    ln_emp_tax_unit_id      NUMBER;
    ln_assignment_action_id NUMBER;

    ln_locking_action_id    NUMBER;

  BEGIN
    hr_utility.set_location(gv_package || '.action_creation', 10);
    get_payroll_action_info (
             p_payroll_action_id
            ,ld_start_date
            ,ld_end_date
            ,lv_report_qualifier
            ,lv_report_type
            ,lv_report_category
            ,ln_business_group_id);

    hr_utility.set_location(gv_package || '.action_creation', 20);
    open c_get_mwr_asg( ln_business_group_id
                       ,ld_start_date
                       ,ld_end_date
                       ,p_start_assignment
                       ,p_end_assignment);
    loop
      hr_utility.set_location(gv_package || '.action_creation', 30);
      fetch c_get_mwr_asg into ln_assignment_id, ld_effective_date,
                               ln_emp_tax_unit_id, ln_assignment_action_id;
      if c_get_mwr_asg%notfound then
         hr_utility.set_location(gv_package || '.action_creation', 40);
         exit;
      end if;

      hr_utility.set_location(gv_package || '.action_creation', 50);
      select pay_assignment_actions_s.nextval
        into ln_locking_action_id
        from dual;

--  **** CHECK FOR SUI WAGES HERE **** ----

      -- insert into pay_assignment_actions.
      hr_nonrun_asact.insact(ln_locking_action_id, ln_assignment_id,
                             p_payroll_action_id, p_chunk, ln_emp_tax_unit_id);
      hr_utility.set_location(gv_package || '.action_creation', 60);

      -- insert an interlock to this action
      hr_nonrun_asact.insint(ln_locking_action_id, ln_assignment_action_id);

      update pay_assignment_actions paa
         set paa.serial_number = ln_assignment_action_id
       where paa.assignment_action_id = ln_locking_action_id;

      hr_utility.set_location(gv_package || '.action_creation', 60);
    end loop;
    close c_get_mwr_asg;

    hr_utility.set_location(gv_package || '.action_creation', 60);
  END action_creation;



  FUNCTION LOAD_RPT_TOTALS( p_payroll_action_id  in number)
    RETURN number
  IS

   CURSOR get_pact_asg IS
      SELECT paa.assignment_id
           ,paa.tax_unit_id
           ,paa.serial_number
           ,ppa.business_group_id
      FROM  pay_payroll_actions    ppa,
            pay_assignment_actions paa
      WHERE ppa.payroll_action_id = p_payroll_action_id
      AND   ppa.payroll_action_id = paa.payroll_action_id;

   CURSOR c_asg_loc_mon ( p_ass_act_id   number
                         ,p_mon_of_qtr   number) IS
   SELECT fai.value,
          pus.state_code || '-000-0000',
          pus.state_abbrev
   FROM   ff_archive_items fai
         ,ff_user_entities ue
         ,pay_us_states pus
         ,hr_locations  hl
   where fai.user_entity_id = ue.user_entity_id
   and fai.context1 = to_char(p_ass_act_id)  -- context of assignment action id
   and ue.user_entity_name =
         decode(p_mon_of_qtr,4,'A_SQWL_LOC_QTR_END','A_SQWL_LOC_MON_' || to_char(p_mon_of_qtr))
   and fai.value = hl.location_id
   and hl.region_2 = pus.state_abbrev;

  CURSOR c_get_sui_code ( p_tax_unit_id number,
                          p_jurisdiction varchar2 ) IS
    SELECT /*+ use_nl (hoi1, hoi2)*/
           hoi1.org_information2,
           hoi2.org_information1
    FROM   pay_state_rules SR,
           hr_organization_information hoi1,
           hr_organization_information hoi2
    WHERE hoi1.organization_id = p_tax_unit_id
    AND hoi1.org_information_context = 'State Tax Rules'
    AND hoi1.org_information1 = SR.state_code
    AND SR.jurisdiction_code = substr(p_jurisdiction,1,2)||'-000-0000'
    AND hoi2.organization_id = hoi1.organization_id
    AND hoi2.org_information_context = 'Employer Identification' ;

   CURSOR c_get_sui_subject ( p_ass_act_id        number,
                            p_user_entity_id    number,
                            p_tax_unit_id       number,
                            P_jurisdiction_code varchar2
                           ) IS
         SELECT fai.value
         FROM   ff_archive_item_contexts con3,
                ff_archive_item_contexts con2,
                ff_contexts fc3,
                ff_contexts fc2,
                ff_archive_items fai
         WHERE fai.user_entity_id = p_user_entity_id
         and   fai.context1 = to_char(p_ass_act_id)
	  	   /* context assignment action id */
         and fc2.context_name = 'TAX_UNIT_ID'
         and con2.archive_item_id = fai.archive_item_id
         and con2.context_id = fc2.context_id
         and ltrim(rtrim(con2.context)) = to_char(p_tax_unit_id)
		   /* 2nd context of tax_unit_id */
         and fc3.context_name = 'JURISDICTION_CODE'
         and con3.archive_item_id = fai.archive_item_id
         and con3.context_id = fc3.context_id
         and substr(con3.context,1,2) = substr(p_jurisdiction_code,1,2)
             /* 3rd context of state jurisdiction_code*/;


/*
 CURSOR c_derive_wksite_estab (p_payroll_action_id number,
                                 p_est_hierarchy_id  number,
                                 p_hierarchy_ver_id  number,
                                 p_location_id       number) IS
      SELECT pghn2.entity_id
      FROM  per_gen_hierarchy pgh
           ,per_gen_hierarchy_versions pghv
           ,per_gen_hierarchy_nodes    pghn2  -- establishment organizations
           ,pay_payroll_actions        ppa
      where ppa.payroll_action_id = p_payroll_action_id
      and   pgh.hierarchy_id = p_est_hierarchy_id
      and   pgh.business_group_id = ppa.business_group_id
      and   pgh.hierarchy_id = pghv.hierarchy_id
      and   pghv.HIERARCHY_VERSION_id = p_hierarchy_ver_id
      and   pghv.hierarchy_version_id = pghn2.hierarchy_version_id
      and  ( ( pghn2.node_type            = 'EST'
               and pghn2.entity_id             = p_location_id
              )
      OR
             ( pghn2.node_type            = 'EST'
               AND p_location_id in
                    ( SELECT pghn3.entity_id
                      FROM   per_gen_hierarchy_nodes pghn3
                      WHERE  pghn3.node_type = 'LOC'
                      AND    pghn3.hierarchy_version_id = pghv.HIERARCHY_VERSION_id
                      AND    pghn3.parent_hierarchy_node_id = pghn2.hierarchy_node_id
                     )
              )
            );

*/

/* rmonge 15-DEC-2004 */
/* Performance bug 4047812 */
/* Changed subquery to use index and also changed p_hierarchy_ver_id */
/* to pghn2.hierarchy_version_id                                     */

CURSOR c_derive_wksite_estab (p_hierarchy_ver_id  number,
                                 p_location_id       number) IS
      SELECT pghn2.entity_id
      FROM  per_gen_hierarchy_nodes    pghn2  -- establishment organizations

      where p_hierarchy_ver_id = pghn2.hierarchy_version_id
      and  ( ( pghn2.node_type            = 'EST'
               and pghn2.entity_id             = p_location_id
              )
      OR
             ( pghn2.node_type            = 'EST'
               AND p_location_id in
                    ( SELECT /*+ pghn3 PER_GEN_HIER_NOD_VER_N4 */ pghn3.entity_id
                      FROM   per_gen_hierarchy_nodes pghn3
                      WHERE  pghn3.node_type = 'LOC'
                      AND    pghn3.hierarchy_version_id =
                             pghn2.hierarchy_version_id      --p_hierarchy_ver_id
                      AND    pghn3.parent_hierarchy_node_id =
                             pghn2.hierarchy_node_id
                     )
              )
            );



CURSOR  c_get_sqwl_month_count ( cp_sqwl_assact in number,
                                 cp_month_of_quarter in number)
IS

select fai.value,
       ppa.report_qualifier
from ff_archive_items fai,
     ff_user_entities ue,
     pay_assignment_actions paa,
     pay_payroll_actions ppa
where fai.context1 = cp_sqwl_assact
and   paa.assignment_action_id = fai.context1
and   fai.user_entity_id       = ue.user_entity_id
and   ue.user_entity_name     = 'A_SQWL_MONTH' || to_char(cp_month_of_quarter) || '_COUNT'
and   ppa.payroll_action_id    = paa.payroll_action_id ;

    l_month_count_state_code varchar2(2);
    l_est_hierarchy_id   number;
    l_hierarchy_ver_id   number;
    l_ass_id            number;
    l_sqwl_assact       number;
    l_business_group_id number;
    v_session_id        number;
    l_location_id       number;
    l_jurisdiction      varchar2(11);
    l_sqwl_jurisdiction_code varchar2(11);
    l_wage_jurisdiction_code varchar2(11);
    l_state_abbrev      varchar2(2);
    l_estab_loc_id      number;
    l_archive_value     number;
    l_sit_exists        varchar2(1);
    l_user_entity_id    number;
    l_tax_unit_id       number;
    l_sui_id            varchar2(50);
    l_fed_ein           varchar2(50);
    l_worksite          number;
    l_ppa_legislative_parameters   varchar2(2000);
    l_procedure         varchar2(15) := 'load_rpt_totals';

    FUNCTION calc_sui_reductions ( p_sqwl_assact  in number
                                  ,p_tax_unit_id  in number
                                  ,p_jurisdiction in varchar2)
    RETURN number
    IS

       CURSOR c_get_sui_reds  ( cp_ass_act_id        number,
                                cp_user_entity_id    number,
                                cp_tax_unit_id       number,
                                cp_jurisdiction_code varchar2
                               ) IS
         SELECT fai.value
         FROM   ff_archive_item_contexts con3,
                ff_archive_item_contexts con2,
                ff_contexts fc3,
                ff_contexts fc2,
                ff_archive_items fai
         WHERE fai.user_entity_id = cp_user_entity_id
         and   fai.context1 = to_char(cp_ass_act_id)
	  	   /* context assignment action id */
         and fc2.context_name = 'TAX_UNIT_ID'
         and con2.archive_item_id = fai.archive_item_id
         and con2.context_id = fc2.context_id
         and ltrim(rtrim(con2.context)) = to_char(cp_tax_unit_id)
		   /* 2nd context of tax_unit_id */
         and fc3.context_name = 'JURISDICTION_CODE'
         and con3.archive_item_id = fai.archive_item_id
         and con3.context_id = fc3.context_id
         and substr(con3.context,1,2) = substr(cp_jurisdiction_code,1,2)
             /* 3rd context of state jurisdiction_code*/;

       l_sui_total_reductions    number;
       l_user_entity_id          number;
    BEGIN

       SELECT fue.user_entity_id
       INTO   l_user_entity_id
       FROM   ff_user_entities fue
       WHERE  fue.user_entity_name = 'A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD'
       AND    fue.legislation_code = 'US';

       OPEN c_get_sui_reds( p_sqwl_assact
                           ,l_user_entity_id
                           ,p_tax_unit_id
                           ,p_jurisdiction);

       FETCH c_get_sui_reds INTO l_sui_total_reductions;

       IF c_get_sui_reds%NOTFOUND THEN
          l_sui_total_reductions :=0;
       END IF;

       CLOSE c_get_sui_reds;

       return(l_sui_total_reductions);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RETURN(0);
   END calc_sui_reductions;



  BEGIN

    hr_utility.set_location(gv_package || '.' || l_procedure , 10);

  --get the session id
    SELECT userenv('sessionid')
    INTO v_session_id
    FROM dual;

  --get the hierarchy version and establishment from legislative paramters
    SELECT ppa.legislative_parameters
    INTO   l_ppa_legislative_parameters
    FROM   pay_payroll_actions ppa
    where  ppa.payroll_action_id = p_payroll_action_id;

    hr_utility.set_location(gv_package || '.' || l_procedure , 20);

    l_est_hierarchy_id :=
                   to_number(pay_mag_utils.get_parameter('TRANSFER_HIERARCHY_ID'
                                                ,'TRANSFER_HIERARCHY_VERSION'
                                                ,l_ppa_legislative_parameters));
    l_hierarchy_ver_id :=
                   pay_mag_utils.get_parameter('TRANSFER_HIERARCHY_VERSION'
                                                ,''
                                                ,l_ppa_legislative_parameters);

    hr_utility.set_location(gv_package || '.' || l_procedure , 30);

  -- cusror loop.
  OPEN   get_pact_asg;

  FETCH get_pact_asg into l_ass_id, l_tax_unit_id, l_sqwl_assact, l_business_group_id;

  WHILE get_pact_asg%FOUND LOOP

     hr_utility.set_location(gv_package || '.' || l_procedure , 40);

     FOR i IN 1 .. 4 LOOP

        OPEN c_asg_loc_mon(l_sqwl_assact,
                           i);
        Fetch c_asg_loc_mon into l_location_id, l_jurisdiction, l_state_abbrev;
        IF c_asg_loc_mon%NOTFOUND THEN
           CLOSE c_asg_loc_mon;
           l_location_id := NULL;
           l_jurisdiction := NULL;
           l_state_abbrev := NULL;
        ELSE
           CLOSE C_ASG_LOC_MON;
           l_sit_exists := 'Y';
           l_wage_jurisdiction_code := l_jurisdiction;

           hr_utility.set_location(gv_package || '.' || l_procedure , 50);

        -- get the sui ID for the SQWL assignment action
           OPEN c_get_sui_code( l_tax_unit_id, l_jurisdiction );

           FETCH c_get_sui_code into l_sui_id, l_fed_ein;

           IF c_get_sui_code%NOTFOUND THEN
              l_sui_ID := lpad(' ',50,0);
              l_fed_ein := lpad(' ',50,0);
           END IF;
           CLOSE c_get_sui_code;

         -- get the user_entity_id for the 'A_SIT_GROSS_PER_JD_GRE_MON_*' DBI
           IF i < 4 THEN
              SELECT ue.user_entity_id
              INTO   l_user_entity_id
              FROM   ff_user_entities ue
              WHERE  ue.user_entity_name = 'A_SIT_GROSS_PER_JD_GRE_MON_' || to_char(i)
              AND    ue.legislation_code = 'US';
           ELSE
              SELECT ue.user_entity_id
              INTO   l_user_entity_id
              FROM   ff_user_entities ue
              WHERE  ue.user_entity_name = 'A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD'
              AND    ue.legislation_code = 'US';
           END IF;

            -- As of Q 1 2002 we no longer archive the A_SIT_GROSS_PER_JD_GRE_MON*
            -- data (used for month counts in the sqwl).  We will not archive a new
            -- Datat base item named A_SQWL_MONTH*_COUNT (where * is 1, 2, 3).
            -- need to check for the existance of the NEW DBI first and if not
            -- found revert back to the old DBI's (this is for re-runs of Multiple
            -- work site report prior to Q 1 2002).  For a 1 thru 4 loop we will still
            -- fetch the A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD which stores the quarterly
            -- wages.

            OPEN  c_get_sqwl_month_count ( l_sqwl_assact,
                                           i );

            FETCH c_get_sqwl_month_count
            INTO  l_archive_value,
                  l_month_count_state_code;

            IF c_get_sqwl_month_count%NOTFOUND THEN

               close c_get_sqwl_month_count;

               -- get the value for the A_SIT_GROSS_PER_JD_GRE_MON_* archive item.

               hr_utility.set_location(gv_package || '.' || l_procedure , 60);
               OPEN c_get_sui_subject ( l_sqwl_assact
                                     ,l_user_entity_id
                                     ,l_tax_unit_id
                                     ,l_jurisdiction);

               FETCH c_get_sui_subject into l_archive_value;

               IF c_get_sui_subject%NOTFOUND THEN
               -- If get sit_gross is not found then need to check the jurisdiction
               -- of the SQWL assignment action.
                  CLOSE c_get_sui_subject;

                  BEGIN
                     SELECT psr.jurisdiction_code
                     INTO l_sqwl_jurisdiction_code
                     FROM pay_assignment_actions paa,
                          pay_payroll_actions    ppa,
                          pay_state_rules        psr
                     WHERE paa.assignment_action_id = l_sqwl_assact
                     AND   ppa.payroll_action_id    = paa.payroll_action_id
                     AND   psr.state_code = ppa.report_qualifier;

                     l_wage_jurisdiction_code := l_sqwl_jurisdiction_code;

                     OPEN c_get_sui_subject ( l_sqwl_assact
                                           ,l_user_entity_id
                                           ,l_tax_unit_id
                                           ,l_sqwl_jurisdiction_code);

                     FETCH c_get_sui_subject into l_archive_value;

                     IF c_get_sui_subject%NOTFOUND THEN
                        l_archive_value := 0;
                        CLOSE c_get_sui_subject;
                     ELSE
                     --  if we've gotten this far, then wages are in a different state
                     --  than assignment work location.  Need to set the l_location_id
                     --  to -99999 and the l_state_code to the state of the l_sqwl_jurisdiction

                        l_location_id := -99999;

                        SELECT report_qualifier
                        INTO   l_state_abbrev
                        FROM   pay_assignment_actions paa,
                               pay_payroll_actions   ppa
                        WHERE  ppa.payroll_action_id = paa.payroll_action_id
                        AND    paa.assignment_action_id =  l_sqwl_assact;

                        CLOSE c_get_sui_subject;

                     -- also need to point the SUI id to the of the state where wages were paid
                     -- verses the sui id of the assignment location state.

                         SELECT hoi1.org_information2
                         INTO   l_sui_id
                         FROM   pay_state_rules SR,
                                hr_organization_information hoi1
                         WHERE hoi1.organization_id = l_tax_unit_id
                         AND hoi1.org_information_context = 'State Tax Rules'
                         AND hoi1.org_information1 = SR.state_code
                         AND SR.jurisdiction_code =
                                  substr(l_sqwl_jurisdiction_code,1,2)||'-000-0000';

                     END IF;

                  EXCEPTION when NO_DATA_FOUND THEN

                     l_archive_value := 0;
                  END;
               ELSE
                  CLOSE c_get_sui_subject;

               END IF;

               -- Need to see it SIT exists in the state where we just retrived
               -- the archive value, as there are 9 states that have no SIT and
               -- the arcive value will be 0.  They must still be counted on
               -- the report.
                l_sit_exists := 'Y';

                Select psif.sit_exists
                into   l_sit_exists
                from pay_us_state_tax_info_f psif,
                     pay_payroll_actions ppa
               where ppa.payroll_action_id = p_payroll_action_id
               and psif.state_code = substr(l_jurisdiction,1,2)
               and ppa.effective_date
                  BETWEEN psif.effective_start_date AND psif.effective_end_date
               and sta_information_category = 'State tax limit rate info';

            ELSE
            -- compare the state code retured from the c_get_sqwl_month_count
            -- to the state code of the locations ID, if = then fine, else
            -- change the jurisdiction_code to that of the state that is
            -- returned in the c_get_sqwl_month_cursor.

               close c_get_sqwl_month_count;

               l_sit_exists := 'Y';

               IF l_state_abbrev = l_month_count_state_code THEN
                  NULL;
               ELSE

		-- Bug fix 5399921 START

                    SELECT psr.jurisdiction_code
                     INTO l_sqwl_jurisdiction_code
                     FROM pay_assignment_actions paa,
                          pay_payroll_actions    ppa,
                          pay_state_rules        psr
                     WHERE paa.assignment_action_id = l_sqwl_assact
                     AND   ppa.payroll_action_id    = paa.payroll_action_id
                     AND   psr.state_code = ppa.report_qualifier;

                        SELECT hoi1.org_information2
                         INTO   l_sui_id
                         FROM   pay_state_rules SR,
                                hr_organization_information hoi1
                          WHERE hoi1.organization_id = l_tax_unit_id
                          AND hoi1.org_information_context = 'State Tax Rules'
                          AND hoi1.org_information1 = SR.state_code
                         AND SR.jurisdiction_code = substr(l_sqwl_jurisdiction_code,1,2)||'-000-0000';

                   -- Bug fix 5399921 End

                  l_location_id := -99999;
                  l_state_abbrev := l_month_count_state_code;
               END IF;

            END IF;  -- if c_get_sqwl_month_count%NOT FOUND

           -- If I've gotten this far then I know location_id is not null.
           IF l_archive_value <> 0 OR
              (l_sit_exists = 'N' and
               l_jurisdiction is not NULL ) THEN

           /* if i = 4 we are getting the sui wages  All states report reduced SUI
               subject wages using the formula

               SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD -
               SUI_ER_125_REDNS_PER_JD_GRE_QTD -
               SUI_ER_401_REDNS_PER_JD_GRE_QTD -
               SUI_ER_DEP_CARE_REDNS_PER_JD_GRE_QTD

               except Ohio State_abbrev 'OH'  and Wyoming State_abbrev 'OH'
               which use SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD
           */
              IF i = 4
                /* bug 2914661 and
                 l_state_abbrev <> 'OH' and
                 l_state_abbrev <> 'WY'*/
                THEN
                 l_archive_value := l_archive_value -
                                   calc_sui_reductions ( l_sqwl_assact
                                                        ,l_tax_unit_id
                                                        ,l_wage_jurisdiction_code);
              END IF;


           -- derive the establishment
              hr_utility.set_location(gv_package || '.' || l_procedure , 70);

              IF l_location_id <> -99999 THEN
                 OPEN c_derive_wksite_estab( l_hierarchy_ver_id,
                                            l_location_id);

                 FETCH c_derive_wksite_estab into l_worksite;

                 IF c_derive_wksite_estab%NOTFOUND THEN
                    l_worksite := -99999;
                 END IF;

                 CLOSE c_derive_wksite_estab;
              ELSE
                 l_worksite := -99999;
              END IF;

           -- Write the us_rpt_totals record
             hr_utility.set_location(gv_package || '.' || l_procedure , 80);

              IF i = 1 THEN      -- UPDATING / INSERTING into column value1
              hr_utility.set_location(gv_package || '.' || l_procedure , 90);
              UPDATE pay_us_rpt_totals prt
              SET prt.value1 = NVL(prt.value1,0) + 1
              WHERE prt.session_id  = v_session_id
              AND   prt.organization_id = p_payroll_action_id
              AND   prt.location_id = l_worksite
              AND   prt.state_abbrev  = l_state_abbrev
              AND   prt.attribute1  = 'MWS_EST'
              and   prt.attribute2  = l_sui_id
              and   prt.attribute3  = l_fed_ein;

                 IF SQL%ROWCOUNT = 0 THEN  --- Row doesn't exist in table must insert.
                    hr_utility.set_location(gv_package || '.' || l_procedure , 100);

                    INSERT into pay_us_rpt_totals
                    ( session_id
                     ,organization_id
                     ,location_id
                     ,state_abbrev
                     ,attribute1
                     ,attribute2
                     ,attribute3
                     ,value1)
                     VALUES
                     ( v_session_id
                      ,p_payroll_action_id
                      ,l_worksite
                      ,l_state_abbrev
                      ,'MWS_EST'
                      ,l_sui_id
                      ,l_fed_ein
                      ,1);
                 END IF;
              ELSIF i = 2 THEN -- UPDATING / INSERTING into Column value2
                hr_utility.set_location(gv_package || '.' || l_procedure , 110);
                UPDATE pay_us_rpt_totals prt
                 SET prt.value2 = NVL(prt.value2,0) + 1
                 WHERE prt.session_id  = v_session_id
                 AND   prt.organization_id = p_payroll_action_id
                 AND   prt.location_id = l_worksite
                 AND   prt.state_abbrev  = l_state_abbrev
                 AND   prt.attribute1  = 'MWS_EST'
                 and   prt.attribute2  = l_sui_id
                 and   prt.attribute3  = l_fed_ein;

                 IF SQL%ROWCOUNT = 0 THEN  --- Row doesn't exist in table must insert.
                    hr_utility.set_location(gv_package || '.' || l_procedure , 120);

                    INSERT into pay_us_rpt_totals
                    ( session_id
                     ,organization_id
                     ,location_id
                     ,state_abbrev
                     ,attribute1
                     ,attribute2
                     ,attribute3
                     ,value2)
                     VALUES
                     ( v_session_id
                      ,p_payroll_action_id
                      ,l_worksite
                      ,l_state_abbrev
                      ,'MWS_EST'
                      ,l_sui_id
                      ,l_fed_ein
                      ,1);
                   END IF;
              ELSIF i = 3 THEN -- UPDATING / INSERTING into column value3
                 hr_utility.set_location(gv_package || '.' || l_procedure , 130);
                 UPDATE pay_us_rpt_totals prt
                 SET prt.value3 = NVL(prt.value3,0) + 1
                 WHERE prt.session_id  = v_session_id
                 AND   prt.organization_id = p_payroll_action_id
                 AND   prt.location_id = l_worksite
                 AND   prt.state_abbrev  = l_state_abbrev
                 AND   prt.attribute1  = 'MWS_EST'
                 and   prt.attribute2  = l_sui_id
                 and   prt.attribute3  = l_fed_ein;

                 IF SQL%ROWCOUNT = 0 THEN  --- Row doesn't exist in table must insert.
                    hr_utility.set_location(gv_package || '.' || l_procedure , 140);

                    INSERT into pay_us_rpt_totals
                    ( session_id
                     ,organization_id
                     ,location_id
                     ,state_abbrev
                     ,attribute1
                     ,attribute2
                     ,attribute3
                     ,value3)
                     VALUES
                     ( v_session_id
                      ,p_payroll_action_id
                      ,l_worksite
                      ,l_state_abbrev
                      ,'MWS_EST'
                      ,l_sui_id
                      ,l_fed_ein
                      ,1);
                   END IF;
              ELSE               -- UPDATING / INSERTING into column value4
                 hr_utility.set_location(gv_package || '.' || l_procedure , 150);

                 UPDATE pay_us_rpt_totals prt
                 SET prt.value4 = NVL(prt.value4,0) + l_archive_value
                 WHERE prt.session_id  = v_session_id
                 AND   prt.organization_id = p_payroll_action_id
                 AND   prt.location_id = l_worksite
                 AND   prt.state_abbrev  = l_state_abbrev
                 AND   prt.attribute1  = 'MWS_EST'
                 and   prt.attribute2  = l_sui_id
                 and   prt.attribute3  = l_fed_ein;

                 IF SQL%ROWCOUNT = 0 THEN  --- Row doesn't exist in table must insert.
                    hr_utility.set_location(gv_package || '.' || l_procedure , 160);

                    INSERT into pay_us_rpt_totals
                    ( session_id
                     ,organization_id
                     ,location_id
                     ,state_abbrev
                     ,attribute1
                     ,attribute2
                     ,attribute3
                     ,value4)
                     VALUES
                     ( v_session_id
                      ,p_payroll_action_id
                      ,l_worksite
                      ,l_state_abbrev
                      ,'MWS_EST'
                      ,l_sui_id
                      ,l_fed_ein
                      ,l_archive_value);
                   END IF;

              END IF;
            END IF;
        END IF;

       END LOOP;
     FETCH get_pact_asg into l_ass_id, l_tax_unit_id, l_sqwl_assact, l_business_group_id;

  END LOOP;

  CLOSE   get_pact_asg;

  return(1);

   END LOAD_RPT_TOTALS;

  FUNCTION get_mwr_values(p_payroll_action_id  number
                          ,p_fips_code          in varchar2
                          ,p_sui_id              in varchar2
                          ,p_est_id              in varchar2
                          ,p_fed_ein             in varchar2
                              )
  RETURN varchar2
  IS

     l_state_code        varchar2(2);
     l_month_1_count     number;
     l_month_2_count     number;
     l_month_3_count     number;
     l_est_wages         number(10,0);

     l_return_value      varchar2(28);
  BEGIN
  -- get the state code.
     SELECT state_code
     INTO   l_state_code
     FROM   pay_state_rules
     where  fips_code = to_number(p_fips_code);

  -- sum the counts from pay_us_rpt_totals
     SELECT nvl(sum(prt.value1),0),
            nvl(sum(prt.value2),0),
            nvl(sum(prt.value3),0),
            nvl(sum(prt.value4),0)
     INTO   l_month_1_count,
            l_month_2_count,
            l_month_3_count,
            l_est_wages
     FROM   pay_us_rpt_totals prt
     WHERE  prt.organization_id = p_payroll_action_id
     AND    prt.location_id = to_number(p_est_id)
     AND    prt.state_abbrev  = l_state_code
     AND    prt.attribute2  = p_sui_id
     AND    prt.attribute3  = p_fed_ein
     and    prt.attribute1  = 'MWS_EST';

  -- Format the output
     l_return_value := lpad(to_char(l_month_1_count),6,0) ||
                       lpad(to_char(l_month_2_count),6,0) ||
                       lpad(to_char(l_month_3_count),6,0) ||
                       lpad(to_char(l_est_wages),10,0);

     IF l_return_value = '0000000000000000000000000000' THEN
         return ('-999999999999999999999999999');
     ELSE
         return (l_return_value);
     END IF;

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         return ('-999999999999999999999999999');
  END get_mwr_values;

  FUNCTION REMOVE_RPT_TOTALS(p_payroll_action_id  number)
  RETURN NUMBER
  IS
  BEGIN
      DELETE
      FROM pay_us_rpt_totals prt
      WHERE prt.organization_id = p_payroll_action_id
      AND   prt.attribute1  = 'MWS_EST';

      return (1);
  END remove_rpt_totals;


  FUNCTION derive_sui_id ( p_state_code         in varchar2
                          ,p_sui_id             in varchar2
                         )
  RETURN varchar2
  IS

  l_return_sui_id varchar2(10);

  BEGIN

    if p_state_code = 'AZ' OR
          p_state_code = 'DE' OR
          p_state_code = 'IL' OR
          p_state_code = 'LA' OR
          p_state_code = 'NY' OR
          p_state_code = 'NC' OR
          p_state_code = 'PA' OR
          p_state_code = 'RI' OR
          p_state_code = 'SC' OR
          p_state_code = 'TN' OR
          p_state_code = 'WA' OR
          p_state_code = 'WV' THEN

          if instr(p_sui_id,'-') > 0 then
   	         l_return_sui_id  :=
                lpad(
                     substr(p_sui_id
                            ,1
                            ,instr(p_sui_id,'-') -1
                            )
                     ,10
                     ,'0');
           else
   	         l_return_sui_id  :=
                lpad(substr(p_sui_id,1,10)
                     ,10
                     ,'0');
           end if;

    elsif p_state_code = 'IA' OR
          p_state_code = 'KS' THEN

          if instr(p_sui_id,'-') > 0 then
   	         l_return_sui_id  :=
                 lpad(
                      substr(p_sui_id
                             ,1
                             ,greatest(6
                                       ,instr(p_sui_id,'-') -1
                                       )
                             )
                      ,10
                      ,'0');
           else
   	         l_return_sui_id  :=
                lpad(substr(p_sui_id,1,10)
                     ,10
                     ,'0');
           end if;

    elsif p_state_code = 'KY' OR
          p_state_code = 'MA' OR
          p_state_code = 'MI' OR
          p_state_code = 'NV' OR
          p_state_code = 'OR' OR
          p_state_code = 'SD' THEN

	      l_return_sui_id  :=
              lpad(
                   substr(p_sui_id
                          ,1
                          ,LENGTH(p_sui_id) -1)
                   ,10
                   ,'0');

    elsif p_state_code = 'CA' OR
          p_state_code = 'MN' OR
          p_state_code = 'OH' THEN

	      l_return_sui_id  :=
              lpad(
                   substr(p_sui_id,1,7)
                   ,10
                   ,'0');

    elsif p_state_code = 'MO' OR
          p_state_code = 'PR' OR
          p_state_code = 'WI' THEN

	      l_return_sui_id  :=
              lpad(
                   substr(p_sui_id,1,6)
                   ,10
                   ,'0');


    elsif p_state_code = 'CO' THEN

          if     length(p_sui_id) = 11
             and instr(p_sui_id,'-') = 7
             and instr(p_sui_id,'-',1,2) = 10 THEN

	         l_return_sui_id  :=
                 lpad(
                      substr(p_sui_id,8,2) ||
                      substr(p_sui_id,1,6) ||
                      substr(p_sui_id,11,1)
                      ,10
                      ,'0');
           else
               l_return_sui_id := lpad(substr(p_sui_id,1,10),10,'0');
           end if;


    elsif p_state_code = 'FL' THEN

           if length(p_sui_id) = 8 then
   	          l_return_sui_id  :=
                 lpad(
                      substr(p_sui_id,1,7) ||
                           '0'
                      ,10
                      ,'0');
           else
               l_return_sui_id := lpad(substr(p_sui_id,1,10),10,'0');
           end if;

    elsif p_state_code = 'GA' THEN

          if instr(p_sui_id,'-') > 0 then
              l_return_sui_id  :=
                 lpad(
                      substr(p_sui_id,1,6) ||
                      substr(p_sui_id,8,1)
                      ,10
                      ,'0');
           else
               l_return_sui_id := lpad(substr(p_sui_id,1,10),10,'0');
           end if;


    elsif p_state_code = 'MD' THEN

          if instr(p_sui_id,'-') > 0 then
             l_return_sui_id  :=
                 lpad(
                      substr(p_sui_id,1,9) ||
                      substr(p_sui_id,11,1)
                     ,10
                     ,'0');
           else
               l_return_sui_id := lpad(substr(p_sui_id,1,10),10,'0');
           end if;

    elsif p_state_code = 'MS' THEN

          if length(p_sui_id) = 10 THEN
             l_return_sui_id := p_sui_id;
          else
	         l_return_sui_id  :=
               rpad(
                    substr(p_sui_id,1,8)
                    ,10
                    ,'0');
          end if;

    elsif p_state_code = 'NE' THEN

	      l_return_sui_id  :=
              lpad(
                   substr(p_sui_id,1,10)
                   ,10
                   ,'0');

    elsif p_state_code = 'UT' THEN

          if     instr(p_sui_id,'-') > 0
             and instr(p_sui_id,'-',1,2) > 0 then
	         l_return_sui_id  :=
                lpad(
                     substr(p_sui_id
                            ,instr(p_sui_id,'-') + 1
                            ,6) ||
                     substr(p_sui_id
                            ,instr(p_sui_id,'-',-1) + 1
                            ,1)
                     ,10
                     ,'0');
           else
               l_return_sui_id := lpad(substr(p_sui_id,1,10),10,'0');
           end if;

    else
	   l_return_sui_id  :=
           lpad(
                substr(p_sui_id,1,10)
                ,10
                ,'0');
    end if;

    return l_return_sui_id;

END derive_sui_id;

FUNCTION update_global_values(p_estab_ID number,
                              p_state_abbrev varchar2)

  RETURN NUMBER
  IS
  BEGIN

      IF p_estab_id <> pay_us_mwr_reporting_pkg.est_id
         OR p_state_abbrev <> pay_us_mwr_reporting_pkg.state_abbrev
         OR pay_us_mwr_reporting_pkg.estab_count = 20 THEN
         pay_us_mwr_reporting_pkg.estab_count := 0;
         pay_us_mwr_reporting_pkg.est_id := p_estab_id;
         pay_us_mwr_reporting_pkg.state_abbrev := p_state_abbrev;
      ELSE
         pay_us_mwr_reporting_pkg.estab_count := pay_us_mwr_reporting_pkg.estab_count + 1;
      END IF;


      return (pay_us_mwr_reporting_pkg.estab_count);
END update_global_values;

END pay_us_mwr_reporting_pkg;

/
