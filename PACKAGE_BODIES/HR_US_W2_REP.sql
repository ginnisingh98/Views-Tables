--------------------------------------------------------
--  DDL for Package Body HR_US_W2_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_W2_REP" AS
/* $Header: pyusw2pg.pkb 120.2.12010000.5 2009/09/14 13:01:03 kagangul ship $ */

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+
Name        : pyusw2pg.pkb
Description : This package declares functions and procedures which are
              used to return values for the W2 US Payroll reports.

Change List
-----------

Version Date      Author       ER/CR No. Description of Change
-------+---------+------------+---------+--------------------------
40.0    13-MAY-98 SSarma                 Date Created
40.1    18-AUG-98 ahanda                 modified packaged
40.2    18-AUG-98 ahanda                 added condition for 1099R
40.5    15-jan-99 ssarma                 Added logic for A_SPL_CITY_LOCAL_WAGES,
                                         A_SPL_CITY_WITHHELD_PER_JD_GRE_YTD
40.6    21-JAN-99 ahanda                 Removed the check for Jurisdiction Code
                                         length.
40.8/   22-JAN-99 achauhan               Added logic to bypass gross for bouroughs
110.4                                    if the withheld is zero.
115.1   23-APR-99 scgrant                Multi-radix changes.
115.6   10-may-99 iharding               removed set serveroutput on
115.7   08-AUG-99 ssarma                 Added functions get_w2_tax_unit_item,
                                         get_tax_unit_addr_line,get_tax_unit_bg,
                                         get_per_item,get_state_item for eoy99.
115.9   16-Sep-99 skutteti               Pre-tax enhancements
115.10  10-Aug-01 kthirmiy               added a new function get_leav_reason to get the
                                         termination reason meaning to fix the bug 1482168.
                                         used fnd_lookup_values in the function
                                         instead of fnd_common_lookups because
                                         of release 115
115.15  07-SEP-01 ssarma                 Fix for 1977767.
115.18  16-SEP-01 ssarma                 Overloaded function get_w2_box_15
115.19  17-SEP-01 ssarma                 Removed default for effective date from
                                         function get_w2_box_15.
115.20  29-NOV-01 meshah                 Fix for 2125750. adding
                                         A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_
                                         TO_TAX_PER_GRE_YTD
                                         to the deduction calculation for A_WAGES.
115.21  30-NOV-01 meshah                 add dbdrv.
115.22  10-DEC-01 meshah                 adding
                                         A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_
                                         TO_TAX_PER_GRE_YTD
                                         and A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD
                                         to the earnings calculation for A_WAGES
                                         not deductions.
115.23  17-DEC-02 fusman       2380518   Changed the hr_locations to hr_locations_all for
                                         Employer address.
115.24  18-JUL-02 kthirmiy     2465183   Changed from p_per_item per_people_f.
                                         middle_names%type
                                         to per_people_f.first_name%type
                                         for bug 2465183 because of UTF8 the length
                                         has been increased
115.25  06-AUG-02 ppanda       2145804   Procedure get_county_tax_info added
                               2207317   Procedures fetches County Tax info for
                                         tax computation

                               2287844   Currently SS Wages includes Tips which is
                                         reported in Box-7 In order to report
                                         correctly the SS Wages, SS Tips should be
                                         subtracted from SS Wages.

                               2400545   For NY states State wages must be equal to
                                         Federal wages
                                         when a taxpapayer has state tax withholding
                                         for any part of the tax year.

                               2505076  This is fix for Yonker City of NY state,
                                        which requires City wages
                                        to match with Fed wages when taxpayer
                                        has yonker City tax withheld
115.26 10-SEP-2002 kthirmiy    1992073  Added a new procedure get_agent_tax_unit_id for
                                        Agent reporting enhancement
                                        Note that the message will take only
                                        45 characters in the pyugen
                                        process to display.
115.28 11-SEP-2002 kthirmiy             Added Both in the error message
115.30 12-SEP-2002 kthirmiy             Changed to 2678 Filer instead of Agent
                                        in the error mesg
115.31 12-SEP-2002 ahanda               Changed 2678 Filer to only pick up
                                        non 1099R GREs
115.32 17-SEP-2002 kthirmiy             Changed the Error mesg bug 2573499
115.35 18-SEP-2002 irgonzal    2577109  Modified get_agent_tax_unit_id procedure.
                                        Added following conditions:
                                        a) if only one 2678 Filer GRE is found,
                                        only this GRE should be the W2
                                        Transmitter. b) Only one 2678 Filer
                                        GRE can exist within a BG
115.36 20-SEP-2002 irgonzal             Modifed error message for bug 2577109.
115.37 20-SEP-2002 irgonzal             Modified get_agent_tax_unit_id procedure.
                                        Ensured error message does not exceed 100 chrs.
115.38 13-Nov-2002 fusman      2625264  Checked the optional reporting
                                        parameter of fed wages in state wages
                                        for NY
115.39 13-Nov-2002 fusman               Moved the PL/SQL declaration to package header.

115.41 02-DEC-2002 asasthan             nocopy changes for gscc compliance.
115.42 20-JAN-2003 jgoswami             Modified the A_W2_GROSS_1099R code to
                                        get correct gross for 1099r paper,1099r
                                        register and view:PAY_US_WAGES_1099R_V.
115.45 12-AUG-2003 rsethupa    2631650  Rolled back the changes introduced in
                                        version 115.44
115.46 26-AUG-2003 meshah               Added in a new function
                                        get_w2_box17_label. This function is
                                        called from the pay_us_locality_w2_v.
115.47 07-JAN-2004 ahanda      3347942  Added 'A_FIT_3RD_PARTY_PER_GRE_YTD' to
                                        get_w2_box_15
115.48 28-JUL-2004 rsethupa    3347948  Removed 'A_FIT_3RD_PARTY_PER_GRE_YTD'
                                        from get_w2_box_15. Will use only
					A_W2_TP_SICK_PAY_PER_GRE_YTD for Sick
					Pay Indicator
115.49 13-Aug-2004 meshah      3725848  Now checking for 26-000-0690 (Kansas
                                        City) jurisdiction code in
                                        A_SPL_CITY_WITHHELD_PER_JD_GRE_YTD
                                        and A_SPL_CITY_LOCAL_WAGES.
                                        pay_us_locality_w2_v will also change.

115.50 23-Jan-2006 sausingh    5748431  Added two extra conditions for checking
                                        the box 13b in case of designated roth
                                        contribution under section 401(k) plan
                                        and under section 403(b) plan.
115.25 27-SEP-2007 sausingh   5517938   Added a new function get_last_deffer_year
                                         to display first year of designated roth
                                         contribution

115.26 08-jan-2008 psugumar   5855662   Added a new functions get_w2_location_cd
							     get_w2_worker_compensation
							     get_w2_employee_number
					to display new information required for Bug #5855662
115.55 14-Sep-2009 kagangul   8353425   Added a new function get_w2_employee_name.


=============================================================================

*/

FUNCTION get_w2_bal_amt (w2_asg_act_id   number,
                         w2_balance_name varchar2,
                         w2_tax_unit_id  varchar2,
                         w2_jurisdiction_code varchar2,
                         w2_jurisdiction_level number) RETURN NUMBER
IS
 l_user_entity_id number;
 l_bal_amt        number := 0;
 l_tax_context_id number := 0;
 l_jd_context_id  number := 0;

BEGIN

--dbms_output.put_line('inside get_w2_bal_amt');

  l_user_entity_id := get_user_entity_id(w2_balance_name);
  l_jd_context_id :=  hr_us_w2_rep.get_context_id('JURISDICTION_CODE');
  l_tax_context_id := hr_us_w2_rep.get_context_id('TAX_UNIT_ID');


  if w2_tax_unit_id is not null then
     if w2_jurisdiction_code <> '00-000-0000' then
        --dbms_output.put_line('got jd and gre as not null  ');
        select nvl(fnd_number.canonical_to_number(fai.value),0) into l_bal_amt
          from ff_archive_items fai,
               ff_archive_item_contexts fic1,
               ff_archive_item_contexts fic2
         where fai.context1 = w2_asg_act_id
           and fai.user_entity_id = l_user_entity_id
           and fai.archive_item_id = fic1.archive_item_id
           and fic1.context_id = l_tax_context_id
           and ltrim(rtrim(fic1.context)) = w2_tax_unit_id
           and fai.archive_item_id = fic2.archive_item_id
           and fic2.context_id = l_jd_context_id
           and substr(ltrim(rtrim(fic2.context)),1,w2_jurisdiction_level) = substr(w2_jurisdiction_code,1,w2_jurisdiction_level);
      else
         --dbms_output.put_line('got jd as null and gre as not null  ');
         select nvl(fnd_number.canonical_to_number(fai.value),0) into l_bal_amt
           from ff_archive_items fai,
                ff_archive_item_contexts fic
          where fai.context1 = w2_asg_act_id
            and fai.user_entity_id = l_user_entity_id
            and fai.archive_item_id = fic.archive_item_id
            and fic.context_id = l_tax_context_id
            and ltrim(rtrim(fic.context)) = w2_tax_unit_id;
      end if;
   else
     if w2_jurisdiction_code <> '00-000-0000' then
        --dbms_output.put_line('got jd as not null and gre as null  ');
        select nvl(fnd_number.canonical_to_number(fai.value),0) into l_bal_amt
          from ff_archive_items fai,
               ff_archive_item_contexts fic
         where fai.context1 = w2_asg_act_id
           and fai.user_entity_id = l_user_entity_id
           and fai.archive_item_id = fic.archive_item_id
           and fic.context_id = l_jd_context_id
           and substr(ltrim(rtrim(fic.context)),1,w2_jurisdiction_level) = substr(w2_jurisdiction_code,1,w2_jurisdiction_level);
     else
        --dbms_output.put_line('got jd and gre as null  ');
        select nvl(fnd_number.canonical_to_number(fai.value),0) into l_bal_amt
          from ff_archive_items fai
         where fai.context1 = w2_asg_act_id
           and fai.user_entity_id = l_user_entity_id;
     end if;
  end if;

  return(l_bal_amt);

EXCEPTION
 when no_data_found then
   return(0);

END get_w2_bal_amt;

FUNCTION get_user_entity_id (w2_balance_name in varchar2)
                         RETURN NUMBER
IS
  l_user_entity_id	number := 0;

BEGIN
   select fdi.user_entity_id into l_user_entity_id
     from ff_database_items fdi,
          ff_user_entities fue
     where user_name = w2_balance_name
       and fdi.user_entity_id = fue.user_entity_id
       and fue.legislation_code = 'US';

  --dbms_output.put_line('got user_entity_id = ' || to_char(l_user_entity_id));
  return (l_user_entity_id);

EXCEPTION
  when no_data_found then
    return(-1);

END get_user_entity_id;

FUNCTION get_context_id (w2_context_name in varchar2)
 RETURN NUMBER
IS
  l_context_id 	number := 0;
BEGIN
      select context_id into l_context_id
      from ff_contexts
      where context_name = w2_context_name;

      return (l_context_id);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         return(-1);

END get_context_id;

FUNCTION  get_w2_arch_bal(w2_asg_act_id         number,
                          w2_balance_name       varchar2,
                          w2_tax_unit_id        number ,
                          w2_jurisdiction_code  varchar2 ,
                          w2_jurisdiction_level number) RETURN NUMBER IS

  TYPE numeric_table IS TABLE OF number(17,2)
                        INDEX BY BINARY_INTEGER;

  TYPE text_table IS TABLE OF varchar2(2000)
                     INDEX BY BINARY_INTEGER;

  g_user_name		text_table;
  g_element_value		numeric_table;

  l_jursd_tbl              text_table;
  l_count                  number := 0;
  l_user_entity_id	 number :=0;
  l_earnings		 number :=0;
  l_deductions		 number :=0;
  bal_amt			 number :=0;
  l_amt                    number := 0;
  l_withheld               number := 0;
  l_city_tax_withheld      number := 0;


  FUNCTION get_ny_fed_state_wage_match (p_w2_tax_unit_id in number)
  RETURN varchar2

  IS
     cursor c_ny_st_match_fed (cp_tax_unit_id in number)
     IS
       select nvl(hoi.org_information1, 'Y')
         from hr_organization_information hoi,
              hr_organization_units hou
        where hoi.organization_id =  hou.business_group_id
          and hou.organization_id = cp_tax_unit_id
          and hoi.org_information_context = 'US State Tax Info';

     l_ny_st_match_fed        varchar2(1) := 'Y';
     l_ny_bg_found            boolean := FALSE;

     l_index               NUMBER;

  BEGIN
      if ltr_newyork_tax_table.count > 0 then
           for j in ltr_newyork_tax_table.first .. ltr_newyork_tax_table.last loop

               IF ltr_newyork_tax_table(j).tax_unit_id = w2_tax_unit_id THEN
                  l_ny_st_match_fed := ltr_newyork_tax_table(j).tax_value;
                  l_ny_bg_found := TRUE;
                  exit;
               END IF;
           end loop;
        end if;

        IF NOT l_ny_bg_found THEN --l_bg_found checking
           OPEN c_ny_st_match_fed(p_w2_tax_unit_id);
           FETCH c_ny_st_match_fed into l_ny_st_match_fed;
           CLOSE c_ny_st_match_fed;

           l_index := ltr_newyork_tax_table.count;
           ltr_newyork_tax_table(l_index).tax_unit_id := w2_tax_unit_id;
           ltr_newyork_tax_table(l_index).tax_value := l_ny_st_match_fed;
        END IF;

        return (l_ny_st_match_fed);
  END get_ny_fed_state_wage_match;

BEGIN

   for i in  1..50 loop
       g_element_value(i) := 0;
   end loop;

   for i in  1..50 loop
       l_jursd_tbl(i) := null;
   end loop;

   -- pay_us_balance_view_pkg.debug_msg('FUNCTION : get_w2_arch_bal ');
   -- pay_us_balance_view_pkg.debug_msg('Assignment Action Id : '||to_char(w2_asg_act_id));
   -- pay_us_balance_view_pkg.debug_msg('Balance Name : '||w2_balance_name);

   if   w2_balance_name = 'A_WAGES' then

         g_user_name(1) :=  'A_REGULAR_EARNINGS_PER_GRE_YTD';
         g_user_name(2) :=  'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';
         g_user_name(3) :=  'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD';
         g_user_name(4) :=  'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';
         g_user_name(5) :=  'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD';
         g_user_name(6) :=  'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD';

         for i in 1..6 loop
             g_element_value(i) := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 g_user_name(i),
                                                 to_char(w2_tax_unit_id),
                                                 '00-000-0000',
                                                 w2_jurisdiction_level);
         end loop;

         l_earnings := 0;
         l_deductions := 0;

         for i in 1..5 loop
            l_earnings := l_earnings + g_element_value(i);
         end loop;

         for i in 6..6 loop
            l_deductions := l_deductions + g_element_value(i);
         end loop;

         bal_amt := l_earnings - l_deductions;

   elsif w2_balance_name = 'A_W2_STATE_WAGES' then

         g_user_name(1) :=  'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD';
         g_user_name(2) :=  'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD';
         g_user_name(3) :=  'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD';

         for i in 1..3 loop
             g_element_value(i) := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 g_user_name(i),
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level);
         end loop;

         l_earnings := 0;
         l_deductions := 0;

         for i in 1..2 loop
            l_earnings := l_earnings + g_element_value(i);
         end loop;

         for i in 3..3 loop
            l_deductions := l_deductions + g_element_value(i);
         end loop;

         bal_amt := l_earnings - l_deductions;

         --
         -- This is to fix Bug # 2400545
         -- Start for the Fix
         -- For NY states State wages must be equal to Federal wages
         -- when a taxpapayer has state tax withholding
         --  for anypart of the tax year.
         if substr(w2_jurisdictioN_code,1,2) = '33' then  -- NY testing

            if get_ny_fed_state_wage_match(w2_tax_unit_id) = 'Y' THEN
               if bal_amt <> 0 then
                  bal_amt := hr_us_w2_rep.get_w2_arch_bal(
                                    w2_asg_act_id,
                                    'A_WAGES',
                                    w2_tax_unit_id,
                                   '00-000-0000',0);
               end if;
            end if;

         end if; -- NY checking


   elsif w2_balance_name = 'A_CITY_LOCAL_WAGES' then

         g_user_name(1) :=  'A_CITY_SUBJ_WHABLE_PER_JD_GRE_YTD';
         g_user_name(2) :=  'A_CITY_SUBJ_NWHABLE_PER_JD_GRE_YTD';
         g_user_name(3) :=  'A_CITY_PRE_TAX_REDNS_PER_JD_GRE_YTD';

         for i in 1..3 loop
             g_element_value(i) := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 g_user_name(i),
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level);
         end loop;

         l_earnings := 0;
         l_deductions := 0;

         for i in 1..2 loop
            l_earnings := l_earnings + g_element_value(i);
         end loop;

         for i in 3..3 loop
            l_deductions := l_deductions + g_element_value(i);
         end loop;

         bal_amt := l_earnings - l_deductions;

         -- This is fix for Bug # 2505076
         -- Where for Yonker City of NY state requires City wages to
         -- match with Fed wages when taxpayer has yonker City tax withheld
         -- Start fix for Bug # 2505076
         --
         if w2_jurisdiction_code = '33-119-3230' then
            -- When City jurisdiction is Yonkers derive city tax withheld
            --
            l_city_tax_withheld := hr_us_w2_rep.get_w2_arch_bal(
                                       w2_asg_act_id,
                                       'A_CITY_WITHHELD_PER_JD_GRE_YTD' ,
                                       to_char(w2_tax_unit_id),
                                       w2_jurisdiction_code,
                                       w2_jurisdiction_level);
            -- When City Tax withheld is Greater than Zero derive
            -- Fed wages and assign to City Wages
            --
            if get_ny_fed_state_wage_match(w2_tax_unit_id) = 'Y' then
               if l_city_tax_withheld > 0 then
                  bal_amt := hr_us_w2_rep.get_w2_arch_bal(
                                       w2_asg_act_id,
                                       'A_WAGES',
                                       w2_tax_unit_id,
                                      '00-000-0000',0);
               end if;
            end if;
         end if;


   elsif w2_balance_name = 'A_SPL_CITY_LOCAL_WAGES' then

         if w2_jurisdiction_code = '33-000-2010' then

            l_jursd_tbl(1) := '33-005-2010';
            l_jursd_tbl(2) := '33-047-2010';
            l_jursd_tbl(3) := '33-061-2010';
            l_jursd_tbl(4) := '33-081-2010';
            l_jursd_tbl(5) := '33-085-2010';

            l_count        := 5;

         end if;

         if w2_jurisdiction_code = '26-000-0690' then
/* Kansas Missouri */
            l_jursd_tbl(1) := '26-047-0690';
            l_jursd_tbl(2) := '26-037-0690';
            l_jursd_tbl(3) := '26-095-0690';
            l_jursd_tbl(4) := '26-165-0690';

            l_count        := 4;

          end if;
         g_user_name(1) :=  'A_CITY_SUBJ_WHABLE_PER_JD_GRE_YTD';
         g_user_name(2) :=  'A_CITY_SUBJ_NWHABLE_PER_JD_GRE_YTD';
         g_user_name(3) :=  'A_CITY_PRE_TAX_REDNS_PER_JD_GRE_YTD';

         l_earnings := 0;
         l_deductions := 0;

         for j in 1..l_count loop

             for i in 1..3 loop

                 l_withheld := hr_us_w2_rep.get_w2_bal_amt(
                                                 w2_asg_act_id,
                                                 'A_CITY_WITHHELD_PER_JD_GRE_YTD',
                                                 to_char(w2_tax_unit_id),
                                                 l_jursd_tbl(j),
                                                 w2_jurisdiction_level);
                 if l_withheld <= 0 then
                    g_element_value(i) := 0;
                 else
                    g_element_value(i) := hr_us_w2_rep.get_w2_bal_amt(
                                                 w2_asg_act_id,
                                                 g_user_name(i),
                                                 to_char(w2_tax_unit_id),
                                                 l_jursd_tbl(j),
                                                 w2_jurisdiction_level);
                 end if;
             end loop;


             for i in 1..2 loop
                 l_earnings := l_earnings + g_element_value(i);
             end loop;

             for i in 3..3 loop
                 l_deductions := l_deductions + g_element_value(i);
             end loop;

         end loop;

         bal_amt := l_earnings - l_deductions;

   elsif w2_balance_name = 'A_COUNTY_LOCAL_WAGES' then

         g_user_name(1) :=  'A_COUNTY_SUBJ_WHABLE_PER_JD_GRE_YTD';
         g_user_name(2) :=  'A_COUNTY_SUBJ_NWHABLE_PER_JD_GRE_YTD';
         g_user_name(3) :=  'A_COUNTY_PRE_TAX_REDNS_PER_JD_GRE_YTD';

         for i in 1..3 loop
             g_element_value(i) := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 g_user_name(i),
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level);
         end loop;

         l_earnings := 0;
         l_deductions := 0;

         for i in 1..2 loop
            l_earnings := l_earnings + g_element_value(i);
         end loop;

         for i in 3..3 loop
            l_deductions := l_deductions + g_element_value(i);
         end loop;

         bal_amt := l_earnings - l_deductions;

   elsif w2_balance_name = 'A_SCHOOL_LOCAL_WAGES' then

         g_user_name(1) :=  'A_SCHOOL_SUBJ_WHABLE_PER_JD_GRE_YTD';
         g_user_name(2) :=  'A_SCHOOL_SUBJ_NWHABLE_PER_JD_GRE_YTD';
         g_user_name(3) :=  'A_SCHOOL_PRE_TAX_REDNS_PER_JD_GRE_YTD';

         for i in 1..3 loop
             g_element_value(i) := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 g_user_name(i),
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level);
         end loop;

         l_earnings := 0;
         l_deductions := 0;

         for i in 1..2 loop
            l_earnings := l_earnings + g_element_value(i);
         end loop;

         for i in 3..3 loop
            l_deductions := l_deductions + g_element_value(i);
         end loop;

         bal_amt := l_earnings - l_deductions;

   elsif  w2_balance_name = 'A_W2_GROSS_1099R' then

         g_user_name(1) :=  'A_GROSS_EARNINGS_PER_GRE_YTD';

             bal_amt := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 g_user_name(1),
                                                 to_char(w2_tax_unit_id),
                                                 '00-000-0000',
                                                 w2_jurisdiction_level);


   elsif  w2_balance_name = 'A_SPL_CITY_WITHHELD_PER_JD_GRE_YTD' then

       if w2_jurisdiction_code = '33-000-2010' then

            l_jursd_tbl(1) := '33-005-2010';
            l_jursd_tbl(2) := '33-047-2010';
            l_jursd_tbl(3) := '33-061-2010';
            l_jursd_tbl(4) := '33-081-2010';
            l_jursd_tbl(5) := '33-085-2010';

            l_count        := 5;

        end if;

        if w2_jurisdiction_code = '26-000-0690' then
/* Kansas Missouri city */
            l_jursd_tbl(1) := '26-047-0690';
            l_jursd_tbl(2) := '26-037-0690';
            l_jursd_tbl(3) := '26-095-0690';
            l_jursd_tbl(4) := '26-165-0690';

            l_count        := 4;

        end if;
        bal_amt := 0;

        for j in 1..l_count loop

           l_amt := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                  'A_CITY_WITHHELD_PER_JD_GRE_YTD',
                                  to_char(w2_tax_unit_id),
                                  l_jursd_tbl(j),
                                  w2_jurisdiction_level);

        bal_amt := bal_amt + l_amt;

        end loop;
   --
   -- This is to Fix the Social Security Wages Bug 2287844
   --
   elsif w2_balance_name = 'A_SS_EE_TAXABLE_PER_GRE_YTD' then
             bal_amt := /* Social Security Wages */
                        hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 w2_balance_name,
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level)
                        -
                        /* Social Security Tips - Box 7 */
                        hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 'A_W2_BOX_7_PER_GRE_YTD',
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level);

   elsif w2_balance_name = 'A_W2_401K_PER_GRE_YTD' then
             bal_amt := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 w2_balance_name,
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level)
                        -
                        get_w2_userra_bal(w2_asg_act_id,
                                          w2_tax_unit_id        ,
                                          w2_jurisdiction_code  ,
                                          w2_jurisdiction_level ,
                                          '401K');
   elsif w2_balance_name = 'A_W2_403B_PER_GRE_YTD' then
             bal_amt := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 w2_balance_name,
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level)
                        -
                        get_w2_userra_bal(w2_asg_act_id,
                                          to_char(w2_tax_unit_id),
                                          w2_jurisdiction_code  ,
                                          w2_jurisdiction_level ,
                                          '403B');
   elsif w2_balance_name = 'A_W2_457_PER_GRE_YTD' then
             bal_amt := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 w2_balance_name,
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level)
                        -
                        get_w2_userra_bal(w2_asg_act_id,
                                          to_char(w2_tax_unit_id),
                                          w2_jurisdiction_code  ,
                                          w2_jurisdiction_level ,
                                          '457');

   --
   -- For all other Archived Balance not conditionally computed
   -- above is derived with the following

   else
             bal_amt := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                 w2_balance_name,
                                                 to_char(w2_tax_unit_id),
                                                 w2_jurisdiction_code,
                                                 w2_jurisdiction_level);
   end if;

   return(bal_amt);

EXCEPTION
 WHEN OTHERS THEN
   return(0);

END; /* FUNCTION get_w2_arch_bal */


FUNCTION get_w2_organization_id(w2_asg_id in number, w2_effective_date in date)
                          RETURN NUMBER IS
l_org_id number;

BEGIN
   -- pay_us_balance_view_pkg.debug_msg('FUNCTION : get_w2_organization_id ');
   -- pay_us_balance_view_pkg.debug_msg('Assignment Id : '||to_char(w2_asg_id));
   -- pay_us_balance_view_pkg.debug_msg('Effective Date : '|| to_char(w2_effective_date,'DD-MM-YYYY'));

	select paf.organization_id
	into   l_org_id
	from   per_assignments_f paf
	where  paf.assignment_id = w2_asg_id
	and    w2_effective_date between paf.effective_start_date
			         and     paf.effective_end_date;
        return(l_org_id);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     return(-99999);
	WHEN OTHERS THEN
	     return(-99999);
END; /* FUNCTION get_w2_organization_id */


FUNCTION get_w2_location_id(w2_asg_id in number, w2_effective_date in date)
                          RETURN NUMBER IS
l_loc_id number;

BEGIN
   -- pay_us_balance_view_pkg.debug_msg('FUNCTION :  get_w2_location_id ');
   -- pay_us_balance_view_pkg.debug_msg('Assignment Id : '||to_char(w2_asg_id));
   -- pay_us_balance_view_pkg.debug_msg('Effective Date : '|| to_char(w2_effective_date,'DD-MM-YYYY'));

        select paf.location_id
        into   l_loc_id
        from   per_assignments_f paf
        where  paf.assignment_id = w2_asg_id
        and    w2_effective_date between paf.effective_start_date
                                 and     paf.effective_end_date;
        return(l_loc_id);
EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return(-99999);
        WHEN OTHERS THEN
             return(-99999);
END; /* FUNCTION get_w2_organization_id */


FUNCTION get_w2_postal_code(w2_person_id in number, w2_effective_date in date)
                          RETURN VARCHAR2 IS

l_postal_code per_addresses.postal_code%type;

BEGIN
   -- pay_us_balance_view_pkg.debug_msg('FUNCTION :  get_w2_postal_code ');
   -- pay_us_balance_view_pkg.debug_msg('Person Id : '||to_char(w2_person_id));
   -- pay_us_balance_view_pkg.debug_msg('Effective Date : '|| to_char(w2_effective_date,'DD-MM-YYYY'));
        select pa.postal_code
        into   l_postal_code
        from   per_addresses pa
        where  pa.person_id = w2_person_id
	and    pa.primary_flag = 'Y'
        and    w2_effective_date between pa.date_from
                                 and     nvl(pa.date_to,w2_effective_date);
        return(l_postal_code);
EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return(00000);
        WHEN OTHERS THEN
             return(000000);
END; /* FUNCTION get_w2_organization_id */

FUNCTION get_w2_employee_name(w2_person_id IN NUMBER, w2_effective_date IN DATE)
RETURN VARCHAR2 IS

CURSOR c_w2_emp_name IS
SELECT ppf.last_name|| ' ' || ppf.first_name || ' ' || substr(ppf.middle_names,1,1) emp_name
FROM per_all_people_f ppf
WHERE ppf.person_id = w2_person_id
AND w2_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

c_w2_emp_name_rec	c_w2_emp_name%ROWTYPE;

BEGIN

OPEN c_w2_emp_name;
FETCH c_w2_emp_name INTO c_w2_emp_name_rec;
CLOSE c_w2_emp_name;

RETURN c_w2_emp_name_rec.emp_name;

END;


FUNCTION get_w2_state_ein   (   w2_tax_unit_id in number,
                                w2_state_abbrev in varchar2)
                                RETURN varchar2 IS

CURSOR my_cursor IS
		select 	ORG_INFORMATION3
		from	hr_organization_information
 		where 	organization_id 	= w2_tax_unit_id
 		and	org_information_context = 'State Tax Rules'
		and 	org_information1 	= w2_state_abbrev;


state_id 	hr_organization_information.ORG_INFORMATION3%TYPE;

BEGIN
--
-- Get Employee State ID No for Box 16
--


	OPEN my_cursor;
	FETCH my_cursor INTO state_id;
	CLOSE my_cursor;

	return(state_id);

EXCEPTION WHEN NO_DATA_FOUND THEN
	return('NO STATE EIN');

END; /* get_w2_state_ein */

FUNCTION get_w2_state_uin      (   w2_tax_unit_id in number,
                                w2_state_abbrev in varchar2)
                                RETURN varchar2 IS
CURSOR UI_cursor IS
		select 	nvl(ORG_INFORMATION2,'NO STATE UI#')
		from	hr_organization_information
 		where 	organization_id 	= w2_tax_unit_id
 		and	org_information_context = 'State Tax Rules'
		and 	org_information1 	= w2_state_abbrev;


ui_id 	hr_organization_information.ORG_INFORMATION2%TYPE;

BEGIN

-- Get Employee State UI ID No for Box 16 - NJ
--

	OPEN UI_cursor;
	FETCH UI_cursor INTO ui_id;
	CLOSE UI_cursor;

	return(ui_id);

EXCEPTION WHEN NO_DATA_FOUND THEN
	return('NO STATE UI#');
	  WHEN OTHERS THEN
	return('NO STATE UI#');

END; /* get_w2_state_uin */



FUNCTION get_w2_high_comp_amt  (w2_rownum in number,
                                w2_restrict in number,
                                w2_bal_amt in number)
                                RETURN number IS
l_return_value number :=0;

BEGIN
	if (	w2_rownum * w2_restrict - (0.01 * (w2_rownum-1))) <= w2_bal_amt then
		l_return_value := w2_restrict - (0.01 * (w2_rownum-1));
	else
		l_return_value := w2_bal_amt;
		for i in 1 .. (w2_rownum - 1) LOOP
			l_return_value := l_return_value - (w2_restrict - (0.01 * (i-1)));
		end loop;
		if l_return_value <= 0 then
		   l_return_value := 0;
		end if;
	end if;

	return(l_return_value);
EXCEPTION
	WHEN OTHERS THEN
	return(0);
END; /* get_w2_high_comp_amt */


FUNCTION get_w2_box_15 (w2_asg_act_id   number,
                        w2_balance_name varchar2,
                        w2_tax_unit_id  number,
                        w2_jurisdiction_code varchar2,
                        w2_jurisdiction_level number
                        ) RETURN VARCHAR2 is
BEGIN

   return(hr_us_w2_rep.get_w2_box_15 (w2_asg_act_id,
                  w2_balance_name,
                  w2_tax_unit_id,
                  w2_jurisdiction_code,
                  w2_jurisdiction_level,
                  null));

END get_w2_box_15;


FUNCTION get_w2_box_15 (w2_asg_act_id   number,
                        w2_balance_name varchar2,
                        w2_tax_unit_id  number,
                        w2_jurisdiction_code varchar2,
                        w2_jurisdiction_level number,
                        w2_effective_date date ) RETURN VARCHAR2 is

l_user_entity_id number;
l_bal_amt        number;

cursor c_sel is
 select decode(fai.value, 'Y', 1, 'D', 1, 0)
   from ff_archive_items fai
  where fai.context1 = w2_asg_act_id
    and fai.user_entity_id = l_user_entity_id;

BEGIN

  if w2_balance_name = 'A_W2_PENSION_PLAN_PER_GRE_YTD' then
     -- Changed for EOY 2000
      if w2_effective_date is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_BOX_13D_PER_GRE_YTD', /* EOY 2000 */
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);

        if l_bal_amt <= 0 or l_bal_amt is null then
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_BOX_13E_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;

        if l_bal_amt <= 0 or l_bal_amt is null then
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    w2_balance_name,
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;
     else
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_401K_PER_GRE_YTD', /* EOY 2001 */
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);

        if l_bal_amt <= 0 or l_bal_amt is null then
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_403B_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;

        if l_bal_amt <= 0 or l_bal_amt is null then
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_408K_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;

        if l_bal_amt <= 0 or l_bal_amt is null then
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_501C_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;

        if l_bal_amt <= 0 or l_bal_amt is null then
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    w2_balance_name,
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;

          if l_bal_amt <= 0 or l_bal_amt is null then      /* 5748431 */
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                   'A_W2_ROTH_403B_PER_GRE_YTD',
                                   to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;



        if l_bal_amt <= 0 or l_bal_amt is null then        /* 5748431 */
           l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                   'A_W2_ROTH_401K_PER_GRE_YTD',
                                   to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
        end if;

       end if;
  elsif w2_balance_name = 'A_DEF_COMP_401K_PER_GRE_YTD' then
     if w2_effective_date is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_BOX_13D_PER_GRE_YTD', /* EOY 2000 */
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      if l_bal_amt <= 0 or l_bal_amt is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                     'A_W2_BOX_13E_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      end if;
      if l_bal_amt <= 0 or l_bal_amt is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                     'A_W2_BOX_13G_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      end if;
      if l_bal_amt <= 0 or l_bal_amt is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    w2_balance_name,
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      end if;
    else
      l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    'A_W2_401K_PER_GRE_YTD', /* EOY 2001 */
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      if l_bal_amt <= 0 or l_bal_amt is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                     'A_W2_403B_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      end if;
      if l_bal_amt <= 0 or l_bal_amt is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                     'A_W2_457_PER_GRE_YTD',
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      end if;
      if l_bal_amt <= 0 or l_bal_amt is null then
        l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    w2_balance_name,
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
      end if;

    end if;
  elsif w2_balance_name  = 'A_W2_TP_SICK_PAY_PER_GRE_YTD' then
     /* For Sick Pay Indicator, will use only this balance */
     l_bal_amt := hr_us_w2_rep.get_w2_bal_amt
                                   (w2_asg_act_id,
                                    w2_balance_name,
                                    to_char(w2_tax_unit_id),
                                    w2_jurisdiction_code,
                                    w2_jurisdiction_level);
  else
    l_user_entity_id := get_user_entity_id(w2_balance_name);

    open c_sel;
    fetch c_sel into l_bal_amt;
    if c_sel%notfound then
       l_bal_amt := 0;
    end if;
    close c_sel;

  end if;

  if l_bal_amt > 0 then
     return('X');
  else
     return(' ');
  end if;

end get_w2_box_15;

FUNCTION get_w2_tax_unit_item (w2_tax_unit_id   number,
                               w2_payroll_action_id number,
                               w2_tax_unit_item varchar2) RETURN VARCHAR2 is

CURSOR c_tax_unit_item IS
                     select fai.value
                     from   ff_archive_item_contexts faic,
                            ff_contexts              fc,
                            ff_archive_items         fai,
                            ff_database_items        fdi
                     where  fdi.user_name        = w2_tax_unit_item
                       and  fdi.user_entity_id   = fai.user_entity_id
                       and  fai.context1         = w2_payroll_action_id
                       and  fc.context_name      = 'TAX_UNIT_ID'
                       and  fai.archive_item_id  = faic.archive_item_id
                       and  faic.context_id      = fc.context_id
                       and  faic.context         = to_char(w2_tax_unit_id);

p_tax_unit_item    ff_archive_items.value%type;

BEGIN
        OPEN  c_tax_unit_item;
        FETCH c_tax_unit_item INTO p_tax_unit_item;
        CLOSE c_tax_unit_item;

        return(p_tax_unit_item);

EXCEPTION WHEN NO_DATA_FOUND THEN
        return(null);
END; /* get_w2_tax_unit_item */

FUNCTION get_tax_unit_addr_line (w2_tax_unit_id   number,
                                 w2_addr_item varchar2) RETURN VARCHAR2 is

cursor c_addr_line is
                   select decode(w2_addr_item,
                      'ADDR1' ,address_line_1,
                      'ADDR2' ,address_line_2,
                      'ADDR3' ,address_line_3,
                      'CITY'  ,town_or_city,
                      'STATE' ,region_2,
                      'COUNTRY',country,
                      'ZIP'   ,postal_code,null)
        from   hr_locations_all hl, /*Bug:2380518 fix */
               hr_organization_units hou
        where  hou.organization_id = w2_tax_unit_id
          and  hou.location_id     = hl.location_id;

addr_line     hr_locations.address_line_1%type;

begin
        OPEN  c_addr_line;
        FETCH c_addr_line INTO addr_line;
        CLOSE c_addr_line;

          return(addr_line);

EXCEPTION when no_data_found then
          return(null);

end; /* get_tax_unit_addr_line */

FUNCTION get_tax_unit_bg (w2_tax_unit_id   number)
                           RETURN NUMBER is

cursor c_bg is
        select
               business_group_id
        from   hr_organization_units hou
        where  hou.organization_id = w2_tax_unit_id;

p_business_group_id hr_organization_units.business_group_id%type;

begin
          OPEN  c_bg;
          FETCH c_bg INTO p_business_group_id;
          CLOSE c_bg;

          return(p_business_group_id);

EXCEPTION when no_data_found then
          return(null);

end; /* get_tax_unit_bg */

FUNCTION get_per_item (w2_assignment_action_id   number,
                       w2_per_item               varchar2)
                       RETURN VARCHAR2 is

cursor c_per_item is
        select
               fai.value
        from   ff_archive_items   fai,
               ff_database_items  fdi
        where  fdi.user_name      = w2_per_item
          and  fdi.user_entity_id = fai.user_entity_id
          and  fai.context1       = w2_assignment_action_id;

-- changed from
-- p_per_item per_people_f.middle_names%type;
-- for bug 2465183 because of UTF8 the length has been
-- increased

 p_per_item per_people_f.last_name%type;

begin

          OPEN  c_per_item;
          FETCH c_per_item INTO p_per_item;
          CLOSE c_per_item;

          return(p_per_item);

EXCEPTION when no_data_found then
          return(null);

end; /* get_per_item */

FUNCTION get_state_item (w2_tax_unit_id   number,
                         w2_jurisdiction_code varchar2,
                         w2_payroll_action_id number,
                         w2_state_item varchar2)
                         RETURN VARCHAR2 is

cursor c_state_item is
        select
          fai.value
        from
          ff_archive_item_contexts faic2,
          ff_archive_item_contexts faic1,
          ff_contexts              fc2,
          ff_contexts              fc1,
          ff_archive_items         fai,
          ff_database_items        fdi
        where fdi.user_name       = w2_state_item
          and fdi.user_entity_id  = fai.user_entity_id
          and fai.context1        = w2_payroll_action_id
          and fc2.context_name    = 'TAX_UNIT_ID'
          and fc1.context_name    = 'JURISDICTION_CODE'
          and fai.archive_item_id = faic2.archive_item_id
          and faic2.context_id    = fc2.context_id
          and faic2.context       = to_char(w2_tax_unit_id)
          and fai.archive_item_id = faic1.archive_item_id
          and faic1.context_id    = fc1.context_id
          and faic1.context       = w2_jurisdiction_code;

p_state_item       varchar2(240);

begin
          OPEN  c_state_item;
          FETCH c_state_item INTO p_state_item;
          CLOSE c_state_item;

          return(p_state_item);

EXCEPTION when no_data_found then
          return(null);

end; /* get_state_item */

FUNCTION get_leav_reason (w2_leaving_reason varchar2)
                       RETURN VARCHAR2 is

cursor c_leav_reason is
      select meaning
      from fnd_lookup_values
      where lookup_type='LEAV_REAS'
      and lookup_code= w2_leaving_reason ;

l_leav_reason VARCHAR2(80);

begin
          OPEN  c_leav_reason;
          FETCH c_leav_reason INTO l_leav_reason;
          CLOSE c_leav_reason;

          return(l_leav_reason);

EXCEPTION when no_data_found then
          return('ZZ');

          when others then
          return('ZZ');

end; /* get_leav_reason */


PROCEDURE GET_COUNTY_TAX_INFO
   ( p_jurisdiction_code IN Varchar2 ,
     p_tax_year           IN NUMBER,
     p_tax_rate           OUT NOCOPY NUMBER,
     P_mh_tax_rate        OUT NOCOPY NUMBER,
     P_mh_tax_limit       OUT NOCOPY NUMBER,
     P_occ_mh_tax_limit   OUT NOCOPY NUMBER,
     P_occ_mh_wage_limit  OUT NOCOPY NUMBER,
     P_mh_tax_wage_limit  OUT NOCOPY NUMBER
     )
   IS

--
-- Purpose: Procedure to fetch County Tax info from pay_us_county_tax_info_f table
--          The return values used in W2 reports for computing Boone County Taxes
--          like Occupatinal and Mental Health Taxes
--
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- ppanda      05-Aug-2002  Initial Version
--
-- Declaration of  Local program variables
--
   l_occ_tax_rate           Varchar2(80) := '';
   l_mh_tax_rate            Varchar2(80) := '';
   l_mh_tax_limit           Varchar2(80) := '';
   l_occ_mh_tax_limit       Varchar2(80) := '';
   l_occ_mh_wage_limit      Varchar2(80) := '';
   l_mh_tax_wage_limit      Varchar2(80) := '';
--
-- This Cursor fetches Tax info for the given jurisdiction and effective date
--
Cursor C_cnty_tax_info (C_jurisdiction_code Varchar2,
                        C_tax_year          NUMBER) IS
       select cnty_information2 occ_tax_rate,
              cnty_information3 mh_tax_rate,
              cnty_information4 mh_tax_limit,
              cnty_information5 occ_mh_tax_limit,
              cnty_information6 occ_mh_wage_limit,
              cnty_information7 mh_tax_wage_limit
         from PAY_US_COUNTY_TAX_INFO_F
        where jurisdiction_code = C_jurisdiction_code
          and (to_date('31-12-'||to_char(C_tax_year), 'DD-MM-YYYY')
                      between effective_start_date and effective_end_date);

BEGIN
    OPEN C_cnty_tax_info(p_jurisdiction_code, P_tax_year);
    FETCH C_cnty_tax_info INTO     l_occ_tax_rate,
                                   l_mh_tax_rate,
                                   l_mh_tax_limit,
                                   l_occ_mh_tax_limit,
                                   l_occ_mh_wage_limit,
                                   l_mh_tax_wage_limit;
    IF C_cnty_tax_info%FOUND then
       p_tax_rate           :=  l_occ_tax_rate;
       P_mh_tax_rate        :=  l_mh_tax_rate;
       P_mh_tax_limit       :=  l_mh_tax_limit;
       P_occ_mh_tax_limit   :=  l_occ_mh_tax_limit;
       P_occ_mh_wage_limit  :=  l_occ_mh_wage_limit;
       P_mh_tax_wage_limit  :=  l_mh_tax_wage_limit;
    END IF;
    CLOSE C_cnty_tax_info;
EXCEPTION
    WHEN others THEN
         NULL;
END; -- Procedure get_county_tax_info


PROCEDURE get_agent_tax_unit_id ( p_business_group_id in number,
                                  p_year              in number,
                                  p_agent_tax_unit_id out nocopy number,
                                  p_error_mesg   out nocopy varchar2 )

IS

--
-- Purpose: Procedure to get Agent Tax Unit Id. Called from Emp W2, ER W2 report
--          and W2 Register report.
--          Input parameter is business_group_id and
--          Output parameter is p_agent_tax_unit_id and p_error_mesg
--          The calling program has to check
--          If p_error_mesg is not null then
--             Error and write the this error mesg in the log file
--          Else if p_agent_tax_unit_id is null then
--               there is no change in the existing process ie incase of
--               Emp W2 it has to take the w2 parameter GRE's name, address and EIN
--          Else (p_agent_tax_unit_id is not null) then
--               the report need to use the p_agent_tax_unit_id to retrieve the
--               GRE's name, address and EIN
--

l_agent_tax_unit_id   number ;
l_count               number ;
l_agent_tax_unit_name varchar2(240) := ' ';
l_w2_tax_unit_id      number ;



begin

  l_agent_tax_unit_id  := null ;
  l_w2_tax_unit_id := null;

  begin

  -- Get 2678 Filer
  select hou.organization_id,
         hou.name
  into l_agent_tax_unit_id,
       l_agent_tax_unit_name
  from hr_organization_information hoi,
       hr_organization_units hou
  where hoi.org_information_context = 'W2 Reporting Rules'
   and hou.organization_id = hoi.organization_id
   and hou.business_group_id = p_business_group_id
   and nvl(org_information8, 'N') = 'Y'
   and not exists (
           select  'Y'
             from hr_organization_information
            where organization_id = hou.organization_id
              and org_information_context = '1099R Magnetic Report Rules');

   begin
      -- Get W2 Transmitter
      select hou.organization_id
       into l_w2_tax_unit_id
      from hr_organization_information hoi,
           hr_organization_units hou
      where hoi.org_information_context = 'W2 Reporting Rules'
       and hou.organization_id = hoi.organization_id
       and hou.business_group_id = p_business_group_id
       and nvl(org_information1, 'N') = 'Y'  -- W2 Transmitter flag
       and not exists (
               select  'Y'
                 from hr_organization_information
                where organization_id = hou.organization_id
                  and org_information_context = '1099R Magnetic Report Rules');

       if l_agent_tax_unit_id = l_w2_tax_unit_id  then  -- is the Filer defined as W2 transmitter ?

         -- Now check whether this agent gre is archived or not
         --
         begin

            select count(*)
            into l_count
            from  pay_us_w2_tax_unit_v
            where tax_unit_id = l_agent_tax_unit_id
             and  year = p_year ;

            if l_count = 0 then

               p_agent_tax_unit_id := null ;
               p_error_mesg        := 'Error : 2678 Filer GRE ' || l_agent_tax_unit_name || 'for Year '
                                              || to_char(p_year) || ' is Not Archived ' ;

            else

               p_agent_tax_unit_id := l_agent_tax_unit_id ;
               p_error_mesg        := null ;

            end if;

         end ; -- End gre is archived ?
       else
         p_agent_tax_unit_id := null ;
         p_error_mesg        := 'Error: 2678 Filer GRE must be defined as W-2 Transmitter. ';

       end if;
   exception -- W2 Transmitter check exception section
    when no_data_found then
       -- error: Filer found; but no W2-Transmitter found
       p_agent_tax_unit_id := null ;
       p_error_mesg        := 'Error: 2678 Filer GRE must be defined as W-2 Transmitter. ';

    when too_many_rows then
       -- error: Multiple W2-Transmitter found
       p_agent_tax_unit_id := null ;
       p_error_mesg        := 'Error:GRE in the business group defined as a 2678 Filer but multiple GREs marked as W-2 transmitter.';


    when others then

       p_agent_tax_unit_id := null ;
       p_error_mesg        := substr(SQLERRM,1,45);

   end;  -- W2 Transmitter check

  exception when too_many_rows then

        -- error multiple Filer GREs found

       p_agent_tax_unit_id := null ;
       p_error_mesg        := 'Error: Only one 2678 Filer GRE can exist in a business group. ' ;
       --p_error_mesg        := p_error_mesg || 'Cannot have more than one GRE with 2678 Filer and/or W-2 Transmitter defined.' ;

  when no_data_found then
        -- Normal processing: no 2678 Filer GREs found.

        p_agent_tax_unit_id := null;
        p_error_mesg        := null;

  when others then

       p_agent_tax_unit_id := null ;
       p_error_mesg        := substr(SQLERRM,1,45);

  end ; -- 2678 Filer check

END get_agent_tax_unit_id;


function  get_w2_userra_bal(w2_asg_act_id         number,
                            w2_tax_unit_id        number ,
                            w2_jurisdiction_code  varchar2 ,
                            w2_jurisdiction_level number,
                            p_userra_code          varchar2
                           ) return number is

l_userra_balance number := 0;
l_bal_amt        number := 0;

cursor c_userra_db_items (c_userra_code varchar2) is
       select user_name
         from ff_database_items
        where user_name like 'A_W2_USERRA_'||c_userra_code||'%_PER_GRE_YTD';

l_balance_name ff_database_items.user_name%type;
begin
for userra_db_items IN c_userra_db_items(p_userra_code)
loop
             l_balance_name :=userra_db_items.user_name;

             l_bal_amt := hr_us_w2_rep.get_w2_bal_amt(w2_asg_act_id,
                                                      l_balance_name,
                                                      w2_tax_unit_id,
                                                      w2_jurisdiction_code,
                                                      w2_jurisdiction_level);
             if l_bal_amt <> 0 then
                 l_userra_balance := l_userra_balance + l_bal_amt;
             end if;
end loop;
return (l_userra_balance);
end get_w2_userra_bal;

FUNCTION  get_w2_box17_label (p_tax_unit_id    in number,
                              p_state_abbrev   in varchar2)
return varchar2 is

   cursor c_get_value_gre is

       select nvl(org_information18,'SDI')
       from hr_organization_information
       where organization_id = p_tax_unit_id
         and org_information_context = 'W2 Reporting Rules';

l_box17_label    varchar2(5);

begin
/* check if the state is 'CA'. If yes then we nned to check == first in the
   plsql table for the value else fetch the value and populate the table
   and return the value */

   hr_utility.trace('TUID is : '|| to_char(p_tax_unit_id));
   hr_utility.trace('State Abbrev is : '|| p_state_abbrev);

   if p_state_abbrev <> 'CA' then

      return ('SDI');

   else

      if hr_us_w2_rep.ltr_box17.exists(p_tax_unit_id) then

         hr_utility.trace('Value exists ');
         l_box17_label := hr_us_w2_rep.ltr_box17(p_tax_unit_id).value;

      else

         hr_utility.trace('Value does not exists ');
         open c_get_value_gre;
         fetch c_get_value_gre into l_box17_label;
         if c_get_value_gre%NOTFOUND then
            l_box17_label := 'SDI';
         end if;
         close c_get_value_gre;

         hr_utility.trace('SQL Value is : '|| l_box17_label);
         hr_us_w2_rep.ltr_box17(p_tax_unit_id).state_abbrev := p_state_abbrev;
         hr_us_w2_rep.ltr_box17(p_tax_unit_id).value := l_box17_label;

      end if;

      hr_utility.trace('Return Value is : '|| l_box17_label);
      return (l_box17_label);

   end if;

end get_w2_box17_label ;



FUNCTION  get_last_deffer_year (p_ass_action_id in number)
return varchar2 is

year   varchar2(20);

CURSOR get_year( cp_action_id number) is

select fai.value designated_roth_contri
from FF_USER_ENTITIES fue,
FF_ARCHIVE_ITEMS fai
where fai.context1 = cp_action_id
 AND fai.user_entity_id = fue.user_entity_id
 AND upper(fue.user_entity_name) = 'A_FIRST_YEAR_ROTH_CONTRIB' ;

 Begin

 OPEN get_year (p_ass_action_id) ;
 FETCH get_year INTO year ;
 CLOSE get_year ;

 RETURN (year);

 END get_last_deffer_year;

 --New function added to get the employee number from active tables

FUNCTION get_w2_employee_number(w2_nat_ident in varchar2, w2_effective_date in date)
                          RETURN varchar2 IS
l_emp_number varchar2(30);

BEGIN
        SELECT peo.employee_number INTO l_emp_number
        FROM   per_all_people_f peo
        WHERE  peo.national_identifier = w2_nat_ident
        AND    w2_effective_date BETWEEN peo.effective_start_date
                                 AND     peo.effective_end_date;
        RETURN(l_emp_number);
EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return(' ');
        WHEN OTHERS THEN
             return(' ');
END;

 --New function added to get the workers compensation code from active tables

FUNCTION get_w2_worker_compensation(w2_asg_id in number, w2_effective_date in date)
                          RETURN varchar2 IS
    l_emp_wc varchar2(30);
    l_emp_loc per_all_assignments_f.location_id%type;
    l_emp_job per_all_assignments_f.job_id%type;
BEGIN
  	    SELECT job_id,location_id into l_emp_job,l_emp_loc
 	        FROM per_all_assignments_f
	 	WHERE assignment_id=w2_asg_id
    	AND w2_effective_date BETWEEN effective_start_date AND effective_end_date;
  		SELECT jwc.wc_code INTO l_emp_wc
             FROM pay_job_wc_code_usages jwc,
                  hr_locations_all hl
          WHERE jwc.job_id = l_emp_job
		        AND hl.location_id = l_emp_loc
		        AND jwc.state_code = hl.region_2;
        return(l_emp_wc);
EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return(' ');
        WHEN OTHERS THEN
             return(' ');
END;

 --New function added to get the location code from active tables

FUNCTION get_w2_location_cd(w2_asg_id in number, w2_effective_date in date)
                          RETURN varchar2 IS
    l_emp_loc varchar2(60);

BEGIN
	SELECT location_code into l_emp_loc
    	FROM per_all_assignments_f paf,
    	     hr_locations_all hl
	WHERE assignment_id=w2_asg_id
    	AND w2_effective_date BETWEEN effective_start_date AND effective_end_date
    	AND paf.location_id=hl.location_id;
        RETURN(l_emp_loc);
EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return(' ');
        WHEN OTHERS THEN
             return(' ');
END;


end hr_us_w2_rep;

/
