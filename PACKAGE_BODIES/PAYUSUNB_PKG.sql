--------------------------------------------------------
--  DDL for Package Body PAYUSUNB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAYUSUNB_PKG" as
/* $Header: payusunb.pkb 120.0.12010000.7 2010/01/13 11:16:44 jdevasah ship $ */
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

   Name       : PAYUSUNB_PKG

   Description: This package defines the cursors needed to run
                Unacceptable Tax Balance


   Change List
   -----------
   Date        Name      Bug No   Vers   Description
   ----------- --------- -------- -----  -----------------------------------
   29-SEP-1999 mcpham             110.0  created
   03-DEC-1999 mcpham             115.1  Added fnd_date.canonical_to_date
   05-JAN-2000 mcpham             115.2  converted latest file from release 11.0
   22-AUG-2001 tmehra    1158217  115.3  Added new function to check if
                                         an employee is Medicare Exempt
                         1709095         Added Generic Pre-Tax enhancements
   14-NOV-2001 meshah             115.4  now comparing state_code of HI and NY
                                         as characters.
   26-NOV-2001 meshah             115.5  added dbdrv command.
   26-NOV-2001 meshah             115.6  commenting all the balance calls to
                                         401, 125 and dep care.
   30-NOV-2001 meshah                    also commenting checking for condition
                                         L_fit_ee_gross_earnings <> L_medi_ee_bal
                                         +L_fit_ee_125_redns_qtd
                                         +L_fit_ee_dep_care_redns_qtd
                                         for both qtd and ytd.
   30-NOV-2001 meshah                    changed DD-MON to DD-MM for GSCC compliance.
   21-DEC-2001 meshah    2152217  115.7  Moved one each SDI and SUI conditions
                                         in the respective loops for QTD and YTD.
   25-SEP-2002 tclewis            115.8  Performance improvements to range
                                         cursor procedure and associated cursors.
   18-OCT-2002 tclewis            115.10 Modified the action_creation cursor removing
                                         the for update of . . . added a for update
                                         on the lock the created assignment_action_id.
   06-DEC-2002 tclewis            115.11 Added NOCOPY directive and fixed some typo's
                                         formatting issue with the 'YTD SUI EE Taxable'
                                         and 'YTD SUI ER Taxable' messages
   25-JUN-2003 vinaraya  2963239  115.13 Added extra check in prc_process_data for medicare
                                         and SS balance check.(bug number 2963239)
                                         Moved the call to prc_process_data from report to
                                         action_creation code. prc_write_data definition has
                                         been changed to include two new arguements.
   30-JUN-2003 vinaraya  3005756  115.14 Modified code for caching and removal of unwanted
                                         code as per review comments.
   01-JUL-2003 vinaraya  3005756  115.15 Changed function fnc_get_tax_limit_rate to include
                                         join for start date in the cursor c_sui_sdi_info.
   03-JUL-2003 vinaraya  3005756  115.16 Included 4 new cursors for state,county,city and
                                         school jurisdiction data fetch.Included check for
					 validity of run balances to make use of the new
					 cursors accordingly.
                                         Moved state,county,city and school
					 balance checks to inline procedures.
   08-JUL-2003 vinaraya  3005756  115.17 Restructured entire code to remove repeated code.
                                         Removed action interlocking
   27-AUG-2003 kaverma   3115988  115.18 Added difference calculation for FUTA
   19-DEC-2003 saurgupt  3291736  115.19 In action_creation, procedure insert_action
                                         is removed. Also, if no Unacceptable tax balances
                                         are found then a dummy action is created. This will
                                         happen only if payroll/prepayments have been run.
   26-DEC-2003 saurgupt  3316599  115.20 Tax Unit id is added to where condition to decrease
                                         the cost of query.
   06-JAN-2004 sdahiya   3316599  115.21 Modified queries for performance enhancement.
   24-MAR-2004 fusman    3418991  115.22 Modified cursors c_actions,c_get_latest_asg,
                                         c_school_jurisdictions_valid and
                                         c_school_jurisdictions.
   17-NOV-2004 ahanda    3962872  115.23 Changed range code, action creation and
                                         enabled RANGE_PERSON_ID.
   18-NOV-2004 ahanda             115.24 Fixed GSCC issues.
   18-NOV-2004 ahanda             115.25 Fixed GSCC issues.
   08-NOV-2007 dduvvuri  6360505  115.26 Performance Improvements for Bug 6360505
   05-May-2008 Pannapur  6719359  115.27 Reverted the peformance fix
   01-Jul-2008 Pannapur  7174993  115.28 Perfomance Improvements for bug 7174993
   21-Jul-2008 Pannapur  7174993  115.29 Perfomance Improvements for bug 7174993(removed the hint added
                                          in previous version)
   10-Jul-2009 emunisek  8665548  115.30 Modified cursor c_sui_sdi_info in function
                                         fnc_get_tax_limit_rate to pick a state tax
					 record which is effective on "As of Date"
   07-Jan-2010 pbalu     8754952  115.31 Added new error condition for Negative Reduced Subject whable
  ******************************************************************************/

   c_fixed_futa_rt CONSTANT NUMBER(10,4) := 6.2;

   -- define some global variables for temporary storage
   G_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE := NULL;
   G_payroll_id     pay_payroll_actions.payroll_id%TYPE := NULL;
   G_got_fed_rate   BOOLEAN := FALSE;
   G_ss_ee_rate     NUMBER := NULL;
   G_ss_er_rate     NUMBER := NULL;
   G_medi_ee_rate   NUMBER := NULL;
   G_medi_er_rate   NUMBER := NULL;
   G_commit_count   NUMBER := NULL;

   -- Global values to store the flag based on the validity of
   -- the corresponding balances i.e., IF G_state_flag := 'Y' then
   -- all state balances are valid in pay_run_balances
   -- else atleast one of the state balance is invalid
   G_state_flag    VARCHAR2(1);
   G_county_flag   VARCHAR2(1);
   G_city_flag     VARCHAR2(1);
   G_school_flag   VARCHAR2(1);

   -- Bug 3291736
   -- Variable to hold the dummy assignment insertion
   -- if there are no employees with Unacceptable balance
   G_dummy_action_inserted_flag  VARCHAR2(1) := 'N';

   /**********************Bug 2963239 Changes start ******************************
   ********************** variables to hold the SS limit values ******************/
   G_ss_ee_wage_limit NUMBER := NULL;
   G_ss_er_wage_limit NUMBER := NULL;

   /********************3005756 START *******************************/
   -- Definitions of the pl/sql tables for caching.

   TYPE futa_credit_info_rec IS RECORD
     ( organization_id    NUMBER
      ,sui_state_code     VARCHAR2(2)
      ,futa_credit_rate   NUMBER );

   TYPE futa_credit_info_table IS TABLE OF
     futa_credit_info_rec
   INDEX BY BINARY_INTEGER;

   futa_credit_info    futa_credit_info_table;

   TYPE sui_sdi_tax_info_rec IS RECORD
     ( sui_ee_limit  NUMBER
      ,sui_er_limit  NUMBER
      ,sdi_ee_limit  NUMBER
      ,sdi_er_limit  NUMBER
     );

   TYPE sui_sdi_tax_info_table IS TABLE OF
    sui_sdi_tax_info_rec
   INDEX BY BINARY_INTEGER;

   sui_sdi_tax_info1    sui_sdi_tax_info_table;
   sui_sdi_tax_info2    sui_sdi_tax_info_table;
   sui_sdi_tax_info3    sui_sdi_tax_info_table;

   TYPE sui_sdi_override_rec is RECORD
    ( sui_override_rate      NUMBER
     ,sui_dummy_rate         NUMBER
     ,sdi_override_rate      NUMBER );

   TYPE sui_sdi_override_tab IS TABLE OF sui_sdi_override_rec
     INDEX BY BINARY_INTEGER;

   sui_sdi_override_info sui_sdi_override_tab;

   /********************** fnc_lit ***************************/
   TYPE county_tax_info_rec IS RECORD
     ( jurisdiction_code    varchar2(11)
      ,cnty_tax_exists      varchar2(1)
      ,cnty_sd_tax_exists   varchar2(1)
      );

   TYPE county_tax_info_table IS TABLE OF
      county_tax_info_rec
   INDEX BY BINARY_INTEGER;

   county_tax_info  county_tax_info_table;

   TYPE city_tax_info_rec IS RECORD
       ( jurisdiction_code    varchar2(11)
       , city_tax_exists      varchar2(1)
       , city_sd_tax_exists   varchar2(1)
       );

   TYPE city_tax_info_table IS TABLE OF
       city_tax_info_rec
   INDEX BY BINARY_INTEGER;

   city_tax_info    city_tax_info_table;

   -- Global variables to hold vales fetched by c_get_payroll_stuff cursor
   G_as_of_date     DATE := NULL;
   G_business_id    per_all_assignments_f.business_group_id%TYPE;
   G_leg_param      pay_payroll_actions.legislative_parameters%TYPE;

   -- Cursor and global variable to store the futa_override rate
   G_futa_override_rt   NUMBER := 0;

   -- Cursor fetches the futa override rate based on the tax unit id passed.
   CURSOR c_get_futa_override_rt(
              IN_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE) IS
     SELECT NVL(org_information7,0)/100
       FROM hr_organization_information
      WHERE organization_id = IN_tax_unit_id
        AND org_information_context = 'Federal Tax Rules';

   -- cursor c_get_payroll_stuff made public
   -- It will now be called once in action_creation
   CURSOR c_get_payroll_stuff(IN_pact_id IN pay_payroll_actions.payroll_action_id%TYPE) IS
     SELECT effective_date, business_group_id, legislative_parameters
       FROM pay_payroll_actions
      WHERE payroll_action_id = IN_pact_id;

/***************** 3005756 END ******************************/

 /***********************************************************************
 * routine name: range_cursor
 * purpose:
 * parameters:
 * return:
 * specs:
 *************************************************************************/
 PROCEDURE range_cursor (IN_pactid   IN NUMBER,
                         OUT_sqlstr OUT NOCOPY VARCHAR2)
 IS

   lv_sqlstr           varchar2(32000);
   lv_leg_param        varchar2(2000);
   lv_cur_date         varchar2(30);
   lv_b_dim            varchar2(10);
   lv_location_id      varchar2(30);
   lv_organization_id  varchar2(30);
   lv_tax_unit_id      varchar2(30);
   ld_effective_date   date;
   ld_cur_date         date;


 BEGIN
   BEGIN
     select effective_date,legislative_parameters
       into ld_effective_date,lv_leg_param
       from pay_payroll_actions
      where payroll_action_id = IN_pactid;

   END;

   lv_tax_unit_id := payusunb_pkg.fnc_get_parameter('GRE',lv_leg_param);
   lv_organization_id := payusunb_pkg.fnc_get_parameter('Org',lv_leg_param);
   lv_location_id := payusunb_pkg.fnc_get_parameter('Loc',lv_leg_param);
   lv_b_dim := payusunb_pkg.fnc_get_parameter('B_Dim',lv_leg_param);

   if lv_b_dim ='QTD' then
      ld_cur_date := TRUNC(ld_effective_date,'Q');
   elsif lv_b_dim ='YTD' then
      ld_cur_date := TRUNC(ld_effective_date, 'Y');
   end if;

   select fnd_date.date_to_canonical(ld_cur_date)
     into lv_cur_date
     from dual;

   -- range cursor query
   lv_sqlstr :=
        'SELECT /*+ ORDERED
                    INDEX (ppa PAY_PAYROLL_ACTIONS_PK)
                    INDEX (pa1 PAY_PAYROLL_ACTIONS_N5)
                    INDEX (act PAY_ASSIGNMENT_ACTIONS_N50)
                    INDEX (paf PER_ASSIGNMENTS_F_PK) */
                DISTINCT paf.person_id
           FROM pay_payroll_actions    ppa,
                pay_payroll_actions    pa1,
                pay_assignment_actions act,
                per_assignments_f      paf
          WHERE ppa.payroll_action_id    = :payroll_action_id
            AND pa1.effective_date >= fnd_date.canonical_to_date('''|| lv_cur_date ||''')
            AND pa1.effective_date <=  ppa.effective_date
            AND pa1.payroll_action_id = act.payroll_action_id
            AND paf.assignment_id        = act.assignment_id
            AND pa1.effective_date BETWEEN paf.effective_start_date
                                       AND paf.effective_end_date
            AND pa1.action_type in (''B'',''I'',''R'',''Q'',''V'')
            AND act.action_status = ''C''
            AND paf.business_group_id +0 = ppa.business_group_id
            AND act.tax_unit_id = ' || lv_tax_unit_id;

   if lv_organization_id is not null then
       lv_sqlstr :=  lv_sqlstr || ' and  paf.organization_id = '||lv_organization_id;
   end if;

   if lv_location_id is not null then
       lv_sqlstr :=  lv_sqlstr || ' and  paf.location_id = '||lv_location_id;
   end if;

   lv_sqlstr :=  lv_sqlstr || ' ORDER BY paf.person_id';


   OUT_sqlstr := lv_sqlstr;

 END range_cursor;


 /***************************************************************************
 * routine name: action_creation
 * purpose:
 * parameters:
 * return:
 * specs:
 ****************************************************************************/
 PROCEDURE action_creation(IN_pactid    IN NUMBER,
                           IN_stperson  IN NUMBER,
                           IN_endperson IN NUMBER,
                           IN_chunk     IN NUMBER) IS

   CURSOR c_actions(cp_start_person_id   in number
                   ,cp_end_person_id     in number
                   ,cp_tax_unit_id       in number
                   ,cp_organization_id   in number
                   ,cp_location_id       in number
                   ,cp_business_group_id in number
                   ,cp_period_start      in date
                   ,cp_period_end        in date) is
     SELECT DISTINCT
            paf.person_id person_id
       FROM per_all_assignments_f      paf,
            pay_all_payrolls_f         PPY
      WHERE exists
           (select /*+ INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                       INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
                   'x'
              from pay_payroll_actions ppa,
                   pay_assignment_actions paa
             where ppa.effective_date between cp_period_start
                                          and cp_period_end
               and  ppa.action_type in ('R','Q','V','B','I')
               and  ppa.action_status = 'C'
               and  ppa.business_group_id + 0 = cp_business_group_id
               and  ppa.payroll_action_id = paa.payroll_action_id
               and  paa.tax_unit_id = cp_tax_unit_id
               and  paa.action_status = 'C'
               and  paa.assignment_id = paf.assignment_id
               and  ppa.business_group_id = paf.business_group_id +0
               and  ppa.effective_date between paf.effective_start_date
                                           and  paf.effective_end_date)
        AND paf.person_id between cp_start_person_id and cp_end_person_id
        AND paf.assignment_type = 'E'
        AND (cp_organization_id is null OR
             paf.organization_id = cp_organization_id)
        AND (cp_location_id is null OR
             paf.LOCATION_ID =  cp_location_id)
        AND PPY.payroll_id = paf.payroll_id;

   CURSOR c_actions_person_on(
                    cp_payroll_Action_id in number
                   ,cp_chunk_number      in number) is
     SELECT ppr.person_id person_id
       FROM pay_population_ranges ppr
      where ppr.payroll_action_id = cp_payroll_Action_id
        and ppr.chunk_number = cp_chunk_number;


   -- Cursor to get the latest assignment action id details for the person
   -- selected
   CURSOR c_get_latest_asg(
                       cp_person_id       IN NUMBER
                      ,cp_tax_unit_id     IN NUMBER
                      ,cp_as_of_date      IN DATE
                      ,cp_start_date      IN DATE
                      ,IN_org_id          IN NUMBER
                     ,IN_location_id     IN NUMBER
                      ) IS
   /* Change for Performance Bug 6360505 */
     SELECT /*+ ORDERED */
            to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id
       FROM per_all_assignments_f paf,
            pay_payroll_actions ppa,
            pay_assignment_actions paa,
            pay_action_classifications pac
      WHERE paf.person_id = cp_person_id
        AND paf.payroll_id = ppa.payroll_id
        AND (paf.organization_id = IN_org_id
              OR IN_org_id IS NULL)
        AND (paf.location_id = IN_location_id
              OR IN_location_id IS NULL)
        AND paa.assignment_id = paf.assignment_id
        AND paa.tax_unit_id = cp_tax_unit_id
        AND paa.payroll_action_id = ppa.payroll_action_id
        AND ((NVL(paa.run_type_id, ppa.run_type_id) IS NULL
                   AND paa.source_action_id IS NULL)
               OR (NVL(paa.run_type_id, ppa.run_type_id) IS NOT NULL
                   AND paa.source_action_id IS NOT NULL )
               OR (ppa.action_type = 'V' AND ppa.run_type_id IS NULL
                   AND paa.run_type_id IS NOT NULL
                   AND paa.source_action_id IS NULL))
        AND ppa.effective_date  BETWEEN paf.effective_start_date
                                    AND paf.effective_end_date
        AND ppa.effective_date  BETWEEN cp_start_date AND cp_as_of_date
        AND ppa.action_type = pac.action_type
        AND pac.classification_name = 'SEQUENCED';

/* Change for Performance Bug 6360505 */
   CURSOR c_get_asg_details(
                            cp_asg_act_id      IN NUMBER
			   ,cp_tax_unit_id     IN NUMBER
			   ,cp_person_id       IN NUMBER
			   ,cp_as_of_date      IN DATE
                           ,cp_start_date      IN DATE
                            ) IS
     SELECT paa.assignment_id ,
            paf.location_id,
            paf.organization_id,
            paf.assignment_number
       FROM pay_assignment_actions paa,
            pay_payroll_actions ppa,
            per_all_assignments_f paf
      WHERE paa.assignment_action_id = cp_asg_act_id
        AND paa.tax_unit_id = cp_tax_unit_id
        AND ppa.payroll_action_id = paa.payroll_action_id
        AND ppa.effective_date  BETWEEN cp_start_date AND cp_as_of_date
        AND paf.assignment_id = paa.assignment_id
	AND ppa.effective_date  BETWEEN paf.effective_start_date
                                    AND paf.effective_end_date
	AND paf.person_id = cp_person_id;
/* Change for Performance Bug 6360505 */

   L_lockingactid  NUMBER;
   L_lockedactid   NUMBER;
   L_assignid      NUMBER;
   L_greid         NUMBER;
   L_as_of_date    DATE := NULL;
   L_start_date    DATE;
   L_leg_param     pay_payroll_actions.legislative_parameters%TYPE;
   L_gre_id        pay_assignment_actions.tax_unit_id%TYPE;
   L_org_id        per_all_assignments_f.organization_id%TYPE;
   L_location_id   per_all_assignments_f.location_id%TYPE;
   L_business_id   per_all_assignments_f.business_group_id%TYPE;
   L_dimension     VARCHAR2(20) := NULL;

   L_person_id	       per_all_assignments_f.person_id%TYPE;
   L_loc_id            per_all_assignments_f.location_id%TYPE;
   L_organization_id   per_all_assignments_f.organization_id%TYPE;
   L_assignment_number per_all_assignments_f.assignment_number%TYPE;

   l_range_person  BOOLEAN;
 BEGIN

   -- get all required parameters from legislative parameter string
   OPEN c_get_payroll_stuff(IN_pactid);
   FETCH c_get_payroll_stuff INTO G_as_of_date, G_business_id, G_leg_param;
   CLOSE c_get_payroll_stuff;

   -- Local variables for payroll related stuff
   L_as_of_date  := G_as_of_date;
   L_business_id := G_business_id;
   L_leg_param   := G_leg_param;

   L_dimension   := fnc_get_parameter('B_Dim',L_leg_param);
   L_gre_id      := fnc_get_parameter('GRE',L_leg_param);
   L_org_id      := fnc_get_parameter('Org',L_leg_param);
   L_location_id := fnc_get_parameter('Loc',L_leg_param);

   /***************************3005756 START *******************************/
   -- Get the futa override rate
   OPEN c_get_futa_override_rt(L_gre_id);
   FETCH c_get_futa_override_rt INTO G_futa_override_rt;
   CLOSE c_get_futa_override_rt;
   /******************************* 3005756 END *******************************/

   -- calculate the start date based on YTD or QTD dimensions
   IF L_dimension = 'QTD' THEN
      L_start_date := TRUNC(L_as_of_date,'Q');
   ELSIF L_dimension = 'YTD' THEN
      L_start_date := TRUNC(L_as_of_date,'YYYY');
   END IF;

   /************************* 3005756 start ********************************/
   -- Fetch the balance validity flags into the global variables for use in
   -- prc_process_data
   G_state_flag  := pay_us_payroll_utils.check_balance_status(L_start_date,L_gre_id,'UNB_STATE');
   G_county_flag := pay_us_payroll_utils.check_balance_status(L_start_date,L_gre_id,'UNB_COUNTY');
   G_city_flag   := pay_us_payroll_utils.check_balance_status(L_start_date,L_gre_id,'UNB_CITY');
   G_school_flag := pay_us_payroll_utils.check_balance_status(L_start_date,L_gre_id,'UNB_SCHOOL');
   /************************* 3005756 end *********************************/

   l_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'PAYUSUNB'
                          ,p_report_format    => 'DEFAULT'
                          ,p_report_qualifier => 'DEFAULT'
                          ,p_report_category  => 'REPORT');
   hr_utility.set_location('procpyr',1);
   if l_range_person then
      OPEN c_actions_person_on(IN_pactid, IN_chunk);
   else
      OPEN c_actions(IN_stperson, IN_endperson, L_gre_id,
                     L_org_id, L_location_id, L_business_id,
                     L_start_date, L_as_of_date);
   end if;

   LOOP
      hr_utility.set_location('procpyr',2);
      if l_range_person then
         FETCH c_actions_person_on INTO L_person_id;
         EXIT WHEN c_actions_person_on%NOTFOUND;
      else
         FETCH c_actions INTO L_person_id;
         EXIT WHEN c_actions%NOTFOUND;
      end if;

      -- Bug 3291736
      -- insert_action(IN_pactid,IN_chunk,L_gre_id,L_person_id,
      --               L_location_id,L_org_id,L_start_date,L_as_of_date);
      -- Code to replace call to insert_actions.

      -- we need to insert one action for each of the
      -- rows that we return FROM the cursor (i.e. one
      -- for each assignment/pre-payment/reversal).
      hr_utility.trace('L_person_id = '||to_char(L_person_id));
      hr_utility.trace('L_org_id = '||to_char(L_org_id));
      hr_utility.trace('L_location_id = '||to_char(L_location_id));
      hr_utility.trace('L_as_of_date = '||L_as_of_date);
      hr_utility.trace('L_start_date = '||L_start_date);
      hr_utility.trace('L_gre_id = '||to_char(L_gre_id));

      OPEN c_get_latest_asg(L_person_id,L_gre_id,L_as_of_date,
                            L_start_date,L_org_id,L_location_id);
      FETCH c_get_latest_asg INTO L_lockedactid;        /* Change for Performance Bug 6360505 */
      CLOSE c_get_latest_asg;

      hr_utility.trace('L_lockedactid  ' || L_lockedactid);
      /* Change for Performance Bug 6360505 */
      OPEN c_get_asg_details(L_lockedactid, L_gre_id, L_person_id,
                             L_as_of_date, L_start_date);
      FETCH c_get_asg_details INTO L_assignid,L_loc_id,
                                  L_organization_id,L_assignment_number;
      CLOSE c_get_asg_details;
      /* Change for Performance Bug 6360505 */

      hr_utility.trace('L_assignid '||to_char(L_assignid));
      hr_utility.trace('L_assignid ' || L_assignid);
      hr_utility.set_location('procpyr',3);

      SELECT pay_assignment_actions_s.NEXTVAL
        INTO L_lockingactid
        FROM dual;

      IF L_lockedactid is not null then
         prc_process_data(IN_pactid,IN_chunk,500,L_lockingactid,
                          L_lockedactid,L_assignid,L_gre_id
                         ,L_person_id,L_loc_id,L_organization_id
                         ,L_assignment_number );
      END IF;

   END LOOP;
   if l_range_person then
      CLOSE c_actions_person_on;
   else
      CLOSE c_actions;
   end if;

   -- Bug 3291736
   -- Code to insert dummuy action if there are no actions inserted.
   -- But if there is no payroll run or prepayments then no dummy action
   -- will be inserted.
   IF L_lockedactid is not null and
      G_dummy_action_inserted_flag = 'N'  THEN
      hr_nonrun_asact.insact(L_lockingactid,L_assignid,
                             IN_pactid,IN_chunk,L_gre_id);
   END IF;

 END action_creation;


 /*************************************************************************
 * routine name: sort_action
 * purpose:
 * parameters:
 * return:
 * specs:
 **************************************************************************/
 PROCEDURE sort_action(IN_payactid IN     VARCHAR2
                      ,IO_sqlstr   IN OUT NOCOPY VARCHAR2
                      ,OUT_len     OUT    NOCOPY NUMBER)
 IS
 BEGIN
   IO_sqlstr := 'SELECT paa1.rowid
                /* we need the row id of the assignment actions that are
                   created by PYUGEN */
                   FROM hr_organization_units  hou,
			hr_organization_units  hou1,
                        hr_locations  	       loc,
			per_people_f           ppf,
                        per_all_assignments_f  paf,
                        pay_assignment_actions paa1, /* PYUGEN assignment action */
                        pay_payroll_actions    ppa1  /* PYUGEN payroll action id */
		  WHERE ppa1.payroll_action_id = :pactid
		    AND paa1.payroll_action_id = ppa1.payroll_action_id
		    AND paa1.assignment_id = paf.assignment_id
                    AND paf.effective_start_date =
                         (SELECT MAX(paf1.effective_start_date)
                            FROM per_assignments_f paf1
                           WHERE paf1.assignment_id = paf.assignment_id
                             AND paf1.effective_start_date <= ppa1.effective_date
                             AND paf1.effective_end_date >=
                                 DECODE(payusunb_pkg.fnc_get_parameter(''B_Dim'',
                                    ppa1.legislative_parameters),
                                        ''QTD'',
                                        TRUNC(ppa1.effective_date,''Q''),
                                        ''YTD'',
                                        TRUNC(ppa1.effective_date,''Y''))
                         )
  		    AND hou1.organization_id = paa1.tax_unit_id
 		    AND hou.organization_id = paf.organization_id
		    AND loc.location_id  = paf.location_id
		    AND ppf.person_id = paf.person_id
		    AND ppa1.effective_date BETWEEN ppf.effective_start_date
                                                AND ppf.effective_END_date
                 ORDER BY
                      hou1.name,   /* GRE */
                      DECODE(payusunb_pkg.fnc_get_parameter(
                         ''SO1'',ppa1.legislative_parameters),
                                     ''Employee'',ppf.full_name,
                                     ''Social'',ppf.national_identifier,
                                     ''Organization'',hou.name,
                                     ''Location'',loc.location_code,null),
	              DECODE(payusunb_pkg.fnc_get_parameter(
                         ''SO2'',ppa1.legislative_parameters),
                                     ''Employee'',ppf.full_name,
                                     ''Social'',ppf.national_identifier,
                                     ''Organization'',hou.name,
                                     ''Location'',loc.location_code,null),
                      DECODE(payusunb_pkg.fnc_get_parameter(
                         ''SO3'',ppa1.legislative_parameters),
                                     ''Employee'',ppf.full_name,
                                     ''Social'',ppf.national_identifier,
                                     ''Organization'',hou.name,
                                     ''Location'',loc.location_code,null),
                      hou.name,
                      ppf.full_name
		 FOR UPDATE of paa1.assignment_action_id';

   OUT_len := LENGTH(IO_sqlstr); -- return the length of the string.

 END sort_action;


 /*************************************************************************
 routine name: fnc_get_parameter
 purpose:      Gets specified parameter value from legislative Parameter
               String
 parameters:   IN_name             - name of the parameter to get value
               IN_parameter_list   - String containing legislative parameter
 return:       Value for specified parameter name
 specs:
 **************************************************************************/
 FUNCTION fnc_get_parameter(IN_name           IN VARCHAR2,
                            IN_parameter_list IN VARCHAR2) RETURN VARCHAR2
 IS
   L_start_ptr NUMBER;
   L_end_ptr   NUMBER;
   L_token_val pay_payroll_actions.legislative_parameters%TYPE;
   L_par_value pay_payroll_actions.legislative_parameters%TYPE;
 BEGIN

     L_token_val := IN_name||'=';
     L_start_ptr := INSTR(IN_parameter_list, L_token_val)
                       + length(L_token_val);
     L_end_ptr := INSTR(IN_parameter_list, ' ',L_start_ptr);

     /* if there is no spaces use then length of the string */
     IF L_end_ptr = 0 THEN
        L_end_ptr := LENGTH(IN_parameter_list)+1;
     END IF;

     /* Did we find the token */
     IF INSTR(IN_parameter_list, L_token_val) = 0 THEN
       L_par_value := NULL;
     ELSE
       L_par_value := SUBSTR(IN_parameter_list,
                              L_start_ptr, L_end_ptr - L_start_ptr);
     END IF;

     RETURN L_par_value;

 EXCEPTION
    WHEN OTHERS THEN
       --hr_utility.trace('Error: PAYUSUNB_PKG.fnc_get_parameter failed - ORA'||TO_CHAR(SQLCODE));
       RAISE;
 END fnc_get_parameter;

 /*************************************************************************
 routine name: prc_get_balance
 purpose:      Pulls all applicable balances for specified dimension,
               tax type and juridiction
 parameters:
 return:
 specs:
 **************************************************************************/
 PROCEDURE prc_get_balance(IN_asg_action_id   IN  NUMBER,
                           IN_tax_unit_id     IN  NUMBER,
                           IN_as_of_date      IN  DATE,
                           IN_dimension       IN  VARCHAR2,
                           IN_tax_type        IN  VARCHAR2,
                           IN_balance_type    IN  VARCHAR2,
                           IN_ee_or_er        IN  VARCHAR2,
                           IN_jurisdiction    IN  VARCHAR2,
                           OUT_bal            OUT NOCOPY NUMBER) IS

   L_rval   NUMBER := 0;

 BEGIN

    L_rval := pay_us_tax_bals_pkg.us_tax_balance
                 (IN_balance_type,
                  IN_tax_type,
                  IN_ee_or_er,
                  IN_dimension,
                  'PER',
                  IN_tax_unit_id,
                  IN_jurisdiction,
                  IN_asg_action_id,
                  NULL,
                  NULL,
                  NULL,
                  TRUE);

    IF L_rval IS NULL THEN
       L_rval := 0;
    END IF;

    OUT_bal := L_rval;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      OUT_bal := 0;
   WHEN OTHERS THEN
      RAISE;
 END prc_get_balance;

 /*************************************************************************
 routine name: fnc_get_tax_limit_rate
 purpose:      get tax limit rates in table PAY_US_STATE_TAX_INFO_F for
               specified state and category
 parameters:
 return:
 specs:
 **************************************************************************/
 FUNCTION fnc_get_tax_limit_rate(IN_state_code  IN pay_us_states.state_code%TYPE,
                                 IN_start_date  IN DATE,
                                 IN_as_of_date  IN DATE,
                                 IN_tax_type    IN VARCHAR2,
                                 IN_ee_or_er    IN VARCHAR2,
                                 IN_tab_flag    IN VARCHAR2,
                                 IN_tax_unit_id IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    L_return_val   NUMBER;

/**********************3005756 START ****************************************/

-- Modified the function to cache the values and later use it instead of
-- hitting the database for each balance call

-- Modified cursor c_sui_sdi_info to get the state tax record effective on As of Date
-- as against looking for the tax record for the entire period.

CURSOR c_sui_sdi_info  IS
       SELECT state_code,sta_information5,sta_information6,sta_information3,sta_information4
       FROM pay_us_state_tax_info_f pusif
       WHERE IN_as_of_date between pusif.effective_start_date AND pusif.effective_end_date
       --IN_as_of_date <= pusif.effective_end_date    --Modified for Bug#8665548
       --AND   IN_start_date >= pusif.effective_start_date  --Removed for Bug#8665548
       AND pusif.sta_information_category = 'State tax limit rate info'
       ORDER BY 1;

l_sui_ee      VARCHAR2(20);
l_sui_er      VARCHAR2(20);
l_sdi_ee      VARCHAR2(20);
l_sdi_er      VARCHAR2(20);
lv_state_code VARCHAR2(2);

/********************** 3005756 END ************************************/

 BEGIN

/************************ 3005756 START **************************************/
-- Check if the date passes is as_of_date and populate the pl/sql accordingly
-- If date = as_of_date populate the sui_sdi_tax_info1 table
-- else  populate sui_sdi_tax_info2 table

   IF IN_tab_flag = 'FULL' THEN
      IF payusunb_pkg.sui_sdi_tax_info1.count < 1 THEN
         OPEN c_sui_sdi_info ;
	 LOOP
	   FETCH c_sui_sdi_info  into lv_state_code,l_sui_ee,l_sui_er,l_sdi_ee,l_sdi_er;
           EXIT WHEN c_sui_sdi_info%NOTFOUND;
	   payusunb_pkg.sui_sdi_tax_info1(lv_state_code).sui_ee_limit := l_sui_ee;
           payusunb_pkg.sui_sdi_tax_info1(lv_state_code).sui_er_limit := l_sui_er;
	   payusunb_pkg.sui_sdi_tax_info1(lv_state_code).sdi_ee_limit := l_sdi_ee;
	   payusunb_pkg.sui_sdi_tax_info1(lv_state_code).sdi_er_limit := l_sdi_er;
         END LOOP;
	 CLOSE c_sui_sdi_info ;
      END IF;

     IF payusunb_pkg.sui_sdi_tax_info1.exists(IN_state_code) THEN

       IF IN_tax_type = 'SUI' AND IN_ee_or_er = 'EE' THEN
          L_return_val := payusunb_pkg.sui_sdi_tax_info1(IN_state_code).sui_ee_limit;
       ELSIF IN_tax_type = 'SUI' AND IN_ee_or_er = 'ER' THEN
          L_return_val := payusunb_pkg.sui_sdi_tax_info1(IN_state_code).sui_er_limit;
       ELSIF IN_tax_type = 'SDI' AND IN_ee_or_er = 'EE' THEN
          L_return_val := payusunb_pkg.sui_sdi_tax_info1(IN_state_code).sdi_ee_limit;
       ELSIF IN_tax_type = 'SDI' AND IN_ee_or_er = 'ER' THEN
          L_return_val := payusunb_pkg.sui_sdi_tax_info1(IN_state_code).sdi_er_limit;
       END IF;

     END IF;

   ELSIF IN_tab_flag = 'FIRST' THEN

       IF payusunb_pkg.sui_sdi_tax_info2.count < 1 THEN
         OPEN c_sui_sdi_info ;
	 LOOP
	   FETCH c_sui_sdi_info  into lv_state_code,l_sui_ee,l_sui_er,l_sdi_ee,l_sdi_er;
           EXIT WHEN c_sui_sdi_info%NOTFOUND;
	   payusunb_pkg.sui_sdi_tax_info2(lv_state_code).sui_ee_limit := l_sui_ee;
           payusunb_pkg.sui_sdi_tax_info2(lv_state_code).sui_er_limit := l_sui_er;
	   payusunb_pkg.sui_sdi_tax_info2(lv_state_code).sdi_ee_limit := l_sdi_ee;
	   payusunb_pkg.sui_sdi_tax_info2(lv_state_code).sdi_er_limit := l_sdi_er;
         END LOOP;
	 CLOSE c_sui_sdi_info ;
       END IF;

       IF payusunb_pkg.sui_sdi_tax_info2.exists(IN_state_code) THEN

         IF IN_tax_type = 'SUI' AND IN_ee_or_er = 'EE' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info2(IN_state_code).sui_ee_limit;
         ELSIF IN_tax_type = 'SUI' AND IN_ee_or_er = 'ER' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info2(IN_state_code).sui_er_limit;
         ELSIF IN_tax_type = 'SDI' AND IN_ee_or_er = 'EE' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info2(IN_state_code).sdi_ee_limit;
         ELSIF IN_tax_type = 'SDI' AND IN_ee_or_er = 'ER' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info2(IN_state_code).sdi_er_limit;
         END IF;

	END IF;

     ELSIF IN_tab_flag = 'LAST' THEN

       IF payusunb_pkg.sui_sdi_tax_info3.count < 1 THEN
         OPEN c_sui_sdi_info ;
         LOOP
           FETCH c_sui_sdi_info  into lv_state_code,l_sui_ee,l_sui_er,l_sdi_ee,l_sdi_er;
           EXIT WHEN c_sui_sdi_info%NOTFOUND;
           payusunb_pkg.sui_sdi_tax_info3(lv_state_code).sui_ee_limit := l_sui_ee;
           payusunb_pkg.sui_sdi_tax_info3(lv_state_code).sui_er_limit := l_sui_er;
           payusunb_pkg.sui_sdi_tax_info3(lv_state_code).sdi_ee_limit := l_sdi_ee;
           payusunb_pkg.sui_sdi_tax_info3(lv_state_code).sdi_er_limit := l_sdi_er;
         END LOOP;
         CLOSE c_sui_sdi_info ;
       END IF;

       IF payusunb_pkg.sui_sdi_tax_info3.exists(IN_state_code) THEN

         IF IN_tax_type = 'SUI' AND IN_ee_or_er = 'EE' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info3(IN_state_code).sui_ee_limit;
         ELSIF IN_tax_type = 'SUI' AND IN_ee_or_er = 'ER' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info3(IN_state_code).sui_er_limit;
         ELSIF IN_tax_type = 'SDI' AND IN_ee_or_er = 'EE' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info3(IN_state_code).sdi_ee_limit;
         ELSIF IN_tax_type = 'SDI' AND IN_ee_or_er = 'ER' THEN
            L_return_val := payusunb_pkg.sui_sdi_tax_info3(IN_state_code).sdi_er_limit;
         END IF;

        END IF;


     END IF;

/**************************3005756 END ***********************************************/

   IF L_return_val IS NULL THEN
      L_return_val := 0.0;
   END IF;

   RETURN L_return_val;

 END fnc_get_tax_limit_rate;

 /****************************** 3005756 START ******************************/

 -- New function to cache the futa credit rates in pl/sql tables .
 -- Used in place of the cursor c_get_futa_credit_rt

FUNCTION fnc_get_futa_credit_rate(IN_organization_id  IN  per_all_assignments_f.organization_id%TYPE,
                                  IN_sui_state_code   IN VARCHAR2 ) RETURN NUMBER IS
    L_return_val   NUMBER;

 CURSOR c_get_futa_credit_rt (IN_organization_id IN per_all_assignments_f.organization_id%TYPE) IS
         SELECT org_information1,org_information15
         FROM hr_organization_information
         WHERE organization_id = IN_organization_id
         AND org_information_context = 'State Tax Rules';

 CURSOR c_get_state_code (IN_sui_state_code   IN VARCHAR2) Is
         SELECT state_abbrev
	   FROM pay_us_states
         WHERE state_code = IN_sui_state_code;

    l_flag VARCHAR2(2) := 'F' ;
    l_count   NUMBER := 0;
    l_sui_state_code  VARCHAR2(2);
    l_futa_state_code VARCHAR2(10);
    l_futa_credit_rate NUMBER;

 BEGIN

    l_count := payusunb_pkg.futa_credit_info.count;

    OPEN c_get_state_code(IN_sui_state_code);
    FETCH c_get_state_code into l_sui_state_code;
    CLOSE c_get_state_code;

    hr_utility.trace('L_count ' || to_char(l_count));
    hr_utility.trace('Org Id   ' || to_char(IN_organization_id));
    IF l_count > 0 THEN
       For i in 1..l_count
       LOOP
          hr_utility.trace('IN_sui_state_code : ' || IN_sui_state_code);
	  IF payusunb_pkg.futa_credit_info.exists(i) THEN
	    IF payusunb_pkg.futa_credit_info(i).organization_id = IN_organization_id THEN
	       l_flag := 'T' ;
	       IF (payusunb_pkg.futa_credit_info(i).sui_state_code = l_sui_state_code) THEN
		L_return_val := payusunb_pkg.futa_credit_info(i).futa_credit_rate;
	        RETURN nvl(L_return_val,0);
               END IF;
            END IF;
           END IF; -- exists
        END LOOP;
     END IF;
    IF l_flag = 'F' THEN
       OPEN c_get_futa_credit_rt ( IN_organization_id );
       LOOP
         l_count := l_count + 1;
	 FETCH c_get_futa_credit_rt INTO l_futa_state_code,l_futa_credit_rate ;
	 EXIT WHEN c_get_futa_credit_rt%NOTFOUND;
         hr_utility.trace('State_code pupulated : ' || l_futa_state_code);
         payusunb_pkg.futa_credit_info(l_count).organization_id  := IN_organization_id;
         payusunb_pkg.futa_credit_info(l_count).sui_state_code   := l_futa_state_code;
	 payusunb_pkg.futa_credit_info(l_count).futa_credit_rate := NVL(l_futa_credit_rate,0);
	 IF l_futa_state_code = IN_sui_state_code THEN
	    L_return_val := nvl(l_futa_credit_rate,0);
         END IF;

       END LOOP;
       CLOSE c_get_futa_credit_rt;
     END IF;
   hr_utility.trace('return value : ' || L_return_val);

   RETURN nvl(L_return_val,0);

 END fnc_get_futa_credit_rate;



-- New function to cache the sui and sdi override rates
-- Caches for the first time and returns the value later on

FUNCTION fnc_sui_sdi_override ( IN_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE
                               ,IN_state_code  IN VARCHAR2
			       ,IN_ret_flag    IN VARCHAR2) RETURN NUMBER IS

 L_return_val NUMBER;

 CURSOR c_get_sui_sdi_overide_rt (IN_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE) IS
   SELECT pus.state_code,org_information6/100, org_information7/100 , org_information14/100
     FROM hr_organization_information org, pay_us_states pus
    WHERE org.org_information1 = pus.state_abbrev
      AND pus.state_code between 00 and 99
      AND org.organization_id = IN_tax_unit_id
      AND org.org_information_context = 'State Tax Rules';

 ln_sui_override_rt NUMBER;
 ln_sui_dummy_rt    NUMBER;
 ln_sdi_override_rt NUMBER;
 lv_state_code      VARCHAR2(2);
 ln_count           NUMBER;

BEGIN
     IF  payusunb_pkg.sui_sdi_override_info.count < 1 THEN
         hr_utility.trace('Inside the sui_override');
         OPEN c_get_sui_sdi_overide_rt ( IN_tax_unit_id );
         LOOP
	   FETCH c_get_sui_sdi_overide_rt INTO lv_state_code,ln_sui_override_rt,ln_sui_dummy_rt,ln_sdi_override_rt ;
	   EXIT WHEN c_get_sui_sdi_overide_rt%NOTFOUND;
           payusunb_pkg.sui_sdi_override_info(lv_state_code).sui_override_rate  := ln_sui_override_rt;
           payusunb_pkg.sui_sdi_override_info(lv_state_code).sui_dummy_rate     := ln_sui_dummy_rt;
	   payusunb_pkg.sui_sdi_override_info(lv_state_code).sdi_override_rate  := ln_sdi_override_rt;
         END LOOP;
         CLOSE c_get_sui_sdi_overide_rt ;
     END IF;

     IF payusunb_pkg.sui_sdi_override_info.exists(IN_state_code) THEN
       IF IN_ret_flag = 'C' THEN  -- calculated value
          L_return_val := payusunb_pkg.sui_sdi_override_info(IN_state_code).sui_override_rate ;
         ELSIF IN_ret_flag = 'D' THEN -- Dummy value
            L_return_val := payusunb_pkg.sui_sdi_override_info(IN_state_code).sui_dummy_rate ;
           ELSIF IN_ret_flag = 'SDI' THEN -- SDI value
            L_return_val := payusunb_pkg.sui_sdi_override_info(IN_state_code).sdi_override_rate ;
       END IF;
     END IF;
     RETURN L_return_val;

END fnc_sui_sdi_override ;


/**************************************** 3005756 END ***************************************/

 /*************************************************************************
 routine name: prc_write_data
 purpose:      Write data to temp table PAY_US_RPT_TOTALS
 parameters:   IN_record_type   - 'V' record is part of tax verification
                                - 'U' record is part of unacceptable
               IN_gre_id        -
               IN_org_id        -
               IN_location_id   -
               IN_pact_id       - PYUGEN payroll_action_id
               IN_chunk_number  -
               IN_person_id     -
               IN_balance_nm    - String containing name of balance
               IN_taxable       -
               IN_withheld      -
               IN_calculated    -
               IN_difference    -
               IN_jurisdiction  -
               IN_message       - Corresponding message for each record
               IN_sort_code     - Derived Jurisdiction code for sorting in report
 return:       None
 specs:        Below is the mapping that it used to write processed data to
               PAY_US_RPT_TOTALS table.  There are two types of records, 1 is
               header record and the other is detail record.
               column mapping specs for header record:
               SESSION_ID        := payroll_action_id (PYUGEN Payroll Action)
               TAX_UNIT_ID       := tax_unit_id (from pay_assignment_actions)
               ORGANIZATION_ID   := organization_id (from per_assignments_f)
               LOCATION_ID       := location_id (from per_assignments_f)
               BUSINESS_GROUP_ID := chunk number from PYUGEN process
               VALUE1            := person_id
               GRE_NAME          := assignment_number (from per_assignments_f)
               STATE_CODE        := H indicating this record is header record
               VALUE6            := assignment_action_id
               Each header record may have multiple detail records and the key
               used to link header to detail records is assignment_action_id
               stored in value6 column.
               column mapping specs for detail record:
               SESSION_ID        := payroll_action_id (PYUGEN Payroll Action)
               VALUE6            := assignment_action_id
               BUSINESS_GROUP_ID := chunk number from PYUGEN process
               STATE_NAME        := jurisdiction_code
               STATE_CODE        := U if row is data for Unacceptable Balance
                                    V if row is data for Taxable Verification
               ORGANIZATION_NAME := IF STATE_CODE = U THEN "Balance 1 Name"
                                    IF STATE_CODE = V THEN "Reported Balance Name"
               LOCATION_NAME     := IF STATE_CODE = U THEN "Balance 2 Name"
               VALUE2            := IF STATE_CODE = U THEN "Balance 1 Name" Value
                                    IF STATE_CODE = V THEN "Tax Balance" Value
               VALUE3            := IF STATE_CODE = U THEN "Balance 2 Name" Value
                                    IF STATE_CODE = V THEN "Tax Withheld" Value
               VALUE4            := IF STATE_CODE = V THEN "Calculated Withheld" Value
               VALUE5            := IF STATE_CODE = V THEN Difference (Value3 - Value4)
               ATTRIBUTE1        := IF STATE_CODE = U THEN "Unacceptable Report" Message
                                    IF STATE_CODE = V THEN "Taxable Verification Report" Message
               ATTRIBUTE2        := Derived Jurisdiction Code for sorting in report
**************************************************************************/
 PROCEDURE prc_write_data (IN_commit_count        IN NUMBER,
                          IN_record_type          IN VARCHAR2,
                          IN_asgn_action_id       IN NUMBER,
                          IN_gre_id               IN NUMBER,
                          IN_org_id               IN NUMBER,
                          IN_location_id	  IN NUMBER,
                          IN_pact_id		  IN NUMBER,
                          IN_chunk_number	  IN NUMBER,
                          IN_person_id		  IN NUMBER,
                          IN_assignment_no	  IN VARCHAR2,
                          IN_balance_nm1	  IN VARCHAR2,
                          IN_balance_nm2	  IN VARCHAR2,
                          IN_taxable		  IN NUMBER,
                          IN_withheld		  IN NUMBER,
                          IN_calculated		  IN NUMBER,
                          IN_difference		  IN NUMBER,
                          IN_jurisdiction	  IN VARCHAR2,
                          IN_message		  IN VARCHAR2,
                          IN_sort_code		  IN VARCHAR2,
			  IN_locked_asg_action_id IN NUMBER,
			  IN_assign_id            IN NUMBER) IS

 L_jurisdiction   VARCHAR2(30);

 BEGIN

   IF IN_jurisdiction IS NULL THEN
      L_jurisdiction := 'Federal';
   ELSE
      L_jurisdiction := IN_jurisdiction;
   END IF;

   IF G_asgn_action_id IS NULL OR G_asgn_action_id <> IN_asgn_action_id THEN

      -- if assignment_action_id changed then write new header record
      G_asgn_action_id := IN_asgn_action_id;

      INSERT INTO pay_us_rpt_totals
          (state_code,
           tax_unit_id,
           organization_id,
          location_id,
          session_id,
          business_group_id,
          value1,
          gre_name,
          value6
         )
      VALUES
         ('H',
          IN_gre_id,
          IN_org_id,
          IN_location_id,
          IN_pact_id,
          IN_chunk_number,
          IN_person_id,
          IN_assignment_no,
          IN_asgn_action_id
         );

/******************************** 2963239 Change ***********************************************************/

	 -- insert the action record.

         hr_nonrun_asact.insact(IN_asgn_action_id,IN_assign_id,IN_pact_id,IN_chunk_number,IN_gre_id);

	 -- Bug 3291736: Change the flag to Y as the assignment action is created
	 G_dummy_action_inserted_flag := 'Y';

/******************************** END ******************************************************************/

   END IF;

      -- write data for taxable verification/unacceptable portion of report
      INSERT INTO pay_us_rpt_totals
         (state_code,
	  tax_unit_id,
          session_id,
          business_group_id,
          organization_name,
          location_name,  -- NULL
          value2,
          value3,
          value4,
          value5,
          value6,
          state_name,
          attribute1,
          attribute2
         )
      VALUES
         (IN_record_type,
	  IN_gre_id,
          IN_pact_id,
          IN_chunk_number,
          IN_balance_nm1,
          IN_balance_nm2,  -- NULL
          IN_taxable,
          IN_withheld,
          IN_calculated,  -- NULL
          IN_difference,  -- NULL
          IN_asgn_action_id,
          L_jurisdiction,
          IN_message,
          IN_sort_code
         );

   G_commit_count := G_commit_count - 1;
   IF G_commit_count = 0 THEN
      COMMIT;
      G_commit_count := IN_commit_count;
   END IF;
 END prc_write_data;

 /*************************************************************************
 routine name: fnc_sit_exists
 purpose:      checks table pay_us_state_tax_info_f and return TRUE/FALSE
               based on value of column sit_exists.
 parameters:   IN_state_code    -
               IN_as_of_date   -
 return:       TRUE/FALSE
 specs:
 **************************************************************************/
 FUNCTION fnc_sit_exists(IN_state_code IN pay_us_states.state_code%TYPE,
                         IN_as_of_date IN DATE) RETURN BOOLEAN IS

/********************* 3005756 START ************************************/

    L_sit_exists pay_us_state_tax_info_f.sit_exists%TYPE;

 BEGIN

    IF pay_us_payroll_utils.ltr_state_tax_info.count < 1 THEN
       pay_us_payroll_utils.populate_jit_information ( p_effective_date => IN_as_of_date
                                                      ,p_get_state      => 'Y' );
    END IF;

    IF pay_us_payroll_utils.ltr_state_tax_info.exists(IN_state_code) THEN
       L_sit_exists := pay_us_payroll_utils.ltr_state_tax_info(IN_state_code).sit_exists ;
    END IF;

/************************** 3005756 END ********************************************/

    IF L_sit_exists = 'Y' THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
 END fnc_sit_exists;

 /*************************************************************************
 routine name: fnc_lit_tax_exists
 purpose:      checks table pay_us_city_tax_info_f and return TRUE/FALSE
               based on value of column city_tax or school_tax flag
               depending on IN_lit string.
               IF IN_lit is 'COUNTY' then checks table pay_us_county_tax_info_f
               and return TRUE/FALSE based on value of column county_tax.
 parameters:   IN_jurisdiction    -
               IN_as_of_date      -
               IN_lit             - string contain 'CITY' or 'SCHOOL' or 'COUNTY'
 return:       TRUE/FALSE
 specs:
 **************************************************************************/
 FUNCTION fnc_lit_tax_exists(IN_jurisdiction IN pay_us_county_tax_info_f.jurisdiction_code%TYPE,
                             IN_as_of_date   IN DATE,
                             IN_lit          IN VARCHAR2) RETURN BOOLEAN IS

/******************* 3005756 changes start *********************************/

   CURSOR c_check_city IS
      SELECT city_tax,school_tax
      FROM pay_us_city_tax_info_f
      WHERE jurisdiction_code = IN_jurisdiction
      AND IN_as_of_date BETWEEN effective_start_date AND effective_end_date;


   CURSOR c_check_county IS
       SELECT county_tax,school_tax
       FROM pay_us_county_tax_info_f
       WHERE jurisdiction_code = IN_jurisdiction
       AND IN_as_of_date BETWEEN effective_start_date AND effective_end_date;


   L_jurisdiction_code  VARCHAR2(11);
   L_city_tax           VARCHAR2(1);
   L_school_tax         VARCHAR2(1);
   L_county_tax         VARCHAR2(1);

   lv_state_code   VARCHAR2(20);
   lv_county_code  VARCHAR2(20);
   lv_city_code    VARCHAR2(20);
   lv_temp_code    VARCHAR2(20);
   ln_index_code   NUMBER;

   L_tax_flag VARCHAR2(1);

BEGIN

    lv_state_code  := substr(IN_jurisdiction,1,2);
    lv_county_code := substr(IN_jurisdiction,4,3);
    lv_city_code   := substr(IN_jurisdiction,8,4);

    lv_temp_code   := lv_state_code||lv_county_code||lv_city_code;
    ln_index_code  := to_number(lv_temp_code);


    IF IN_lit = 'CITY' THEN
       IF payusunb_pkg.city_tax_info.exists(ln_index_code) THEN
          L_tax_flag := payusunb_pkg.city_tax_info(ln_index_code).city_tax_exists;
       ELSE
          OPEN   c_check_city ;
	  FETCH  c_check_city INTO L_city_tax,L_school_tax;
          payusunb_pkg.city_tax_info(ln_index_code).jurisdiction_code  := IN_jurisdiction;
	  payusunb_pkg.city_tax_info(ln_index_code).city_tax_exists    := L_city_tax;
          payusunb_pkg.city_tax_info(ln_index_code).city_sd_tax_exists := L_school_tax;
	  CLOSE  c_check_city;
	  L_tax_flag := payusunb_pkg.city_tax_info(ln_index_code).city_tax_exists;
       END IF;

    ELSIF IN_lit = 'SCHOOL' THEN
       IF payusunb_pkg.city_tax_info.exists(ln_index_code) THEN
          L_tax_flag := payusunb_pkg.city_tax_info(ln_index_code).city_sd_tax_exists;
       ELSE
          OPEN   c_check_city ;
	  FETCH  c_check_city INTO L_city_tax,L_school_tax;
	  payusunb_pkg.city_tax_info(ln_index_code).jurisdiction_code  := IN_jurisdiction;
	  payusunb_pkg.city_tax_info(ln_index_code).city_tax_exists    := L_city_tax;
          payusunb_pkg.city_tax_info(ln_index_code).city_sd_tax_exists := L_school_tax;
	  CLOSE  c_check_city;
	  L_tax_flag := payusunb_pkg.city_tax_info(ln_index_code).city_sd_tax_exists;
       END IF;

    ELSIF IN_lit = 'COUNTY' THEN
       IF payusunb_pkg.county_tax_info.exists(ln_index_code) THEN
          L_tax_flag := payusunb_pkg.county_tax_info(ln_index_code).cnty_tax_exists;
       ELSE
          OPEN c_check_county;
          FETCH c_check_county INTO L_county_tax,L_school_tax;
          payusunb_pkg.county_tax_info(ln_index_code).jurisdiction_code    := IN_jurisdiction;
          payusunb_pkg.county_tax_info(ln_index_code).cnty_tax_exists      := L_county_tax;
          payusunb_pkg.county_tax_info(ln_index_code).cnty_sd_tax_exists   := L_school_tax;
	  CLOSE c_check_county;
	  L_tax_flag := payusunb_pkg.county_tax_info(ln_index_code).cnty_tax_exists;
       END IF;

     END IF;

  IF L_tax_flag = 'Y' THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

/****************************** 3005756 Changes End ********************************/

 END fnc_lit_tax_exists;


/************************* 2963239 Change *******************************************/

 /*************************************************************************
 routine name: prc_process_data
 purpose:      Does the entire processing for unacceptable balance report
               and Dumps the data to table PAY_US_RPT_TOTALS
 parameters:   IN_pact_id		-
               IN_chunk_no		-
	       IN_commit_count		-
	       IN_lockingactid		-
	       IN_lockedactid		-
	       IN_assignment_id		-
	       IN_tax_unit_id		-
	       IN_person_id		-
	       IN_location_id		-
	       IN_organization_id	-
	       IN_assignment_number	-

 return:       None
 specs:
 **************************************************************************/
 PROCEDURE prc_process_data(IN_pact_id			 IN pay_payroll_actions.payroll_action_id%TYPE,
                            IN_chunk_no			 IN NUMBER,
                            IN_commit_count		 IN NUMBER DEFAULT 1000,
			    IN_prc_lockingactid		 IN pay_assignment_actions.assignment_action_id%TYPE,
		            IN_prc_lockedactid		 IN pay_assignment_actions.assignment_action_id%TYPE,
	                    IN_prc_assignment_id	 IN pay_assignment_actions.assignment_id%TYPE,
	                    IN_prc_tax_unit_id		 IN pay_assignment_actions.tax_unit_id%TYPE,
	                    IN_prc_person_id		 IN per_all_assignments_f.person_id%TYPE,
	                    IN_prc_location_id		 IN per_all_assignments_f.location_id%TYPE,
	                    IN_prc_organization_id	 IN per_all_assignments_f.organization_id%TYPE,
	                    IN_prc_assignment_number	 IN per_all_assignments_f.assignment_number%TYPE ) IS

/****************************** END ***************************************************/


/*************************** 3005756 start **********************************************/
 -- Run Balance cursors
 -- get all state level jurisdiction codes for specified person
     CURSOR c_state_jurisdictions_valid(IN_person_id  IN per_people_f.person_id%TYPE,
                                        IN_state_code IN VARCHAR2,
                                        IN_start_date IN DATE,
                                        IN_as_of_date IN DATE) IS
       SELECT DISTINCT
              prb.jurisdiction_code||'-000-0000' jurisdiction_code,
              pus.state_code state_code,
              pus.state_abbrev
         FROM pay_run_balances prb,
              per_assignments_f paf,
              pay_us_states pus
        WHERE paf.person_id = IN_person_id
          AND prb.effective_date BETWEEN IN_start_date and IN_as_of_date
          AND prb.effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
          AND prb.assignment_id = paf.assignment_id
          AND prb.jurisdiction_code = pus.state_code
          AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL);


     -- get all county level jurisdiction codes for specified person
     CURSOR c_county_jurisdictions_valid(IN_person_id  IN per_people_f.person_id%TYPE,
                                         IN_state_code IN VARCHAR2,
                                         IN_start_date IN DATE,
                                         IN_as_of_date IN DATE) IS
       SELECT DISTINCT
              prb.jurisdiction_code||'-0000' jurisdiction_code,
              puc.county_name||','||pus.state_abbrev jurisdiction_name
         FROM pay_run_balances prb,
              per_assignments_f paf,
              pay_us_states pus,
              pay_us_counties puc
        WHERE paf.person_id = IN_person_id
          AND paf.effective_start_date <= IN_as_of_date
          AND paf.effective_end_date   >= IN_start_date
          AND prb.assignment_id = paf.assignment_id
          AND prb.effective_date BETWEEN paf.effective_start_date
                                    AND paf.effective_end_date
          AND prb.effective_date BETWEEN IN_start_date AND IN_as_of_date
          AND pus.state_code = prb.jurisdiction_comp1
          AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
          AND prb.jurisdiction_code = puc.state_code||'-'||puc.county_code
          AND pus.state_code = puc.state_code;


     -- get all city level jurisdiction codes for specified person
     CURSOR c_city_jurisdictions_valid(IN_person_id  IN per_people_f.person_id%TYPE,
                                       IN_state_code IN VARCHAR2,
                                       IN_start_date IN DATE,
                                       IN_as_of_date IN DATE) IS
       SELECT DISTINCT
              prb.jurisdiction_code,
              pun.city_name||','||pus.state_abbrev jurisdiction_name
         FROM pay_run_balances prb,
              per_assignments_f paf,
              pay_us_states pus,
              pay_us_city_names pun
        WHERE paf.person_id          = IN_person_id
          AND paf.effective_start_date <= IN_as_of_date
          AND paf.effective_end_date   >= IN_start_date
          AND paf.assignment_id      = prb.assignment_id
          AND prb.effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
          AND prb.effective_date BETWEEN IN_start_date AND IN_as_of_date
          AND prb.jurisdiction_code =
              pun.state_code||'-'||pun.county_code||'-'||pun.city_code
          AND pun.primary_flag = 'Y'
          AND prb.jurisdiction_comp2 = pun.county_code
          AND prb.jurisdiction_comp3 = pun.city_code
          AND pun.state_code = pus.state_code
          AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
          AND pus.state_code = prb.jurisdiction_comp1;


     -- get all city level jurisdiction codes for specified person
     CURSOR c_school_jurisdictions_valid(IN_person_id   IN per_people_f.person_id%TYPE,
                                         IN_state_code  IN VARCHAR2,
                                         IN_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE,
                                         IN_start_date  IN DATE,
                                         IN_as_of_date  IN DATE) IS
       SELECT DISTINCT
              prb.jurisdiction_code,
              psd.school_dst_name||','||pus.state_abbrev jurisdiction_name,
              psd.state_code||'-'||psd.county_code||'-'||psd.city_code reg_jurisdiction_cd
         FROM pay_run_balances prb,
              per_assignments_f paf,
              pay_us_states pus,
              pay_us_city_school_dsts psd
        WHERE paf.person_id = IN_person_id
          AND paf.effective_start_date <= IN_as_of_date
          AND paf.effective_end_date   >= IN_start_date
          AND paf.assignment_id         = prb.assignment_id
          AND prb.effective_date BETWEEN IN_start_date AND IN_as_of_date
          AND prb.effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
          AND prb.jurisdiction_code  = psd.state_code||'-'||psd.school_dst_code
          AND prb.jurisdiction_comp2 = psd.school_dst_code
          AND prb.jurisdiction_comp1 = psd.state_code
          AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
          AND prb.jurisdiction_comp1 = pus.state_code
          AND pus.state_code         = psd.state_code
       UNION ALL
       SELECT /*+ ORDERED */DISTINCT
              prb.jurisdiction_code,
              psd.school_dst_name||','||pus.state_abbrev jurisdiction_name,
              psd.state_code||'-'||psd.county_code||'-0000' reg_jurisdiction_cd
         FROM per_assignments_f paf,
              pay_run_balances prb,
              pay_us_states pus,
              pay_us_county_school_dsts psd
        WHERE paf.person_id = IN_person_id
          AND paf.effective_start_date <= IN_as_of_date
          AND paf.effective_end_date   >= IN_start_date
          AND prb.assignment_id         = paf.assignment_id
          AND prb.effective_date BETWEEN IN_start_date AND IN_as_of_date
          AND prb.effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
          AND prb.jurisdiction_code = psd.state_code||'-'||psd.school_dst_code
          AND prb.jurisdiction_comp2 = psd.school_dst_code
          AND prb.jurisdiction_comp1 = psd.state_code
          AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
          AND prb.jurisdiction_comp1 = pus.state_code
          AND pus.state_code         = psd.state_code;


--   Original run result cursors


     -- get all state level jurisdiction codes for specified person
     CURSOR c_state_jurisdictions(IN_person_id  IN per_people_f.person_id%TYPE,
                                  IN_state_code IN VARCHAR2,
                                  IN_start_date IN DATE,
                                  IN_as_of_date IN DATE) IS
       SELECT DISTINCT
             pes.jurisdiction_code,
             pes.state_code,
             pus.state_abbrev
        FROM pay_us_emp_state_tax_rules_f pes,
             per_assignments_f paf,
             pay_us_states pus
       WHERE pes.assignment_id = paf.assignment_id
         AND pes.state_code = pus.state_code
         AND paf.effective_start_date BETWEEN pes.effective_start_date
                                          AND pes.effective_end_date
         /* Change for Performance Bug 6360505 */
         AND IN_as_of_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         /* Change for Performance Bug 6360505 */
         AND IN_start_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         AND paf.person_id = IN_person_id
           /* Change for Performance Bug 7174993 */
            AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
        -- AND pus.state_code = NVL(IN_state_code, pus.state_code)
         AND EXISTS (
                SELECT 'X'
                  FROM pay_payroll_actions ppa,
                       pay_assignment_actions paa,
                       pay_run_results prr
                 WHERE action_type IN ('B','I','R','Q','V')
                   AND ppa.action_status = 'C'
                   AND ppa.effective_date BETWEEN IN_start_date
                                              AND IN_as_of_date
                   AND paa.payroll_action_id = ppa.payroll_action_id
                   AND paa.assignment_id = pes.assignment_id
                   AND prr.assignment_action_id = paa.assignment_action_id
                   AND prr.jurisdiction_code = pes.jurisdiction_code
                   AND rownum = 1);   -- added rownum to improve performance (Bug 3316599)



     -- get all county level jurisdiction codes for specified person
     CURSOR c_county_jurisdictions(IN_person_id  IN per_people_f.person_id%TYPE,
                                   IN_state_code IN VARCHAR2,
                                   IN_start_date IN DATE,
                                   IN_as_of_date IN DATE) IS
      SELECT DISTINCT  pes.jurisdiction_code,
             puc.county_name||','||pus.state_abbrev jurisdiction_name
        FROM pay_us_emp_county_tax_rules_f pes,
             per_assignments_f paf,
             pay_us_states pus,
             pay_us_counties puc
       WHERE pes.assignment_id = paf.assignment_id
         AND pes.state_code = pus.state_code
         AND pes.county_code = puc.county_code
         AND pes.state_code = puc.state_code
         AND paf.effective_start_date BETWEEN pes.effective_start_date
                                          AND pes.effective_end_date
        /* Change for Performance Bug 6360505 */
         AND IN_as_of_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         /* Change for Performance Bug 6360505 */
         AND IN_start_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         AND paf.person_id = IN_person_id
           /* Change for Performance Bug 7174993 */
            AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
         --AND pus.state_code = NVL(IN_state_code, pus.state_code)
         AND EXISTS (
                SELECT 'X'
                  FROM pay_payroll_actions ppa,
                       pay_assignment_actions paa,
                       pay_run_results prr
                 WHERE action_type IN ('B','I','R','Q','V')
                   AND ppa.action_status = 'C'
                   AND ppa.effective_date BETWEEN IN_start_date
                                              AND IN_as_of_date
                   AND paa.payroll_action_id = ppa.payroll_action_id
                   AND paa.assignment_id = pes.assignment_id
                   AND prr.assignment_action_id = paa.assignment_action_id
                   AND prr.jurisdiction_code = pes.jurisdiction_code
                   AND rownum = 1);  -- added rownum to improve performance (Bug 3316599)


     -- get all city level jurisdiction codes for specified person
     CURSOR c_city_jurisdictions(IN_person_id  IN per_people_f.person_id%TYPE,
                                 IN_state_code IN VARCHAR2,
                                 IN_start_date IN DATE,
                                 IN_as_of_date IN DATE) IS
      SELECT DISTINCT
             pes.jurisdiction_code,
             pun.city_name||','||pus.state_abbrev jurisdiction_name
        FROM pay_us_emp_city_tax_rules_f pes,
             per_assignments_f paf,
             pay_us_states pus,
             pay_us_city_names pun
       WHERE pes.assignment_id = paf.assignment_id
         AND pes.state_code = pus.state_code
         AND pes.state_code = pun.state_code
         AND pes.county_code = pun.county_code
         AND pes.city_code = pun.city_code
         AND paf.effective_start_date BETWEEN pes.effective_start_date
                                          AND pes.effective_end_date
         AND pun.primary_flag = 'Y'
         /* Change for Performance Bug 6360505 */
         AND IN_as_of_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         /* Change for Performance Bug 6360505 */
         AND IN_start_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         AND paf.person_id = IN_person_id
         /* Change for Performance Bug 7174993 */
            AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
         -- AND pus.state_code = NVL(IN_state_code, pus.state_code)
         AND EXISTS (
                SELECT 'X'
                  FROM pay_payroll_actions ppa,
                       pay_assignment_actions paa,
                       pay_run_results prr
                 WHERE action_type IN ('B','I','R','Q','V')
                   AND ppa.action_status = 'C'
                   AND ppa.effective_date BETWEEN IN_start_date
                                              AND IN_as_of_date
                   AND paa.payroll_action_id = ppa.payroll_action_id
                   AND paa.assignment_id = pes.assignment_id
                   AND prr.assignment_action_id = paa.assignment_action_id
                   AND prr.jurisdiction_code = pes.jurisdiction_code
                   AND rownum = 1); -- added rownum to improve performance (Bug 3316599)


     -- get all city level jurisdiction codes for specified person
     CURSOR c_school_jurisdictions(IN_person_id   IN per_people_f.person_id%TYPE,
                                   IN_state_code  IN VARCHAR2,
                                   IN_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE,
                                   IN_start_date  IN DATE,
                                   IN_as_of_date  IN DATE) IS
      SELECT DISTINCT
            pes.state_code||'-'||pes.school_district_code jurisdiction_code,
             psd.school_dst_name||','||pus.state_abbrev jurisdiction_name,
             pes.jurisdiction_code reg_jurisdiction_cd
        FROM pay_us_emp_city_tax_rules_f pes,
             per_assignments_f paf,
             pay_us_states pus,
             pay_us_city_school_dsts psd
       WHERE pes.assignment_id = paf.assignment_id
         AND pes.school_district_code IS NOT NULL
         AND pes.state_code = pus.state_code
         AND pes.school_district_code = psd.school_dst_code
         AND pes.state_code = psd.state_code
         AND pes.county_code = psd.county_code
         AND pes.city_code = psd.city_code
         AND paf.effective_start_date BETWEEN pes.effective_start_date
                                          AND pes.effective_end_date
        /* Change for Performance Bug 6360505 */
         AND IN_as_of_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         /* Change for Performance Bug 6360505 */
         AND IN_start_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         AND paf.person_id = IN_person_id
         --AND pus.state_code = NVL(IN_state_code, pus.state_code)
         /* Change for Performance Bug 7174993 */
            AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
         AND EXISTS (
                SELECT 'X'
                  FROM pay_payroll_actions ppa,
                       pay_assignment_actions paa,
                       pay_run_results prr
                 WHERE action_type IN ('B','I','R','Q','V')
                   AND ppa.action_status = 'C'
                   AND ppa.effective_date BETWEEN IN_start_date
                                              AND IN_as_of_date
                   AND paa.payroll_action_id = ppa.payroll_action_id
                   AND paa.assignment_id = pes.assignment_id
                   AND prr.assignment_action_id = paa.assignment_action_id
                   AND prr.jurisdiction_code = pes.state_code||'-'||pes.school_district_code
                   AND rownum = 1)   -- Added rownum for perfromance enhancement (Bug 3316599)
      UNION
      SELECT DISTINCT
             pes.state_code||'-'||pes.school_district_code jurisdiction_code,
             psd.school_dst_name||','||pus.state_abbrev jurisdiction_name,
             pes.jurisdiction_code reg_jurisdiction_cd
        FROM pay_us_emp_county_tax_rules_f pes,
             per_assignments_f paf,
             pay_us_states pus,
             pay_us_county_school_dsts psd
       WHERE pes.assignment_id = paf.assignment_id
         AND pes.school_district_code IS NOT NULL
         AND pes.state_code = pus.state_code
         AND pes.school_district_code = psd.school_dst_code
         AND pes.state_code = psd.state_code
         AND pes.county_code = psd.county_code
         AND paf.effective_start_date BETWEEN pes.effective_start_date
                                          AND pes.effective_end_date
        /* Change for Performance Bug 6360505 */
         AND IN_as_of_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         /* Change for Performance Bug 6360505 */
         AND IN_start_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
         AND paf.person_id = IN_person_id
         --AND pus.state_code = NVL(IN_state_code, pus.state_code)
         /* Change for Performance Bug 7174993 */
            AND (pus.state_code = IN_state_code
              OR IN_state_code IS NULL)
         AND EXISTS (
                SELECT 'X'
                  FROM pay_payroll_actions ppa,
                       pay_assignment_actions paa,
                       pay_run_results prr
                 WHERE action_type IN ('B','I','R','Q','V')
                   AND ppa.action_status = 'C'
                   AND ppa.effective_date BETWEEN IN_start_date
                                              AND IN_as_of_date
                   AND paa.payroll_action_id = ppa.payroll_action_id
                   AND paa.assignment_id = pes.assignment_id
                   AND prr.assignment_action_id = paa.assignment_action_id
                   AND prr.jurisdiction_code = pes.state_code||'-'||pes.school_district_code
                   AND rownum = 1);  -- Added rownum for perfromance enhancement (Bug 3316599)

/*************************************** 3005756 end ****************************************************/

     CURSOR c_get_sui_state_code (IN_business_id   IN NUMBER,
                                  IN_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
                                  IN_start_date    IN DATE,
                                  IN_as_of_date    IN DATE) IS
         SELECT NVL(sui_state_code,'00')
           FROM pay_us_emp_fed_tax_rules_f
          WHERE business_group_id = IN_business_id
            AND assignment_id = IN_assignment_id
            AND effective_start_date <= IN_start_date
            AND effective_end_date >= IN_as_of_date;

     L_as_of_date       DATE := NULL;
     L_start_date       DATE ;
     L_leg_param        pay_payroll_actions.legislative_parameters%TYPE;
     L_gre_id           pay_assignment_actions.tax_unit_id%TYPE;
     L_org_id           per_all_assignments_f.organization_id%TYPE;
     L_location_id      per_all_assignments_f.location_id%TYPE;
     L_business_id      per_all_assignments_f.business_group_id%TYPE;
     L_dimension        VARCHAR2(20) := NULL;
     L_tax_type         VARCHAR2(20) := NULL;
     L_tax_type_state   VARCHAR2(20) := NULL;
     L_usr_SDI_ER_rate  NUMBER := NULL;
     L_usr_SDI_EE_rate  NUMBER := NULL;
     L_asg_action_id    NUMBER ;
     L_first_half_date  DATE ;
     L_sui_state_code   VARCHAR2(2);
     L_calc_rate        NUMBER := NULL;
     L_dummy_rate       NUMBER ;
     L_futa_override_rt NUMBER := 0;
     L_futa_credit_rt   NUMBER := 0;
     L_first_half_rate  NUMBER ;
     L_second_half_rate NUMBER ;
     L_difference       NUMBER ;
     L_calculated       NUMBER ;
     L_medi_exempt      VARCHAR2(1);       -- added by tmehra
                                           -- for bug#1158217

     -- FUTA balance variables
     L_futa_bal                  NUMBER := 0;
     L_futa_tax                  NUMBER := 0;

     -- Medicare balance variables
     L_medi_ee_bal               NUMBER := 0;
     L_medi_ee_tax               NUMBER := 0;
     L_medi_er_bal               NUMBER := 0;
     L_medi_er_tax               NUMBER := 0;
     L_medi_er_liability         NUMBER := 0;

     -- SS balance variables
     L_ss_ee_bal                 NUMBER := 0;
     L_ss_ee_tax                 NUMBER := 0;
     L_ss_er_bal                 NUMBER := 0;
     L_ss_er_liability           NUMBER := 0;

     -- SUI balance variables(only for YTD )
     L_sui_ee_bal_first              NUMBER := 0;
     L_sui_er_bal_first              NUMBER := 0;

     L_sum_sui_er_bal            NUMBER := 0;
     L_sui_ee_tax                NUMBER := 0;
     L_sui_ee_bal                NUMBER := 0;
     L_sui_er_tax                NUMBER := 0;
     L_sui_er_bal                NUMBER := 0;
     L_sui_ee_subj_whable        NUMBER := 0;
     L_sui_er_subj_whable        NUMBER := 0;

     -- SDI balance variables
     L_sdi_ee_bal                NUMBER := 0;
     L_sdi_ee_tax                NUMBER := 0;
     L_sdi_er_bal                NUMBER := 0;
     L_sdi_er_tax                NUMBER := 0;
     L_sum_sdi_ee_bal            NUMBER := 0;
     L_sdi_ee_subj_whable        NUMBER := 0;
     L_sdi_ee_subj_nwhable       NUMBER := 0;

     -- SIT balance variables
     L_sit_ee_subject            NUMBER := 0;
     L_sit_ee_withheld           NUMBER := 0;
     L_sit_ee_pretax_redns       NUMBER := 0;
     L_sit_ee_subj_whable        NUMBER := 0;
     L_sit_ee_subj_nwhable       NUMBER := 0;
     L_sit_ee_reduced_s_whable   NUMBER := 0;

     --FIT balance variables
     L_fit_ee_gross_earnings     NUMBER := 0;
     L_fit_ee_reduced_s_whable   NUMBER := 0;
     L_fit_ee_tax                NUMBER := 0;
     L_fit_ee_subject            NUMBER := 0;

     -- these balances are for deriving other fit balances
     L_fit_ee_subj_whable        NUMBER := 0;
     L_fit_ee_subj_nwhable       NUMBER := 0;
     L_fit_ee_pretax_redns       NUMBER := 0;


     -- LIT City balance variables
     L_city_ee_tax               NUMBER := 0;
     L_city_ee_subject           NUMBER := 0;
     L_city_ee_r_s_whable        NUMBER := 0;
     L_city_ee_s_whable          NUMBER := 0;
     L_city_ee_s_nwhable         NUMBER := 0;

     -- LIT County balance variables
     L_county_ee_tax             NUMBER := 0;
     L_county_ee_subject         NUMBER := 0;
     L_county_ee_r_s_whable      NUMBER := 0;
     L_county_ee_s_whable        NUMBER := 0;
     L_county_ee_s_nwhable       NUMBER := 0;

     -- LIT School balance variables
     L_school_ee_tax             NUMBER := 0;
     L_school_ee_subject         NUMBER := 0;
     L_school_ee_r_s_whable      NUMBER := 0;
     L_school_ee_s_whable        NUMBER := 0;
     L_school_ee_s_nwhable       NUMBER := 0;

/****************** Bug 2963239 Changes start   ******************************************
*** Flags for SS and medicare balances.Set the flags when the balances are fetched  ******/

   L_medi_ee_bal_flg  VARCHAR2(1) := 'F';
   L_medi_er_bal_flg  VARCHAR2(1) := 'F';
   L_ss_ee_bal_flg    VARCHAR2(1) := 'F';
   L_ss_er_bal_flg    VARCHAR2(1) := 'F';




-- Message variables for prc_write_data

   L_balance_nm1      VARCHAR2(150);
   L_balance_nm2      VARCHAR2(150);
   L_main_mesg        VARCHAR2(150);

-----------------------------------------------
--
-- changes made be tmehra
--
    FUNCTION f_check_medi_exempt(f_assignment_id IN pay_assignment_actions.assignment_id%TYPE,
                                 f_start_date    IN DATE,
                                 f_as_of_date    IN DATE) RETURN VARCHAR2 IS

          CURSOR c_chk_medi_exempt(IN_assignment_id IN pay_assignment_actions.assignment_id%TYPE,
                                   IN_start_date    IN DATE,
                                   IN_as_of_date    IN DATE) IS
            SELECT medicare_tax_exempt
              FROM pay_us_emp_fed_tax_rules_v
             WHERE assignment_id = IN_assignment_id
               AND effective_start_date <= IN_start_date
               AND effective_end_date >= IN_as_of_date;

          l_exempt_status VARCHAR2(1);

    BEGIN

       l_exempt_status := 'N';

       FOR i in  c_chk_medi_exempt (f_assignment_id,
                                    f_start_date,
                                    f_as_of_date)
       LOOP
         l_exempt_status := i.medicare_tax_exempt;
       END LOOP;

       RETURN l_exempt_status;

   END; -- end of function f_check_medi_exempt


/******************************** 3005756 start ******************************************/

-- prc_federal_balances
-- prc_state_balances
-- prc_county_balances
-- prc_city_balances
-- prc_school_balances


PROCEDURE prc_federal_balances
IS
BEGIN
      IF L_tax_type IS NULL OR (L_tax_type <> 'SIT' AND L_tax_type <> 'LIT') THEN
              prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                              L_as_of_date, L_dimension, 'FIT', 'GROSS', 'EE',
                              NULL, L_fit_ee_gross_earnings);

      END IF;

     -- The following balance will be required if tax type is FIT or Medicare
      IF  (L_tax_type = 'FIT'   OR L_tax_type = 'Medicare'   OR L_tax_type = 'SIT'   OR L_tax_type IS NULL)
      AND L_medi_exempt = 'N'  THEN

           prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                           L_as_of_date, L_dimension, 'MEDICARE', 'TAXABLE', 'EE',
                           NULL, L_medi_ee_bal);
           L_medi_ee_bal_flg := 'T' ;

           -- added new pre-tax balance - tmehra
           prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                           L_as_of_date,L_dimension, 'FIT', 'PRE_TAX_REDNS', 'EE',
                           NULL, L_fit_ee_pretax_redns);

      END IF;

      -- if tax_type is anything but Medicare, SS, FUTA,
      -- then get subj whable balance for later use
      IF (L_tax_type <> 'Medicare' AND L_tax_type <> 'SS' AND L_tax_type <> 'FUTA')
      OR L_tax_type IS NULL  THEN
         prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                         L_as_of_date, L_dimension, 'FIT', 'SUBJ_WHABLE', 'EE',
                         NULL, L_fit_ee_subj_whable);
      END IF;

      IF L_tax_type = 'FIT' OR L_tax_type = 'SIT' OR L_tax_type IS NULL THEN

         L_fit_ee_reduced_s_whable := L_fit_ee_subj_whable - L_fit_ee_pretax_redns;

         prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                         L_as_of_date, L_dimension, 'FIT', 'SUBJ_NWHABLE', 'EE',
                         NULL, L_fit_ee_subj_nwhable);

        L_fit_ee_subject := L_fit_ee_subj_whable + L_fit_ee_subj_nwhable;

      END IF;

      IF L_tax_type = 'FIT' OR L_tax_type IS NULL THEN

	  prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                          L_as_of_date, L_dimension, 'FIT', 'WITHHELD', 'EE',
                          NULL, L_fit_ee_tax);

	  -- d)
	  IF L_fit_ee_subj_whable < L_fit_ee_reduced_s_whable THEN

               L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
               L_balance_nm2 := L_dimension || ' FIT Reduced Subject Withholdable';
               L_main_mesg   := '*** ' || L_dimension ||' FIT Subject Withholdable < ' || L_dimension ||
                                ' FIT Reduced Subject '||'Withholdable ***';

	       prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
                              L_balance_nm2,
                              L_fit_ee_subj_whable, L_fit_ee_reduced_s_whable,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
	                      L_asg_action_id,
	                      IN_prc_assignment_id );
            END IF;


            -- c)
            IF L_fit_ee_subj_whable <= 0 AND L_fit_ee_tax > 0 THEN

               L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
               L_balance_nm2 := L_dimension || ' FIT Withheld';
               L_main_mesg   := '*** ' || L_dimension ||' FIT Subject Withholdable <= 0 but ' ||
                                L_dimension || ' FIT '||'Withheld > 0 ***';

               prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_subj_whable, L_fit_ee_tax,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
	                      L_asg_action_id ,
	                      IN_prc_assignment_id );
            END IF;

            -- b)
            IF L_fit_ee_reduced_s_whable <= 0 AND L_fit_ee_tax > 0 THEN

               L_balance_nm1 := L_dimension || ' FIT Reduced Subject Withholdable';
	       L_balance_nm2 := L_dimension || ' FIT Withheld';
	       L_main_mesg   := '***  ' || L_dimension || ' FIT Reduced Subject Withholdable <= 0 but '||
	                        L_dimension || ' FIT '||'Withheld > 0 ***';

               prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_reduced_s_whable, L_fit_ee_tax,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
                              L_asg_action_id ,
                              IN_prc_assignment_id );
            END IF;

            -- a)
            IF L_fit_ee_gross_earnings < L_fit_ee_reduced_s_whable THEN

               L_balance_nm1 := L_dimension || ' FIT Gross Earnings';
	       L_balance_nm2 := L_dimension || ' FIT Reduced Subject Withholdable';
	       L_main_mesg   := '*** ' || L_dimension || ' FIT Gross Earnings < ' || L_dimension ||
	                        ' FIT Reduced Subject '||'Withholdable ***';

               prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_gross_earnings, L_fit_ee_reduced_s_whable,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id ,
			      IN_prc_assignment_id );
            END IF;

	   --8754952 BEGIN
	   IF L_fit_ee_reduced_s_whable < 0 THEN

	      L_balance_nm1 := L_dimension || ' FIT Reduced Subject Withholdable';
	      L_balance_nm2 := NULL;
	      L_main_mesg   := '*** ' || L_dimension || ' FIT Reduced Subject Withholdable < 0' ;

	               prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
	                              IN_prc_tax_unit_id,
	                              IN_prc_organization_id, IN_prc_location_id,
	   			      IN_pact_id,IN_chunk_no, IN_prc_person_id,
				      IN_prc_assignment_number,
			              L_balance_nm1,
				      L_balance_nm2,
			              L_fit_ee_reduced_s_whable,
			              NULL,
			              NULL, NULL, NULL,
			              L_main_mesg,
			              '00-000-0000',
				      L_asg_action_id ,
				      IN_prc_assignment_id );
	  END IF;
	  --8754952 END

       END IF;  -- end if 'FIT'

       -- Pull all federal level applicable FUTA balances
       IF L_tax_type = 'FUTA' OR L_tax_type IS NULL THEN

	     -- all applicable balances will be pulled beginning with Federal
             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                             L_as_of_date, L_dimension, 'FUTA', 'TAXABLE', 'ER', NULL, L_futa_bal);

             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                             L_as_of_date, L_dimension, 'FUTA', 'LIABILITY', 'ER', NULL, L_futa_tax);


            /***************************** 3005756 START *********************************/

            -- Value is fetched into the global variable in action_creation

            L_futa_override_rt := G_futa_override_rt ;

            /************************************** 3005756 END ******************************/

            IF L_futa_override_rt = 0 THEN
               BEGIN
                  OPEN c_get_sui_state_code(L_business_id, IN_prc_assignment_id,
                                            L_start_date, L_as_of_date);
                  FETCH c_get_sui_state_code INTO L_sui_state_code;
                  CLOSE c_get_sui_state_code;
               EXCEPTION
                  WHEN OTHERS THEN
                     L_sui_state_code := '00';
               END;




               IF L_sui_state_code <> '00' THEN
                  -- find for futa tax credit only if state found

               /**************************3005756 START ************************************/

                  L_futa_credit_rt := fnc_get_futa_credit_rate( IN_prc_organization_id, L_sui_state_code );

               /*********************** 3005656 END ******************************************/

               ELSE
                  L_futa_credit_rt := 0;
               END IF;

               L_calc_rate := (c_fixed_futa_rt - TO_NUMBER(L_futa_credit_rt))/100;
            ELSE
               L_calc_rate := L_futa_override_rt;
            END IF;

            IF L_dimension = 'QTD' THEN
		L_calculated := L_futa_bal * L_calc_rate;
            ELSE
                L_calculated := ROUND(L_futa_bal * L_calc_rate,2);
            END IF;


            IF ABS(L_futa_tax - L_calculated) > 0.1 THEN

               L_difference  := L_futa_tax - L_calculated; --Bug 3115988
	       L_balance_nm1 := L_dimension || ' FUTA Taxable';
	       L_balance_nm2 :=  NULL;
	       L_main_mesg   := '*** FUTA ER Liability does not = '||TO_CHAR(L_calc_rate*100)||'% of FUTA ER Taxable Balance ***';

               -- significant different found, write to tmp file for report
               prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
			      L_futa_bal, L_futa_tax,
                              L_calculated, L_difference, NULL,
                              L_main_mesg,
                              '00-000-0000',
	                      L_asg_action_id,
	                      IN_prc_assignment_id );
            END IF;


            -- e)
            IF L_fit_ee_gross_earnings < L_futa_bal THEN

               L_balance_nm1 := L_dimension || ' FIT Gross Earnings';
	       L_balance_nm2 := L_dimension || ' FUTA Taxable';
	       L_main_mesg   := '*** '|| L_dimension || ' FIT Gross Earnings < ' || L_dimension || ' FUTA Taxable ***';

               prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_gross_earnings, L_futa_bal,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
	                      L_asg_action_id,
	                      IN_prc_assignment_id );
            END IF;



         END IF;  -- end if 'FUTA'


	 -- Pull all federal level applicable Medicare balances
         -- tmehra added the L_medi_exempt condition
         IF (L_tax_type = 'Medicare' OR L_tax_type IS NULL) AND L_medi_exempt = 'N' THEN
             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'MEDICARE', 'WITHHELD', 'EE',
                            NULL, L_medi_ee_tax);

             L_calculated := ROUND(L_medi_ee_bal * G_medi_ee_rate,2);

             IF ABS(L_medi_ee_tax - L_calculated) > 0.1 THEN

		L_difference := L_medi_ee_tax - L_calculated;
                -- significant different found, write to tmp file for report

                L_balance_nm1 := L_dimension || ' MEDICARE EE Taxable';
		L_balance_nm2 := NULL;
	        L_main_mesg   := '*** Medicare Withheld does not = '||TO_CHAR(G_medi_ee_rate*100)||'% of Taxable Balance ***';
                prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
			      L_medi_ee_bal,
                              L_medi_ee_tax,
                              L_calculated, L_difference, NULL,
                              L_main_mesg,
                              '00-000-0000',
	                      L_asg_action_id,
	                      IN_prc_assignment_id );
             END IF;

             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'MEDICARE', 'TAXABLE', 'ER',
                            NULL, L_medi_er_bal);

             /********************* Bug 2963239 changes start : Set flag *******************************/

             L_medi_er_bal_flg := 'T' ;

             /******************** Bug  2963239 Changes End   ******************************************/

             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'MEDICARE', 'WITHHELD', 'ER',
                            NULL, L_medi_er_tax);

             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'MEDICARE', 'LIABILITY', 'ER',
                            NULL, L_medi_er_liability);

             L_calculated := ROUND(L_medi_er_bal * G_medi_er_rate,2);

             IF ABS(L_medi_er_tax - L_calculated) > 0.1 THEN

                L_difference := L_medi_er_tax - L_calculated;
                L_balance_nm1 := L_dimension || ' MEDICARE ER Taxable';
	        L_balance_nm2 :=  NULL;
	        L_main_mesg   := '*** Medicare Withheld does not = '||TO_CHAR(G_medi_er_rate*100)||'% of Taxable Balance ***';

                -- significant different found, write to tmp file for report
                prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
			      L_medi_er_bal,
                              L_medi_er_tax,
                              L_calculated, L_difference, NULL,
                              '*** Medicare Withheld does not = '||TO_CHAR(G_medi_er_rate*100)||'% of Taxable Balance ***',
                              '00-000-0000',
	                      L_asg_action_id ,
	                      IN_prc_assignment_id );
             END IF;


             -- g)
             IF L_medi_ee_tax <> L_medi_er_liability THEN

                L_balance_nm1 := L_dimension || ' Medicare EE Withheld';
	        L_balance_nm2 := L_dimension || ' Medicare ER Liability';
	        L_main_mesg   := '*** ' || L_dimension || ' Medicare EE Withheld does not = ' ||L_dimension ||
	                         ' Medicare ER Liability ***';

                prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_medi_ee_tax, L_medi_er_liability,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
             END IF;


             -- f)
             IF L_fit_ee_gross_earnings < L_medi_ee_bal THEN

                L_balance_nm1 := L_dimension || ' FIT Gross Earnings';
	        L_balance_nm2 := L_dimension || ' Medicare EE Taxable';
	        L_main_mesg   := '*** ' || L_dimension || ' FIT Gross Earnings < ' || L_dimension || ' Medicare EE Taxable ***';

                prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_gross_earnings, L_medi_ee_bal,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-00-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
             END IF;


	 END IF;  -- end if 'Medicare'


         -- Pull all federal level applicable Social Security balances
         IF L_tax_type = 'SS' OR L_tax_type IS NULL THEN

	    prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'SS', 'TAXABLE', 'EE', NULL, L_ss_ee_bal);

            /********************* Bug 2963239 changes start : Set flag *******************************/

            L_ss_ee_bal_flg := 'T' ;

            /******************** Bug  2963239 Changes End   ******************************************/

            prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'SS', 'WITHHELD', 'EE', NULL, L_ss_ee_tax);

            L_calculated := ROUND(L_ss_ee_bal * G_ss_ee_rate,2);

            IF ABS(L_ss_ee_tax - L_calculated) > 0.1 THEN

               L_difference := L_ss_ee_tax - L_calculated;
               L_balance_nm1 := L_dimension || ' SS EE Taxable';
	       L_balance_nm2 :=  NULL;
	       L_main_mesg   := '*** SS Withheld does not = '||TO_CHAR(G_ss_ee_rate*100)||'% of Taxable Balance ***';
               -- significant different found, write to tmp file for report
               prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
			      L_ss_ee_bal,L_ss_ee_tax,
                              L_calculated, L_difference, NULL,
                              L_main_mesg,
                              '00-000-0000',
	                      L_asg_action_id,
	                      IN_prc_assignment_id );
             END IF;

             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                             L_as_of_date, L_dimension, 'SS', 'TAXABLE', 'ER', NULL, L_ss_er_bal);


             /********************* Bug 2963239 changes start : Set flag *******************************/

             L_ss_er_bal_flg := 'T' ;

             /******************** Bug  2963239 Changes End   ******************************************/

             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'SS', 'LIABILITY', 'ER',
                            NULL, L_ss_er_liability);

             L_calculated := ROUND(L_ss_er_bal * G_ss_er_rate,2);


             IF ABS(L_ss_er_liability - L_calculated) > 0.1 THEN

                L_difference := L_ss_er_liability - L_calculated;
                -- significant different found, write to tmp file for report
                L_balance_nm1 := L_dimension || ' SS ER Taxable';
	        L_balance_nm2 :=  NULL;
	        L_main_mesg   := '*** SS Withheld does not = '||TO_CHAR(G_ss_er_rate*100)||'% of Taxable Balance ***';
               prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
			      L_ss_er_bal, L_ss_er_liability,
                              L_calculated, L_difference, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
            END IF;

            -- i)
            IF L_ss_ee_tax <> L_ss_er_liability THEN

                L_balance_nm1 := L_dimension || ' SS EE Withheld';
	        L_balance_nm2 := L_dimension || ' SS ER Liability';
	        L_main_mesg   := '*** ' || L_dimension || ' SS EE Withheld does not = ' || L_dimension || ' SS ER Liability ***';

               prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_ss_ee_tax, L_ss_er_liability,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
            END IF;


            -- h)
            IF L_fit_ee_gross_earnings < L_ss_ee_bal THEN

                L_balance_nm1 := L_dimension || ' FIT Gross Earnings';
	        L_balance_nm2 := L_dimension || ' SS EE Taxable';
	        L_main_mesg   := '*** ' || L_dimension || ' FIT Gross Earnings < ' || L_dimension || ' SS EE Taxable ***';

	       prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_gross_earnings, L_ss_ee_bal,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
            END IF;


         END IF;  -- end if 'SS'


/********************* Bug 2963239 Changes start: Extra check **********************************/

         IF L_tax_type = 'SS' or L_tax_type = 'Medicare' or L_tax_type IS NULL THEN

            IF L_medi_ee_bal_flg = 'F' THEN
               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                              L_as_of_date, L_dimension, 'MEDICARE', 'TAXABLE', 'EE',
                              NULL, L_medi_ee_bal);
            END IF;
            IF L_medi_er_bal_flg = 'F' THEN
               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'MEDICARE', 'TAXABLE', 'ER',
                            NULL, L_medi_er_bal);
            END IF;
            IF L_ss_ee_bal_flg = 'F' THEN
               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'SS', 'TAXABLE', 'EE', NULL, L_ss_ee_bal);
            END IF;
            IF L_ss_er_bal_flg = 'F' THEN
               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                            L_as_of_date, L_dimension, 'SS', 'TAXABLE', 'ER', NULL, L_ss_er_bal);
            END IF;


            IF  L_ss_ee_bal > L_medi_ee_bal  THEN

                L_balance_nm1 := L_dimension || ' MEDICARE EE Taxable';
                L_balance_nm2 := L_dimension || ' SS EE Taxable';
                L_main_mesg   := '*** ' || L_dimension || ' SS EE Taxable > ' || L_dimension || ' MEDICARE EE Taxable ***' ;

	       prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_medi_ee_bal, L_ss_ee_bal,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
            END IF;

            IF  L_ss_er_bal > L_medi_er_bal THEN

                L_balance_nm1 := L_dimension || ' MEDICARE ER Taxable';
	        L_balance_nm2 := L_dimension || ' SS ER Taxable';
	        L_main_mesg   := '*** ' || L_dimension || ' SS ER Taxable > ' || L_dimension || ' MEDICARE ER Taxable ***';

	       prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_medi_er_bal, L_ss_er_bal,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
            END IF;

         END IF;  -- ss or medicare

END prc_federal_balances ;



PROCEDURE prc_state_balances ( curr_jurisdiction_code IN VARCHAR2
                             , curr_state_code        IN VARCHAR2
			     , curr_state_abbrev      IN VARCHAR2)
IS
BEGIN
           IF L_tax_type = 'SIT' OR L_tax_type IS NULL THEN
		 prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
			         L_as_of_date, L_dimension, 'SIT', 'WITHHELD', 'EE',
				 curr_jurisdiction_code,
				 L_sit_ee_withheld);

		 prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
				 L_as_of_date, L_dimension, 'SIT', 'SUBJ_WHABLE', 'EE',
				 curr_jurisdiction_code,
				 L_sit_ee_subj_whable);

		 prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
			         L_as_of_date, L_dimension, 'SIT', 'SUBJ_NWHABLE', 'EE',
				 curr_jurisdiction_code,
				 L_sit_ee_subj_nwhable);

		 prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
			         L_as_of_date,L_dimension, 'SIT', 'PRE_TAX_REDNS', 'EE',
				 curr_jurisdiction_code,
				 L_sit_ee_pretax_redns);

		 L_sit_ee_subject := L_sit_ee_subj_whable + L_sit_ee_subj_nwhable;
	         L_sit_ee_reduced_s_whable := L_sit_ee_subj_whable - L_sit_ee_pretax_redns;

		 -- j)
                 IF L_sit_ee_subj_whable <= 0 AND L_sit_ee_withheld > 0 THEN

                     L_balance_nm1 := L_dimension || ' SIT Subject Withholdable';
		     L_balance_nm2 := L_dimension || ' SIT Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' SIT Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SIT Withheld > 0 ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_sit_ee_subj_whable, L_sit_ee_withheld,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id ,
				    IN_prc_assignment_id );
                  END IF;


                  -- l)
                  IF L_sit_ee_subj_whable < L_sit_ee_reduced_s_whable THEN

                     L_balance_nm1 := L_dimension || ' SIT Subject Withholdable';
		     L_balance_nm2 := L_dimension || ' SIT Reduced Subject Withholdable';
		     L_main_mesg   := '*** ' || L_dimension || ' SIT Subject Withholdable < ' || L_dimension ||
		                      ' SIT Reduced Subject Withholdable  ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
                                    L_balance_nm2,
                                    L_sit_ee_subj_whable, L_sit_ee_reduced_s_whable,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;


                  -- o)
                  IF L_fit_ee_subject < L_sit_ee_subject THEN

                     L_balance_nm1 := L_dimension || ' FIT Subject';
	             L_balance_nm2 := L_dimension || ' SIT Subject';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Subject < ' || L_dimension || ' SIT Subject ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_fit_ee_subject, L_sit_ee_subject,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id ,
				    IN_prc_assignment_id );
                  END IF;


                  -- k)
                  IF L_fit_ee_subj_whable <= 0 AND L_sit_ee_withheld > 0 THEN

                     L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
		     L_balance_nm2 := L_dimension || ' SIT Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SIT Withheld > 0 ***';
                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_fit_ee_subj_whable, L_sit_ee_withheld,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id ,
				    IN_prc_assignment_id );
                  END IF;


		  -- p)
                  IF L_sit_ee_withheld > 0 AND NOT
                     fnc_sit_exists(curr_state_code, L_as_of_date)
                  THEN

                     L_balance_nm1 := L_dimension || ' SIT Withheld';
		     L_balance_nm2 := ' ';
		     L_main_mesg   := '*** ' || L_dimension || ' SIT Withheld > 0 when state has no SIT '||'withholding rule ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_sit_ee_withheld, NULL,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id ,
				    IN_prc_assignment_id );
                  END IF;


              END IF;  -- end if 'SIT'


              -- don't bother checking if state is Hawaii or New York
              IF (L_tax_type = 'SDI' OR L_tax_type IS NULL) AND
                  curr_state_code NOT IN ('12','33')
              THEN
                  -- first get the rate, if user specified rate exists then use it, otherwise ...
                  IF L_usr_SDI_EE_rate IS NOT NULL THEN
                     L_calc_rate := L_usr_SDI_EE_rate/100;
                  ELSE
                     L_calc_rate := fnc_get_tax_limit_rate(curr_state_code,
                                                           L_start_date, L_as_of_date,
                                                           'SDI', 'EE','FULL');
                  END IF;

                  prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                  L_as_of_date, L_dimension, 'SDI', 'SUBJ_WHABLE', 'EE',
                                  curr_jurisdiction_code,
                                  L_sdi_ee_subj_whable);

                  prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                  L_as_of_date, L_dimension, 'SDI', 'SUBJ_NWHABLE', 'EE',
                                  curr_jurisdiction_code,
                                  L_sdi_ee_subj_nwhable);

                  prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                  L_as_of_date, L_dimension, 'SDI', 'TAXABLE', 'EE',
                                  curr_jurisdiction_code,
                                  L_sdi_ee_bal);

                  L_sum_sdi_ee_bal := L_sum_sdi_ee_bal + L_sdi_ee_bal;


                  prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                  L_as_of_date, L_dimension, 'SDI', 'WITHHELD', 'EE',
                                  curr_jurisdiction_code,
                                  L_sdi_ee_tax);

                  L_calculated := ROUND(L_sdi_ee_bal * L_calc_rate,2);


                  IF ABS(L_sdi_ee_tax - L_calculated) > 0.1 THEN

                     L_difference := L_sdi_ee_tax - L_calculated;
                     -- significant different found, write to tmp file for report
                     L_balance_nm1 := L_dimension || ' SDI EE Taxable';
		     L_balance_nm2 :=  NULL;
		     L_main_mesg   := '*** SDI EE Liability does not = '||TO_CHAR(L_calc_rate*100)||'% of SDI EE Taxable Balance ***';

                     prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
				    L_sdi_ee_bal, L_sdi_ee_tax,
                                    L_calculated, L_difference, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;


		  L_calc_rate := NULL;
                  IF L_usr_SDI_ER_rate IS NOT NULL THEN
                     L_calc_rate := L_usr_SDI_ER_rate/100;
                  ELSE

                  /****************************** 3005756 START ****************************************************/

		  L_calc_rate  := fnc_sui_sdi_override( IN_prc_tax_unit_id , curr_state_code ,'SDI' );

                  /************************************* 3005756 END *******************************************/

                     IF L_calc_rate IS NULL THEN
                        L_calc_rate := fnc_get_tax_limit_rate(curr_state_code, L_start_date,
                                                           L_as_of_date, 'SDI', 'ER','FULL');
                     END IF;
                  END IF;

                  prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                  L_as_of_date, L_dimension, 'SDI', 'TAXABLE', 'ER',
                                  curr_jurisdiction_code,
                                  L_sdi_er_bal);

                  prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                  L_as_of_date, L_dimension, 'SDI', 'LIABILITY', 'ER',
                                  curr_jurisdiction_code,
                                  L_sdi_er_tax);


                  L_calculated := ROUND(L_sdi_er_bal * L_calc_rate,2);


                  IF ABS(L_sdi_er_tax - L_calculated) > 0.1 THEN

		     L_difference := L_sdi_er_tax - L_calculated;
                     -- significant different found, write to tmp file for report
                     L_balance_nm1 := L_dimension || ' SDI ER Taxable';
		     L_balance_nm2 :=  NULL;
		     L_main_mesg   := '*** SDI ER Liability does not = '||TO_CHAR(L_calc_rate*100)||'% of SDI ER Taxable Balance ***';

                     prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
				    L_sdi_er_bal, L_sdi_er_tax,
                                    L_calculated, L_difference, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;


                  -- u)
                  IF L_sdi_ee_subj_whable <= 0 AND L_sdi_ee_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' SDI EE Subject Withholdable';
	             L_balance_nm2 := L_dimension || ' SDI EE Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' SDI EE Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SDI EE Withheld > 0 ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_sdi_ee_subj_whable, L_sdi_ee_tax,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;


                  -- v)
                  IF L_fit_ee_subj_whable <= 0 AND L_sdi_ee_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
		     L_balance_nm2 := 'YTD SDI EE Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SDI EE Withheld > 0 ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_fit_ee_subj_whable, L_sdi_ee_tax,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;


                  -- v)
                  IF L_fit_ee_subj_whable <= 0 AND L_sdi_er_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
	             L_balance_nm2 := L_dimension || ' SDI ER Liability';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SDI ER Withheld > 0 ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_fit_ee_subj_whable, L_sdi_er_tax,
                                    NULL, NULL, curr_state_abbrev,
                                    L_main_mesg,
                                    curr_state_code||'-000-0000',
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;


		  -- t)
                  IF L_fit_ee_gross_earnings < L_sum_sdi_ee_bal THEN

                     L_balance_nm1 := L_dimension || ' FIT Gross Earnings';
		     L_balance_nm2 := 'TOTAL ' || L_dimension || ' SDI EE Taxable';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Gross Earnings < TOTAL ' || L_dimension ||
		                      ' SDI EE Taxable ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_gross_earnings, L_sum_sdi_ee_bal,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
                  END IF;


               END IF;  -- end if 'SDI'



               IF L_tax_type = 'SUI' OR L_tax_type IS NULL THEN
                     L_calc_rate := fnc_get_tax_limit_rate(curr_state_code, L_start_date,
                                                           L_as_of_date, 'SUI', 'EE','FULL');

                     prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                     L_as_of_date, L_dimension, 'SUI', 'TAXABLE', 'EE',
                                     curr_jurisdiction_code,
                                     L_sui_ee_bal);

                     prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                     L_as_of_date, L_dimension, 'SUI', 'WITHHELD', 'EE',
                                     curr_jurisdiction_code,
                                     L_sui_ee_tax);


                     IF L_dimension = 'QTD' THEN

		       /******************* QTD **************************************/

                       L_calculated := ROUND(L_sui_ee_bal * L_calc_rate,2);

		       IF ABS(L_sui_ee_tax - L_calculated) > 0.1 THEN

                          L_difference := L_sui_ee_tax - L_calculated;
                          -- significant different found, write to tmp file for report
			  L_balance_nm1 := 'QTD SUI EE Taxable';
			  L_balance_nm2 :=  NULL;
			  L_main_mesg   := '*** SUI EE Liability does not = '||TO_CHAR(L_calc_rate*100)||'% of SUI EE Taxable Balance ***';

                          prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id, IN_prc_location_id,
                                       IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
				       L_sui_ee_bal, L_sui_ee_tax,
                                       L_calculated, L_difference, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id ,
				       IN_prc_assignment_id );
                       END IF;



                       -- Now do the ER SUI portion
                       -- First check if SUI override rate is entered by user
                       L_calc_rate := NULL;

                       /********************************** 3005756 START *******************************************/

                       L_calc_rate  := fnc_sui_sdi_override( IN_prc_tax_unit_id, curr_state_code , 'C' );
		       L_dummy_rate := fnc_sui_sdi_override( IN_prc_tax_unit_id, curr_state_code , 'D' );

                       /********************************** 3005756 END **********************************************/


                       IF L_calc_rate IS NULL THEN
                          L_calc_rate := fnc_get_tax_limit_rate(curr_state_code, L_start_date,
                                                                L_as_of_date, 'SUI', 'ER','FULL');
                       END IF;

                       /******************************* QTD *********************************************/

                    END IF; -- QTD

                    prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                     L_as_of_date, L_dimension, 'SUI', 'TAXABLE', 'ER',
                                     curr_jurisdiction_code,
                                     L_sui_er_bal);

                    L_sum_sui_er_bal := L_sum_sui_er_bal + L_sui_er_bal;


		    prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                     L_as_of_date, L_dimension, 'SUI', 'LIABILITY', 'ER',
                                     curr_jurisdiction_code,
                                     L_sui_er_tax);

                    IF L_dimension = 'QTD' THEN

		       /**************************   QTD    ********************************/
                       L_calculated := ROUND(L_sui_er_bal * L_calc_rate,2);

                       IF ABS(L_sui_er_tax - L_calculated) > 0.1 THEN

                          L_difference := L_sui_er_tax - L_calculated;
                          -- significant different found, write to tmp file for report
			  L_balance_nm1 := 'QTD SUI ER Taxable';
			  L_balance_nm2 :=  NULL ;
			  L_main_mesg   := '*** SUI ER Liability does not = '||TO_CHAR(L_calc_rate*100)||'% of SUI ER Taxable Balance ***';

			  prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id, IN_prc_location_id,
                                       IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
				       L_sui_er_bal, L_sui_er_tax,
                                       L_calculated, L_difference, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id,
				       IN_prc_assignment_id );
                       END IF;

                       /************************   QTD   ***********************************/

                     END IF;  -- QTD

		     prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                       L_as_of_date, L_dimension, 'SUI', 'SUBJ_WHABLE', 'EE',
                                       curr_jurisdiction_code,
                                       L_sui_ee_subj_whable);


                     prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                                     L_as_of_date, L_dimension, 'SUI', 'SUBJ_WHABLE', 'ER',
                                     curr_jurisdiction_code,
                                     L_sui_er_subj_whable);

                   IF L_dimension = 'YTD' THEN

		      /******************   YTD   *************************************/

                     -- only do this if state is New Hampshire, New Jersey, Tennessee, Vermont and
                     -- dimension is YTD
                     IF curr_state_code IN (30, 31, 43, 46) AND
                        L_as_of_date > L_first_half_date THEN

                        -- get the rates from jan 1 to end of june and for july 1 to as_of_date
                        L_first_half_rate := fnc_get_tax_limit_rate(curr_state_code,
                                                 L_start_date, L_first_half_date, 'SUI', 'EE','FIRST');

                        L_second_half_rate := fnc_get_tax_limit_rate(curr_state_code,
                                              L_first_half_date+1, L_as_of_date, 'SUI', 'EE','LAST');

                        -- get ee balance for first 6 months
                        BEGIN
                        L_sui_ee_bal_first := pay_us_tax_bals_pkg.us_tax_balance
                                              ('TAXABLE',
                                               'SUI',
                                               'EE',
                                               'YTD',
                                               'ASG',
                                               IN_prc_tax_unit_id,
                                               curr_jurisdiction_code,
                                               NULL,
                                               L_asg_action_id,
                                               L_first_half_date,
                                               NULL,
                                               TRUE);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              L_sui_ee_bal_first := 0;
                           WHEN OTHERS THEN
                              RAISE;
                        END;
                        -- now combine first and second half to make complete ee balance
                        L_calculated := ROUND((L_sui_ee_bal_first * L_first_half_rate)
                                              + ((L_sui_ee_bal-L_sui_ee_bal_first)
                                              *L_second_half_rate),2);

                        -- now check if ee difference is erroneous
                        IF ABS(L_sui_ee_tax - L_calculated) > 0.1 THEN

			   L_difference := L_sui_ee_tax - L_calculated;
                           -- significant different found, write to tmp file for report
                           L_balance_nm1 := 'YTD SUI EE Taxable';
			   L_balance_nm2 :=  NULL;
			   L_main_mesg   := '*** SUI EE Liability does not = 1st half year '||
			                    TO_CHAR(L_first_half_rate*100)||'%, 2nd half year '
					    ||TO_CHAR(L_second_half_rate*100)||'% of SUI EE Taxable Balance ***';

			   prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                          IN_prc_tax_unit_id,
                                          IN_prc_organization_id,
                                          IN_prc_location_id, IN_pact_id,
                                          IN_chunk_no, IN_prc_person_id,
                                          IN_prc_assignment_number,
                                          L_balance_nm1,
					  L_balance_nm2,
                                          L_sui_ee_bal, L_sui_ee_tax,
                                          L_calculated, L_difference, curr_state_abbrev,
                                          L_main_mesg,
                                          curr_state_code||'-000-0000',
					  L_asg_action_id,
					  IN_prc_assignment_id );
                        END IF;

                        -- now do the ER portion
                        -- First check if SUI override rate is entered by user

                        /************************************* 3005756 START ****************************************/

			L_first_half_rate  := fnc_sui_sdi_override( IN_prc_tax_unit_id , curr_state_code ,'C' );
                        L_second_half_rate  := fnc_sui_sdi_override( IN_prc_tax_unit_id , curr_state_code ,'D' );

                        /************************************* 3005756 END *******************************************/

                        IF L_first_half_rate IS NULL THEN
                           L_first_half_rate := fnc_get_tax_limit_rate(curr_state_code,
                                                   L_start_date, L_first_half_date, 'SUI', 'ER','FIRST');
                        END IF;

                        IF L_second_half_rate IS NULL THEN
                           L_second_half_rate := fnc_get_tax_limit_rate(curr_state_code,
                                                 L_first_half_date+1, L_as_of_date, 'SUI', 'ER','LAST');
                        END IF;

                        -- get er balance for first 6 months
                        BEGIN
                        L_sui_er_bal_first := pay_us_tax_bals_pkg.us_tax_balance
                                              ('TAXABLE',
                                               'SUI',
                                               'ER',
                                               'YTD',
                                               'ASG',
                                               IN_prc_tax_unit_id,
                                               curr_jurisdiction_code,
                                               NULL,
                                               L_asg_action_id,
                                               L_first_half_date,
                                               NULL,
                                               TRUE);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              L_sui_er_bal_first := 0;
                           WHEN OTHERS THEN
                              RAISE;
                        END;

                        -- now combine first and second half to make complete er balance
                        L_calculated := ROUND((L_sui_er_bal_first * L_first_half_rate)
                                            + ((L_sui_er_bal - L_sui_er_bal_first)
                                            *L_second_half_rate),2);

                        -- now check if ee difference is erroneous
                        IF ABS(L_sui_er_tax - L_calculated) > 0.1 THEN

                           L_difference := L_sui_er_tax - L_calculated;
                           -- significant different found, write to tmp file for report
			   L_balance_nm1 := 'YTD SUI ER Taxable';
			   L_balance_nm2 :=  NULL;
			   L_main_mesg   :=  '*** SUI ER Liability does not = 1st 6 month rate '||
                                             TO_CHAR(L_first_half_rate*100)||
                                             '%, last 6 month rate '||
                                             TO_CHAR(L_second_half_rate*100)||
                                             '% of SUI ER Taxable Balance ***';

                           prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                          IN_prc_tax_unit_id,
                                          IN_prc_organization_id,
                                          IN_prc_location_id, IN_pact_id,
                                          IN_chunk_no, IN_prc_person_id,
                                          IN_prc_assignment_number,
                                          L_balance_nm1,
					  L_balance_nm2,
                                          L_sui_er_bal, L_sui_er_tax,
                                          L_calculated, L_difference, curr_state_abbrev,
                                          L_main_mesg,
                                          curr_state_code||'-000-0000',
					  L_asg_action_id,
					  IN_prc_assignment_id );
                        END IF;
                  ELSE
                     L_calc_rate := fnc_get_tax_limit_rate(curr_state_code, L_start_date,
                                                           L_as_of_date, 'SUI', 'EE','FULL');

                     L_calculated := ROUND(L_sui_ee_bal * L_calc_rate,2);

                     IF ABS(L_sui_ee_tax - L_calculated) > 0.1 THEN

                        L_difference := L_sui_ee_tax - L_calculated;
                        -- significant different found, write to tmp file for report
                        L_balance_nm1 := 'YTD SUI EE Taxable';
		        L_balance_nm2 :=  NULL;
			L_main_mesg   :=  '*** SUI EE Liability does not = '||TO_CHAR(L_calc_rate*100)||'% of SUI EE Taxable Balance ***';

			prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id,
                                       IN_prc_location_id, IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
                                       L_sui_ee_bal, L_sui_ee_tax,
                                       L_calculated, L_difference, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id,
				       IN_prc_assignment_id );
                     END IF;

                     -- Now do the ER portion
                     -- First check if SUI override rate is entered by user
                     L_calc_rate := NULL;


                     /*********************************** 3005756 START ****************************************/

		     L_calc_rate  := fnc_sui_sdi_override( IN_prc_tax_unit_id , curr_state_code ,'C' );
                     L_dummy_rate  := fnc_sui_sdi_override( IN_prc_tax_unit_id , curr_state_code ,'D' );

                     /************************************* 3005756 END *******************************************/

                     IF L_calc_rate IS NULL THEN
                        L_calc_rate := fnc_get_tax_limit_rate(curr_state_code, L_start_date,
                                                           L_as_of_date, 'SUI', 'ER','FULL');
                     END IF;

                     L_calculated := ROUND(L_sui_er_bal * L_calc_rate,2);

                     IF ABS(L_sui_er_tax - L_calculated) > 0.1 THEN

                        L_difference := L_sui_er_tax - L_calculated;
                        -- significant different found, write to tmp file for report
                        L_balance_nm1 := 'YTD SUI ER Taxable';
		        L_balance_nm2 :=  NULL;
			L_main_mesg   := '*** SUI ER Liability does not = '||TO_CHAR(L_calc_rate*100)||'% of SUI ER Taxable Balance ***';

                        prc_write_data(IN_commit_count,'V', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id,
                                       IN_prc_location_id, IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
                                       L_sui_er_bal, L_sui_er_tax,
                                       L_calculated, L_difference, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id,
				       IN_prc_assignment_id );
                     END IF;

                  END IF;  -- end if curr_state_code IN (30, 31, 43, 46)

                 /****************** YTD     ****************************************/

	      END IF; -- YTD

              -- q)
              IF L_sui_ee_subj_whable <= 0 AND L_sui_ee_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' SUI EE Subject Withholdable';
	             L_balance_nm2 := L_dimension || ' SUI EE Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' SUI EE Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SUI EE Withheld > 0 ***';

                        prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id, IN_prc_location_id,
                                       IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
                                       L_sui_ee_subj_whable, L_sui_ee_tax,
                                       NULL, NULL, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id,
				       IN_prc_assignment_id );
               END IF;

              -- q)
              IF L_sui_er_subj_whable <= 0 AND L_sui_er_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' SUI ER Subject Withholdable';
		     L_balance_nm2 := L_dimension || ' SUI ER Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' SUI ER Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SUI ER Withheld > 0 ***';

                        prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id, IN_prc_location_id,
                                       IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
                                       L_sui_er_subj_whable, L_sui_er_tax,
                                       NULL, NULL, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id,
				       IN_prc_assignment_id );
              END IF;


              -- s)
              IF L_fit_ee_subj_whable <= 0 AND L_sui_ee_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
		     L_balance_nm2 := L_dimension || ' SUI EE Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SUI EE Withheld > 0 ***';

                        prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id, IN_prc_location_id,
                                       IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
                                       L_fit_ee_subj_whable, L_sui_ee_tax,
                                       NULL, NULL, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id,
				       IN_prc_assignment_id );
               END IF;


               -- s)
               IF L_fit_ee_subj_whable <= 0 AND L_sui_er_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
		     L_balance_nm2 := L_dimension || ' SUI ER Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                      ' SUI ER Withheld > 0 ***';

                        prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                       IN_prc_tax_unit_id,
                                       IN_prc_organization_id, IN_prc_location_id,
                                       IN_pact_id,
                                       IN_chunk_no, IN_prc_person_id,
                                       IN_prc_assignment_number,
                                       L_balance_nm1,
				       L_balance_nm2,
                                       L_fit_ee_subj_whable, L_sui_er_tax,
                                       NULL, NULL, curr_state_abbrev,
                                       L_main_mesg,
                                       curr_state_code||'-000-0000',
				       L_asg_action_id,
				       IN_prc_assignment_id );
                END IF;


                -- r)
                IF L_fit_ee_gross_earnings < L_sum_sui_er_bal THEN

                     L_balance_nm1 := L_dimension || ' FIT Gross Earnings';
		     L_balance_nm2 := 'TOTAL ' || L_dimension || ' SUI ER Taxable';
		     L_main_mesg   := '*** ' || L_dimension || ' FIT Gross Earnings < TOTAL ' || L_dimension ||
		                      ' SUI ER Taxable ***';

                        prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                              IN_prc_tax_unit_id,
                              IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                              IN_chunk_no, IN_prc_person_id, IN_prc_assignment_number,
                              L_balance_nm1,
			      L_balance_nm2,
                              L_fit_ee_gross_earnings, L_sum_sui_er_bal,
                              NULL, NULL, NULL,
                              L_main_mesg,
                              '00-000-0000',
			      L_asg_action_id,
			      IN_prc_assignment_id );
                END IF;


               END IF;  -- end if 'SUI'


END prc_state_balances ;


PROCEDURE prc_county_balances ( curr_jurisdiction_code IN VARCHAR2
                              , curr_jurisdiction_name IN VARCHAR2 )
IS
BEGIN
             prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'COUNTY', 'WITHHELD', 'EE',
                               curr_jurisdiction_code,
                               L_county_ee_tax);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'COUNTY', 'SUBJ_WHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_county_ee_s_whable);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'COUNTY', 'SUBJ_NWHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_county_ee_s_nwhable);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'COUNTY', 'REDUCED_SUBJ_WHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_county_ee_r_s_whable);


              L_county_ee_subject := L_county_ee_s_whable + L_county_ee_s_nwhable;


              -- y)
              IF L_county_ee_s_whable < L_county_ee_r_s_whable THEN

		  L_balance_nm1 := L_dimension || ' COUNTY EE Subject Withholdable';
		  L_balance_nm2 := L_dimension || ' COUNTY EE Reduced Subject Withholdable';
		  L_main_mesg   := '*** ' || L_dimension || ' COUNTY EE Subject Withholdable < ' || L_dimension ||
		                   ' COUNTY EE '||'Reduced Subject Withholdable ***';

                  prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                 IN_prc_tax_unit_id,
                                 IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                                 IN_chunk_no, IN_prc_person_id,
                                 IN_prc_assignment_number,
                                 L_balance_nm1,
                                 L_balance_nm2,
                                 L_county_ee_s_whable, L_county_ee_r_s_whable,
                                 NULL, NULL, curr_jurisdiction_name,
                                 L_main_mesg,
                                 SUBSTR(curr_jurisdiction_code,1,6)||'-0000',
				 L_asg_action_id ,
				 IN_prc_assignment_id );
               END IF;

               -- x)
               IF L_fit_ee_subj_whable <= 0 AND L_county_ee_tax > 0 THEN

		  L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
		  L_balance_nm2 := L_dimension || ' County Withheld';
		  L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                   ' County '||'Withheld > 0 ***';

                  prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                 IN_prc_tax_unit_id,
                                 IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                                 IN_chunk_no, IN_prc_person_id,
                                 IN_prc_assignment_number,
                                 L_balance_nm1,
				 L_balance_nm2,
                                 L_fit_ee_subj_whable, L_county_ee_tax,
                                 NULL, NULL, curr_jurisdiction_name,
                                 L_main_mesg,
                                 SUBSTR(curr_jurisdiction_code,1,6)||'-0000',
				 L_asg_action_id,
				 IN_prc_assignment_id );
               END IF;


               -- w)
               IF fnc_lit_tax_exists(curr_jurisdiction_code, L_as_of_date, 'COUNTY') THEN
                  IF L_county_ee_subject <= 0 AND L_county_ee_tax > 0 THEN

		     L_balance_nm1 := L_dimension || ' County Subject';
		     L_balance_nm2 := L_dimension || ' County Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' County Subject <= 0 and ' || L_dimension ||
		                      ' County Withheld > 0 ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_county_ee_subject, L_county_ee_tax,
                                    NULL, NULL, curr_jurisdiction_name,
                                    L_main_mesg,
                                    SUBSTR(curr_jurisdiction_code,1,6)||'-0000',
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;
                END IF;  -- w)


END prc_county_balances ;


PROCEDURE prc_city_balances ( curr_jurisdiction_code IN VARCHAR2
                            , curr_jurisdiction_name IN VARCHAR2 )
IS
BEGIN
               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'CITY', 'WITHHELD', 'EE',
                               curr_jurisdiction_code,
                               L_city_ee_tax);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'CITY', 'SUBJ_WHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_city_ee_s_whable);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date,L_dimension, 'CITY', 'SUBJ_NWHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_city_ee_s_nwhable);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'CITY', 'REDUCED_SUBJ_WHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_city_ee_r_s_whable);

               L_city_ee_subject := L_city_ee_s_whable + L_city_ee_s_nwhable;

               -- y)
               IF L_city_ee_s_whable < L_city_ee_r_s_whable THEN

                  L_balance_nm1 := L_dimension || ' CITY EE Subject Withholdable';
		  L_balance_nm2 := L_dimension || ' CITY EE Reduced Subject Withholdable';
		  L_main_mesg   := '*** ' || L_dimension || ' CITY EE Subject Withholdable < ' || L_dimension ||
		                   ' CITY EE Reduced '||'Subject Withholdable ***';

                  prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                 IN_prc_tax_unit_id,
                                 IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                                 IN_chunk_no, IN_prc_person_id,
                                 IN_prc_assignment_number,
                                 L_balance_nm1,
                                 L_balance_nm2,
                                 L_city_ee_s_whable, L_city_ee_r_s_whable,
                                 NULL, NULL, curr_jurisdiction_name,
                                 L_main_mesg,
                                 curr_jurisdiction_code,
				 L_asg_action_id,
				 IN_prc_assignment_id );
               END IF;


               -- x)
               IF L_fit_ee_subj_whable <= 0 AND L_city_ee_tax > 0 THEN

                  L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
                  L_balance_nm2 := L_dimension || ' City Withheld';
		  L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                   ' City '||'Withheld > 0 ***';


                  prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                 IN_prc_tax_unit_id,
                                 IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                                 IN_chunk_no, IN_prc_person_id,
                                 IN_prc_assignment_number,
                                 L_balance_nm1,
				 L_balance_nm2,
                                 L_fit_ee_subj_whable, L_city_ee_tax,
                                 NULL, NULL, curr_jurisdiction_name,
                                 L_main_mesg,
                                 curr_jurisdiction_code,
				 L_asg_action_id,
				 IN_prc_assignment_id );
               END IF;


               -- w)
               IF fnc_lit_tax_exists(curr_jurisdiction_code, L_as_of_date, 'CITY') THEN
                  IF L_city_ee_subject <= 0 AND L_city_ee_tax > 0 THEN

		     L_balance_nm1 := L_dimension || ' City Subject';
		     L_balance_nm2 := L_dimension || ' City Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' City Subject <= 0 and ' || L_dimension ||
		                      ' City Withheld > 0 ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_city_ee_subject, L_city_ee_tax,
                                    NULL, NULL, curr_jurisdiction_name,
                                    L_main_mesg,
                                    curr_jurisdiction_code,
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;
               END IF;


END prc_city_balances ;



PROCEDURE prc_school_balances ( curr_jurisdiction_code   IN VARCHAR2
                                  , curr_jurisdiction_name   IN VARCHAR2
				  , curr_reg_jurisdiction_cd IN VARCHAR2 )
IS
BEGIN
               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'SCHOOL', 'WITHHELD', 'EE',
                               curr_jurisdiction_code,
                               L_school_ee_tax);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'SCHOOL', 'SUBJ_WHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_school_ee_s_whable);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'SCHOOL', 'SUBJ_NWHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_school_ee_s_nwhable);

               prc_get_balance(L_asg_action_id, IN_prc_tax_unit_id,
                               L_as_of_date, L_dimension, 'SCHOOL', 'REDUCED_SUBJ_WHABLE', 'EE',
                               curr_jurisdiction_code,
                               L_school_ee_r_s_whable);

               L_school_ee_subject := L_school_ee_s_whable + L_school_ee_s_nwhable;


               -- y)
               IF L_school_ee_s_whable < L_school_ee_r_s_whable THEN

		  L_balance_nm1 := L_dimension || ' SCHOOL EE Subject Withholdable';
		  L_balance_nm2 := L_dimension || ' SCHOOL EE Reduced Subject Withholdable';
		  L_main_mesg   := '*** ' || L_dimension || ' SCHOOL EE Subject Withholdable < ' || L_dimension ||
		                   ' SCHOOL EE '||'Reduced Subject Withholdable ***';

                  prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                 IN_prc_tax_unit_id,
                                 IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                                 IN_chunk_no, IN_prc_person_id,
                                 IN_prc_assignment_number,
                                 L_balance_nm1,
                                 L_balance_nm2,
                                 L_school_ee_s_whable, L_school_ee_r_s_whable,
                                 NULL, NULL, curr_jurisdiction_name,
                                 L_main_mesg,
                                 curr_reg_jurisdiction_cd,
				 L_asg_action_id,
				 IN_prc_assignment_id );
               END IF;


               -- x)
               IF L_fit_ee_subj_whable <= 0 AND L_school_ee_tax > 0 THEN

		  L_balance_nm1 := L_dimension || ' FIT Subject Withholdable';
		  L_balance_nm2 := L_dimension || ' School Withheld';
		  L_main_mesg   := '*** ' || L_dimension || ' FIT Subject Withholdable <= 0 and ' || L_dimension ||
		                   ' School '||'Withheld > 0 ***';

                  prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                 IN_prc_tax_unit_id,
                                 IN_prc_organization_id, IN_prc_location_id, IN_pact_id,
                                 IN_chunk_no, IN_prc_person_id,
                                 IN_prc_assignment_number,
                                 L_balance_nm1,
				 L_balance_nm2,
                                 L_fit_ee_subj_whable, L_school_ee_tax,
                                 NULL, NULL, curr_jurisdiction_name,
                                 L_main_mesg,
                                 curr_reg_jurisdiction_cd,
				 L_asg_action_id ,
				 IN_prc_assignment_id );
               END IF;


               -- w)
               IF fnc_lit_tax_exists(curr_reg_jurisdiction_cd, L_as_of_date, 'SCHOOL') THEN
                  IF L_school_ee_subject <= 0 AND L_school_ee_tax > 0 THEN

                     L_balance_nm1 := L_dimension || ' School Subject';
		     L_balance_nm2 := L_dimension || ' School Withheld';
		     L_main_mesg   := '*** ' || L_dimension || ' School Subject <= 0 and ' || L_dimension ||
		                      ' School Withheld > 0 ***';

                     prc_write_data(IN_commit_count,'U', IN_prc_lockingactid,
                                    IN_prc_tax_unit_id,
                                    IN_prc_organization_id, IN_prc_location_id,
                                    IN_pact_id,
                                    IN_chunk_no, IN_prc_person_id,
                                    IN_prc_assignment_number,
                                    L_balance_nm1,
				    L_balance_nm2,
                                    L_school_ee_subject, L_school_ee_tax,
                                    NULL, NULL, curr_jurisdiction_name,
                                    L_main_mesg,
                                    curr_reg_jurisdiction_cd,
				    L_asg_action_id,
				    IN_prc_assignment_id );
                  END IF;
               END IF;

END prc_school_balances ;

/******************************** 3005756 end ************************************************/

-----------------------------------------------
  BEGIN
     -- setup commit counter before we start


     G_commit_count := IN_commit_count;

     -- get all required parameters from legislative parameter string

    /***************** 3005756 START *******************************/

    -- Assign the local payroll stuff variables the global values

     L_business_id := G_business_id;
     L_as_of_date  := G_as_of_date;
     L_leg_param   := G_leg_param;

    /*********************3005756 END ***************************/

     L_dimension := fnc_get_parameter('B_Dim',L_leg_param);
     L_gre_id := fnc_get_parameter('GRE',L_leg_param);
     L_org_id := fnc_get_parameter('Org',L_leg_param);
     L_location_id := fnc_get_parameter('Loc',L_leg_param);
     L_tax_type := fnc_get_parameter('T_T',L_leg_param);
     L_tax_type_state := fnc_get_parameter('T_T_S',L_leg_param);
     L_usr_SDI_ER_rate := fnc_get_parameter('ERR',L_leg_param);
     L_usr_SDI_EE_rate := fnc_get_parameter('EER',L_leg_param);

     -- calculate first half date for later use if type is SUI
     --L_first_half_date := TO_DATE('30-JUN-'||TO_CHAR(L_as_of_date,'YYYY'),'DD-MON-YYYY');
     L_first_half_date := TO_DATE('30-06-'||TO_CHAR(L_as_of_date,'YYYY'),'DD-MM-YYYY');

     -- calculate the start date based on YTD or QTD dimensions

    /***********************3005756 START *********************************/

    -- If the federal pl/sql table is empty populate it and then fetch the
    -- values into global variables

        IF pay_us_payroll_utils.ltr_fed_tax_info.count<1 THEN
           pay_us_payroll_utils.populate_jit_information(p_effective_date => L_as_of_date
                                                        ,p_get_federal    => 'Y' );
        END IF;

           G_ss_ee_wage_limit := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_ee_wage;
           G_ss_ee_rate       := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_ee_rate;
           G_ss_er_wage_limit := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_er_wage;
           G_ss_er_rate       := pay_us_payroll_utils.ltr_fed_tax_info(1).ss_er_rate;
           G_medi_ee_rate     := pay_us_payroll_utils.ltr_fed_tax_info(1).med_ee_rate;
           G_medi_er_rate     := pay_us_payroll_utils.ltr_fed_tax_info(1).med_er_rate;

/****************************** 3005756 END     ***************************************/


         IF L_dimension = 'QTD' THEN
           L_start_date := TRUNC(L_as_of_date,'Q') ;
         ELSIF L_dimension = 'YTD' THEN
           L_start_date := TRUNC(L_as_of_date,'YYYY');
         END IF;

         L_asg_action_id := IN_prc_lockedactid ;

         L_medi_exempt := f_check_medi_exempt(IN_prc_assignment_id,
                                              L_start_date,
                                              L_as_of_date);


         -- Call for all Unacceptable Federal balance checks

         prc_federal_balances();

/************************************* Bug 2963239 Changes End *********************************************/



         IF L_tax_type = 'SDI' OR L_tax_type = 'SUI' OR L_tax_type = 'SIT'
            OR L_tax_type IS NULL
         THEN

	    -- this variable must be reset before going into loop

	    L_sum_sui_er_bal := 0;
            L_sum_sdi_ee_bal := 0;

	    /************************ 3005756 start *******************************************************/

            IF G_state_flag = 'Y' THEN

	       hr_utility.trace('Balances are valid .Inside vailid state cursor');

	       FOR curr_state IN c_state_jurisdictions_valid(IN_prc_person_id,
                                                             L_tax_type_state, L_start_date,
                                                             L_as_of_date)
               LOOP

                 prc_state_balances ( curr_state.jurisdiction_code,curr_state.state_code,curr_state.state_abbrev);

               END LOOP;  -- end curr_state

            ELSE
               hr_utility.trace('Balances are invalid .Inside invalid state cursor');

	       FOR curr_state IN c_state_jurisdictions(IN_prc_person_id,
                                                       L_tax_type_state, L_start_date,
                                                       L_as_of_date)
               LOOP

	       prc_state_balances ( curr_state.jurisdiction_code,curr_state.state_code,curr_state.state_abbrev);

               END LOOP;  -- end curr_state

             END IF;


/************************** 3005756 end ********************************************************/

         END IF;  -- end if 'SDI', 'SUI', 'SIT'



         IF L_tax_type = 'LIT' OR L_tax_type IS NULL THEN
            -- for each valid county jurisdiction ...


         /******************** 3005756 start ***********************************************/

            IF G_county_flag = 'Y' THEN
	        hr_utility.trace('Balances are valid .Inside valid county cursor');

                FOR curr_county IN c_county_jurisdictions_valid(IN_prc_person_id,
                                                                L_tax_type_state, L_start_date,
                                                                L_as_of_date)
                LOOP

		prc_county_balances ( curr_county.jurisdiction_code,curr_county.jurisdiction_name );

                END LOOP;  -- end curr_county loop

	    ELSE
                hr_utility.trace('Balances are invalid .Inside invalid county cursor');

	        FOR curr_county IN c_county_jurisdictions(IN_prc_person_id,
                                                          L_tax_type_state, L_start_date,
                                                          L_as_of_date)
                LOOP

	        prc_county_balances ( curr_county.jurisdiction_code,curr_county.jurisdiction_name );

                END LOOP;  -- end curr_county loop

	    END IF;

/**************************3005756 end ********************************/

            -- for each city valid jurisdiction ...


/*********************** 3005756 start *****************************************/

	    IF G_city_flag = 'Y' THEN
                hr_utility.trace('Balances are valid .Inside valid city cursor');

                FOR curr_city IN c_city_jurisdictions_valid(IN_prc_person_id,
                                                            L_tax_type_state, L_start_date,
                                                            L_as_of_date)
                LOOP

                prc_city_balances ( curr_city.jurisdiction_code,curr_city.jurisdiction_name );

                END LOOP;  -- end curr_city loop

            ELSE
                hr_utility.trace('Balances are invalid .Inside invalid city cursor');

		FOR curr_city IN c_city_jurisdictions(IN_prc_person_id,
                                                      L_tax_type_state, L_start_date,
                                                      L_as_of_date)
                LOOP

                prc_city_balances ( curr_city.jurisdiction_code,curr_city.jurisdiction_name );

                END LOOP;  -- end curr_city loop

            END IF;

/************************************ 3005756 end ***************************/


            -- for each valid school jurisdiction ...

/**************************** 3005756 start **********************************/

            IF G_school_flag = 'Y' THEN
                hr_utility.trace('Balances are valid .Inside valid school cursor');

	        FOR curr_school IN c_school_jurisdictions_valid(IN_prc_person_id,
                                                                L_tax_type_state,
                                                                IN_prc_tax_unit_id, L_start_date,
                                                                L_as_of_date)
                LOOP

                prc_school_balances ( curr_school.jurisdiction_code
		                        , curr_school.jurisdiction_name
					, curr_school.reg_jurisdiction_cd );

                END LOOP;  -- end curr_school loop

	    ELSE
                hr_utility.trace('Balances are invalid .Inside invalid school cursor');

	        FOR curr_school IN c_school_jurisdictions(IN_prc_person_id,
                                                          L_tax_type_state,
                                                          IN_prc_tax_unit_id, L_start_date,
                                                          L_as_of_date)
                LOOP

                prc_school_balances ( curr_school.jurisdiction_code
		                        , curr_school.jurisdiction_name
					, curr_school.reg_jurisdiction_cd );

                END LOOP;  -- end curr_school loop

	    END IF;

/*********************************** 3005756 end ******************************/


         END IF;  -- end if 'LIT'



EXCEPTION
   WHEN OTHERS THEN
      -- rollback all uncommited changes
      ROLLBACK;
      -- does not matter what the error is delete all commited inserted tmp records
      DELETE pay_us_rpt_totals
       WHERE session_id        = IN_pact_id
         AND business_group_id = IN_chunk_no
	 AND tax_unit_id       = IN_prc_tax_unit_id;  -- Bug 3316599 to reduce the cost of query
      COMMIT;
      -- reraise the error
      RAISE;
END prc_process_data;


END PAYUSUNB_PKG;

/
