--------------------------------------------------------
--  DDL for Package Body PAY_US_EMP_PAYSLIP_ACCRUAL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EMP_PAYSLIP_ACCRUAL_WEB" 
/* $Header: pyusacrw.pkb 120.5.12000000.3 2007/03/05 06:20:04 sackumar ship $ */
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

    Name        : pay_us_emp_payslip_accrual_web

    Description : Package gets all the Accrual plans for an
                  Employee and populates a PL/SQL table -
                  LTR_ASSIGNMENT_ACCRUALS.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    01-JUL-1999 ahanda   110.0           Created.
    24-DEC-1999 ahanda   110.1  1115325  Added paramter to procedure
                                         get_emp_net_accrual to return the
                                         total no. of Accrual Categories.
    17-JAN-2000 ahanda   110.2           Changed the logic for getting the
                                         Current Accruals.
    20-feb-2001 djoshi   115.2           Added procedure to delete the
                                         pl/sql table for the accurual
                                         procedure is
                                         delete_ltr_assignment_accrual
    29-NOV-2001 asasthan                 Changed get_net_accruals
                                         Added p_assignment_action_id
                                         parameter
    24-JAN-2002 ahanda                   Added fnd_date.canonical_to_date
                                         for getting Cont Calc Date
    12-JUN-2002 ahanda   115.5           Changed length of var lv_accrual_code
                                         to 100.
    26-JUN-2003 ahanda   115.6           Changed cursor c_accrual_category
    06-Aug-2003 vpandya  115.8           Added NOCOPY with out parameter.
    28-May-2005 sackumar 115.9  4053111  in get_emp_net_accrual procedure the
					 values of current arrcrual is coming
					 incorrectly for that i introduce a new
					 call of the procedure
					 per_accrual_calc_functions.get_net_accrual
    17-JUN-2005 sackumar 115.10          Add distinct in c_accrual_category cursor.
    17-OCT-2005 ahanda   115.11 4681780  Initalized variables
    18-OCT-2005 ahanda   115.12 4681780  Initalized all total variables
    09-JAN-2006 ahanda    115.13 4761039 Passing -1 for asg action in
                                         pay_us_pto_accrual.get_net_accrual
    31-MAY-2006 ppanda   115.14 5220628  Cursor c_accrual_category changed in procedure
                                         get_emp_net_accrual to filter values based on
                                         Security Group
    02-OCT-2006 ahanda   115.15 5473954  Storing Accrual Code in PL/SQL table
    05-MAR-2007 sackumar 115.16 5470648  Modified get_emp_net_accrual procedure.
  *******************************************************************/
  AS
   /*****************************************************
   ** Global Package Body Variables
   ******************************************************/
   gv_package_name  VARCHAR2(100) := 'pay_us_emp_payslip_accrual_web';


   PROCEDURE get_emp_net_accrual (
                    p_assignment_action_id  in  number
                   ,p_assignment_id         in  number
                   ,p_cur_earned_date       in  date
                   ,p_total_acc_category    out NOCOPY number
                  )
   /******************************************************************
   **
   ** Description:
   **   This procedure puts the Accrual Info for an employee
   **   and for Payment Date.
   **
   ** Access Status:
   **     Public.
   **
   ******************************************************************/
   IS

    Cursor c_time_periods( cp_payroll_id     in number
                          ,cp_effective_date in date
                          ) is
      select start_date,
             end_date,
             period_num,
             ptpt.number_per_fiscal_year
        from per_time_period_types ptpt,
             per_time_periods ptp
       where ptpt.period_type = ptp.period_type
         and ptp.payroll_id = cp_payroll_id
         and cp_effective_date between ptp.start_date
                                   and ptp.end_date;

    Cursor c_payroll_id(
                 cp_assignment_action_id in number
                 ) is
      select payroll_id, business_group_id
        from pay_payroll_actions ppa,
             pay_assignment_actions paa
       where ppa.payroll_action_id = paa.payroll_action_id
         and paa.assignment_action_id = cp_assignment_action_id;
--
-- Following cursor changed to filter the lookup values based on security group
-- This changes made to fix Bug # 5220628
    Cursor c_accrual_category(cp_language varchar2) is
      select distinct flv.lookup_code,
                           flv.meaning
        from fnd_lookup_values flv
       where flv.lookup_type = 'US_PTO_ACCRUAL'
          and flv.language = nvl(cp_language,userenv('LANG'))
          and flv.security_group_id = fnd_global.lookup_security_group(flv.lookup_type, flv.view_application_id);

    Cursor c_accrual_plan( cp_assignment_id    in number
                          ,cp_effective_date   in date
                          ,cp_accrual_category in varchar2
                          )
      is
      select pap.accrual_plan_id,
             pap.accrual_plan_element_type_id
        from pay_accrual_plans pap,
             pay_element_links_f pel,
             pay_element_entries_f pee
       where pap.accrual_category = cp_accrual_category
         and pel.element_type_id= pap.accrual_plan_element_type_id
         and cp_effective_date between pel.effective_start_date
                                   and pel.effective_end_date
         and pee.element_link_id = pel.element_link_id
         and pee.assignment_id = cp_assignment_id
         and cp_effective_date between pee.effective_start_date
                                   and pee.effective_end_date;

      ln_payroll_id          NUMBER;
      ln_business_group_id   NUMBER;

      lv_accrual_code        VARCHAR2(100);
      lv_accrual_category    VARCHAR2(100);
      lv_correspndence_lang  VARCHAR2(100);

      ln_accrual_plan_id     NUMBER;
      ln_accrual_ele_type_id NUMBER;

      ld_period_start_date   DATE;
      ld_period_end_date     DATE;
      ln_period_num          NUMBER;
      ln_fiscal_period_num   NUMBER;

      l_net_accrual_hours     NUMBER := 0;
      l_pre_accrual           NUMBER := 0;
      l_latest_accrual        Number := 0;
      l_cur_tot_accrual_hours NUMBER := 0;
      l_net_tot_accrual_hours NUMBER := 0;
      l_pre_tot_accrual       NUMBER := 0;
      l_latest_tot_accrual    Number := 0;
      ld_dummy_dat            DATE;
      ld_dummy_dat1           DATE;
      ld_dummy_dat2           DATE;
      ln_dummy_num            NUMBER;

      i_count         NUMBER := 0;
      lc_plan_exists  VARCHAR2(1) := 'N';

   BEGIN

      hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 10);
      hr_utility.trace('p_assignment_action_id = ' || p_assignment_action_id);
      hr_utility.trace('p_assignment_id        = ' || p_assignment_id       );
      hr_utility.trace('p_cur_earned_date      = ' || p_cur_earned_date     );

      open c_payroll_id(p_assignment_action_id);
      fetch c_payroll_id into ln_payroll_id, ln_business_group_id;
      if c_payroll_id%found then
         open c_time_periods(ln_payroll_id, p_cur_earned_date);
         fetch c_time_periods into ld_period_start_date, ld_period_end_date,
                                   ln_period_num, ln_fiscal_period_num;
         close c_time_periods;
      end if;
      close c_payroll_id;

      hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 30);
      hr_utility.trace('Payroll Start Date    = ' || ld_period_start_date);
      hr_utility.trace('Payroll End Date      = ' || ld_period_end_date);

      lv_correspndence_lang := pay_emp_action_arch.gv_correspondence_language;

      hr_utility.trace('lv_correspndence_lang  = ' || lv_correspndence_lang);

      open c_accrual_category(lv_correspndence_lang);
      loop
        fetch c_accrual_category into lv_accrual_code, lv_accrual_category;
        if c_accrual_category%notfound then
           exit;
        end if;

        hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 50);
        hr_utility.trace('Accrual Category = ' || lv_accrual_code);

        open c_accrual_plan( p_assignment_id
                            ,p_cur_earned_date
                            ,lv_accrual_code
                            );
        loop
           fetch c_accrual_plan into ln_accrual_plan_id
                                   ,ln_accrual_ele_type_id;
           if c_accrual_plan%notfound then
              hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 60);
              exit;
           end if;

           hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 70);
           hr_utility.trace('Accrual Plan ID = ' || ln_accrual_plan_id);
           hr_utility.trace('Accrual Elem ID = ' || ln_accrual_ele_type_id);


           /*************************************************************
           ** Set Var. if Plan Exists.
           *************************************************************/
           lc_plan_exists      := 'Y';
           l_pre_accrual       := 0;
           l_latest_accrual    := 0;
           l_net_accrual_hours := 0;

           /*************************************************************
           ** Get Net Accruals
           *************************************************************/
           l_net_accrual_hours := pay_us_pto_accrual.get_net_accrual (
                                    p_assignment_id    => p_assignment_id
	                           ,p_calculation_date => ld_period_end_date
                                   ,p_plan_id          => ln_accrual_plan_id
                                   ,p_plan_category    => lv_accrual_code
                                   ,p_assignment_action_id => -1
                                   );


           hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 80);

           per_accrual_calc_functions.get_net_accrual(
                 p_assignment_id        => p_assignment_id,
                 p_plan_id              => ln_accrual_plan_id,
                 p_payroll_id           => ln_payroll_id,
                 p_business_group_id    => ln_business_group_id,
                 p_assignment_action_id => -1, --p_assignment_action_id,
                 p_calculation_date     => ld_period_end_date,
                 p_accrual_start_date     => null,
    	       	 p_accrual_latest_balance => null,
                 p_calling_point          => 'BP',
                 p_accrual              => l_latest_accrual,
                 p_net_entitlement      => ln_dummy_num,
                 p_end_date             => ld_dummy_dat,
                 p_accrual_end_date     => ld_dummy_dat1,
                 p_start_date           => ld_dummy_dat2
                );

           IF ld_dummy_dat1 is not null THEN
             IF ld_dummy_dat1 >= ld_period_start_date AND ld_dummy_dat1 <= ld_period_end_date THEN
             -- New Call Suggested for Bug No 4053111
                 per_accrual_calc_functions.get_net_accrual(
                 p_assignment_id        => p_assignment_id,
                 p_plan_id              => ln_accrual_plan_id,
                 p_payroll_id           => ln_payroll_id,
                 p_business_group_id    => ln_business_group_id,
                 --p_calculation_date     => ld_period_end_date - 1, -- Commented for bug 5470648
                 p_calculation_date     => ld_dummy_dat1 - 1, -- Added for bug 5470648
                 p_assignment_action_id => -1, ---p_assignment_action_id,
                 p_accrual_start_date   => NULL,
        	 p_accrual_latest_balance => null,
              	 p_calling_point          => 'BP',
                 p_accrual              => l_pre_accrual,
                 p_net_entitlement      => ln_dummy_num,
                 p_end_date             => ld_dummy_dat,
                 p_accrual_end_date     => ld_dummy_dat1,
                 p_start_date           => ld_dummy_dat2
                );
              ELSE
                l_pre_accrual := l_latest_accrual;
              END IF;
            ELSE
              l_pre_accrual := l_latest_accrual;
            END IF;

           l_pre_tot_accrual       := l_pre_tot_accrual + l_pre_accrual;
           l_latest_tot_accrual    := l_latest_tot_accrual + l_latest_accrual;
           l_net_tot_accrual_hours := l_net_tot_accrual_hours + l_net_accrual_hours;
       end loop;
       close c_accrual_plan;
       l_cur_tot_accrual_hours := l_latest_tot_accrual - l_pre_tot_accrual;

       if lc_plan_exists = 'Y' then

          i_count := i_count + 1;

          hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 100);
          lc_plan_exists := 'N';

          pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i_count).accrual_code
                        := lv_accrual_code;
          pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i_count).accrual_category
                        := lv_accrual_category;
          pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i_count).accrual_cur_value
                        := l_cur_tot_accrual_hours;
          pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i_count).accrual_net_value
                        := l_net_tot_accrual_hours;

          lv_accrual_category      := null;
          lv_accrual_code          := null;
          l_cur_tot_accrual_hours  := 0;
          l_net_tot_accrual_hours  := 0;
          l_latest_tot_accrual     := 0;
          l_pre_tot_accrual        := 0;
       end if;
    end loop;
    close c_accrual_category;

    p_total_acc_category := i_count;


    for i in 1 .. i_count loop
        hr_utility.trace('Accrual Code = '
                  || pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_code);
        hr_utility.trace('Accrual Type = '
                  || pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_category);
        hr_utility.trace('Accrual Current = '
                  || pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_cur_value);
        hr_utility.trace('Accrual Bal = '
                  || pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_net_value);
    end loop;

    hr_utility.trace('Total Accrual Account = ' || i_count);
    hr_utility.set_location(gv_package_name || '.get_emp_net_accrual', 110);

   END get_emp_net_accrual;


   PROCEDURE delete_ltr_assignment_accrual

   /******************************************************************
   **
   ** Description:
   **   This procedure Deletes the ltr_assignment_accrual PL/SQL
   **   Table
   **
   **
   ** Access Status:
   **     Public.
   **
   ******************************************************************/

   IS
   BEGIN
     /* Delete the accrual PL/SQL table */
     ltr_assignment_accruals.delete;
   END delete_ltr_assignment_accrual;


--BEGIN
--  hr_utility.trace_on(null, 'ORACLE');

END pay_us_emp_payslip_accrual_web;

/
