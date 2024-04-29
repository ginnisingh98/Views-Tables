--------------------------------------------------------
--  DDL for Package Body PER_ZA_EMPLOYMENT_EQUITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_EMPLOYMENT_EQUITY_PKG" as
/* $Header: perzaeer.pkb 120.30.12010000.16 2010/04/01 09:33:50 rbabla ship $ */
/*
==============================================================================
This package loads data into table per_za_employment_equity for use by
the Employment Equity Reports

MODIFICATION HISTORY

Name           Date        Version Bug     Text
-------------- ----------- ------- ------- -----------------------------
R. Kingham     22 May 2000   110.0         Initial Version
R. Kingham     15 Jun 2000   110.1         Added Extra functionality for EEQ.
D. Son         20 Jun 2001   110.2         Removed data load dbms_sql procedures.
                                           Replaced with lookup functions and
                                           insert procedures.
F.D. Loubser   11 Sep 2001   115.4         Almost complete rewrite for 11i.
F.D. Loubser   10 Dec 2001   115.7         Business_group_id on user table
F.D. Loubser    1 Feb 2002   115.8         QA fixes
F.D. Loubser    1 Feb 2002   115.9         Added checkfile
F.D. Loubser    7 Feb 2002   115.10        Removed low list skip optimization
F.D. Loubser   14 Feb 2002   115.11        Added multiple legal entity
J.N. Louw       5 Apr 2002   115.12        Bug 2306877
                                           Fixed default select statements
                                           each section EQ1 to 6
F.D. Loubser    9 May 2002   115.13        g_cat_flex variable too small
Nirupa S       05 Dec 2002  115.14 2686695 In accordance with the APPS-wide
                                           performance changes for 11.5.9,
                                           NOCOPY has been added to all
                                           OUT and IN OUT  parameters.
Nirupa S       10 Dec 2002  115.14 2686695 Added exception handling for
                                           NOCOPY in calc_highest_and_lowest_avg
A.Sengar       11 Dec 2002  115.16 2665394 Modified the query to improve
                                           performance.
Nageswara      17 Nov 2004  115.17 3962073 modified query to fetch Employee Type
                                           when user has entered value.
                                           Supressed GSCC warnings
Nageswara      24 Nov 2004  115.18 4027769 modified select query to all disabilities
                                           'F','P' as 'Y' (Disabled)
Kaladhaur P    28-Jun-2005  115.20 4445926 Fix GSCC Error: File.Sql.8 and File.Sql.18
Kaladhaur P    28-Jun-2005  115.21 4413678 Function get_avg_5_lowest_salary has been
                                           modified to process employees with race
                                           not equal to 'Not Used'.
A. Mahanty     19-Dec-2005  115.24 4872110 R12 Performance Bug fix. Modified the query in
                                           function get_avg_5_lowest_salary
A. Mahanty     21-Dec-2005  115.25 4872110 R12 Performance Bug fix. Modified the queries in
                                           function populate_ee_table
Kaladhaur P    22-May-2006  115.26 4413678 Function get_avg_5_lowest_salary has been
                                           modified to process employees with race
                                           not equal to 'Not Used'.
Kaladhaur P    20-Jun-2006  115.27 5228238 Query in function get_lookup_code has been
                                           modified to fetch one row for lookup meaning
                                           'Not Applicable'.
Kaladhaur P    04-Jul-2006  115.28 4413678 Modified the comments.
R Pahune       24-Jul-2006  115.30 5406242 Employment equity enhancment.
R Pahune       08-jan-2008  115.43 6773326 To get correct Employment Category due to
                                           changes for WSP.
R Babla        18-Feb-2008  115.49 6817148 Changes in populate_ee_table to consider the
                                           new segment added for foreign national
R Babla        23-Jul-2008  115.50 7277745/Changes done to consider chinese as Africans
                                   7237663 and to cater for employer contribution
R Babla        30-Jul-2008  115.51 7277745/Changes done to add 'Normal' to the balance name
                                   7237663 for Normal ER contribution
P Arusia       25-Aug-2008  115.52 7277745 Corrected the procedure
                                           init_g_cat_lev_table to add l_er_annual_income
                                           to net annual income
R Babla        30-Jul-2008  115.54 7360563 Changes done in cursor c_assignments of
                                           proc init_g_cat_lev_table so as not to
                                           include employee in differential report
                                           which has any of occupational cat/ level
                                           or function type as 'Not Applicable'
R Babla        16-Sep-2009  115.56 8911880 Changes done in procedure init_g_cat_lev_table
                                           to ensure the income differential report doesnt annualize
                                           the income for employees who did not work for completing
                                           reporting year + show actual remuneration for fluctuating
                                           income.
NCHINNAM       17-Nov-2009  115.57 8486088 1. Commented 'EQ1' - Occupational Categories
                                           2. Changed Termination Categories
                                           3. Changed foreign national logic
NCHINNAM       17-Nov-2009  115.58         Fixed GSCC Errors
R Babla        24-Nov-2009  115.59 9112237 Added init_g_cat_lev_new_table and supporting procedures from
                                           reporting year 2009
R Babla        24-Nov-2009  115.60 9112237 Fixed GSCC Warnings
NCHINNAM       01-Dec-2009  115.61 9112237 Added new procedures from
                                           reporting year 2009
NCHINNAM       03-Dec-2009  115.62 9112237 renaming the reason is moved to dt.
R Babla        18-Dec-2009  115.63 9112237 Modified query for inserting rows if row present for foreigner
                                           non permanent, but not present for non foreigner non permanent
                                           in procedure init_g_cat_lev_new_table
R Babla        01-Apr-2010  115.64 9462039 Modified procedures to remove the dependency on Occupation Category
                                           from reporting year 2009
==============================================================================
*/

-- Global types
type r_assignments is record
(
   payroll_id            per_all_assignments_f.payroll_id%type,
   legal_entity_id       hr_all_organization_units.organization_id%type,
   legal_entity       hr_all_organization_units.name%type,
   occupational_level_id    hr_lookups.lookup_code%type,
   occupational_category_id  hr_lookups.lookup_code%type,
   occupational_level    hr_lookups.meaning%type,
   occupational_category  hr_lookups.meaning%type,
   race                  per_all_people_f.per_information4%type,
   sex                   per_all_people_f.sex%type,
   annual_income         number
);

type r_averages is record
(
   high number,
   low  number
);

-- Added for Employment equity report enhancement
type r_Encome_diff_rec is record
(
   legal_entity_id     hr_all_organization_units.organization_id%type,
   legal_entity     hr_all_organization_units.NAME%type,
   occupational_code_id   hr_lookups.lookup_code%type,
   occupational_code   hr_lookups.meaning%type,
   ma                  number,
   mc                  number,
   mi                  number,
   mw                  number,
   fa                  number,
   fc                  number,
   fi                  number,
   fw                  number,
   total               number,
   ma_inc              number,
   mc_inc              number,
   mi_inc              number,
   mw_inc              number,
   fa_inc              number,
   fc_inc              number,
   fi_inc              number,
   fw_inc              number,
   total_inc           number
);

type t_assignments is table of r_assignments index by binary_integer;
type t_averages    is table of r_averages    index by binary_integer;

TYPE t_E_differential IS TABLE OF r_Encome_diff_rec INDEX BY binary_integer;


type rec_assignments is record
(
   payroll_id            per_all_assignments_f.payroll_id%type,
   legal_entity_id       hr_all_organization_units.organization_id%type,
   legal_entity       hr_all_organization_units.name%type,
   occupational_level_id    hr_lookups.lookup_code%type,
   occupational_category_id  hr_lookups.lookup_code%type,
   occupational_level    hr_lookups.meaning%type,
   occupational_category  hr_lookups.meaning%type,
   race                  per_all_people_f.per_information4%type,
   sex                   per_all_people_f.sex%type,
   employment_type       varchar2(30), --Permanent/Non Permanent
   foreigner             varchar2(30), --Foreigner or not
   annual_income         number
);
type t_new_assignments is table of rec_assignments index by binary_integer;
g_new_assignments_table   t_new_assignments;
g_lev_Enc_Diff_table_F t_E_differential; --For Permanent foreigners
g_lev_Enc_Diff_table_T t_E_differential; --For Temporary non foreigner workers
g_lev_Enc_Diff_table_TF t_E_differential; --For Temporary foreigners workers



-- Global variables
g_package            constant varchar2(30) := 'per_za_employment_equity_pkg.';
g_assignments_table  t_assignments;
g_cat_averages_table t_averages;
g_lev_averages_table t_averages;

g_cat_Enc_Diff_table t_E_differential;
g_lev_Enc_Diff_table t_E_differential;

g_grade_name         per_grades.name%type;
g_grade_report_date  date;
g_grade_asg_id       per_all_assignments_f.assignment_id%type;

g_position_name      per_all_positions.name%type;
g_pos_report_date    date;
g_pos_asg_id         per_all_assignments_f.assignment_id%type;

g_job_name           per_jobs.name%type;
g_job_report_date    date;
g_job_asg_id         per_all_assignments_f.assignment_id%type;

g_lev_name           hr_lookups.meaning%type;
g_lev_report_date    date;
g_lev_asg_id         per_all_assignments_f.assignment_id%type;

g_cat_name           hr_lookups.meaning%type;
g_cat_report_date    date;
g_cat_asg_id         per_all_assignments_f.assignment_id%type;

g_lev_flex           pay_user_column_instances_f.value%type := null;
g_lev_segment        pay_user_column_instances_f.value%type := null;
g_cat_flex           pay_user_column_instances_f.value%type := null;
g_cat_segment        pay_user_column_instances_f.value%type := null;
g_f_type_name        hr_lookups.meaning%type;
g_Func_flex          pay_user_column_instances_f.value%type := null;
g_Func_segment       pay_user_column_instances_f.value%type := null;

g_high1 number := 0;
g_high2 number := 0;
g_high3 number := 0;
g_high4 number := 0;
g_high5 number := 0;

g_low1 number := 999999999999999;
g_low2 number := 999999999999999;
g_low3 number := 999999999999999;
g_low4 number := 999999999999999;
g_low5 number := 999999999999999;

g_all_high_avg number := -9999;
g_all_low_avg  number := -9999;

-- This procedure resets the list of highest and lowest values.
procedure reset_high_low_lists is

l_proc constant varchar2(60) := g_package || 'reset_high_low_lists';

begin

   hr_utility.set_location('Entering ' || l_proc, 10);

   g_high1 := 0;
   g_high2 := 0;
   g_high3 := 0;
   g_high4 := 0;
   g_high5 := 0;

   g_low1  := 999999999999999;
   g_low2  := 999999999999999;
   g_low3  := 999999999999999;
   g_low4  := 999999999999999;
   g_low5  := 999999999999999;

end reset_high_low_lists;

-- This procedure returns the average of the 5 highes and lowest values from the lists.
procedure calc_highest_and_lowest_avg
(
   p_high_avg out nocopy number,
   p_low_avg  out nocopy number
)  is

l_high_avg number  := 0;
l_low_avg  number  := 0;
l_count    integer := 0;

begin

   if g_high1 <> 0 then
      l_count    := 1;
      l_high_avg := g_high1;
   end if;
   if g_high2 <> 0 then
      l_count    := l_count + 1;
      l_high_avg := l_high_avg + g_high2;
   end if;
   if g_high3 <> 0 then
      l_count    := l_count + 1;
      l_high_avg := l_high_avg + g_high3;
   end if;
   if g_high4 <> 0 then
      l_count    := l_count + 1;
      l_high_avg := l_high_avg + g_high4;
   end if;
   if g_high5 <> 0 then
      l_count    := l_count + 1;
      l_high_avg := l_high_avg + g_high5;
   end if;
   if l_count = 0 then
      p_high_avg := 0;
   else
      p_high_avg := l_high_avg / l_count;
   end if;

   l_count := 0;
   if g_low1 <> 999999999999999 then
      l_count   := 1;
      l_low_avg := g_low1;
   end if;
   if g_low2 <> 999999999999999 then
      l_count   := l_count + 1;
      l_low_avg := l_low_avg + g_low2;
   end if;
   if g_low3 <> 999999999999999 then
      l_count   := l_count + 1;
      l_low_avg := l_low_avg + g_low3;
   end if;
   if g_low4 <> 999999999999999 then
      l_count   := l_count + 1;
      l_low_avg := l_low_avg + g_low4;
   end if;
   if g_low5 <> 999999999999999 then
      l_count   := l_count + 1;
      l_low_avg := l_low_avg + g_low5;
   end if;
   if l_count = 0 then
      p_low_avg := 0;
   else
      p_low_avg := l_low_avg / l_count;
   end if;
--
exception
   when others then
    p_high_avg := null;
    p_low_avg  := null;
--

end calc_highest_and_lowest_avg;

-- This procedure maintains a list of the 5 highest and lowest values passed to it.
procedure get_highest_and_lowest(p_value in number) is

l_proc constant varchar2(60) := g_package || 'get_highest_and_lowest';

begin

   hr_utility.set_location('Entering ' || l_proc, 10);
   hr_utility.set_location('p_value ' || to_char(p_value), 20);

   -- Ignore the value if it is zero
   if p_value <> 0 then

      -- Determine whether the value belongs in the highest list
      if p_value > g_high5 then

         if p_Value > g_high4 then

            if p_value > g_high3 then

               if p_value > g_high2 then

                  if p_value > g_high1 then

                     g_high5 := g_high4;
                     g_high4 := g_high3;
                     g_high3 := g_high2;
                     g_high2 := g_high1;
                     g_high1 := p_value;

                  else

                     g_high5 := g_high4;
                     g_high4 := g_high3;
                     g_high3 := g_high2;
                     g_high2 := p_value;

                  end if;

               else

                  g_high5 := g_high4;
                  g_high4 := g_high3;
                  g_high3 := p_value;

               end if;

            else

               g_high5 := g_high4;
               g_high4 := p_value;

            end if;

         else

            g_high5 := p_value;

         end if;

      end if;

      hr_utility.set_location('g_high1 ' || to_char(g_high1), 40);
      hr_utility.set_location('g_high2 ' || to_char(g_high2), 50);
      hr_utility.set_location('g_high3 ' || to_char(g_high3), 60);
      hr_utility.set_location('g_high4 ' || to_char(g_high4), 70);
      hr_utility.set_location('g_high5 ' || to_char(g_high5), 80);

      -- Determine whether the value belongs in the lowest list
      if p_value < g_low5 then

         if p_value < g_low4 then

            if p_value < g_low3 then

               if p_value < g_low2 then

                  if p_value < g_low1 then

                     g_low5 := g_low4;
                     g_low4 := g_low3;
                     g_low3 := g_low2;
                     g_low2 := g_low1;
                     g_low1 := p_value;

                  else

                     g_low5 := g_low4;
                     g_low4 := g_low3;
                     g_low3 := g_low2;
                     g_low2 := p_value;

                  end if;

               else

                  g_low5 := g_low4;
                  g_low4 := g_low3;
                  g_low3 := p_value;

               end if;

            else

               g_low5 := g_low4;
               g_low4 := p_value;

            end if;

         else

            g_low5 := p_value;

         end if;

      end if;

      hr_utility.set_location('g_low1 ' || to_char(g_low1), 90);
      hr_utility.set_location('g_low2 ' || to_char(g_low2), 100);
      hr_utility.set_location('g_low3 ' || to_char(g_low3), 110);
      hr_utility.set_location('g_low4 ' || to_char(g_low4), 120);
      hr_utility.set_location('g_low5 ' || to_char(g_low5), 130);

   end if; -- Zero check

end get_highest_and_lowest;

-- This function returns the number of days the assignment's status was Active Assignment
-- Note: Suspended Assignment is not seen as active in this case, since it is not
--       income generating
function get_active_days
(
   p_assignment_id number,
   p_report_start  date,
   p_report_end    date
)  return number is

l_count number;

begin

   select sum
          (
             decode(sign(p_report_end - paaf.effective_end_date), 1, paaf.effective_end_date, p_report_end)
             -
             decode(sign(p_report_start - paaf.effective_start_date), 1, p_report_start, paaf.effective_start_date)
             + 1
          )
   into   l_count
   from   per_assignment_status_types past,
          per_all_assignments_f       paaf
   where  paaf.assignment_id = p_assignment_id
   and    past.assignment_status_type_id = paaf.assignment_status_type_id
   and    past.per_system_status = 'ACTIVE_ASSIGN'
   and    paaf.effective_start_date <= p_report_end
   and    paaf.effective_end_date   >= p_report_start;

   return l_count;

exception
   when no_data_found then
      return 0;

end get_active_days;

-- This function returns the termination reason from the user tables.
function get_termination_reason
(
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_reason_code       in per_periods_of_service.leaving_reason%type
)  return varchar2 is

l_termination_reason pay_user_column_instances_f.value%type;

begin

   select pucifcat.value
   into   l_termination_reason
   from   pay_user_column_instances_f pucifcat,
          pay_user_rows_f             purfcat,
          pay_user_columns            puccat,
          pay_user_rows_f             purfqc,
          pay_user_column_instances_f pucifqc,
          pay_user_columns            pucqc,
          pay_user_tables             put
   where  put.user_table_name = 'ZA_TERMINATION_CATEGORIES'
   and    put.business_group_id is null
   and    put.legislation_code = 'ZA'
   and    pucqc.user_table_id = put.user_table_id
   and    pucqc.user_column_name = 'Lookup Code'
   and    pucifqc.user_column_id = pucqc.user_column_id
   and    pucifqc.business_group_id = p_business_group_id
   and    p_report_date between pucifqc.effective_start_date and pucifqc.effective_end_date
   and    pucifqc.value = p_reason_code
   and    purfqc.user_table_id = put.user_table_id
   and    purfqc.user_row_id = pucifqc.user_row_id
   and    purfqc.business_group_id = pucifqc.business_group_id
   and    p_report_date between purfqc.effective_start_date and purfqc.effective_end_date
   and    puccat.user_table_id = put.user_table_id
   and    puccat.user_column_name = 'Termination Category'
   and    purfcat.user_table_id = put.user_table_id
   and    purfcat.business_group_id = pucifqc.business_group_id
   and    p_report_date between purfcat.effective_start_date and purfcat.effective_end_date
   and    purfcat.row_low_range_or_name = purfqc.row_low_range_or_name
   and    pucifcat.user_column_id = puccat.user_column_id
   and    pucifcat.user_row_id = purfcat.user_row_id
   and    p_report_date between pucifcat.effective_start_date and pucifcat.effective_end_date
   and    pucifcat.business_group_id = pucifqc.business_group_id
   and    pucifcat.value in
   (
      'Resignation',
      'Non-Renewal of Contract',
      'Dismissal - Operational Requirements',
      'Dismissal - Misconduct',
      'Dismissal - Incapacity',
      'Other'
   );

   return l_termination_reason;

exception
   when no_data_found then
      return 'No Leaving Reason';

end get_termination_reason;

-- This procedure resets all the data structures for the Income Differentials report.
procedure reset_tables is

l_proc constant varchar2(60) := g_package || 'reset_tables';

begin

   -- hr_utility.trace_on(null, 'T');
   hr_utility.set_location('Entering ' || l_proc, 10);

   g_assignments_table.delete;
   g_all_high_avg := -9999;
   g_all_low_avg  := -9999;
   g_cat_averages_table.delete;
   g_lev_averages_table.delete;
   g_cat_Enc_Diff_table.delete;
   g_lev_Enc_Diff_table.delete;
   DELETE FROM per_za_employment_equity
    Where report_id IN
                   ( 'ED1', 'ED2', 'ED1I','ED2I');

end reset_tables;

-- This function returns the average 5 highest paid employees per category or level.
function get_avg_5_highest_salary
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legent_param           in per_assignment_extra_info.aei_information7%type := null,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_occupational_level_cat in hr_lookups.meaning%type,
   p_lookup_code            in hr_lookups.lookup_code%type,
   p_occupational_type      in varchar2, -- CAT = Category, LEV = Level
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
)  return number is

l_avg_5_highest_salary number;
l_index                number;
l_proc                 constant varchar2(60) := g_package || 'get_avg_5_highest_salary';

begin

   hr_utility.set_location('Entering ' || l_proc, 10);

   -- The index is calculted by multiplying the legal entity id by 100 and then adding the lookup code
   -- This should always give a unique value, since the lookup code is less than 100
   begin

      l_index := p_legal_entity_id * 100 + p_lookup_code;
      hr_utility.set_location('LEV/CAT INDEX ' || l_index, 25);

   exception
      when others then
         raise_application_error(-20006, 'The lookup code in the ZA_EMP_EQ_OCCUPATIONAL_LEV and ZA_EMP_EQ_OCCUPATIONAL_CAT lookups must be numeric.');

   end;

   -- First populate the cache tables, if necessary
   -- Note: No check is made for the validity of the table data, since it is assumed that the
   --       reset_tables procedure was called before this procedure.
   -- This does not actually calculate the value, it just calls the lowest procedure
   -- to populate the cache
   if p_occupational_type = 'LEV' then

      -- Check whether the averages for the current occupational level already exist.
      if not g_lev_averages_table.exists(l_index) then

         hr_utility.set_location('Step ' || l_proc, 20);
         l_avg_5_highest_salary := get_avg_5_lowest_salary
                                (
                                   p_report_date            => p_report_date,
                                   p_business_group_id      => p_business_group_id,
                                   p_legal_entity_id        => p_legal_entity_id,
                                   p_occupational_level_cat => p_occupational_level_cat,
                                   p_lookup_code            => p_lookup_code,
                                   p_occupational_type      => p_occupational_type,
                                   p_salary_method          => p_salary_method
                                );
      end if;

   elsif p_occupational_type = 'CAT' then

      -- Check whether the averages for the current occupational category already exist.
      if not g_cat_averages_table.exists(l_index) then

         hr_utility.set_location('Step ' || l_proc, 23);
         l_avg_5_highest_salary := get_avg_5_lowest_salary
                                (
                                   p_report_date            => p_report_date,
                                   p_business_group_id      => p_business_group_id,
                                   p_legal_entity_id        => p_legal_entity_id,
                                   p_occupational_level_cat => p_occupational_level_cat,
                                   p_lookup_code            => p_lookup_code,
                                   p_occupational_type      => p_occupational_type,
                                   p_salary_method          => p_salary_method
                                );
      end if;

   elsif p_occupational_type is null then

      -- Check whether the averages already exist.
      if g_all_high_avg = -9999 then

         hr_utility.set_location('Step ' || l_proc, 24);
         l_avg_5_highest_salary := get_avg_5_lowest_salary
                                (
                                   p_report_date            => p_report_date,
                                   p_business_group_id      => p_business_group_id,
                                   p_legal_entity_id        => p_legal_entity_id,
                                   p_occupational_level_cat => p_occupational_level_cat,
                                   p_lookup_code            => p_lookup_code,
                                   p_occupational_type      => p_occupational_type,
                                   p_salary_method          => p_salary_method
                                );

      end if;

   end if;

   hr_utility.set_location('Lookup Code ' || p_lookup_code, 25);

   -- Check Occupational Type
   if p_occupational_type = 'LEV' then

      l_avg_5_highest_salary := g_lev_averages_table(l_index).high;
      hr_utility.set_location('LEV ' || to_char(l_avg_5_highest_salary), 30);

   elsif p_occupational_type = 'CAT' then

      l_avg_5_highest_salary := g_cat_averages_table(l_index).high;
      hr_utility.set_location('CAT ' || to_char(l_avg_5_highest_salary), 40);

   -- Average 5 highest salaries for all employees, irrespective of category or levels
   -- elsif p_occupational_type not in ('CAT','LEV')
   elsif p_occupational_type is null then

      l_avg_5_highest_salary := g_all_high_avg;
      hr_utility.set_location('TOTAL ' || to_char(l_avg_5_highest_salary), 50);

   end if;

   hr_utility.set_location('Exiting ' || l_proc, 60);
   return l_avg_5_highest_salary;

end get_avg_5_highest_salary;

-- This function returns the average 5 lowest paid employees per category or level.
function get_avg_5_lowest_salary
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legent_param           in per_assignment_extra_info.aei_information7%type := null,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_occupational_level_cat in hr_lookups.meaning%type,
   p_lookup_code            in hr_lookups.lookup_code%type,
   p_occupational_type      in varchar2, -- LEV = Levels, CAT = Categories
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
)  return number is

cursor c_assignments is
   select paaf.assignment_id,
          paaf.person_id, -- Bug 4413678
          paaf.payroll_id,
          paei.aei_information7,
          per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)    occupational_level,
          per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id) occupational_category,
          paaf.pay_basis_id
   from   per_assignment_extra_info   paei,
          per_assignment_status_types past,
          per_all_assignments_f       paaf
   where  paaf.business_group_id = p_business_group_id
   and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
   and    past.assignment_status_type_id = paaf.assignment_status_type_id
   and    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    paei.assignment_id = paaf.assignment_id
   and    paei.information_type = 'ZA_SPECIFIC_INFO'
   and    paei.aei_information7 = nvl(p_legent_param, paei.aei_information7)
   and    paei.aei_information7 is not null
   and    nvl(paei.aei_information6, 'N') <> 'Y'
   order  by paaf.payroll_id;

l_avg_5_lowest_salary number;
l_old_payroll_id      per_all_assignments_f.payroll_id%type := -9999;
l_rowind              pls_integer;
l_active_days         number;
l_ee_income           number;
l_ee_annual_income    number;
l_report_start        date;
l_report_end          date;
l_report_date         date;
l_difference          number;
l_period_frequency    per_time_period_types.number_per_fiscal_year%type;
l_ee_balance_type_id  pay_balance_types.balance_type_id%type;
l_eea_balance_type_id pay_balance_types.balance_type_id%type;
l_input_value_id      pay_input_values_f.input_value_id%type;
l_index               number;
l_proc                constant varchar2(60) := g_package || 'get_avg_5_lowest_salary';
l_race                per_all_people_f.per_information4%type; -- Bug 4413678

begin

   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Determine whether we need to populate the cache tables
   -- Note: No check is made for the validity of the table data, since it is assumed that the
   --       reset_tables procedure was called before this procedure.
   if g_assignments_table.count = 0 then

      hr_utility.set_location('Setup assignments cache', 20);
      g_assignments_table.delete;

      if p_salary_method = 'BAL' then

         -- Get the balance type id's for the normal and annual balances
         begin

            select balance_type_id
            into   l_ee_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable Income'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

            select balance_type_id
            into   l_eea_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable Annual Income'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

         exception
            when no_data_found then
               raise_application_error(-20000, 'The Employment Equitable balances do not exist.');

         end;

      end if;

      if p_salary_method = 'ELE' then

         -- Get the ZA Employment Equity Remuneration element details
         begin

            select pivf.input_value_id
            into   l_input_value_id
            from   pay_input_values_f         pivf,
                   pay_element_types_f        petf
            where  petf.element_name = 'ZA Employment Equity Remuneration'
            and    petf.business_group_id is null
            and    petf.legislation_code = 'ZA'
            and    p_report_date between petf.effective_start_date and petf.effective_end_date
            and    pivf.element_type_id = petf.element_type_id
            and    pivf.name = 'Remuneration'
            and    p_report_date between pivf.effective_start_date and pivf.effective_end_date;

         exception
            when no_data_found then
               raise_application_error(-20004, 'The ZA Employment Equity Remuneration element does not exist.');

         end;

      end if;

      -- Loop through the assignments cursor and populate the assignments table
      for l_assignment in c_assignments loop

         hr_utility.set_location('ASG ' || l_assignment.assignment_id, 21);

         -- Bug 4413678: Begin
         Select per_information4
         into l_race
         From per_all_people_f papf
         Where papf.person_id = l_assignment.person_id
               and p_report_date between papf.effective_start_date and papf.effective_end_date;
         -- Bug 4413678: End


         if l_assignment.payroll_id is not null and l_race <> 'N' then -- Bug 4413678: Added l_race <> 'Not Used'

            g_assignments_table(l_assignment.assignment_id).payroll_id            := l_assignment.payroll_id;
            g_assignments_table(l_assignment.assignment_id).legal_entity_id       := l_assignment.aei_information7;
            g_assignments_table(l_assignment.assignment_id).occupational_level    := l_assignment.occupational_level;
            g_assignments_table(l_assignment.assignment_id).occupational_category := l_assignment.occupational_category;

            hr_utility.set_location('LEGENT ' || l_assignment.aei_information7, 22);

            -- Check for a new payroll_id and cache the new payroll details in the payrolls table
            if l_assignment.payroll_id <> l_old_payroll_id then

               -- Get the start date and end date of the report
               begin


                  l_report_date := p_report_date;
                  l_difference := 0;

                  while (l_difference < 355 or l_difference > 375) loop

                     select ptpf.end_date + 1,
                            ptpl.end_date
                     into   l_report_start,
                            l_report_end
                     from   per_time_periods ptpf,
                            per_time_periods ptpl
                     where  ptpl.payroll_id = l_assignment.payroll_id
                     and    l_report_date between ptpl.start_date and ptpl.end_date
                     and    ptpf.payroll_id = l_assignment.payroll_id
                     and    add_months(l_report_date, -12) + 1 between ptpf.start_date and ptpf.end_date;

                     l_difference := l_report_end - l_report_start + 1;

                     if (l_difference < 355 or l_difference > 375) then

                        l_report_date := l_report_date - 1;

                     end if;

                  end loop;

               exception
                  when no_data_found then
                     begin
                             select ptpl.end_date
                             into   l_report_end
                             from   per_time_periods ptpl
                             where  ptpl.payroll_id = l_assignment.payroll_id
                             and    p_report_date between ptpl.start_date and ptpl.end_date;

                     exception
                             when no_data_found then
                                      Null;
                     end;

                     l_report_start := add_months(l_report_end, -12) + 1;

               end;

               -- Get the payroll period frequency
               begin

                  select ptpt.number_per_fiscal_year
                  into   l_period_frequency
                  from   per_time_period_types ptpt,
                         pay_all_payrolls_f    payr
                  where  payr.payroll_id = l_assignment.payroll_id
                  and    p_report_date between payr.effective_start_date and payr.effective_end_date
                  and    ptpt.period_type = payr.period_type;

               exception
                  when no_data_found then
                     raise_application_error(-20005, 'The Payroll Period Frequency does not exist.');

               end;

               l_old_payroll_id := l_assignment.payroll_id;

            end if;

            hr_utility.set_location('REP_START ' || to_char(l_report_start, 'DD\MM\YYYY'), 22);
            hr_utility.set_location('REP_END   ' || to_char(l_report_end, 'DD\MM\YYYY'), 23);
            hr_utility.set_location('FREQ      ' || l_period_frequency, 24);

            if p_salary_method = 'BAL' then

               -- Get the amount of days the assignment status was Active Assignment
               l_active_days := get_active_days
                                (
                                   p_assignment_id => l_assignment.assignment_id,
                                   p_report_start  => l_report_start,
                                   p_report_end    => l_report_end
                                );

               hr_utility.set_location('ACT_DAYS ' || l_active_days, 25);

               -- Get the Employment Equitable Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_ee_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  -- BUG 2665394 ADDED THE TABLE TO IMPROVE THE PERFORMANCE
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                  and    ppa.date_earned between l_report_start and l_report_end
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_ee_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  -- BUG 2665394 ADDED THE JOINS TO IMPROVE THE PERFORMANCE
                  and    paa.assignment_id = asg.assignment_id
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_ee_income := 0;

               end;

               -- Get the Employment Equitable Annual Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_ee_annual_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  -- BUG 2665394 ADDED THE TABLE TO IMPROVE THE PERFORMANCE
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                  and    ppa.date_earned between l_report_start and l_report_end
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_eea_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  -- BUG 2665394 ADDED THE JOINS TO IMPROVE THE PERFORMANCE
                  and    paa.assignment_id = asg.assignment_id
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_ee_annual_income := 0;

               end;

               hr_utility.set_location('EE_INC ' || l_ee_income, 26);
               hr_utility.set_location('EE_ANN ' || l_ee_annual_income, 27);
               hr_utility.set_location('STminEND ' || (l_report_end - l_report_start + 1), 28);

               -- Calculate the annual income = annualize normal income + annual income
               g_assignments_table(l_assignment.assignment_id).annual_income :=
                  (
                     (l_report_end - l_report_start + 1) / l_active_days * l_ee_income
                  ) + l_ee_annual_income;

               hr_utility.set_location('ANSWER ' || g_assignments_table(l_assignment.assignment_id).annual_income, 29);

            elsif p_salary_method = 'SAL' then

               -- Get the annual salary basis for the current period
               begin

                  select ppp.proposed_salary_n * ppb.pay_annualization_factor
                  into   g_assignments_table(l_assignment.assignment_id).annual_income
                  from   per_pay_proposals ppp,
                         per_pay_bases     ppb
                  where  ppb.pay_basis_id = l_assignment.pay_basis_id
                  and    ppp.assignment_id = l_assignment.assignment_id
                  and    ppp.approved = 'Y'
                  and    ppp.change_date =
                  (
                     select max(ppp2.change_date)
                     from   per_pay_proposals ppp2
                     where  ppp2.assignment_id = l_assignment.assignment_id
                     and    ppp2.change_date <= p_report_date
                     and    ppp2.approved = 'Y'
                  );

               exception
                  when no_data_found then
                     g_assignments_table(l_assignment.assignment_id).annual_income := 0;

               end;

            elsif p_salary_method = 'ELE' then

               begin

                  select peevf.screen_entry_value * l_period_frequency
                  into   g_assignments_table(l_assignment.assignment_id).annual_income
                  from   pay_element_entry_values_f peevf,
                         pay_element_entries_f      peef
                  where  peef.assignment_id = l_assignment.assignment_id
                  and    p_report_date between peef.effective_start_date and peef.effective_end_date
                  and    peevf.element_entry_id = peef.element_entry_id
                  and    peevf.input_value_id = l_input_value_id
                  and    p_report_date between peevf.effective_start_date and peevf.effective_end_date;

               exception
                  when no_data_found then
                     g_assignments_table(l_assignment.assignment_id).annual_income := 0;

               end;

            end if;   -- p_salary_method

         end if;   -- (l_assignment.payroll_id is not null)

      end loop;   -- c_assignments

   end if;   -- g_assignments_table.count = 0

   -- The index is calculted by multiplying the legal entity id by 100 and then adding the lookup code
   -- This should always give a unique value, since the lookup code is less than 100
   begin

      l_index := p_legal_entity_id * 100 + p_lookup_code;
      hr_utility.set_location('LEV/CAT INDEX ' || l_index, 25);

   exception
      when others then
         raise_application_error(-20006, 'The lookup code in the ZA_EMP_EQ_OCCUPATIONAL_LEV and ZA_EMP_EQ_OCCUPATIONAL_CAT lookups must be numeric.');

   end;

   if p_occupational_type = 'LEV' then

      hr_utility.set_location('LEV cache check' || p_lookup_code, 30);

      -- Check whether the averages for the current occupational level already exist.
      if not g_lev_averages_table.exists(l_index) then

         hr_utility.set_location('LEV cache' || p_lookup_code, 40);
         reset_high_low_lists;

         -- Loop through assignments cache table to look for current occupational level
         l_rowind := g_assignments_table.first;
         loop

            exit when l_rowind is null;

            -- If the occupational category of the assignment is the same as the one we are
            -- looking for then add the value to the highest and lowest list
            if  g_assignments_table(l_rowind).occupational_level = p_occupational_level_cat
            and g_assignments_table(l_rowind).legal_entity_id = p_legal_entity_id then

               get_highest_and_lowest(g_assignments_table(l_rowind).annual_income);

            end if;

            l_rowind := g_assignments_table.next(l_rowind);

         end loop;

         -- Calculate the average of the 5 highest and lowest values in the list,
         -- and add the answers to the occupational level average cache table
         calc_highest_and_lowest_avg
         (
            g_lev_averages_table(l_index).high,
            g_lev_averages_table(l_index).low
         );
         l_avg_5_lowest_salary := g_lev_averages_table(l_index).low;

      else

         l_avg_5_lowest_salary := g_lev_averages_table(l_index).low;

      end if;

   elsif p_occupational_type = 'CAT' then

      hr_utility.set_location('CAT cache check' || p_lookup_code, 50);

      -- Check whether the averages for the current occupational category already exist.
      if not g_cat_averages_table.exists(l_index) then

         hr_utility.set_location('CAT cache' || p_lookup_code, 60);
         reset_high_low_lists;

         -- Loop through assignments cache table to look for current occupational category
         l_rowind := g_assignments_table.first;
         loop

            exit when l_rowind is null;

            -- If the occupational category of the assignment is the same as the one we are
            -- looking for then add the value to the highest and lowest list
            if  g_assignments_table(l_rowind).occupational_category = p_occupational_level_cat
            and g_assignments_table(l_rowind).legal_entity_id = p_legal_entity_id then

               get_highest_and_lowest(g_assignments_table(l_rowind).annual_income);

            end if;

            l_rowind := g_assignments_table.next(l_rowind);

         end loop;

         -- Calculate the average of the 5 highest and lowest values in the list,
         -- and add the answers to the occupational category average cache table
         calc_highest_and_lowest_avg
         (
            g_cat_averages_table(l_index).high,
            g_cat_averages_table(l_index).low
         );
         l_avg_5_lowest_salary := g_cat_averages_table(l_index).low;

      else

         l_avg_5_lowest_salary := g_cat_averages_table(l_index).low;

      end if;

   --  elsif p_occupational_type not in ('CAT', 'LEV')
   elsif p_occupational_type is null then

      hr_utility.set_location('TOTAL cache check', 50);

      -- Check whether the averages already exist.
      if g_all_high_avg = -9999 then

         hr_utility.set_location('TOTAL cache', 60);
         reset_high_low_lists;

         -- Loop through assignments cache table to look for current occupational category
         l_rowind := g_assignments_table.first;
         loop

            exit when l_rowind is null;

            -- Add the value to the highest and lowest list
            get_highest_and_lowest(g_assignments_table(l_rowind).annual_income);

            l_rowind := g_assignments_table.next(l_rowind);

         end loop;

         -- Calculate the average of the 5 highest and lowest values in the list,
         -- and add the answers to the occupational level average cache table
         calc_highest_and_lowest_avg
         (
            g_all_high_avg,
            g_all_low_avg
         );
         l_avg_5_lowest_salary := g_all_low_avg;

      else

         l_avg_5_lowest_salary := g_all_low_avg;

      end if;

   end if;

   return l_avg_5_lowest_salary;

end get_avg_5_lowest_salary;

-- This function returns the person's legislated employment type (permanent or non-permanent)
-- The employee has to work for a continuous period of 3 months in order to be seen as permanent
function get_ee_employment_type_name
(
   p_report_date          in per_all_people_f.start_date%type,
   p_period_of_service_id in per_all_assignments_f.period_of_service_id%type
)  return varchar2 is

l_ee_employment_type_name    varchar2(13);
l_date_start                 per_periods_of_service.date_start%type;
l_date_end                   date;
l_actual_termination_date    per_periods_of_service.actual_termination_date%type;
l_projected_termination_date per_periods_of_service.projected_termination_date%type;

begin

   select date_start,
          actual_termination_date,
          projected_termination_date
   into   l_date_start,
          l_actual_termination_date,
          l_projected_termination_date
   from   per_periods_of_service
   where  period_of_service_id = p_period_of_service_id;

   if l_actual_termination_date is null then

      if l_projected_termination_date is null then

         l_date_end := to_date('30-12-4712', 'DD-MM-YYYY');

      else

         -- If the report date is after the projected termination date,
         -- then the projected termination date is discarded
         if p_report_date > l_projected_termination_date then

            l_date_end := to_date('30-12-4712', 'DD-MM-YYYY');

         else   -- Use the projected termination date

            l_date_end := l_projected_termination_date;

         end if;

      end if;

   else

      l_date_end := l_actual_termination_date;

   end if;

   if months_between(l_date_end + 1, l_date_start) < 3 then
      l_ee_employment_type_name := 'Non-Permanent';
   else
      l_ee_employment_type_name := 'Permanent';
   end if;

   return l_ee_employment_type_name;

exception
   when no_data_found then
      return 'Non-Permanent';

end get_ee_employment_type_name;

-- This function returns the occupational category from the common lookups table.
function get_occupational_category
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type
)  return varchar2 is

begin

   -- Check whether we have cached the location of Occupational data
   if g_cat_flex is null then

      cache_occupational_location(p_report_date, p_business_group_id);

   end if;

   -- Check whether the current assignment's value is cached already
   if  p_report_date   = g_cat_report_date
   and p_assignment_id = g_cat_asg_id then

      return g_cat_name;

   else

      g_cat_report_date := p_report_date;
      g_cat_asg_id      := p_assignment_id;

      g_cat_name := get_occupational_data
                    (
                       p_type        => 'CAT',
                       p_flex        => g_cat_flex,
                       p_segment     => g_cat_segment,
                       p_job_id      => p_job_id,
                       p_grade_id    => p_grade_id,
                       p_position_id => p_position_id
                    );

      return g_cat_name;

   end if;

end get_occupational_category;

-- This function returns the occupational levels from the user tables.
function get_occupational_level
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_year              in number
)  return varchar2 is

begin

   -- Check whether we have cached the location of Occupational data
   if g_lev_flex is null then

      cache_occupational_location(p_report_date, p_business_group_id,p_year);

   end if;

   -- Check whether the current assignment's value is cached already
   if  p_report_date   = g_lev_report_date
   and p_assignment_id = g_lev_asg_id then

      return g_lev_name;

   else

      g_lev_report_date := p_report_date;
      g_lev_asg_id      := p_assignment_id;

      g_lev_name := get_occupational_data
                    (
                       p_type        => 'LEV',
                       p_flex        => g_lev_flex,
                       p_segment     => g_lev_segment,
                       p_job_id      => p_job_id,
                       p_grade_id    => p_grade_id,
                       p_position_id => p_position_id
                    );

      return g_lev_name;

   end if;

end get_occupational_level;

function get_occupational_cat_data
(
   p_type        in varchar2,
   p_flex        in varchar2,
   p_segment     in varchar2,
   p_job_id      in per_all_assignments_f.job_id%type,
   p_grade_id    in per_all_assignments_f.grade_id%type,
   p_position_id in per_all_assignments_f.position_id%type
)  return varchar2 is

l_name hr_lookups.meaning%type;
l_sql varchar2(32767);
begin

   hr_utility.set_location('p_job_id '||p_job_id , 30);
   hr_utility.set_location('p_grade_id '||p_grade_id , 30);
   hr_utility.set_location('p_position_id '||p_position_id , 30);

   if p_flex = 'Job' then
      begin

         if p_job_id is not null then
--            hr_utility.set_location('Security_grp_Id    :' || fnd_global.lookup_security_group('ZA_WSP_OCCUPATIONAL_CATEGORIES',3),30);
            l_sql := 'select decode(flv1.attribute1,null,flv1.meaning, flv2.meaning) from fnd_lookup_values flv1, fnd_lookup_values flv2, per_job_definitions pjd, per_jobs pj where pj.job_id = '
                     || to_char(p_job_id)
                     || '  and pjd.job_definition_id = pj.job_definition_id '
                     || ' and flv1.lookup_type = '||'''ZA_WSP_OCCUPATIONAL_CATEGORIES'''
                     || ' and flv1.lookup_code = pjd.' || p_segment
                     || ' and   flv2.lookup_type(+) = '||'''ZA_EMP_EQ_OCCUPATIONAL_CAT'''
                     || ' and   flv2.lookup_code(+) = flv1.attribute1'
                     || ' and   flv1.security_group_id = fnd_global.lookup_security_group(flv1.lookup_type,3)'
                     || ' and   flv1.language = userenv('||'''LANG'''||')'
                     || ' and   flv2.language(+) = userenv('||'''LANG'''||')';


            execute immediate l_sql into l_name;
         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   elsif p_flex = 'Grade' then

      begin
         if p_grade_id is not null then

            l_sql := 'select decode(flv1.attribute1,null,flv1.meaning, flv2.meaning) from fnd_lookup_values flv1, fnd_lookup_values flv2, per_grade_definitions pgd, per_grades pg where pg.grade_id = '
                     || to_char(p_grade_id)
                     || ' and  pgd.grade_definition_id = pg.grade_definition_id '
                     || ' and flv1.lookup_type = '||'''ZA_WSP_OCCUPATIONAL_CATEGORIES'''
                     || ' and  flv1.lookup_code = pgd.' || p_segment
                     || ' and   flv2.lookup_type(+) = '||'''ZA_EMP_EQ_OCCUPATIONAL_CAT'''
                     || ' and   flv2.lookup_code(+) = flv1.attribute1'
                       || ' and   flv1.security_group_id = fnd_global.lookup_security_group(flv1.lookup_type,3)'
                     || ' and   flv1.language = userenv('||'''LANG'''||')'
                     || ' and   flv2.language(+) = userenv('||'''LANG'''||')';

            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   elsif p_flex = 'Position' then

      begin
         if p_position_id is not null then

            l_sql := 'select decode(flv1.attribute1,null,flv1.meaning, flv2.meaning) from fnd_lookup_values flv1, fnd_lookup_values flv2, per_position_definitions ppd, per_all_positions pap where pap.position_id = '
                     || to_char(p_position_id)
                     || '  and ppd.position_definition_id = pap.position_definition_id '
                     || '  and flv1.lookup_type = '||'''ZA_WSP_OCCUPATIONAL_CATEGORIES'''
                     || ' and flv1.lookup_code = ppd.' || p_segment
                     || ' and   flv2.lookup_type(+) = '||'''ZA_EMP_EQ_OCCUPATIONAL_CAT'''
                     || ' and   flv2.lookup_code(+) = flv1.attribute1'
                     || ' and   flv1.security_group_id = fnd_global.lookup_security_group(flv1.lookup_type,3)'
                     || ' and   flv1.language = userenv('||'''LANG'''||')'
                     || ' and   flv2.language(+) = userenv('||'''LANG'''||')';


            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   else

      raise_application_error(-20002, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Flexfield.');

   end if;

RETURN l_name;

END get_occupational_cat_data;


-- This function retrieves the occupational data via dynamic sql from the appropriate flexfield segment
/*
08-Jan-2008
Logic for changes in the get_occupational_data
if the p_type = 'CAT' -- Category
check if the lookup_type 'ZA_WSP_OCCUPATIONAL_CATEGORIES' present in db.
if it is present the Grade/Job/Position flexfields will have the
cotegory code from the ZA_WSP_OCCUPATIONAL_CATEGORIES stored on the flexfield.
And the corresponding the Employment Equity code we have to get from
ZA_EMP_EQ_OCCUPATIONAL_CAT .

*/

function get_occupational_data
(
   p_type        in varchar2,
   p_flex        in varchar2,
   p_segment     in varchar2,
   p_job_id      in per_all_assignments_f.job_id%type,
   p_grade_id    in per_all_assignments_f.grade_id%type,
   p_position_id in per_all_assignments_f.position_id%type
)  return varchar2 is

l_sql  varchar2(32767);
l_indicator  NUMBER;
l_name hr_lookups.meaning%type;
l_code hr_lookups.lookup_code%type;
l_lookup_type hr_lookups.lookup_type%type;

begin
   -- Added 08-Jan-2008
   l_indicator := 0;
   hr_utility.set_location('p_type '||p_type,20);
   hr_utility.set_location('p_flex '||p_flex,20);
   hr_utility.set_location('p_segment'||p_segment,20);
   IF p_type = 'CAT' then
     Select COUNT(*)
     INTO   l_indicator
     FROM   hr_lookups
     WHERE  lookup_type = 'ZA_WSP_OCCUPATIONAL_CATEGORIES';
   END IF ;

   hr_utility.set_location('l_indicator'||l_indicator, 20);

   IF l_indicator > 0 THEN
      l_name := get_occupational_cat_data
                  (
                   p_type        => p_type,
                   p_flex        => p_flex,
                   p_segment     => p_segment,
                   p_job_id      => p_job_id,
                   p_grade_id    => p_grade_id,
                   p_position_id => p_position_id
                   );

   RETURN l_name;
   END IF ;
   --End

   if p_flex = 'Job' then

      begin
         if p_job_id is not null then
            l_sql := 'select hl.meaning from hr_lookups hl, per_job_definitions pjd, per_jobs pj where pj.job_id = '
                     || to_char(p_job_id)
                     || '  and pjd.job_definition_id = pj.job_definition_id and hl.application_id = 800 and hl.lookup_type = ''ZA_EMP_EQ_OCCUPATIONAL_'
                     || p_type || ''' and hl.lookup_code = pjd.' || p_segment;

            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   elsif p_flex = 'Grade' then

      begin
         if p_grade_id is not null then
            l_sql := 'select hl.meaning from hr_lookups hl, per_grade_definitions pgd, per_grades pg where pg.grade_id = '
                     || to_char(p_grade_id)
                     || '  and pgd.grade_definition_id = pg.grade_definition_id and hl.application_id = 800 and hl.lookup_type = ''ZA_EMP_EQ_OCCUPATIONAL_'
                     || p_type || ''' and hl.lookup_code = pgd.' || p_segment;

            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   elsif p_flex = 'Position' then

      begin
         if p_position_id is not null then
            l_sql := 'select hl.meaning from hr_lookups hl, per_position_definitions ppd, per_all_positions pap where pap.position_id = '
                     || to_char(p_position_id)
                     || '  and ppd.position_definition_id = pap.position_definition_id and hl.application_id = 800 and hl.lookup_type = ''ZA_EMP_EQ_OCCUPATIONAL_'
                     || p_type || ''' and hl.lookup_code = ppd.' || p_segment;

            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   else

      raise_application_error(-20002, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Flexfield.');

   end if;

   return l_name;

end get_occupational_data;

-- This procedure caches the location of the occupational category and level data.
procedure cache_occupational_location
(
   p_report_date       in date,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_year              in number
)  is

l_user_table_id       pay_user_tables.user_table_id%type;
l_user_column_id_flex pay_user_columns.user_column_id%type;
l_user_column_id_seg  pay_user_columns.user_column_id%type;
l_user_row_id_cat     pay_user_rows_f.user_row_id%type;
l_user_row_id_lev     pay_user_rows_f.user_row_id%type;
l_user_row_id_func    pay_user_rows_f.user_row_id%type;
l_temp                varchar2(9);

begin
--   hr_utility.trace_on(null,'PERZAEER');

   select user_table_id
   into   l_user_table_id
   from   pay_user_tables
   where  user_table_name = 'ZA_OCCUPATIONAL_TYPES'
   and    business_group_id is null
   and    legislation_code = 'ZA';

   hr_utility.set_location('l_user_table_id'||l_user_table_id, 10);

   select user_column_id
   into   l_user_column_id_flex
   from   pay_user_columns
   where  user_table_id = l_user_table_id
   and    business_group_id is null
   and    legislation_code = 'ZA'
   and    user_column_name = 'Flexfield';

   select user_column_id
   into   l_user_column_id_seg
   from   pay_user_columns
   where  user_table_id = l_user_table_id
   and    business_group_id is null
   and    legislation_code = 'ZA'
   and    user_column_name = 'Segment';

   --Added if condition for Bug 9462039 as Occupational Categories not required from 2009 reporting year
   if p_year < 2009 then
           select user_row_id
           into   l_user_row_id_cat
           from   pay_user_rows_f
           where  user_table_id = l_user_table_id
           and    row_low_range_or_name = 'Occupational Categories'
           and    p_report_date between effective_start_date and effective_end_date;

           select value
           into   g_cat_flex
           from   pay_user_column_instances_f
           where  user_row_id    = l_user_row_id_cat
           and    user_column_id = l_user_column_id_flex
           and    business_group_id = p_business_group_id
           and    p_report_date between effective_start_date and effective_end_date;

           select value
           into   g_cat_segment
           from   pay_user_column_instances_f
           where  user_row_id    = l_user_row_id_cat
           and    user_column_id = l_user_column_id_seg
           and    business_group_id = p_business_group_id
           and    p_report_date between effective_start_date and effective_end_date;

           hr_utility.set_location('l_user_row_id_cat'||l_user_row_id_cat, 10);
           hr_utility.set_location('g_cat_flex'||g_cat_flex, 10);
           hr_utility.set_location('g_cat_segment'||g_cat_segment, 10);

   end if;

   select user_row_id
   into   l_user_row_id_lev
   from   pay_user_rows_f
   where  user_table_id = l_user_table_id
   and    row_low_range_or_name = 'Occupational Levels'
   and    p_report_date between effective_start_date and effective_end_date;

   select user_row_id
   into   l_user_row_id_func
   from   pay_user_rows_f
   where  user_table_id = l_user_table_id
   and    row_low_range_or_name = 'Function Type'
   and    p_report_date between effective_start_date and effective_end_date;


   select value
   into   g_lev_flex
   from   pay_user_column_instances_f
   where  user_row_id    = l_user_row_id_lev
   and    user_column_id = l_user_column_id_flex
   and    business_group_id = p_business_group_id
   and    p_report_date between effective_start_date and effective_end_date;

   select value
   into   g_Func_flex
   from   pay_user_column_instances_f
   where  user_row_id    = l_user_row_id_func
   and    user_column_id = l_user_column_id_flex
   and    business_group_id = p_business_group_id
   and    p_report_date between effective_start_date and effective_end_date;

   select value
   into   g_lev_segment
   from   pay_user_column_instances_f
   where  user_row_id    = l_user_row_id_lev
   and    user_column_id = l_user_column_id_seg
   and    business_group_id = p_business_group_id
   and    p_report_date between effective_start_date and effective_end_date;


   select value
   into   g_Func_segment
   from   pay_user_column_instances_f
   where  user_row_id    = l_user_row_id_func
   and    user_column_id = l_user_column_id_seg
   and    business_group_id = p_business_group_id
   and    p_report_date between effective_start_date and effective_end_date;

   hr_utility.set_location('l_user_table_id'||l_user_table_id, 10);
   hr_utility.set_location('l_user_column_id_flex'||l_user_column_id_flex, 10);
   hr_utility.set_location('l_user_column_id_seg'||l_user_column_id_seg, 10);
   hr_utility.set_location('l_user_row_id_lev'||l_user_row_id_lev, 10);
   hr_utility.set_location('l_user_row_id_func'||l_user_row_id_func, 10);
   hr_utility.set_location('g_lev_flex'||g_lev_flex, 10);
   hr_utility.set_location('g_Func_flex'||g_Func_flex, 10);
   hr_utility.set_location('g_lev_segment'||g_lev_segment, 10);
   hr_utility.set_location('g_Func_segment'||g_Func_segment, 10);
   -- Verify the validity of the segments
   begin

      l_temp := substr(g_lev_segment, 8);
      if substr(g_lev_segment, 1, 7) <> 'SEGMENT' or to_number(l_temp) < 1 or to_number(l_temp) > 30 then
         raise_application_error(-20003, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Segment.');
      end if;

      --Added if condition for Bug 9462039 as Occupational Categories not required from 2009 reporting year
      if p_year < 2009 then
          l_temp := substr(g_cat_segment, 8);
          if substr(g_cat_segment, 1, 7) <> 'SEGMENT' or to_number(l_temp) < 1 or to_number(l_temp) > 30 then
             raise_application_error(-20003, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Segment.');
          end if;
       end if;

   exception
      when invalid_number then
         raise_application_error(-20003, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Segment.');

   end;

exception
   when no_data_found then
      raise_application_error(-20001, 'The Occupational data does not exist in the User Table ZA_OCCUPATIONAL_TYPES.');

end cache_occupational_location;

-- This function returns the lookup_code from the user tables.
function get_lookup_code
(
   p_meaning in hr_lookups.meaning%type
)  return varchar2 is

l_lookup_code hr_lookups.lookup_code%type;

begin

   select distinct hl.lookup_code
   into   l_lookup_code
   from   hr_lookups hl
   where  hl.lookup_type in ('ZA_EMP_EQ_OCCUPATIONAL_CAT', 'ZA_EMP_EQ_OCCUPATIONAL_LEV')
   and    hl.meaning = p_meaning;

   return l_lookup_code;

end get_lookup_code;

-- This function populates an entity's sex and race and category matches.
procedure populate_ee_table
(
   p_report_code       in varchar2,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
)  is

l_counter number;
l_reason  varchar2(200);

begin

   -- Note EQ1 is for the following 2 reports:
   --    2. Occupational Categories (including employees with disabilities)
   --    3. Occupational Categories (only employees with disabilities)
   if p_report_code = 'EQ1' then

      -- Note: The date effective select on per_all_assignments_f is ok in this case, since an assignment
      --       record always exist at the same time as an employee record with status EMP
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )      report_code,
             p_report_date                                                              reporting_date,
             paaf.business_group_id,
             paei.aei_information7                                                      legal_entity_id,
             haou.name                                                                  legal_entity,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)    disability, --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id) employment_type,  -- Bug 3962073
             hl.lookup_code                                                             meaning_code,
             nvl(per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Category') occupational_category,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
      from   hr_lookups                hl,
             hr_lookups                hl1,
             hr_lookups                hl2,
             hr_all_organization_units haou,
             per_assignment_extra_info paei,
             per_all_assignments_f     paaf,
             per_all_people_f          papf
      where  papf.business_group_id = p_business_group_id
      and    p_report_date between papf.effective_start_date and papf.effective_end_date
      and    papf.current_employee_flag = 'Y'
      and    paaf.person_id = papf.person_id
      and    paaf.primary_flag = 'Y'
      and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
      and    paei.assignment_id = paaf.assignment_id
      and    paei.information_type = 'ZA_SPECIFIC_INFO'
      and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
      and    paei.aei_information7 is not null
      and    nvl(paei.aei_information6, 'N') <> 'Y'
      and    haou.organization_id = paei.aei_information7
      and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and    hl.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      AND    hl.lookup_code <> '15' -- Not Applicable.
      and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
      AND    hl1.lookup_code <> '15' -- Not Applicable.
      and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      AND    hl2.lookup_code <> '15' -- Not Applicable.
      and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      group  by paaf.business_group_id,
             paei.aei_information7,
             haou.name,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)), -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id),  -- Bug 3962073
             hl.lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Category'),
             p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                              decode(papf.PER_INFORMATION3,null,null,
                              decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    );

      commit;

      -- Inserts non-associated occupational categories with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ1'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ1'
         and    pzee.business_group_id = p_business_group_id           --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

-- Inseting 0 VALUES FOR FOREIGN nationals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ1F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ1F'
         and    pzee.business_group_id = p_business_group_id           --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ2 is for the following 2 reports:
   --    4. Occupational Levels (including employees with disabilities)
   --    5. Occupational Levels (only employees with disabilities)
   elsif p_report_code = 'EQ2' then

      -- Populate with Occupational Level Totals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))
             ) report_code,
             p_report_date                                                              reporting_date,
             paaf.business_group_id,
             paei.aei_information7                                                      legal_entity_id,
             haou.name                                                                  legal_entity,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)      disability, --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id) employment_type,  -- Bug 3962073
             hl.lookup_code                                                             meaning_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level') occupational_level,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
      from   hr_lookups                hl,
             hr_lookups                hl1,
             hr_lookups                hl2,
             hr_all_organization_units haou,
             per_assignment_extra_info paei,
             per_all_assignments_f     paaf,
             per_all_people_f          papf
      where  papf.business_group_id = p_business_group_id
      and    p_report_date between papf.effective_start_date and papf.effective_end_date
      and    papf.current_employee_flag = 'Y'
      and    paaf.person_id = papf.person_id
      and    paaf.primary_flag = 'Y'
      and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
      and    paei.assignment_id = paaf.assignment_id
      and    paei.information_type = 'ZA_SPECIFIC_INFO'
      and    paei.aei_information7 = nvl(p_legal_entity_id,paei.aei_information7)
      and    paei.aei_information7 is not null
      and    nvl(paei.aei_information6, 'N') <> 'Y'
      and    haou.organization_id = paei.aei_information7
      and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      AND    hl.lookup_code <> '15' -- Not Applicable.
      and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
      AND    hl1.lookup_code <> '15' -- Operation / core function
      and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      AND    hl2.lookup_code <> '15' -- Not Applicable.
      group  by paaf.business_group_id,
             paei.aei_information7,
             haou.name,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)), -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id), -- Bug 3962073
             hl.lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level'),
             p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F')));

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ2'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ2'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


-- inserting 0 values for the Foreign Nationals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ2F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ2F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


      commit;

-- For employment equity enhancement
   elsif p_report_code = 'EQ3' then

      -- Populate with New Hires
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F')))     report_code,
                p_report_date                                                                                                                                       reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                                                                                               legal_entity_id,
                haou.name                                                                                                                                           legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability, -- 3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id)                                                         employment_type, -- Bug 3962073
                hl.lookup_code                                                                                                                                      meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    p_report_date between papf.effective_start_date and papf.effective_end_date
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         AND    hl1.lookup_code = '1' -- Operation / core function
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level'),
                p_report_code ||  decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F')))
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ3'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ3'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ3F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ3F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ4 is for the following report:
   --    2.3.1. Operational / core Functiona (report the total number of new recruits into each occupational level during
   --       the twelve months preceding this report)
   elsif p_report_code = 'EQ4' then

      -- Populate with New Hires
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F')))     report_code,
                p_report_date                                                                                                                                       reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                                                                                               legal_entity_id,
                haou.name                                                                                                                                           legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability, -- 3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id)                                                         employment_type, -- Bug 3962073
                hl.lookup_code                                                                                                                                      meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    p_report_date between papf.effective_start_date and papf.effective_end_date
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         AND    hl1.lookup_code = '2' -- Support function
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level'),
                p_report_code ||  decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F')))
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ4'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ4'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ4F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ4F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

-- End for Emplyment Equity enhancement


   -- Note EQ5 is for the following report:
   --    6. Recruitment (report the total number of new recruits into each occupational level during
   --       the twelve months preceding this report)
   elsif p_report_code = 'EQ5' then

      -- Populate with New Hires
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F')))     report_code,
                p_report_date                                                                                                                                       reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                                                                                               legal_entity_id,
                haou.name                                                                                                                                           legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability, -- 3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id)                                                         employment_type, -- Bug 3962073
                hl.lookup_code                                                                                                                                      meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(ppos.date_start, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_periods_of_service    ppos,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    ppos.person_id = papf.person_id
         and    ppos.date_start between add_months(p_report_date, -12) + 1 and p_report_date
         and    papf.effective_start_date = ppos.date_start
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    paaf.effective_start_date = ppos.date_start
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(ppos.date_start, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         and    hl1.lookup_code <> '15' -- Not Applicable.
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(ppos.date_start, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level'),
                p_report_code ||  decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F')))
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ5'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ5'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ5F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ5F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ6 is for the following report:
   --    7. Promotion (report the total number of promotions into each occupational level during
   --       the twelve months preceding this report)
   elsif p_report_code = 'EQ6' then

      -- Populate with Promotions
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                                decode(papf.PER_INFORMATION3,null,null,
                                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                                       - to_char(p_report_date,'YYYYMMDD'))
                                    ,-1,null,'F')))     report_code,
             p_report_date                                                              reporting_date,
             paaf.business_group_id,
             paei.aei_information7                                                      legal_entity_id,
             haou.name                                                                  legal_entity,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)     disability, --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id) employment_type,
             hl.lookup_code                                                             lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level') occupational_level,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
      from   hr_lookups                hl,
             hr_lookups                hl1,
             hr_lookups                hl2,
             hr_all_organization_units haou,
             per_assignment_extra_info paei,
             per_all_assignments_f     paaf,
             per_periods_of_service    ppos,
             per_all_people_f          papf
      where  papf.business_group_id = p_business_group_id
      and    papf.current_employee_flag = 'Y'
      and    ppos.person_id = papf.person_id
      and    nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY')) > add_months(p_report_date, -12) + 1
      and    ppos.date_start < p_report_date
      and    papf.effective_start_date = ppos.date_start
      and    paaf.person_id = papf.person_id
      and    paaf.primary_flag = 'Y'
      and    paaf.effective_start_date between ppos.date_start and nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
      and    paaf.effective_start_date > add_months(p_report_date, -12) + 1
      and    paaf.effective_start_date <= p_report_date
      and    paei.assignment_id = paaf.assignment_id
      and    paei.information_type = 'ZA_SPECIFIC_INFO'
      and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
      and    paei.aei_information7 is not null
      and    nvl(paei.aei_information6, 'N') <> 'Y'
      and    haou.organization_id = paei.aei_information7
      and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      AND    hl.lookup_code <> '15' -- Not Applicable.
      and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
      and    hl1.lookup_code <> '15' -- Not Applicable.
      and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      AND    hl2.lookup_code <> '15' -- Not Applicable.
      and    nvl(per_za_employment_equity_pkg.get_lookup_code(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)), '9999999999') <
      any
      (
         select per_za_employment_equity_pkg.get_lookup_code(per_za_employment_equity_pkg.get_occupational_level(paaf1.effective_start_date, paaf1.assignment_id, paaf1.job_id, paaf1.grade_id, paaf1.position_id, paaf.business_group_id)) lookup_code
         from   per_all_assignments_f paaf1
         where  paaf1.person_id = papf.person_id
         and    paaf1.primary_flag = 'Y'
         and    per_za_employment_equity_pkg.get_lookup_code(per_za_employment_equity_pkg.get_occupational_level(paaf1.effective_start_date, paaf1.assignment_id, paaf1.job_id, paaf1.grade_id, paaf1.position_id, paaf.business_group_id)) is not null
         and    paaf1.effective_end_date + 1 = paaf.effective_start_date
      )
      group  by paaf.business_group_id,
             paei.aei_information7,
             haou.name,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id)),
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id),
             hl.lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level'),
             p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))) ;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ6'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ6'
         and    pzee.business_group_id = p_business_group_id   --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ6F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ6F'
         and    pzee.business_group_id = p_business_group_id   --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


      commit;

   -- Note EQ5 is for the following report:
   --    8.1 Termination (report the total number of terminations in each occupational level during
   --        the twelve months preceding this report)
   elsif p_report_code = 'EQ7' then

      -- Populate with Terminations
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )       report_code,
                p_report_date                                                              reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                      legal_entity_id,
                haou.name                                                                  legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability,  --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id) employment_type, -- Bug 3962073
                hl.lookup_code                                                             meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_end_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_periods_of_service    ppos,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    ppos.person_id = papf.person_id
         and    nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY')) between add_months(p_report_date, -12) + 1 and p_report_date
         and    papf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    paaf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(paaf.effective_end_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         and    hl1.lookup_code <> '15' -- Not Applicable
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_end_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Level'),
                p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ7'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ7'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id  --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ7F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ7F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id  --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ6 is for the following report:
   --    8.2 Termination Categories (report the total number of terminations in each termination
   --        category during the twelve months preceding this report)
   elsif p_report_code = 'EQ8' then

      -- Populate with Termination Reason totals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             decode
             (
                tpa.termination_reason,
                'Resignation', 1,
                'Non-Renewal of Contract', 2,
                'Dismissal - Operational Requirements', 3,
                'Dismissal - Misconduct', 4,
                'Dismissal - Incapacity', 5,
                'Other', 6,
                null
             )  meaning_code,
             decode
             (
                tpa.termination_reason,
                'Dismissal - Operational Requirements', 'Dismissal - Operational Requirements (Retrenchment)',
                tpa.termination_reason
             ),
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )      report_code,
                p_report_date                                                              reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                      legal_entity_id,
                haou.name                                                                  legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)     disability, --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id) employment_type, -- Bug 3962073
                ppos.leaving_reason                                                        meaning_code,
                nvl(per_za_employment_equity_pkg.get_termination_reason(paaf.business_group_id, p_report_date, ppos.leaving_reason), 'No Leaving Reason') termination_reason,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_periods_of_service    ppos,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    ppos.person_id = papf.person_id
         and    nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY')) between add_months(p_report_date, -12) + 1 and p_report_date
         and    papf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    paaf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)) = 'Permanent'
         and    nvl(per_za_employment_equity_pkg.get_termination_reason(paaf.business_group_id, p_report_date, ppos.leaving_reason), 'No Leaving Reason') <> 'No Leaving Reason'
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         and    hl.lookup_code <> '15' -- Not Applicable
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         and    hl1.lookup_code <> '15' -- Not Applicable
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
         and    hl2.lookup_code <> '15' -- Not Applicable
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id),
                ppos.leaving_reason,
                nvl(per_za_employment_equity_pkg.get_termination_reason(paaf.business_group_id, p_report_date, ppos.leaving_reason), 'No Leaving Reason'),
                p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION3,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION8,1,10),'0001/01/01'),'/','')
                               -to_char(p_report_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )
      ) tpa
      group by tpa.report_code,
               tpa.reporting_date,
               tpa.business_group_id,
               tpa.legal_entity_id,
               tpa.legal_entity,
               tpa.disability,
               tpa.employment_type,
               tpa.meaning_code,
               tpa.termination_reason;

      commit;

      -- Insert zeroes for any Termination Categories that weren't used
      for l_counter in 1..6 loop

         -- The hard coded names of the legislative Termination Categories (not stored anywhere)
         if    l_counter = 1 then
            l_reason := 'Resignation';
         elsif l_counter = 2 then
            l_reason := 'Non-Renewal of Contract';
         elsif l_counter = 3 then
            l_reason := 'Dismissal - Operational Requirements';
         elsif l_counter = 4 then
            l_reason := 'Dismissal - Misconduct';
         elsif l_counter = 5 then
            l_reason := 'Dismissal - Incapacity';
         else
            l_reason := 'Other';
         end if;

         insert into per_za_employment_equity
         (
            report_id,
            reporting_date,
            business_group_id,
            legal_entity_id,
            legal_entity,
            disability,
            employment_type,
            level_cat_code,
            level_cat,
            MA,
            MC,
            MI,
            MW,
            FA,
            FC,
            FI,
            FW,
            total
         )
         select 'EQ8'                 report_id,
                p_report_date         reporting_date,
                p_business_group_id   business_group_id,
                haou.organization_id  legal_entity_id,
                haou.name             legal_entity,
                'Y'                   disability,
                'Permanent'           employment_type,
                decode
                (
                   l_reason,
                   'Resignation', 1,
                   'Non-Renewal of Contract', 2,
                   'Dismissal - Operational Requirements', 3,
                   'Dismissal - Misconduct', 4,
                   'Dismissal - Incapacity', 5,
                   'Other', 6,
                   null
                )                     level_cat_code,
               decode
               (
                l_reason,
                'Dismissal - Operational Requirements', 'Dismissal - Operational Requirements (Retrenchment)',
                l_reason
               )              level_cat,
                0                     MA,
                0                     MC,
                0                     MI,
                0                     MW,
                0                     FA,
                0                     FC,
                0                     FI,
                0                     FW,
                0                     total
         from   hr_all_organization_units haou
         where not exists
         (
            select 'X'
            from   per_za_employment_equity pzee
            where  pzee.level_cat         = l_reason
            and    pzee.report_id         = 'EQ8'
            and    pzee.business_group_id = p_business_group_id  --Bug 4872110
            and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
            and    pzee.disability        = 'Y'
            and    pzee.employment_type   = 'Permanent'
         )
         and haou.business_group_id = p_business_group_id   --Bug 4872110
         and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


         insert into per_za_employment_equity
         (
            report_id,
            reporting_date,
            business_group_id,
            legal_entity_id,
            legal_entity,
            disability,
            employment_type,
            level_cat_code,
            level_cat,
            MA,
            MC,
            MI,
            MW,
            FA,
            FC,
            FI,
            FW,
            total
         )
         select 'EQ8F'                 report_id,
                p_report_date         reporting_date,
                p_business_group_id   business_group_id,
                haou.organization_id  legal_entity_id,
                haou.name             legal_entity,
                'Y'                   disability,
                'Permanent'           employment_type,
                decode
                (
                   l_reason,
                   'Resignation', 1,
                   'Non-Renewal of Contract', 2,
                   'Dismissal - Operational Requirements', 3,
                   'Dismissal - Misconduct', 4,
                   'Dismissal - Incapacity', 5,
                   'Other', 6,
                   null
                )                     level_cat_code,
               decode
               (
                l_reason,
                'Dismissal - Operational Requirements', 'Dismissal - Operational Requirements (Retrenchment)',
                l_reason
               )              level_cat,
                0                     MA,
                0                     MC,
                0                     MI,
                0                     MW,
                0                     FA,
                0                     FC,
                0                     FI,
                0                     FW,
                0                     total
         from   hr_all_organization_units haou
         where not exists
         (
            select 'X'
            from   per_za_employment_equity pzee
            where  pzee.level_cat         = l_reason
            and    pzee.report_id         = 'EQ8F'
            and    pzee.business_group_id = p_business_group_id  --Bug 4872110
            and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
            and    pzee.disability        = 'Y'
            and    pzee.employment_type   = 'Permanent'
         )
         and haou.business_group_id = p_business_group_id   --Bug 4872110
         and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      end loop;

      commit;

   end if;

end populate_ee_table;


function get_functional_type
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_year              in number
)  return VARCHAR2 is

begin
   -- Check whether we have cached the location of Occupational data
   if g_func_flex is null then

      cache_occupational_location(p_report_date, p_business_group_id,p_year);

   end if;

   -- Check whether the current assignment's value is cached already
/*   if  p_report_date   = g_cat_report_date
   and p_assignment_id = g_cat_asg_id then

      return g_f_type_name;

   else

      g_cat_report_date := p_report_date;
      g_cat_asg_id      := p_assignment_id;
*/
      g_f_type_name := get_functional_data
                    (
                       p_flex        => g_Func_flex,
                       p_segment     => g_Func_segment,
                       p_job_id      => p_job_id,
                       p_grade_id    => p_grade_id,
                       p_position_id => p_position_id
                    );

      return g_f_type_name;

--   end if;

END get_functional_type;

-- This function retrieves the functional data via dynamic sql from the appropriate flexfield segment
function get_functional_data
(
   p_flex        in varchar2,
   p_segment     in varchar2,
   p_job_id      in per_all_assignments_f.job_id%type,
   p_grade_id    in per_all_assignments_f.grade_id%type,
   p_position_id in per_all_assignments_f.position_id%type
)  return varchar2 is

l_sql  varchar2(32767);
l_name hr_lookups.meaning%type;

begin

   if p_flex = 'Job' then

      begin

         if p_job_id is not null then

            l_sql := 'select hl.meaning from hr_lookups hl, per_job_definitions pjd, per_jobs pj where pj.job_id = '
                     || to_char(p_job_id)
                     || '  and pjd.job_definition_id = pj.job_definition_id and hl.application_id = 800 and hl.lookup_type = ''ZA_EE_FUNCTION_TYPE'
                     || ''' and hl.lookup_code = pjd.' || p_segment;

            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   elsif p_flex = 'Grade' then

      begin

         if p_grade_id is not null then

            l_sql := 'select hl.meaning from hr_lookups hl, per_grade_definitions pgd, per_grades pg where pg.grade_id = '
                     || to_char(p_grade_id)
                     || '  and pgd.grade_definition_id = pg.grade_definition_id and hl.application_id = 800 and hl.lookup_type = ''ZA_EE_FUNCTION_TYPE'
                     || ''' and hl.lookup_code = pgd.' || p_segment;

            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   elsif p_flex = 'Position' then

      begin

         if p_position_id is not null then

            l_sql := 'select hl.meaning from hr_lookups hl, per_position_definitions ppd, per_all_positions pap where pap.position_id = '
                     || to_char(p_position_id)
                     || '  and ppd.position_definition_id = pap.position_definition_id and hl.application_id = 800 and hl.lookup_type = ''ZA_EE_FUNCTION_TYPE'
                     || ''' and hl.lookup_code = ppd.' || p_segment;

            execute immediate l_sql into l_name;

         else

            l_name := null;

         end if;

      exception
         when no_data_found then
            l_name := null;

      end;

   else

      raise_application_error(-20002, 'The Functional Type in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Flexfield.');

   end if;

   return l_name;

end get_functional_data;

   procedure populate_ee_table_EEWF
   (
      p_report_date       in per_all_assignments_f.effective_end_date%type,
      p_business_group_id in per_all_assignments_f.business_group_id%type,
      p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
   )  is

   begin
    DELETE FROM per_za_employment_equity
    Where REPORT_ID IN ('EQ1','EQ2','EQ3','EQ4','EQ5','EQ6','EQ7','EQ8',
                       'EQ1F','EQ2F','EQ3F','EQ4F','EQ5F','EQ6F','EQ7F','EQ8F'
                       );

    populate_ee_table (
                       p_report_code       =>'EQ1'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table (
                       p_report_code       =>'EQ2'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table (
                       p_report_code       =>'EQ3'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table (
                       p_report_code       =>'EQ4'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table (
                       p_report_code       =>'EQ5'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table (
                       p_report_code       =>'EQ6'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table (
                       p_report_code       =>'EQ7'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table (
                       p_report_code       =>'EQ8'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

      -- Inserts non-associated occupational categories with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select          substr(report_id,1,3),
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
      from   per_za_employment_equity pzee1
      Where  pzee1.business_group_id = p_business_group_id
      AND    pzee1.legal_entity_id = nvl(p_legal_entity_id, pzee1.legal_entity_id)
      AND    pzee1.report_id IN ('EQ1F','EQ2F','EQ3F','EQ4F','EQ5F','EQ6F','EQ7F','EQ8F')
      AND    not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.business_group_id   = pzee1.business_group_id           --Bug 4872110
         AND    pzee.legal_entity_id    = pzee1.legal_entity_id
         AND    pzee.report_id ||'F'     = pzee1.report_id
         AND    pzee1.level_cat_code     = pzee.level_cat_code
         AND    pzee1.level_cat          = pzee.level_cat
         and    nvl(pzee.disability,'X') = nvl(pzee1.disability,'X')
         and    pzee.employment_type     = pzee1.employment_type
      );


      -- Inserts non-associated occupational categories with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select          report_id||'F' report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
      from   per_za_employment_equity pzee1
      Where  pzee1.business_group_id = p_business_group_id
      AND    pzee1.legal_entity_id = nvl(p_legal_entity_id, pzee1.legal_entity_id)
      AND    pzee1.report_id IN ('EQ1','EQ2','EQ3','EQ4','EQ5','EQ6','EQ7','EQ8')
      AND    not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.business_group_id   = pzee1.business_group_id           --Bug 4872110
         AND    pzee.legal_entity_id    = pzee1.legal_entity_id
         AND    pzee1.report_id ||'F'     = pzee.report_id
         AND    pzee1.level_cat_code     = pzee.level_cat_code
         AND    pzee1.level_cat          = pzee.level_cat
         and    nvl(pzee.disability,'X') = nvl(pzee1.disability,'X')
         and    pzee.employment_type     = pzee1.employment_type
      );

  commit;


   End populate_ee_table_EEWF;

-- Procedure to insert data into global tables.
-- used in Employment Equity Encome Differential report
--
PROCEDURE ins_g_Enc_Diff_table(p_mi_inc     IN number
                             , p_mc_inc     IN number
                             , p_ma_inc     IN number
                             , p_mw_inc     IN number
                             , p_fa_inc     IN number
                             , p_fc_inc     IN number
                             , p_fi_inc     IN number
                             , p_fw_inc     IN number
                             , p_total_inc  IN number
                             , p_ma         IN number
                             , p_mc         IN number
                             , p_mi         IN number
                             , p_mw         IN number
                             , p_fa         IN number
                             , p_fc         IN number
                             , p_fi         IN number
                             , p_fw         IN number
                             , p_total      IN number
                             , p_cat_index  IN number
                             , p_lev_index  IN number
                             , p_legal_entity_id       IN hr_all_organization_units.organization_id%type
                             , p_occupational_level IN hr_lookups.meaning%type
                             , p_occupational_category IN hr_lookups.meaning%type
                             , p_occupational_level_id IN hr_lookups.lookup_code%type
                             , p_occupational_category_id IN hr_lookups.lookup_code%type
                              ) is

begin

            IF g_cat_Enc_Diff_table.EXISTS(p_cat_index) then
               g_cat_Enc_Diff_table(p_cat_index).mi_inc    :=    g_cat_Enc_Diff_table(p_cat_index).mi_inc    + p_mi_inc ;
               g_cat_Enc_Diff_table(p_cat_index).mc_inc    :=    g_cat_Enc_Diff_table(p_cat_index).mc_inc    + p_mc_inc ;
               g_cat_Enc_Diff_table(p_cat_index).ma_inc    :=    g_cat_Enc_Diff_table(p_cat_index).ma_inc    + p_ma_inc ;
               g_cat_Enc_Diff_table(p_cat_index).mw_inc    :=    g_cat_Enc_Diff_table(p_cat_index).mw_inc    + p_mw_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fa_inc    :=    g_cat_Enc_Diff_table(p_cat_index).fa_inc    + p_fa_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fc_inc    :=    g_cat_Enc_Diff_table(p_cat_index).fc_inc    + p_fc_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fi_inc    :=    g_cat_Enc_Diff_table(p_cat_index).fi_inc    + p_fi_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fw_inc    :=    g_cat_Enc_Diff_table(p_cat_index).fw_inc    + p_fw_inc ;
               g_cat_Enc_Diff_table(p_cat_index).total_inc :=    g_cat_Enc_Diff_table(p_cat_index).total_inc + p_total_inc;

               g_cat_Enc_Diff_table(p_cat_index).mi    :=    g_cat_Enc_Diff_table(p_cat_index).mi    + p_mi ;
               g_cat_Enc_Diff_table(p_cat_index).mc    :=    g_cat_Enc_Diff_table(p_cat_index).mc    + p_mc ;
               g_cat_Enc_Diff_table(p_cat_index).ma    :=    g_cat_Enc_Diff_table(p_cat_index).ma    + p_ma ;
               g_cat_Enc_Diff_table(p_cat_index).mw    :=    g_cat_Enc_Diff_table(p_cat_index).mw    + p_mw ;
               g_cat_Enc_Diff_table(p_cat_index).fa    :=    g_cat_Enc_Diff_table(p_cat_index).fa    + p_fa ;
               g_cat_Enc_Diff_table(p_cat_index).fc    :=    g_cat_Enc_Diff_table(p_cat_index).fc    + p_fc ;
               g_cat_Enc_Diff_table(p_cat_index).fi    :=    g_cat_Enc_Diff_table(p_cat_index).fi    + p_fi ;
               g_cat_Enc_Diff_table(p_cat_index).fw    :=    g_cat_Enc_Diff_table(p_cat_index).fw    + p_fw ;
               g_cat_Enc_Diff_table(p_cat_index).total :=    g_cat_Enc_Diff_table(p_cat_index).total + p_total;

            else
               g_cat_Enc_Diff_table(p_cat_index).mi_inc    :=  p_mi_inc ;
               g_cat_Enc_Diff_table(p_cat_index).mc_inc    :=  p_mc_inc ;
               g_cat_Enc_Diff_table(p_cat_index).ma_inc    :=  p_ma_inc ;
               g_cat_Enc_Diff_table(p_cat_index).mw_inc    :=  p_mw_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fa_inc    :=  p_fa_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fc_inc    :=  p_fc_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fi_inc    :=  p_fi_inc ;
               g_cat_Enc_Diff_table(p_cat_index).fw_inc    :=  p_fw_inc ;
               g_cat_Enc_Diff_table(p_cat_index).total_inc :=  p_total_inc;

               g_cat_Enc_Diff_table(p_cat_index).mi    :=  p_mi ;
               g_cat_Enc_Diff_table(p_cat_index).mc    :=  p_mc ;
               g_cat_Enc_Diff_table(p_cat_index).ma    :=  p_ma ;
               g_cat_Enc_Diff_table(p_cat_index).mw    :=  p_mw ;
               g_cat_Enc_Diff_table(p_cat_index).fa    :=  p_fa ;
               g_cat_Enc_Diff_table(p_cat_index).fc    :=  p_fc ;
               g_cat_Enc_Diff_table(p_cat_index).fi    :=  p_fi ;
               g_cat_Enc_Diff_table(p_cat_index).fw    :=  p_fw ;
               g_cat_Enc_Diff_table(p_cat_index).total :=  p_total;
               g_cat_Enc_Diff_table(p_cat_index).legal_entity_id := p_legal_entity_id;
               g_cat_Enc_Diff_table(p_cat_index).occupational_code := p_occupational_category;
               g_cat_Enc_Diff_table(p_cat_index).occupational_code_id := p_occupational_category_id;
            END if;
            IF g_lev_Enc_Diff_table.EXISTS(p_lev_index) then
               g_lev_Enc_Diff_table(p_lev_index).mi_inc    :=  g_lev_Enc_Diff_table(p_lev_index).mi_inc    + p_mi_inc ;
               g_lev_Enc_Diff_table(p_lev_index).mc_inc    :=  g_lev_Enc_Diff_table(p_lev_index).mc_inc    + p_mc_inc ;
               g_lev_Enc_Diff_table(p_lev_index).ma_inc    :=  g_lev_Enc_Diff_table(p_lev_index).ma_inc    + p_ma_inc ;
               g_lev_Enc_Diff_table(p_lev_index).mw_inc    :=  g_lev_Enc_Diff_table(p_lev_index).mw_inc    + p_mw_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fa_inc    :=  g_lev_Enc_Diff_table(p_lev_index).fa_inc    + p_fa_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fc_inc    :=  g_lev_Enc_Diff_table(p_lev_index).fc_inc    + p_fc_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fi_inc    :=  g_lev_Enc_Diff_table(p_lev_index).fi_inc    + p_fi_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fw_inc    :=  g_lev_Enc_Diff_table(p_lev_index).fw_inc    + p_fw_inc ;
               g_lev_Enc_Diff_table(p_lev_index).total_inc :=  g_lev_Enc_Diff_table(p_lev_index).total_inc + p_total_inc;

               g_lev_Enc_Diff_table(p_lev_index).ma    := g_lev_Enc_Diff_table(p_lev_index).ma    +  p_ma ;
               g_lev_Enc_Diff_table(p_lev_index).mc    := g_lev_Enc_Diff_table(p_lev_index).mc    +  p_mc ;
               g_lev_Enc_Diff_table(p_lev_index).mi    := g_lev_Enc_Diff_table(p_lev_index).mi    +  p_mi ;
               g_lev_Enc_Diff_table(p_lev_index).mw    := g_lev_Enc_Diff_table(p_lev_index).mw    +  p_mw ;
               g_lev_Enc_Diff_table(p_lev_index).fa    := g_lev_Enc_Diff_table(p_lev_index).fa    +  p_fa ;
               g_lev_Enc_Diff_table(p_lev_index).fc    := g_lev_Enc_Diff_table(p_lev_index).fc    +  p_fc ;
               g_lev_Enc_Diff_table(p_lev_index).fi    := g_lev_Enc_Diff_table(p_lev_index).fi    +  p_fi ;
               g_lev_Enc_Diff_table(p_lev_index).fw    := g_lev_Enc_Diff_table(p_lev_index).fw    +  p_fw ;
               g_lev_Enc_Diff_table(p_lev_index).total := g_lev_Enc_Diff_table(p_lev_index).total +  p_total;
            else
               g_lev_Enc_Diff_table(p_lev_index).mi_inc    :=  p_mi_inc ;
               g_lev_Enc_Diff_table(p_lev_index).mc_inc    :=  p_mc_inc ;
               g_lev_Enc_Diff_table(p_lev_index).ma_inc    :=  p_ma_inc ;
               g_lev_Enc_Diff_table(p_lev_index).mw_inc    :=  p_mw_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fa_inc    :=  p_fa_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fc_inc    :=  p_fc_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fi_inc    :=  p_fi_inc ;
               g_lev_Enc_Diff_table(p_lev_index).fw_inc    :=  p_fw_inc ;
               g_lev_Enc_Diff_table(p_lev_index).total_inc :=  p_total_inc;

               g_lev_Enc_Diff_table(p_lev_index).ma    :=  p_ma ;
               g_lev_Enc_Diff_table(p_lev_index).mc    :=  p_mc ;
               g_lev_Enc_Diff_table(p_lev_index).mi    :=  p_mi ;
               g_lev_Enc_Diff_table(p_lev_index).mw    :=  p_mw ;
               g_lev_Enc_Diff_table(p_lev_index).fa    :=  p_fa ;
               g_lev_Enc_Diff_table(p_lev_index).fc    :=  p_fc ;
               g_lev_Enc_Diff_table(p_lev_index).fi    :=  p_fi ;
               g_lev_Enc_Diff_table(p_lev_index).fw    :=  p_fw ;
               g_lev_Enc_Diff_table(p_lev_index).total :=  p_total;
               g_lev_Enc_Diff_table(p_lev_index).legal_entity_id := p_legal_entity_id;
               g_lev_Enc_Diff_table(p_lev_index).occupational_code := p_occupational_level;
               g_lev_Enc_Diff_table(p_lev_index).occupational_code_id := p_occupational_level_id;
            End if;

END ins_g_Enc_Diff_table;


-- Procedure is used to sort the employee data
-- and ready to inset into global tables

Procedure cat_lev_data ( p_legal_entity_id IN hr_all_organization_units.organization_id%type
                       , p_occupational_level IN hr_lookups.meaning%type
                       , p_occupational_category IN hr_lookups.meaning%type
                       , p_race IN per_all_people_f.per_information4%type
                       , p_sex IN per_all_people_f.sex%type
                       , p_income IN number
                       , p_occupational_level_id IN hr_lookups.lookup_code%type
                       , p_occupational_category_id IN hr_lookups.lookup_code%type
                       ) is

 l_cat_index  pls_integer ;
 l_lev_index  pls_integer ;
begin

   begin

   l_cat_index := p_legal_entity_id *100 + nvl(p_occupational_category_id,0);
   l_lev_index := p_legal_entity_id *100 + nvl(p_occupational_level_id,0);
   hr_utility.set_location('l_cat_index ' || l_cat_index, 25);
   hr_utility.set_location('l_lev_index ' || l_lev_index, 25);

   exception
      when others then
         raise_application_error(-20006, 'The lookup code in the ZA_EMP_EQ_OCCUPATIONAL_LEV and ZA_EMP_EQ_OCCUPATIONAL_CAT lookups must be numeric.');

   end;

     CASE p_sex||p_race
          WHEN  'M01' THEN --male Indian (MI)
              ins_g_Enc_Diff_table(p_mi_inc  =>  p_income
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 1
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'M02' THEN --male African
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    =>  p_income
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 1
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'M03' THEN --male Coloured
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    =>  p_income
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 1
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'M04' THEN --male White
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    =>  p_income
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 1
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'MZA01' THEN --male Chinese (To be reported as African)
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    =>  p_income
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 1
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );

          WHEN  'F01' THEN --female Indian
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    =>  0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    =>p_income
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 1
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'F02' THEN --female African
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => p_income
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 1
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'F03' THEN --female Coloured
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => p_income
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 1
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'F04' THEN --female White
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => p_income
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 1
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
          WHEN  'FZA01' THEN --female Chinese (To be reported as African)
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => p_income
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 1
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             );
             else
             null;
         END case;
END cat_lev_data;



-- Procedure to initialise with the employee details
--
procedure init_g_cat_lev_table
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
)  is
/* commented for Bug 8911880
cursor c_assignments is
   select paaf.assignment_id,
          paaf.person_id, -- Bug 4413678
          paaf.payroll_id,
          paei.aei_information7 ,
          hl_cat.lookup_code      OCCUPATIONAL_CATEGORY_ID,
          hl_lev.lookup_code      OCCUPATIONAL_LEVEL_ID,
          per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)    occupational_level,
          per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id) occupational_category,
          paaf.pay_basis_id
   from   per_assignment_extra_info   paei,
          per_assignment_status_types past,
          per_all_assignments_f       paaf,
          hr_lookups                  hl_cat,
          hr_lookups                  hl_lev,
          hr_lookups                  hl_fn
   where  paaf.business_group_id = p_business_group_id
   and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
   and    past.assignment_status_type_id = paaf.assignment_status_type_id
   and    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    paei.assignment_id = paaf.assignment_id
   and    paei.information_type = 'ZA_SPECIFIC_INFO'
   and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
   and    paei.aei_information7 is not null
   AND    hl_cat.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
   AND    hl_lev.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
   AND    hl_fn.lookup_type = 'ZA_EE_FUNCTION_TYPE'    --Added for Bug 7360563
   AND    hl_cat.lookup_code <> '15'
   AND    hl_lev.lookup_code <> '15'
   AND    hl_fn.lookup_code <>'15'
   AND    hl_cat.application_id = '800'
   AND    hl_lev.application_id = '800'
   AND    hl_fn.application_id  = '800'
   AND    hl_cat.meaning(+)       = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   AND    hl_lev.meaning(+)       = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   AND    hl_fn.meaning(+)        = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   and    nvl(paei.aei_information6, 'N') <> 'Y'
   order  BY paei.aei_information7, paaf.payroll_id;
*/

cursor c_assignments is
   select paaf.assignment_id,
          paaf.person_id, -- Bug 4413678
          paaf.payroll_id,
          paei.aei_information7 ,
          hl_cat.lookup_code      OCCUPATIONAL_CATEGORY_ID,
          hl_lev.lookup_code      OCCUPATIONAL_LEVEL_ID,
          per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)    occupational_level,
          per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id) occupational_category,
          paaf.pay_basis_id
   from   per_assignment_extra_info   paei,
          per_all_assignments_f       paaf,
          hr_lookups                  hl_cat,
          hr_lookups                  hl_lev,
          hr_lookups                  hl_fn
   where  paaf.business_group_id = p_business_group_id
   and    (add_months(p_report_date,-12)+1 <=paaf.effective_end_date and p_report_date >=paaf.effective_start_date)
   and    paaf.effective_end_date = (  select max(paaf1.effective_end_date)
                                       from   per_all_assignments_f paaf1,
                                              per_assignment_status_types past
                                       where  paaf1.assignment_id = paaf.assignment_id
                                       and    paaf1.effective_start_date <= p_report_date
                                       and    past.assignment_status_type_id = paaf1.assignment_status_type_id
                                       and    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
                                     )
   and    paei.assignment_id = paaf.assignment_id
   and    paei.information_type = 'ZA_SPECIFIC_INFO'
   and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
   and    paei.aei_information7 is not null
   AND    hl_cat.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
   AND    hl_lev.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
   AND    hl_fn.lookup_type = 'ZA_EE_FUNCTION_TYPE'    --Added for Bug 7360563
   AND    hl_cat.lookup_code <> '15'
   AND    hl_lev.lookup_code <> '15'
   AND    hl_fn.lookup_code <>'15'
   AND    hl_cat.application_id = '800'
   AND    hl_lev.application_id = '800'
   AND    hl_fn.application_id  = '800'
   AND    hl_cat.meaning(+)       = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   AND    hl_lev.meaning(+)       = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   AND    hl_fn.meaning(+)        = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   and    nvl(paei.aei_information6, 'N') <> 'Y'
   order  BY paei.aei_information7, paaf.payroll_id;


cursor c_ele_rem(l_assignment_id per_all_assignments_f.assignment_id%type
                 ,l_input_id pay_element_entry_values_f.input_value_id%type) is
   select peevf.screen_entry_value screen_value,
          months_between(least(peevf.effective_end_date ,p_report_date),greatest(peevf.effective_start_date-1 ,add_months(p_report_date,-12))) months_bet
   from   pay_element_entry_values_f peevf
          ,pay_element_entries_f      peef
   where  peef.assignment_id     = l_assignment_id
   and    peevf.element_entry_id = peef.element_entry_id
   and    peevf.input_value_id   = l_input_id
   and    (add_months(p_report_date,-12)+1 <=peef.effective_end_date and p_report_date>=peef.effective_start_date)
   and    (add_months(p_report_date,-12)+1 <=peevf.effective_end_date and p_report_date>=peevf.effective_start_date)
   and    peef.effective_start_date between peevf.effective_start_date and peevf.effective_end_date;

l_old_payroll_id      per_all_assignments_f.payroll_id%type := -9999;
v_ele_rem             c_ele_rem%rowtype;
l_rowind              pls_integer;
l_active_days         number;
l_ee_income           number;
l_ee_annual_income    number;
l_report_start        date;
l_report_end          date;
l_report_date         date;
l_difference          number;
l_period_frequency    per_time_period_types.number_per_fiscal_year%type;
l_ee_balance_type_id  pay_balance_types.balance_type_id%type;
l_eea_balance_type_id pay_balance_types.balance_type_id%type;
l_input_value_id      pay_input_values_f.input_value_id%type;
l_index               number;
l_proc                constant varchar2(60) := g_package || 'get_avg_5_lowest_salary';
l_race                per_all_people_f.per_information4%type; -- Bug 4413678
l_sex                 per_all_people_f.sex%type;
--Changes for Bug 7237663
l_er_income           number;
l_er_annual_income    number;
l_er_balance_type_id  pay_balance_types.balance_type_id%type;
l_era_balance_type_id pay_balance_types.balance_type_id%type;


begin
   --hr_utility.trace_on(null,'ZAEID');
   reset_tables;
   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Determine whether we need to populate the cache tables
   -- Note: No check is made for the validity of the table data, since it is assumed that the
   --       reset_tables procedure was called before this procedure.
   if g_assignments_table.count = 0 then

      hr_utility.set_location('Setup assignments cache', 20);
      g_assignments_table.delete;

      if p_salary_method = 'BAL' then

         -- Get the balance type id's for the normal and annual balances
         begin

            select balance_type_id
            into   l_ee_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable Income'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

            select balance_type_id
            into   l_eea_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable Annual Income'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

          --Changes for Bug 7237663
            select balance_type_id
            into   l_er_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable ER Normal Contributions'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

            select balance_type_id
            into   l_era_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable ER Annual Contributions'
            and    legislation_code = 'ZA'
            and    business_group_id is null;
           --End changes for Bug 7237663

         exception
            when no_data_found then
               raise_application_error(-20000, 'The Employment Equitable balances do not exist.');

         end;

      end if;

      if p_salary_method = 'ELE' then

         -- Get the ZA Employment Equity Remuneration element details
         begin

            select pivf.input_value_id
            into   l_input_value_id
            from   pay_input_values_f         pivf,
                   pay_element_types_f        petf
            where  petf.element_name = 'ZA Employment Equity Remuneration'
            and    petf.business_group_id is null
            and    petf.legislation_code = 'ZA'
            and    p_report_date between petf.effective_start_date and petf.effective_end_date
            and    pivf.element_type_id = petf.element_type_id
            and    pivf.name = 'Remuneration'
            and    p_report_date between pivf.effective_start_date and pivf.effective_end_date;

         exception
            when no_data_found then
               raise_application_error(-20004, 'The ZA Employment Equity Remuneration element does not exist.');

         end;

      end if;

      -- Loop through the assignments cursor and populate the assignments table
      for l_assignment in c_assignments loop

         hr_utility.set_location('ASG ' || l_assignment.assignment_id, 21);

         -- Bug 4413678: Begin
         Select per_information4, papf.sex
         into l_race, l_sex
         From per_all_people_f papf
         Where papf.person_id = l_assignment.person_id
               and p_report_date between papf.effective_start_date and papf.effective_end_date;
         -- Bug 4413678: End


         if l_assignment.payroll_id is not null and l_race <> 'N' then -- Bug 4413678: Added l_race <> 'Not Used'
-- added RPAHUNE
            g_assignments_table(l_assignment.assignment_id).payroll_id            := l_assignment.payroll_id;
            g_assignments_table(l_assignment.assignment_id).legal_entity_id       := l_assignment.aei_information7;
            g_assignments_table(l_assignment.assignment_id).occupational_level    := l_assignment.occupational_level;
            g_assignments_table(l_assignment.assignment_id).occupational_category := l_assignment.occupational_category;
            g_assignments_table(l_assignment.assignment_id).occupational_category_ID := l_assignment.occupational_category_id;
            g_assignments_table(l_assignment.assignment_id).occupational_level_id    := l_assignment.occupational_level_id;
            g_assignments_table(l_assignment.assignment_id).race                  := l_race;
            g_assignments_table(l_assignment.assignment_id).sex                   := l_sex;
            hr_utility.set_location('LEGENT ' || l_assignment.aei_information7, 22);

            -- Check for a new payroll_id and cache the new payroll details in the payrolls table
            if l_assignment.payroll_id <> l_old_payroll_id then

               /* Bug 8911880
               -- Get the start date and end date of the report
               begin


                  l_report_date := p_report_date;
                  l_difference := 0;

                  while (l_difference < 355 or l_difference > 375) loop

                     select ptpf.end_date + 1,
                            ptpl.end_date
                     into   l_report_start,
                            l_report_end
                     from   per_time_periods ptpf,
                            per_time_periods ptpl
                     where  ptpl.payroll_id = l_assignment.payroll_id
                     and    l_report_date between ptpl.start_date and ptpl.end_date
                     and    ptpf.payroll_id = l_assignment.payroll_id
                     and    add_months(l_report_date, -12) + 1 between ptpf.start_date and ptpf.end_date;

                     l_difference := l_report_end - l_report_start + 1;

                     if (l_difference < 355 or l_difference > 375) then

                        l_report_date := l_report_date - 1;

                     end if;

                  end loop;

               exception
                  when no_data_found then
                     begin
                             select ptpl.end_date
                             into   l_report_end
                             from   per_time_periods ptpl
                             where  ptpl.payroll_id = l_assignment.payroll_id
                             and    p_report_date between ptpl.start_date and ptpl.end_date;

                     exception
                             when no_data_found then
                                      Null;
                     end;

                     l_report_start := add_months(l_report_end, -12) + 1;

               end;
               */

               /* Bug 8911880
               -- Get the payroll period frequency
               begin

                  select ptpt.number_per_fiscal_year
                  into   l_period_frequency
                  from   per_time_period_types ptpt,
                         pay_all_payrolls_f    payr
                  where  payr.payroll_id = l_assignment.payroll_id
                  and    p_report_date between payr.effective_start_date and payr.effective_end_date
                  and    ptpt.period_type = payr.period_type;

               exception
                  when no_data_found then
                     raise_application_error(-20005, 'The Payroll Period Frequency does not exist.');

               end;
               */

               l_old_payroll_id := l_assignment.payroll_id;

            end if;

--            hr_utility.set_location('REP_START ' || to_char(l_report_start, 'DD\MM\YYYY'), 22);
--            hr_utility.set_location('REP_END   ' || to_char(l_report_end, 'DD\MM\YYYY'), 23);
--            hr_utility.set_location('FREQ      ' || l_period_frequency, 24);

            if p_salary_method = 'BAL' then

               /* Bug 8911880
               -- Get the amount of days the assignment status was Active Assignment
               l_active_days := get_active_days
                                (
                                   p_assignment_id => l_assignment.assignment_id,
                                   p_report_start  => l_report_start,
                                   p_report_end    => l_report_end
                                );

               hr_utility.set_location('ACT_DAYS ' || l_active_days, 25);
               */

               -- Get the Employment Equitable Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_ee_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  -- BUG 2665394 ADDED THE TABLE TO IMPROVE THE PERFORMANCE
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_ee_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  -- BUG 2665394 ADDED THE JOINS TO IMPROVE THE PERFORMANCE
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_ee_income := 0;

               end;

               -- Get the Employment Equitable Annual Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_ee_annual_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  -- BUG 2665394 ADDED THE TABLE TO IMPROVE THE PERFORMANCE
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_eea_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  -- BUG 2665394 ADDED THE JOINS TO IMPROVE THE PERFORMANCE
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_ee_annual_income := 0;

               end;

               --Changes for Bug 7237663
               -- Two new balances added for employer contributions
               -- Get the Employment Equitable ER Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_er_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_er_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_er_income := 0;

               end;

               -- Get the Employment Equitable ER Annual Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_er_annual_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_era_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_er_annual_income := 0;

               end;


               hr_utility.set_location('EE_INC ' || l_ee_income, 26);
               hr_utility.set_location('EE_ANN ' || l_ee_annual_income, 27);
               hr_utility.set_location('ER_INC ' || l_er_income, 26);
               hr_utility.set_location('ER_ANN ' || l_er_annual_income, 27);

           --    hr_utility.set_location('STminEND ' || (l_report_end - l_report_start + 1), 28);

               -- Calculate the annual income = annualize normal income + annual income
               g_assignments_table(l_assignment.assignment_id).annual_income :=
                   l_ee_income + l_er_income + l_ee_annual_income + l_er_annual_income;

               hr_utility.set_location('ANSWER ' || g_assignments_table(l_assignment.assignment_id).annual_income, 29);

            elsif p_salary_method = 'SAL' then

               -- Get the annual salary basis for the current period
               begin

                        select input_value_id
                        into l_input_value_id
                        from per_pay_bases ppb
                        where ppb.pay_basis_id = l_assignment.pay_basis_id;


                        select nvl(sum(fnd_number.canonical_to_number(prrv.result_value)), 0)
                        into   g_assignments_table(l_assignment.assignment_id).annual_income
                        from   pay_run_result_values       prrv,
                               pay_run_results             prr,
                               pay_payroll_actions         ppa,
                               pay_assignment_actions      paa,
                               per_assignments_f       asg
                        where  paa.assignment_id = l_assignment.assignment_id
                        and    ppa.payroll_action_id = paa.payroll_action_id
                        and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                        and    prr.assignment_action_id = paa.assignment_action_id
                        and    prrv.run_result_id  =  prr.run_result_id
                        and    prrv.input_value_id = l_input_value_id
                        and    paa.assignment_id   = asg.assignment_id
                        and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                        and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     g_assignments_table(l_assignment.assignment_id).annual_income := 0;

               end;

            elsif p_salary_method = 'ELE' then

               begin
                  g_assignments_table(l_assignment.assignment_id).annual_income:=0;
                  open c_ele_rem(l_assignment.assignment_id,l_input_value_id);
                  loop
                      fetch c_ele_rem into v_ele_rem;
                      if c_ele_rem%rowcount=0 then
                          g_assignments_table(l_assignment.assignment_id).annual_income:= 0;
                      end if;
                      exit when c_ele_rem%notfound;
                      g_assignments_table(l_assignment.assignment_id).annual_income:=
                             g_assignments_table(l_assignment.assignment_id).annual_income + (v_ele_rem.screen_value * v_ele_rem.months_bet);
                  end loop;
                  close c_ele_rem;
               end;

            end if;   -- p_salary_method

         end if;   -- (l_assignment.payroll_id is not null)

      end loop;   -- c_assignments

   end if;   -- g_assignments_table.count = 0

   -- The index is calculted by multiplying the legal entity id by 100 and then adding the lookup code
   -- This should always give a unique value, since the lookup code is less than 100
-- Start of adding for Employment Equity Report Enhancement Inserting values in table.
   l_rowind := g_assignments_table.first;
   hr_utility.set_location ('l_rowind :=' || l_rowind, 20);
   loop
      exit when l_rowind is null;

   hr_utility.set_location ('g_assignments_table(l_rowind).legal_entity_id' ||g_assignments_table(l_rowind).legal_entity_id, 20);
   hr_utility.set_location ('l_rowind :=' || g_assignments_table(l_rowind).occupational_level, 20);
   hr_utility.set_location ('l_rowind :=' || g_assignments_table(l_rowind).occupational_category, 20);
   hr_utility.set_location ('l_rowind :=' || g_assignments_table(l_rowind).race, 20);
   hr_utility.set_location ('l_rowind :=' || g_assignments_table(l_rowind).sex, 20);
   hr_utility.set_location ('l_rowind :=' || g_assignments_table(l_rowind).annual_income, 20);

      cat_lev_data( g_assignments_table(l_rowind).legal_entity_id
                  , g_assignments_table(l_rowind).occupational_level
                  , g_assignments_table(l_rowind).occupational_category
                  , g_assignments_table(l_rowind).race
                  , g_assignments_table(l_rowind).sex
                  , nvl(g_assignments_table(l_rowind).annual_income,0)
                  , g_assignments_table(l_rowind).occupational_level_id
                  , g_assignments_table(l_rowind).occupational_category_ID
                  );

            l_rowind := g_assignments_table.next(l_rowind);
   END loop;

   l_rowind := g_cat_Enc_Diff_table.first;
   loop
      exit when l_rowind is null;
      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
       Select 'ED1'  -- no of employees in each categories
      , p_report_date
      , p_business_group_id
      , g_cat_Enc_Diff_table(l_rowind).legal_entity_id
      , haou.name
      , null
      , null
      , g_cat_Enc_Diff_table(l_rowind).occupational_code_id
      , g_cat_Enc_Diff_table(l_rowind).occupational_code
      , g_cat_Enc_Diff_table(l_rowind).ma
      , g_cat_Enc_Diff_table(l_rowind).mc
      , g_cat_Enc_Diff_table(l_rowind).mi
      , g_cat_Enc_Diff_table(l_rowind).mw
      , g_cat_Enc_Diff_table(l_rowind).fa
      , g_cat_Enc_Diff_table(l_rowind).fc
      , g_cat_Enc_Diff_table(l_rowind).fi
      , g_cat_Enc_Diff_table(l_rowind).fw
      , g_cat_Enc_Diff_table(l_rowind).total
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_cat_Enc_Diff_table(l_rowind).legal_entity_id;


      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'ED1I'  -- income
      , p_report_date
      , p_business_group_id
      , g_cat_Enc_Diff_table(l_rowind).legal_entity_id
      , haou.name
      , null
      , null
      , g_cat_Enc_Diff_table(l_rowind).occupational_code_id
      , g_cat_Enc_Diff_table(l_rowind).occupational_code
      , g_cat_Enc_Diff_table(l_rowind).ma_inc
      , g_cat_Enc_Diff_table(l_rowind).mc_inc
      , g_cat_Enc_Diff_table(l_rowind).mi_inc
      , g_cat_Enc_Diff_table(l_rowind).mw_inc
      , g_cat_Enc_Diff_table(l_rowind).fa_inc
      , g_cat_Enc_Diff_table(l_rowind).fc_inc
      , g_cat_Enc_Diff_table(l_rowind).fi_inc
      , g_cat_Enc_Diff_table(l_rowind).fw_inc
      , g_cat_Enc_Diff_table(l_rowind).total_inc
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_cat_Enc_Diff_table(l_rowind).legal_entity_id;

     l_rowind := g_cat_Enc_Diff_table.next(l_rowind);
   END loop;

   l_rowind := g_lev_Enc_Diff_table.first;
   loop
      exit when l_rowind is null;
      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'ED2'  -- no of employees in each categories
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , null
      , g_lev_Enc_Diff_table(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table(l_rowind).occupational_code
      , g_lev_Enc_Diff_table(l_rowind).ma
      , g_lev_Enc_Diff_table(l_rowind).mc
      , g_lev_Enc_Diff_table(l_rowind).mi
      , g_lev_Enc_Diff_table(l_rowind).mw
      , g_lev_Enc_Diff_table(l_rowind).fa
      , g_lev_Enc_Diff_table(l_rowind).fc
      , g_lev_Enc_Diff_table(l_rowind).fi
      , g_lev_Enc_Diff_table(l_rowind).fw
      , g_lev_Enc_Diff_table(l_rowind).total
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table(l_rowind).legal_entity_id;

      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'ED2I'  -- income
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , null
      , g_lev_Enc_Diff_table(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table(l_rowind).occupational_code
      , g_lev_Enc_Diff_table(l_rowind).ma_inc
      , g_lev_Enc_Diff_table(l_rowind).mc_inc
      , g_lev_Enc_Diff_table(l_rowind).mi_inc
      , g_lev_Enc_Diff_table(l_rowind).mw_inc
      , g_lev_Enc_Diff_table(l_rowind).fa_inc
      , g_lev_Enc_Diff_table(l_rowind).fc_inc
      , g_lev_Enc_Diff_table(l_rowind).fi_inc
      , g_lev_Enc_Diff_table(l_rowind).fw_inc
      , g_lev_Enc_Diff_table(l_rowind).total_inc
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table(l_rowind).legal_entity_id;

     l_rowind := g_lev_Enc_Diff_table.next(l_rowind);
   END loop;
--hr_utility.trace_off;

      -- Inserts non-associated occupational categories with zero values for no of employees
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'ED1'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             Null              disability,
             Null      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       ,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'ED1'
         and    pzee.business_group_id = p_business_group_id           --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational categories with zero values for no of employees
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'ED1I'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             Null              disability,
             Null      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'ED1I'
         and    pzee.business_group_id = p_business_group_id           --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

-- inserting 0 values for the no of employees
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'ED2'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             null              disability,
             null      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'ED2'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
      )
      and hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

-- inserting 0 values for the Income
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'ED2I'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             null              disability,
             null      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning               ,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'ED2I'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
      )
      and hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

commit;

end init_g_cat_lev_table;


--Reset the structures for Employment Equity Differential from reporting year 2010
procedure reset_new_tables is

l_proc constant varchar2(60) := g_package || 'reset_new_tables';

begin

   -- hr_utility.trace_on(null, 'T');
   g_new_assignments_table.delete;
   g_all_high_avg := -9999;
   g_all_low_avg  := -9999;
   g_cat_averages_table.delete;
   g_lev_averages_table.delete;
   g_cat_Enc_Diff_table.delete;
   g_lev_Enc_Diff_table.delete;
   g_lev_Enc_Diff_table_F.delete;
   g_lev_Enc_Diff_table_T.delete;
   g_lev_Enc_Diff_table_TF.delete;

   DELETE FROM per_za_employment_equity
    Where report_id IN
                   ( 'ED', 'EDI', 'EDF','EDFI');

end reset_new_tables;

--Procedure to insert data into global tables for Employment Equity Differential report from reporting year 2009
PROCEDURE ins_g_Enc_Diff_table(p_mi_inc     IN number
                             , p_mc_inc     IN number
                             , p_ma_inc     IN number
                             , p_mw_inc     IN number
                             , p_fa_inc     IN number
                             , p_fc_inc     IN number
                             , p_fi_inc     IN number
                             , p_fw_inc     IN number
                             , p_total_inc  IN number
                             , p_ma         IN number
                             , p_mc         IN number
                             , p_mi         IN number
                             , p_mw         IN number
                             , p_fa         IN number
                             , p_fc         IN number
                             , p_fi         IN number
                             , p_fw         IN number
                             , p_total      IN number
                             , p_cat_index  IN number
                             , p_lev_index  IN number
                             , p_legal_entity_id       IN hr_all_organization_units.organization_id%type
                             , p_occupational_level IN hr_lookups.meaning%type
                             , p_occupational_category IN hr_lookups.meaning%type
                             , p_occupational_level_id IN hr_lookups.lookup_code%type
                             , p_occupational_category_id IN hr_lookups.lookup_code%type
                             , p_table IN OUT nocopy t_E_differential
                              ) is

begin

          hr_utility.set_location('Entered ins_g_Enc_Diff_table',10);

            --Occupational levels
            IF p_table.EXISTS(p_lev_index) then
               p_table(p_lev_index).mi_inc    :=  p_table(p_lev_index).mi_inc    + p_mi_inc ;
               p_table(p_lev_index).mc_inc    :=  p_table(p_lev_index).mc_inc    + p_mc_inc ;
               p_table(p_lev_index).ma_inc    :=  p_table(p_lev_index).ma_inc    + p_ma_inc ;
               p_table(p_lev_index).mw_inc    :=  p_table(p_lev_index).mw_inc    + p_mw_inc ;
               p_table(p_lev_index).fa_inc    :=  p_table(p_lev_index).fa_inc    + p_fa_inc ;
               p_table(p_lev_index).fc_inc    :=  p_table(p_lev_index).fc_inc    + p_fc_inc ;
               p_table(p_lev_index).fi_inc    :=  p_table(p_lev_index).fi_inc    + p_fi_inc ;
               p_table(p_lev_index).fw_inc    :=  p_table(p_lev_index).fw_inc    + p_fw_inc ;
               p_table(p_lev_index).total_inc :=  p_table(p_lev_index).total_inc + p_total_inc;

               p_table(p_lev_index).ma    := p_table(p_lev_index).ma    +  p_ma ;
               p_table(p_lev_index).mc    := p_table(p_lev_index).mc    +  p_mc ;
               p_table(p_lev_index).mi    := p_table(p_lev_index).mi    +  p_mi ;
               p_table(p_lev_index).mw    := p_table(p_lev_index).mw    +  p_mw ;
               p_table(p_lev_index).fa    := p_table(p_lev_index).fa    +  p_fa ;
               p_table(p_lev_index).fc    := p_table(p_lev_index).fc    +  p_fc ;
               p_table(p_lev_index).fi    := p_table(p_lev_index).fi    +  p_fi ;
               p_table(p_lev_index).fw    := p_table(p_lev_index).fw    +  p_fw ;
               p_table(p_lev_index).total := p_table(p_lev_index).total +  p_total;
            else
               p_table(p_lev_index).mi_inc    :=  p_mi_inc ;
               p_table(p_lev_index).mc_inc    :=  p_mc_inc ;
               p_table(p_lev_index).ma_inc    :=  p_ma_inc ;
               p_table(p_lev_index).mw_inc    :=  p_mw_inc ;
               p_table(p_lev_index).fa_inc    :=  p_fa_inc ;
               p_table(p_lev_index).fc_inc    :=  p_fc_inc ;
               p_table(p_lev_index).fi_inc    :=  p_fi_inc ;
               p_table(p_lev_index).fw_inc    :=  p_fw_inc ;
               p_table(p_lev_index).total_inc :=  p_total_inc;

               p_table(p_lev_index).ma    :=  p_ma ;
               p_table(p_lev_index).mc    :=  p_mc ;
               p_table(p_lev_index).mi    :=  p_mi ;
               p_table(p_lev_index).mw    :=  p_mw ;
               p_table(p_lev_index).fa    :=  p_fa ;
               p_table(p_lev_index).fc    :=  p_fc ;
               p_table(p_lev_index).fi    :=  p_fi ;
               p_table(p_lev_index).fw    :=  p_fw ;
               p_table(p_lev_index).total :=  p_total;
               p_table(p_lev_index).legal_entity_id := p_legal_entity_id;
               p_table(p_lev_index).occupational_code := p_occupational_level;
               p_table(p_lev_index).occupational_code_id := p_occupational_level_id;
            End if;

END ins_g_Enc_Diff_table;


Procedure cat_lev_data ( p_legal_entity_id IN hr_all_organization_units.organization_id%type
                       , p_occupational_level IN hr_lookups.meaning%type
                       , p_occupational_category IN hr_lookups.meaning%type
                       , p_race IN per_all_people_f.per_information4%type
                       , p_sex IN per_all_people_f.sex%type
                       , p_income IN number
                       , p_occupational_level_id IN hr_lookups.lookup_code%type
                       , p_occupational_category_id IN hr_lookups.lookup_code%type
                       , p_table IN OUT nocopy t_E_differential
                       ) is

 l_cat_index  pls_integer ;
 l_lev_index  pls_integer ;
begin

   begin
   hr_utility.set_location('Entered cat_lev_data',25);
   l_cat_index := p_legal_entity_id *100 + nvl(p_occupational_category_id,0);
   l_lev_index := p_legal_entity_id *100 + nvl(p_occupational_level_id,0);
   hr_utility.set_location('l_cat_index ' || l_cat_index, 25);
   hr_utility.set_location('l_lev_index ' || l_lev_index, 25);


   exception
      when others then
         raise_application_error(-20006, 'The lookup code in the ZA_EMP_EQ_OCCUPATIONAL_LEV and ZA_EMP_EQ_OCCUPATIONAL_CAT lookups must be numeric.');

   end;

     CASE p_sex||p_race
          WHEN  'M01' THEN --male Indian (MI)
              ins_g_Enc_Diff_table(p_mi_inc  =>  p_income
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 1
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'M02' THEN --male African
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    =>  p_income
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 1
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'M03' THEN --male Coloured
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    =>  p_income
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 1
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'M04' THEN --male White
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    =>  p_income
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 1
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'MZA01' THEN --male Chinese (To be reported as African)
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    =>  p_income
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 1
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );

          WHEN  'F01' THEN --female Indian
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    =>  0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    =>p_income
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 1
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'F02' THEN --female African
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => p_income
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 1
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'F03' THEN --female Coloured
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => p_income
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 1
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'F04' THEN --female White
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => 0
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => p_income
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 0
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 1
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
          WHEN  'FZA01' THEN --female Chinese (To be reported as African)
              ins_g_Enc_Diff_table(p_mi_inc  => 0
                             , p_mc_inc    => 0
                             , p_ma_inc    => 0
                             , p_mw_inc    => 0
                             , p_fa_inc    => p_income
                             , p_fc_inc    => 0
                             , p_fi_inc    => 0
                             , p_fw_inc    => 0
                             , p_total_inc => p_income
                             , p_ma        => 0
                             , p_mc        => 0
                             , p_mi        => 0
                             , p_mw        => 0
                             , p_fa        => 1
                             , p_fc        => 0
                             , p_fi        => 0
                             , p_fw        => 0
                             , p_total     => 1
                             , p_cat_index => l_cat_index
                             , p_lev_index => l_lev_index
                             , p_legal_entity_id       => p_legal_entity_id
                             , p_occupational_level    => p_occupational_level
                             , p_occupational_category => p_occupational_category
                             , p_occupational_level_id    => p_occupational_level_id
                             , p_occupational_category_id => p_occupational_category_id
                             , p_table => p_table
                             );
             else
             null;
         END case;
END cat_lev_data;



-- Procedure to initialise with the employee details from reporting year 2009
--
procedure init_g_cat_lev_new_table
(
   p_report_date            in per_all_assignments_f.effective_end_date%type,
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type := null,
   p_salary_method          in varchar2  -- SAL = Salary Basis Method, BAL = Payroll Balances Method
)  is
/* commented for Bug 8911880
cursor c_assignments is
   select paaf.assignment_id,
          paaf.person_id, -- Bug 4413678
          paaf.payroll_id,
          paei.aei_information7 ,
          hl_cat.lookup_code      OCCUPATIONAL_CATEGORY_ID,
          hl_lev.lookup_code      OCCUPATIONAL_LEVEL_ID,
          per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)    occupational_level,
          per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id) occupational_category,
          paaf.pay_basis_id
   from   per_assignment_extra_info   paei,
          per_assignment_status_types past,
          per_all_assignments_f       paaf,
          hr_lookups                  hl_cat,
          hr_lookups                  hl_lev,
          hr_lookups                  hl_fn
   where  paaf.business_group_id = p_business_group_id
   and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
   and    past.assignment_status_type_id = paaf.assignment_status_type_id
   and    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    paei.assignment_id = paaf.assignment_id
   and    paei.information_type = 'ZA_SPECIFIC_INFO'
   and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
   and    paei.aei_information7 is not null
   AND    hl_cat.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
   AND    hl_lev.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
   AND    hl_fn.lookup_type = 'ZA_EE_FUNCTION_TYPE'    --Added for Bug 7360563
   AND    hl_cat.lookup_code <> '15'
   AND    hl_lev.lookup_code <> '15'
   AND    hl_fn.lookup_code <>'15'
   AND    hl_cat.application_id = '800'
   AND    hl_lev.application_id = '800'
   AND    hl_fn.application_id  = '800'
   AND    hl_cat.meaning(+)       = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   AND    hl_lev.meaning(+)       = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   AND    hl_fn.meaning(+)        = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
   and    nvl(paei.aei_information6, 'N') <> 'Y'
   order  BY paei.aei_information7, paaf.payroll_id;
*/

--Added employment type for Year 2009 onwards
cursor c_assignments is
   select paaf.assignment_id,
          paaf.person_id, -- Bug 4413678
          paaf.payroll_id,
          paei.aei_information7 ,
          hl_lev.lookup_code      OCCUPATIONAL_LEVEL_ID,
          per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)    occupational_level,
          nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type,
          paaf.pay_basis_id
   from   per_assignment_extra_info   paei,
          per_all_assignments_f       paaf,
          hr_lookups                  hl_lev,
          hr_lookups                  hl_fn
   where  paaf.business_group_id = p_business_group_id
   and    (add_months(p_report_date,-12)+1 <=paaf.effective_end_date and p_report_date >=paaf.effective_start_date)
   and    paaf.effective_end_date = (  select max(paaf1.effective_end_date)
                                       from   per_all_assignments_f paaf1,
                                              per_assignment_status_types past
                                       where  paaf1.assignment_id = paaf.assignment_id
                                       and    paaf1.effective_start_date <= p_report_date
                                       and    past.assignment_status_type_id = paaf1.assignment_status_type_id
                                       and    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
                                     )
   and    paei.assignment_id = paaf.assignment_id
   and    paei.information_type = 'ZA_SPECIFIC_INFO'
   and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
   and    paei.aei_information7 is not null
   AND    hl_lev.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
   AND    hl_fn.lookup_type = 'ZA_EE_FUNCTION_TYPE'    --Added for Bug 7360563
   AND    hl_lev.lookup_code <> '15'
   AND    hl_fn.lookup_code <>'15'
   AND    hl_lev.application_id = '800'
   AND    hl_fn.application_id  = '800'
   AND    hl_lev.meaning(+)       = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
   AND    hl_fn.meaning(+)        = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
   and    nvl(paei.aei_information6, 'N') <> 'Y'
   order  BY paei.aei_information7, paaf.payroll_id;


cursor c_ele_rem(l_assignment_id per_all_assignments_f.assignment_id%type
                 ,l_input_id pay_element_entry_values_f.input_value_id%type) is
   select peevf.screen_entry_value screen_value,
          months_between(least(peevf.effective_end_date ,p_report_date),greatest(peevf.effective_start_date-1 ,add_months(p_report_date,-12))) months_bet
   from   pay_element_entry_values_f peevf
          ,pay_element_entries_f      peef
   where  peef.assignment_id     = l_assignment_id
   and    peevf.element_entry_id = peef.element_entry_id
   and    peevf.input_value_id   = l_input_id
   and    (add_months(p_report_date,-12)+1 <=peef.effective_end_date and p_report_date>=peef.effective_start_date)
   and    (add_months(p_report_date,-12)+1 <=peevf.effective_end_date and p_report_date>=peevf.effective_start_date)
   and    peef.effective_start_date between peevf.effective_start_date and peevf.effective_end_date;

l_old_payroll_id      per_all_assignments_f.payroll_id%type := -9999;
v_ele_rem             c_ele_rem%rowtype;
l_rowind              pls_integer;
l_active_days         number;
l_ee_income           number;
l_ee_annual_income    number;
l_report_start        date;
l_report_end          date;
l_report_date         date;
l_difference          number;
l_period_frequency    per_time_period_types.number_per_fiscal_year%type;
l_ee_balance_type_id  pay_balance_types.balance_type_id%type;
l_eea_balance_type_id pay_balance_types.balance_type_id%type;
l_input_value_id      pay_input_values_f.input_value_id%type;
l_input_value_id2     pay_input_values_f.input_value_id%type;
l_index               number;
l_proc                constant varchar2(60) := g_package || 'get_avg_5_lowest_salary';
l_race                per_all_people_f.per_information4%type; -- Bug 4413678
l_sex                 per_all_people_f.sex%type;
--Changes for Bug 7237663
l_er_income           number;
l_er_annual_income    number;
l_er_balance_type_id  pay_balance_types.balance_type_id%type;
l_era_balance_type_id pay_balance_types.balance_type_id%type;
l_type varchar2(5);


begin
   --hr_utility.trace_on(null,'ZAEID');
   reset_new_tables;
   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Determine whether we need to populate the cache tables
   -- Note: No check is made for the validity of the table data, since it is assumed that the
   --       reset_tables procedure was called before this procedure.
   if g_new_assignments_table.count = 0 then

      hr_utility.set_location('Setup assignments cache', 20);
      g_new_assignments_table.delete;

      if p_salary_method = 'BAL' then

         -- Get the balance type id's for the normal and annual balances
         begin

            select balance_type_id
            into   l_ee_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable Income'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

            select balance_type_id
            into   l_eea_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable Annual Income'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

          --Changes for Bug 7237663
            select balance_type_id
            into   l_er_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable ER Normal Contributions'
            and    legislation_code = 'ZA'
            and    business_group_id is null;

            select balance_type_id
            into   l_era_balance_type_id
            from   pay_balance_types
            where  balance_name = 'Total Employment Equityable ER Annual Contributions'
            and    legislation_code = 'ZA'
            and    business_group_id is null;
           --End changes for Bug 7237663

         exception
            when no_data_found then
               raise_application_error(-20000, 'The Employment Equitable balances do not exist.');

         end;

      end if;

      if p_salary_method = 'ELE' then

         -- Get the ZA Employment Equity Remuneration element details
         begin

            select pivf.input_value_id
            into   l_input_value_id
            from   pay_input_values_f         pivf,
                   pay_element_types_f        petf
            where  petf.element_name = 'ZA Employment Equity Remuneration'
            and    petf.business_group_id is null
            and    petf.legislation_code = 'ZA'
            and    p_report_date between petf.effective_start_date and petf.effective_end_date
            and    pivf.element_type_id = petf.element_type_id
            and    pivf.name = 'Remuneration'
            and    p_report_date between pivf.effective_start_date and pivf.effective_end_date;

         exception
            when no_data_found then
               raise_application_error(-20004, 'The ZA Employment Equity Remuneration element does not exist.');

         end;

      end if;

      -- Loop through the assignments cursor and populate the assignments table
      for l_assignment in c_assignments loop

         hr_utility.set_location('ASG ' || l_assignment.assignment_id, 21);

         -- Bug 4413678: Begin
         --Added for Year 2009
         --If date of naturalization is on or after 27-APR-94 , then foreign national
         Select per_information4, papf.sex,
                decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(substr(papf.PER_INFORMATION11,1,10),'/','')
                               -'19940427')
                           ,-1,null,'F')))
         into l_race, l_sex, l_type
         From per_all_people_f papf
         Where papf.person_id = l_assignment.person_id
               and p_report_date between papf.effective_start_date and papf.effective_end_date;
         -- Bug 4413678: End


         if l_assignment.payroll_id is not null and l_race <> 'N' then -- Bug 4413678: Added l_race <> 'Not Used'
-- added RPAHUNE
            g_new_assignments_table(l_assignment.assignment_id).payroll_id            := l_assignment.payroll_id;
            g_new_assignments_table(l_assignment.assignment_id).legal_entity_id       := l_assignment.aei_information7;
            g_new_assignments_table(l_assignment.assignment_id).occupational_level    := l_assignment.occupational_level;
            --Modified for bug 9462039
            g_new_assignments_table(l_assignment.assignment_id).occupational_category := null;
            g_new_assignments_table(l_assignment.assignment_id).occupational_category_ID := null;
            g_new_assignments_table(l_assignment.assignment_id).occupational_level_id    := l_assignment.occupational_level_id;
            g_new_assignments_table(l_assignment.assignment_id).race                  := l_race;
            g_new_assignments_table(l_assignment.assignment_id).sex                   := l_sex;
            g_new_assignments_table(l_assignment.assignment_id).foreigner              := l_type;
            g_new_assignments_table(l_assignment.assignment_id).employment_type        := l_assignment.employment_type;

            hr_utility.set_location('LEGENT ' || l_assignment.aei_information7, 22);

            -- Check for a new payroll_id and cache the new payroll details in the payrolls table
            if l_assignment.payroll_id <> l_old_payroll_id then

               /* Bug 8911880
               -- Get the start date and end date of the report
               begin


                  l_report_date := p_report_date;
                  l_difference := 0;

                  while (l_difference < 355 or l_difference > 375) loop

                     select ptpf.end_date + 1,
                            ptpl.end_date
                     into   l_report_start,
                            l_report_end
                     from   per_time_periods ptpf,
                            per_time_periods ptpl
                     where  ptpl.payroll_id = l_assignment.payroll_id
                     and    l_report_date between ptpl.start_date and ptpl.end_date
                     and    ptpf.payroll_id = l_assignment.payroll_id
                     and    add_months(l_report_date, -12) + 1 between ptpf.start_date and ptpf.end_date;

                     l_difference := l_report_end - l_report_start + 1;

                     if (l_difference < 355 or l_difference > 375) then

                        l_report_date := l_report_date - 1;

                     end if;

                  end loop;

               exception
                  when no_data_found then
                     begin
                             select ptpl.end_date
                             into   l_report_end
                             from   per_time_periods ptpl
                             where  ptpl.payroll_id = l_assignment.payroll_id
                             and    p_report_date between ptpl.start_date and ptpl.end_date;

                     exception
                             when no_data_found then
                                      Null;
                     end;

                     l_report_start := add_months(l_report_end, -12) + 1;

               end;
               */

               /* Bug 8911880
               -- Get the payroll period frequency
               begin

                  select ptpt.number_per_fiscal_year
                  into   l_period_frequency
                  from   per_time_period_types ptpt,
                         pay_all_payrolls_f    payr
                  where  payr.payroll_id = l_assignment.payroll_id
                  and    p_report_date between payr.effective_start_date and payr.effective_end_date
                  and    ptpt.period_type = payr.period_type;

               exception
                  when no_data_found then
                     raise_application_error(-20005, 'The Payroll Period Frequency does not exist.');

               end;
               */

               l_old_payroll_id := l_assignment.payroll_id;

            end if;

--            hr_utility.set_location('REP_START ' || to_char(l_report_start, 'DD\MM\YYYY'), 22);
--            hr_utility.set_location('REP_END   ' || to_char(l_report_end, 'DD\MM\YYYY'), 23);
--            hr_utility.set_location('FREQ      ' || l_period_frequency, 24);

            if p_salary_method = 'BAL' then

               /* Bug 8911880
               -- Get the amount of days the assignment status was Active Assignment
               l_active_days := get_active_days
                                (
                                   p_assignment_id => l_assignment.assignment_id,
                                   p_report_start  => l_report_start,
                                   p_report_end    => l_report_end
                                );

               hr_utility.set_location('ACT_DAYS ' || l_active_days, 25);
               */

               -- Get the Employment Equitable Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_ee_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  -- BUG 2665394 ADDED THE TABLE TO IMPROVE THE PERFORMANCE
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_ee_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  -- BUG 2665394 ADDED THE JOINS TO IMPROVE THE PERFORMANCE
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_ee_income := 0;

               end;

               -- Get the Employment Equitable Annual Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_ee_annual_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  -- BUG 2665394 ADDED THE TABLE TO IMPROVE THE PERFORMANCE
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_eea_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  -- BUG 2665394 ADDED THE JOINS TO IMPROVE THE PERFORMANCE
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_ee_annual_income := 0;

               end;

               --Changes for Bug 7237663
               -- Two new balances added for employer contributions
               -- Get the Employment Equitable ER Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_er_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_er_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_er_income := 0;

               end;

               -- Get the Employment Equitable ER Annual Income
               begin

                  select nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbff.scale), 0)
                  into   l_er_annual_income
                  from   pay_balance_feeds_f         pbff,
                         pay_run_result_values       prrv,
                         pay_run_results             prr,
                         pay_payroll_actions         ppa,
                         pay_assignment_actions      paa,
                         per_assignments_f       asg     --Bug 4872110
                  where  paa.assignment_id = l_assignment.assignment_id
                  and    ppa.payroll_action_id = paa.payroll_action_id
                --  Bug 8911880
                --  and    ppa.date_earned between l_report_start and l_report_end
                  and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                  and    prr.assignment_action_id = paa.assignment_action_id
                  and    prrv.run_result_id = prr.run_result_id
                  and    pbff.balance_type_id = l_era_balance_type_id
                  and    ppa.effective_date between pbff.effective_start_date and pbff.effective_end_date
                  and    prrv.input_value_id = pbff.input_value_id
                  and    paa.assignment_id = asg.assignment_id
                  and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                  and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     l_er_annual_income := 0;

               end;


               hr_utility.set_location('EE_INC ' || l_ee_income, 26);
               hr_utility.set_location('EE_ANN ' || l_ee_annual_income, 27);
               hr_utility.set_location('ER_INC ' || l_er_income, 26);
               hr_utility.set_location('ER_ANN ' || l_er_annual_income, 27);

           --    hr_utility.set_location('STminEND ' || (l_report_end - l_report_start + 1), 28);

               -- Calculate the annual income = annualize normal income + annual income
               g_new_assignments_table(l_assignment.assignment_id).annual_income :=
                   l_ee_income + l_er_income + l_ee_annual_income + l_er_annual_income;

               hr_utility.set_location('ANSWER ' || g_new_assignments_table(l_assignment.assignment_id).annual_income, 29);

            elsif p_salary_method = 'SAL' then

               -- Get the annual salary basis for the current period
               begin

                        select input_value_id
                        into l_input_value_id
                        from per_pay_bases ppb
                        where ppb.pay_basis_id = l_assignment.pay_basis_id;


                        select pivff.input_value_id --Pay Value input value ID
                        into  l_input_value_id2
                        from  pay_input_values_f pivf, --Sal Basis Input Value
                              pay_input_values_f pivff --Pay Value Input Value
                        where pivf.input_value_id = l_input_value_id
                        and   pivff.element_type_id = pivf.element_type_id
                        and   pivff.name='Pay Value'
                        and   p_report_date between pivf.effective_start_date and pivf.effective_end_date
                        and   p_report_date between pivff.effective_start_date and pivff.effective_end_date;


                        select nvl(sum(fnd_number.canonical_to_number(prrv.result_value)), 0)
                        into   g_new_assignments_table(l_assignment.assignment_id).annual_income
                        from   pay_run_result_values       prrv,
                               pay_run_results             prr,
                               pay_payroll_actions         ppa,
                               pay_assignment_actions      paa,
                               per_assignments_f       asg
                        where  paa.assignment_id = l_assignment.assignment_id
                        and    ppa.payroll_action_id = paa.payroll_action_id
                        and    ppa.date_earned between add_months(p_report_date,-12)+1 and p_report_date
                        and    prr.assignment_action_id = paa.assignment_action_id
                        and    prrv.run_result_id  =  prr.run_result_id
                        and    prrv.input_value_id = l_input_value_id2
                        and    paa.assignment_id   = asg.assignment_id
                        and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
                        and    asg.payroll_id = ppa.payroll_id;

               exception
                  when no_data_found then
                     g_new_assignments_table(l_assignment.assignment_id).annual_income := 0;

               end;

            elsif p_salary_method = 'ELE' then

               begin
                  g_new_assignments_table(l_assignment.assignment_id).annual_income:=0;
                  open c_ele_rem(l_assignment.assignment_id,l_input_value_id);
                  loop
                      fetch c_ele_rem into v_ele_rem;
                      if c_ele_rem%rowcount=0 then
                          g_new_assignments_table(l_assignment.assignment_id).annual_income:= 0;
                      end if;
                      exit when c_ele_rem%notfound;
                      g_new_assignments_table(l_assignment.assignment_id).annual_income:=
                             g_new_assignments_table(l_assignment.assignment_id).annual_income + (v_ele_rem.screen_value * v_ele_rem.months_bet);
                  end loop;
                  close c_ele_rem;
               end;

            end if;   -- p_salary_method

         end if;   -- (l_assignment.payroll_id is not null)

      end loop;   -- c_assignments

   end if;   -- g_new_assignments_table.count = 0

   -- The index is calculted by multiplying the legal entity id by 100 and then adding the lookup code
   -- This should always give a unique value, since the lookup code is less than 100
-- Start of adding for Employment Equity Report Enhancement Inserting values in table.
   l_rowind := g_new_assignments_table.first;
   hr_utility.set_location ('l_rowind :=' || l_rowind, 20);
   loop
      exit when l_rowind is null;

   hr_utility.set_location ('g_new_assignments_table(l_rowind).legal_entity_id' ||g_new_assignments_table(l_rowind).legal_entity_id, 20);
   hr_utility.set_location ('occupational_level :=' || g_new_assignments_table(l_rowind).occupational_level, 20);
   hr_utility.set_location ('occupational_category :=' || g_new_assignments_table(l_rowind).occupational_category, 20);
   hr_utility.set_location ('race :=' || g_new_assignments_table(l_rowind).race, 20);
   hr_utility.set_location ('sex :=' || g_new_assignments_table(l_rowind).sex, 20);
   hr_utility.set_location ('employment_type :=' || g_new_assignments_table(l_rowind).employment_type, 20);
   hr_utility.set_location ('foreigner :=' || g_new_assignments_table(l_rowind).foreigner, 20);
   hr_utility.set_location ('assignment_id :=' || l_rowind, 20);

   if g_new_assignments_table(l_rowind).employment_type='Permanent' then
     if g_new_assignments_table(l_rowind).foreigner is null then
      --Permanent non foreigner
      hr_utility.set_location('Populating permanent non foreigner',25);
      cat_lev_data( g_new_assignments_table(l_rowind).legal_entity_id
                  , g_new_assignments_table(l_rowind).occupational_level
                  , g_new_assignments_table(l_rowind).occupational_category
                  , g_new_assignments_table(l_rowind).race
                  , g_new_assignments_table(l_rowind).sex
                  , nvl(g_new_assignments_table(l_rowind).annual_income,0)
                  , g_new_assignments_table(l_rowind).occupational_level_id
                  , g_new_assignments_table(l_rowind).occupational_category_ID
                  , g_lev_Enc_Diff_table
                  );
     else
      --Permanent foreigner
      hr_utility.set_location('Populating permanent foreigner',25);
      cat_lev_data( g_new_assignments_table(l_rowind).legal_entity_id
                  , g_new_assignments_table(l_rowind).occupational_level
                  , g_new_assignments_table(l_rowind).occupational_category
                  , g_new_assignments_table(l_rowind).race
                  , g_new_assignments_table(l_rowind).sex
                  , nvl(g_new_assignments_table(l_rowind).annual_income,0)
                  , g_new_assignments_table(l_rowind).occupational_level_id
                  , g_new_assignments_table(l_rowind).occupational_category_ID
                  , g_lev_Enc_Diff_table_F
                  );
     end if;
   else --Non permanent
     if g_new_assignments_table(l_rowind).foreigner is null then
      --Non Permanent non foreigner
      hr_utility.set_location('Populating non permanent non foreigner',25);
      cat_lev_data( g_new_assignments_table(l_rowind).legal_entity_id
                  , g_new_assignments_table(l_rowind).occupational_level
                  , g_new_assignments_table(l_rowind).occupational_category
                  , g_new_assignments_table(l_rowind).race
                  , g_new_assignments_table(l_rowind).sex
                  , nvl(g_new_assignments_table(l_rowind).annual_income,0)
                  , g_new_assignments_table(l_rowind).occupational_level_id
                  , g_new_assignments_table(l_rowind).occupational_category_ID
                  , g_lev_Enc_Diff_table_T
                  );
     else
      --Non Permanent foreigner
      hr_utility.set_location('Populating non permanent foreigner',25);
      cat_lev_data( g_new_assignments_table(l_rowind).legal_entity_id
                  , g_new_assignments_table(l_rowind).occupational_level
                  , g_new_assignments_table(l_rowind).occupational_category
                  , g_new_assignments_table(l_rowind).race
                  , g_new_assignments_table(l_rowind).sex
                  , nvl(g_new_assignments_table(l_rowind).annual_income,0)
                  , g_new_assignments_table(l_rowind).occupational_level_id
                  , g_new_assignments_table(l_rowind).occupational_category_ID
                  , g_lev_Enc_Diff_table_TF
                  );
     end if;
   end if;

            l_rowind := g_new_assignments_table.next(l_rowind);
   END loop;

   l_rowind := g_lev_Enc_Diff_table.first;
   loop
      exit when l_rowind is null;

      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'ED'  -- no of employees in each categories
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Permanent'
      , g_lev_Enc_Diff_table(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table(l_rowind).occupational_code
      , g_lev_Enc_Diff_table(l_rowind).ma
      , g_lev_Enc_Diff_table(l_rowind).mc
      , g_lev_Enc_Diff_table(l_rowind).mi
      , g_lev_Enc_Diff_table(l_rowind).mw
      , g_lev_Enc_Diff_table(l_rowind).fa
      , g_lev_Enc_Diff_table(l_rowind).fc
      , g_lev_Enc_Diff_table(l_rowind).fi
      , g_lev_Enc_Diff_table(l_rowind).fw
      , g_lev_Enc_Diff_table(l_rowind).total
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table(l_rowind).legal_entity_id;

      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'EDI'  -- income
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Permanent'
      , g_lev_Enc_Diff_table(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table(l_rowind).occupational_code
      , g_lev_Enc_Diff_table(l_rowind).ma_inc
      , g_lev_Enc_Diff_table(l_rowind).mc_inc
      , g_lev_Enc_Diff_table(l_rowind).mi_inc
      , g_lev_Enc_Diff_table(l_rowind).mw_inc
      , g_lev_Enc_Diff_table(l_rowind).fa_inc
      , g_lev_Enc_Diff_table(l_rowind).fc_inc
      , g_lev_Enc_Diff_table(l_rowind).fi_inc
      , g_lev_Enc_Diff_table(l_rowind).fw_inc
      , g_lev_Enc_Diff_table(l_rowind).total_inc
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table(l_rowind).legal_entity_id;

     l_rowind := g_lev_Enc_Diff_table.next(l_rowind);
   END loop;

   --Permanent Foreigners
   l_rowind := g_lev_Enc_Diff_table_F.first;
   loop
      exit when l_rowind is null;
      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'EDF'  -- no of employees in each categories
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table_F(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Permanent'
      , g_lev_Enc_Diff_table_F(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table_F(l_rowind).occupational_code
      , g_lev_Enc_Diff_table_F(l_rowind).ma
      , g_lev_Enc_Diff_table_F(l_rowind).mc
      , g_lev_Enc_Diff_table_F(l_rowind).mi
      , g_lev_Enc_Diff_table_F(l_rowind).mw
      , g_lev_Enc_Diff_table_F(l_rowind).fa
      , g_lev_Enc_Diff_table_F(l_rowind).fc
      , g_lev_Enc_Diff_table_F(l_rowind).fi
      , g_lev_Enc_Diff_table_F(l_rowind).fw
      , g_lev_Enc_Diff_table_F(l_rowind).total
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table_F(l_rowind).legal_entity_id;

      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'EDFI'  -- income
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table_F(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Permanent'
      , g_lev_Enc_Diff_table_F(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table_F(l_rowind).occupational_code
      , g_lev_Enc_Diff_table_F(l_rowind).ma_inc
      , g_lev_Enc_Diff_table_F(l_rowind).mc_inc
      , g_lev_Enc_Diff_table_F(l_rowind).mi_inc
      , g_lev_Enc_Diff_table_F(l_rowind).mw_inc
      , g_lev_Enc_Diff_table_F(l_rowind).fa_inc
      , g_lev_Enc_Diff_table_F(l_rowind).fc_inc
      , g_lev_Enc_Diff_table_F(l_rowind).fi_inc
      , g_lev_Enc_Diff_table_F(l_rowind).fw_inc
      , g_lev_Enc_Diff_table_F(l_rowind).total_inc
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table_F(l_rowind).legal_entity_id;

     l_rowind := g_lev_Enc_Diff_table_F.next(l_rowind);
   END loop;

   --Non permanent workers
   l_rowind := g_lev_Enc_Diff_table_T.first;
   loop
      exit when l_rowind is null;
      --Non permanent workers
      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'ED'  -- no of employees in each categories
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table_T(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Non-Permanent'
      , g_lev_Enc_Diff_table_T(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table_T(l_rowind).occupational_code
      , g_lev_Enc_Diff_table_T(l_rowind).ma
      , g_lev_Enc_Diff_table_T(l_rowind).mc
      , g_lev_Enc_Diff_table_T(l_rowind).mi
      , g_lev_Enc_Diff_table_T(l_rowind).mw
      , g_lev_Enc_Diff_table_T(l_rowind).fa
      , g_lev_Enc_Diff_table_T(l_rowind).fc
      , g_lev_Enc_Diff_table_T(l_rowind).fi
      , g_lev_Enc_Diff_table_T(l_rowind).fw
      , g_lev_Enc_Diff_table_T(l_rowind).total
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table_T(l_rowind).legal_entity_id;

      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'EDI'  -- income
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table_T(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Non-Permanent'
      , g_lev_Enc_Diff_table_T(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table_T(l_rowind).occupational_code
      , g_lev_Enc_Diff_table_T(l_rowind).ma_inc
      , g_lev_Enc_Diff_table_T(l_rowind).mc_inc
      , g_lev_Enc_Diff_table_T(l_rowind).mi_inc
      , g_lev_Enc_Diff_table_T(l_rowind).mw_inc
      , g_lev_Enc_Diff_table_T(l_rowind).fa_inc
      , g_lev_Enc_Diff_table_T(l_rowind).fc_inc
      , g_lev_Enc_Diff_table_T(l_rowind).fi_inc
      , g_lev_Enc_Diff_table_T(l_rowind).fw_inc
      , g_lev_Enc_Diff_table_T(l_rowind).total_inc
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table_T(l_rowind).legal_entity_id;


     l_rowind := g_lev_Enc_Diff_table_T.next(l_rowind);
   END loop;

   --Non permanent foreigners workers
   l_rowind := g_lev_Enc_Diff_table_TF.first;
   loop
      exit when l_rowind is null;
      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'EDF'  -- no of employees in each categories
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table_TF(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Non-Permanent'
      , g_lev_Enc_Diff_table_TF(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table_TF(l_rowind).occupational_code
      , g_lev_Enc_Diff_table_TF(l_rowind).ma
      , g_lev_Enc_Diff_table_TF(l_rowind).mc
      , g_lev_Enc_Diff_table_TF(l_rowind).mi
      , g_lev_Enc_Diff_table_TF(l_rowind).mw
      , g_lev_Enc_Diff_table_TF(l_rowind).fa
      , g_lev_Enc_Diff_table_TF(l_rowind).fc
      , g_lev_Enc_Diff_table_TF(l_rowind).fi
      , g_lev_Enc_Diff_table_TF(l_rowind).fw
      , g_lev_Enc_Diff_table_TF(l_rowind).total
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table_TF(l_rowind).legal_entity_id;

      INSERT INTO per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      Select 'EDFI'  -- income
      , p_report_date
      , p_business_group_id
      , g_lev_Enc_Diff_table_TF(l_rowind).legal_entity_id
      , haou.name        legal_entity
      , null
      , 'Non-Permanent'
      , g_lev_Enc_Diff_table_TF(l_rowind).occupational_code_id
      , g_lev_Enc_Diff_table_TF(l_rowind).occupational_code
      , g_lev_Enc_Diff_table_TF(l_rowind).ma_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).mc_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).mi_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).mw_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).fa_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).fc_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).fi_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).fw_inc
      , g_lev_Enc_Diff_table_TF(l_rowind).total_inc
      FROM hr_all_organization_units haou
      Where  haou.organization_id = g_lev_Enc_Diff_table_TF(l_rowind).legal_entity_id;

     l_rowind := g_lev_Enc_Diff_table_TF.next(l_rowind);
   END loop;
--hr_utility.trace_off;


-- inserting 0 values for the no of employees
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'ED'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             null              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'ED'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

-- inserting 0 values for the Income
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EDI'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             null              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning               ,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EDI'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

-- inserting 0 values for the no of employees
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EDF'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             null              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EDF'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

-- inserting 0 values for the Income
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EDFI'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             null              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning               ,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EDFI'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

--Insert rows for non permanent
--Rows present for Non foreigner non permanent, but not present for
--foreigner non permanent
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select  decode(report_id,'ED','EDF','EDFI'),
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
      from   per_za_employment_equity pzee1
      Where  pzee1.business_group_id = p_business_group_id
      AND    pzee1.legal_entity_id = nvl(p_legal_entity_id, pzee1.legal_entity_id)
      AND    pzee1.report_id IN ('ED','EDI')
      AND    not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.business_group_id   = pzee1.business_group_id
         AND    pzee.legal_entity_id    = pzee1.legal_entity_id
         AND    ( pzee1.report_id ||'F'     = pzee.report_id    --row not present for ED
                  OR
                  substr(pzee1.report_id,1,2)||'FI'   = pzee.report_id)
         AND    pzee1.level_cat_code     = pzee.level_cat_code
         AND    pzee1.level_cat          = pzee.level_cat
         and    pzee.employment_type     = pzee1.employment_type
      );

--Insert rows for non permanent
--Rows present for foreigner non permanent, but not present for
--non foreigner non permanent
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select  decode(report_id,'EDF','ED','EDI'),
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
      from   per_za_employment_equity pzee1
      Where  pzee1.business_group_id = p_business_group_id
      AND    pzee1.legal_entity_id = nvl(p_legal_entity_id, pzee1.legal_entity_id)
      AND    pzee1.report_id IN ('EDF','EDFI')
      AND    not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.business_group_id   = pzee1.business_group_id
         AND    pzee.legal_entity_id    = pzee1.legal_entity_id
         AND    ( pzee.report_id ||'F'     = pzee1.report_id    --row not present for ED
                  OR
                  (pzee1.report_id='EDFI' and pzee.report_id='EDI'))
         AND    pzee1.level_cat_code     = pzee.level_cat_code
         AND    pzee1.level_cat          = pzee.level_cat
         and    pzee.employment_type     = pzee1.employment_type
      );



commit;

end init_g_cat_lev_new_table;


function get_termination_reason_new
(
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_reason_code       in per_periods_of_service.leaving_reason%type
)  return varchar2 is

l_termination_reason pay_user_column_instances_f.value%type;

begin

   select pucifcat.value
   into   l_termination_reason
   from   pay_user_column_instances_f pucifcat,
          pay_user_rows_f             purfcat,
          pay_user_columns            puccat,
          pay_user_rows_f             purfqc,
          pay_user_column_instances_f pucifqc,
          pay_user_columns            pucqc,
          pay_user_tables             put
   where  put.user_table_name = 'ZA_TERMINATION_CATEGORIES'
   and    put.business_group_id is null
   and    put.legislation_code = 'ZA'
   and    pucqc.user_table_id = put.user_table_id
   and    pucqc.user_column_name = 'Lookup Code'
   and    pucifqc.user_column_id = pucqc.user_column_id
   and    pucifqc.business_group_id = p_business_group_id
   and    p_report_date between pucifqc.effective_start_date and pucifqc.effective_end_date
   and    pucifqc.value = p_reason_code
   and    purfqc.user_table_id = put.user_table_id
   and    purfqc.user_row_id = pucifqc.user_row_id
   and    purfqc.business_group_id = pucifqc.business_group_id
   and    p_report_date between purfqc.effective_start_date and purfqc.effective_end_date
   and    puccat.user_table_id = put.user_table_id
   and    puccat.user_column_name = 'Termination Category'
   and    purfcat.user_table_id = put.user_table_id
   and    purfcat.business_group_id = pucifqc.business_group_id
   and    p_report_date between purfcat.effective_start_date and purfcat.effective_end_date
   and    purfcat.row_low_range_or_name = purfqc.row_low_range_or_name
   and    pucifcat.user_column_id = puccat.user_column_id
   and    pucifcat.user_row_id = purfcat.user_row_id
   and    p_report_date between pucifcat.effective_start_date and pucifcat.effective_end_date
   and    pucifcat.business_group_id = pucifqc.business_group_id
   and    pucifcat.value in
   (
      'Resignation',
      'Non-Renewal of Contract',
      'Dismissal - Operational Requirements',
      'Dismissal - Misconduct',
      'Dismissal - Incapacity',
      --'Other'
      'Retirement',
      'Death'
   );

   return l_termination_reason;

exception
   when no_data_found then
      return 'No Leaving Reason';

end get_termination_reason_new;


procedure populate_ee_table_new
(
   p_report_code       in varchar2,
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
)  is

l_counter number;
l_reason  varchar2(200);
l_nat_date date;

begin

   l_nat_date := to_date('27-04-1994', 'DD-MM-YYYY');

   -- Note EQ1 is for the following 2 reports:
   --    2. Occupational Categories (including employees with disabilities)
   --    3. Occupational Categories (only employees with disabilities)
   if p_report_code = 'EQ1' then

      -- Note: The date effective select on per_all_assignments_f is ok in this case, since an assignment
      --       record always exist at the same time as an employee record with status EMP
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         ma,
         mc,
         mi,
         mw,
         fa,
         fc,
         fi,
         fw,
         total
      )
      select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )      report_code,
             p_report_date                                                              reporting_date,
             paaf.business_group_id,
             paei.aei_information7                                                      legal_entity_id,
             haou.name                                                                  legal_entity,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)    disability, --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id) employment_type,  -- Bug 3962073
             hl.lookup_code                                                             meaning_code,
             nvl(per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Category') occupational_category,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
      from   hr_lookups                hl,
             hr_lookups                hl1,
             hr_lookups                hl2,
             hr_all_organization_units haou,
             per_assignment_extra_info paei,
             per_all_assignments_f     paaf,
             per_all_people_f          papf
      where  papf.business_group_id = p_business_group_id
      and    p_report_date between papf.effective_start_date and papf.effective_end_date
      and    papf.current_employee_flag = 'Y'
      and    paaf.person_id = papf.person_id
      and    paaf.primary_flag = 'Y'
      and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
      and    paei.assignment_id = paaf.assignment_id
      and    paei.information_type = 'ZA_SPECIFIC_INFO'
      and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
      and    paei.aei_information7 is not null
      and    nvl(paei.aei_information6, 'N') <> 'Y'
      and    haou.organization_id = paei.aei_information7
      and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and    hl.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      AND    hl.lookup_code <> '15' -- Not Applicable.
      and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
      AND    hl1.lookup_code <> '15' -- Not Applicable.
      and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      AND    hl2.lookup_code <> '15' -- Not Applicable.
      and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
      group  by paaf.business_group_id,
             paei.aei_information7,
             haou.name,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)), -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id),  -- Bug 3962073
             hl.lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id), 'No Occupational Category'),
             p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                              decode(papf.PER_INFORMATION11,null,null,
                              decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    );

      commit;

      -- Inserts non-associated occupational categories with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ1'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ1'
         and    pzee.business_group_id = p_business_group_id           --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

-- Inseting 0 VALUES FOR FOREIGN nationals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ1F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ1F'
         and    pzee.business_group_id = p_business_group_id           --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ2 is for the following 2 reports:
   --    4. Occupational Levels (including employees with disabilities)
   --    5. Occupational Levels (only employees with disabilities)
   elsif p_report_code = 'EQ2' then

      -- Populate with Occupational Level Totals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))
             ) report_code,
             p_report_date                                                              reporting_date,
             paaf.business_group_id,
             paei.aei_information7                                                      legal_entity_id,
             haou.name                                                                  legal_entity,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)      disability, --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id) employment_type,  -- Bug 3962073
             hl.lookup_code                                                             meaning_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level') occupational_level,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
      from   hr_lookups                hl,
             hr_lookups                hl1,
--             hr_lookups                hl2,
             hr_all_organization_units haou,
             per_assignment_extra_info paei,
             per_all_assignments_f     paaf,
             per_all_people_f          papf
      where  papf.business_group_id = p_business_group_id
      and    p_report_date between papf.effective_start_date and papf.effective_end_date
      and    papf.current_employee_flag = 'Y'
      and    paaf.person_id = papf.person_id
      and    paaf.primary_flag = 'Y'
      and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
      and    paei.assignment_id = paaf.assignment_id
      and    paei.information_type = 'ZA_SPECIFIC_INFO'
      and    paei.aei_information7 = nvl(p_legal_entity_id,paei.aei_information7)
      and    paei.aei_information7 is not null
      and    nvl(paei.aei_information6, 'N') <> 'Y'
      and    haou.organization_id = paei.aei_information7
      and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
      AND    hl.lookup_code <> '15' -- Not Applicable.
      and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
      AND    hl1.lookup_code <> '15' -- Operation / core function
      and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
 --     and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
 --     and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
 --     AND    hl2.lookup_code <> '15' -- Not Applicable.
      group  by paaf.business_group_id,
             paei.aei_information7,
             haou.name,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)), -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id), -- Bug 3962073
             hl.lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level'),
             p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F')));

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ2'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ2'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


-- inserting 0 values for the Foreign Nationals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ2F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ2F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


      commit;

-- For employment equity enhancement
   elsif p_report_code = 'EQ3' then

      -- Populate with New Hires
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F')))     report_code,
                p_report_date                                                                                                                                       reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                                                                                               legal_entity_id,
                haou.name                                                                                                                                           legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability, -- 3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id)                                                         employment_type, -- Bug 3962073
                hl.lookup_code                                                                                                                                      meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
--                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    p_report_date between papf.effective_start_date and papf.effective_end_date
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         AND    hl1.lookup_code = '1' -- Operation / core function
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
--         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
--         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
--         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level'),
                p_report_code ||  decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F')))
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ3'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ3'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ3F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ3F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ4 is for the following report:
   --    2.3.1. Operational / core Functiona (report the total number of new recruits into each occupational level during
   --       the twelve months preceding this report)
   elsif p_report_code = 'EQ4' then

      -- Populate with New Hires
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F')))     report_code,
                p_report_date                                                                                                                                       reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                                                                                               legal_entity_id,
                haou.name                                                                                                                                           legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability, -- 3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id)                                                         employment_type, -- Bug 3962073
                hl.lookup_code                                                                                                                                      meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
--                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    p_report_date between papf.effective_start_date and papf.effective_end_date
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    p_report_date between paaf.effective_start_date and paaf.effective_end_date
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         AND    hl1.lookup_code = '2' -- Support function
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
--         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
--         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
--         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level'),
                p_report_code ||  decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F')))
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ4'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ4'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ4F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ4F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

-- End for Emplyment Equity enhancement


   -- Note EQ5 is for the following report:
   --    6. Recruitment (report the total number of new recruits into each occupational level during
   --       the twelve months preceding this report)
   elsif p_report_code = 'EQ5' then

      -- Populate with New Hires
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F')))     report_code,
                p_report_date                                                                                                                                       reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                                                                                               legal_entity_id,
                haou.name                                                                                                                                           legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability, -- 3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id)                                                         employment_type, -- Bug 3962073
                hl.lookup_code                                                                                                                                      meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(ppos.date_start, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
--                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_periods_of_service    ppos,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    ppos.person_id = papf.person_id
         and    ppos.date_start between add_months(p_report_date, -12) + 1 and p_report_date
         and    papf.effective_start_date = ppos.date_start
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    paaf.effective_start_date = ppos.date_start
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(ppos.date_start, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         and    hl1.lookup_code <> '15' -- Not Applicable.
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
--         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
--         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
--         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(p_report_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(ppos.date_start, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(ppos.date_start, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level'),
                p_report_code ||  decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F')))
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ5'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ5'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ5F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ5F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ6 is for the following report:
   --    7. Promotion (report the total number of promotions into each occupational level during
   --       the twelve months preceding this report)
   elsif p_report_code = 'EQ6' then

      -- Populate with Promotions
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                                decode(papf.PER_INFORMATION11,null,null,
                                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                                       - to_char(l_nat_date,'YYYYMMDD'))
                                    ,-1,null,'F')))     report_code,
             p_report_date                                                              reporting_date,
             paaf.business_group_id,
             paei.aei_information7                                                      legal_entity_id,
             haou.name                                                                  legal_entity,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)     disability, --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id) employment_type,
             hl.lookup_code                                                             lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level') occupational_level,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
             sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
      from   hr_lookups                hl,
             hr_lookups                hl1,
--             hr_lookups                hl2,
             hr_all_organization_units haou,
             per_assignment_extra_info paei,
             per_all_assignments_f     paaf,
             per_periods_of_service    ppos,
             per_all_people_f          papf
      where  papf.business_group_id = p_business_group_id
      and    papf.current_employee_flag = 'Y'
      and    ppos.person_id = papf.person_id
      and    nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY')) > add_months(p_report_date, -12) + 1
      and    ppos.date_start < p_report_date
      and    papf.effective_start_date = ppos.date_start
      and    paaf.person_id = papf.person_id
      and    paaf.primary_flag = 'Y'
      and    paaf.effective_start_date between ppos.date_start and nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
      and    paaf.effective_start_date > add_months(p_report_date, -12) + 1
      and    paaf.effective_start_date <= p_report_date
      and    paei.assignment_id = paaf.assignment_id
      and    paei.information_type = 'ZA_SPECIFIC_INFO'
      and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
      and    paei.aei_information7 is not null
      and    nvl(paei.aei_information6, 'N') <> 'Y'
      and    haou.organization_id = paei.aei_information7
      and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
      AND    hl.lookup_code <> '15' -- Not Applicable.
      and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
      and    hl1.lookup_code <> '15' -- Not Applicable.
      and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
--      and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
--      and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
--      AND    hl2.lookup_code <> '15' -- Not Applicable.
      and    nvl(per_za_employment_equity_pkg.get_lookup_code(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)), '9999999999') <
      any
      (
         select per_za_employment_equity_pkg.get_lookup_code(per_za_employment_equity_pkg.get_occupational_level(paaf1.effective_start_date, paaf1.assignment_id, paaf1.job_id, paaf1.grade_id, paaf1.position_id, paaf.business_group_id,2009)) lookup_code
         from   per_all_assignments_f paaf1
         where  paaf1.person_id = papf.person_id
         and    paaf1.primary_flag = 'Y'
         and    per_za_employment_equity_pkg.get_lookup_code(per_za_employment_equity_pkg.get_occupational_level(paaf1.effective_start_date, paaf1.assignment_id, paaf1.job_id, paaf1.grade_id, paaf1.position_id, paaf.business_group_id,2009)) is not null
         and    paaf1.effective_end_date + 1 = paaf.effective_start_date
      )
      group  by paaf.business_group_id,
             paei.aei_information7,
             haou.name,
             decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
             nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id)),
             -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_start_date, paaf.period_of_service_id),
             hl.lookup_code,
             nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_start_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level'),
             p_report_code   || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))) ;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ6'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ6'
         and    pzee.business_group_id = p_business_group_id   --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ6F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ6F'
         and    pzee.business_group_id = p_business_group_id   --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and hl.lookup_type         = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id          --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


      commit;

   -- Note EQ5 is for the following report:
   --    8.1 Termination (report the total number of terminations in each occupational level during
   --        the twelve months preceding this report)
   elsif p_report_code = 'EQ7' then

      -- Populate with Terminations
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )       report_code,
                p_report_date                                                              reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                      legal_entity_id,
                haou.name                                                                  legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)       disability,  --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id) employment_type, -- Bug 3962073
                hl.lookup_code                                                             meaning_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_end_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level') occupational_level,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
--                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_periods_of_service    ppos,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    ppos.person_id = papf.person_id
         and    nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY')) between add_months(p_report_date, -12) + 1 and p_report_date
         and    papf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    paaf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(paaf.effective_end_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
         AND    hl.lookup_code <> '15' -- Not Applicable.
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         and    hl1.lookup_code <> '15' -- Not Applicable
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
--         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
--         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
--         AND    hl2.lookup_code <> '15' -- Not Applicable.
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id),
                hl.lookup_code,
                nvl(per_za_employment_equity_pkg.get_occupational_level(paaf.effective_end_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009), 'No Occupational Level'),
                p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )
      ) tpa
      group  by tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             tpa.meaning_code,
             tpa.occupational_level;

      commit;

      -- Inserts non-associated occupational levels with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ7'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ7'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id  --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select 'EQ7F'            report_id,
             p_report_date    reporting_date,
             p_business_group_id business_group_id,
             haou.organization_id legal_entity_id,
             haou.name        legal_entity,
             'Y'              disability,
             'Permanent'      employment_type,
             hl.lookup_code   level_cat_code,
             hl.meaning       level_cat,
             0                MA,
             0                MC,
             0                MI,
             0                MW,
             0                FA,
             0                FC,
             0                FI,
             0                FW,
             0                total
      from   hr_lookups hl
         ,   hr_all_organization_units haou
      where not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.level_cat_code    = hl.lookup_code
         and    pzee.report_id         = 'EQ7F'
         and    pzee.business_group_id = p_business_group_id            --Bug 4872110
         and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
         and    pzee.disability        = 'Y'
         and    pzee.employment_type   = 'Permanent'
      )
      and    hl.lookup_type      = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
      and haou.business_group_id = p_business_group_id  --Bug 4872110
      and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      commit;

   -- Note EQ6 is for the following report:
   --    8.2 Termination Categories (report the total number of terminations in each termination
   --        category during the twelve months preceding this report)
   elsif p_report_code = 'EQ8' then

      -- Populate with Termination Reason totals
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select tpa.report_code,
             tpa.reporting_date,
             tpa.business_group_id,
             tpa.legal_entity_id,
             tpa.legal_entity,
             tpa.disability,
             tpa.employment_type,
             decode
             (
                tpa.termination_reason,
                'Resignation', 1,
                'Non-Renewal of Contract', 2,
                'Dismissal - Operational Requirements', 3,
                'Dismissal - Misconduct', 4,
                'Dismissal - Incapacity', 5,
                --'Other', 6,
                'Retirement', 6,
                'Death', 7,
                null
             )  meaning_code,
             /*decode
             (
                tpa.termination_reason,
                'Dismissal - Operational Requirements', 'retrenchment -Operational requirements',
                tpa.termination_reason
             ),*/
             tpa.termination_reason,
             sum(tpa.male_african)    MA,
             sum(tpa.male_coloured)   MC,
             sum(tpa.male_indian)     MI,
             sum(tpa.male_white)      MW,
             sum(tpa.female_african)  FA,
             sum(tpa.female_coloured) FC,
             sum(tpa.female_indian)   FI,
             sum(tpa.female_white)    FW,
             sum(tpa.total)           total
      from
      (
         select p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )      report_code,
                p_report_date                                                              reporting_date,
                paaf.business_group_id,
                paei.aei_information7                                                      legal_entity_id,
                haou.name                                                                  legal_entity,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag)     disability, --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)) employment_type, -- Bug 3962073
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id) employment_type, -- Bug 3962073
                ppos.leaving_reason                                                        meaning_code,
                nvl(per_za_employment_equity_pkg.get_termination_reason_new(paaf.business_group_id, p_report_date, ppos.leaving_reason), 'No Leaving Reason') termination_reason,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   male_african,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0))   male_coloured,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0))   male_indian,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0))   male_white,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0))   female_african,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0))   female_coloured,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0))   female_indian,
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   female_white,
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'M', decode(papf.per_information4, '04', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '02', 1,'ZA01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '03', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '01', 1, 0), 0)) +
                sum(decode(papf.sex, 'F', decode(papf.per_information4, '04', 1, 0), 0))   total
         from   hr_lookups                hl,
                hr_lookups                hl1,
--                hr_lookups                hl2,
                hr_all_organization_units haou,
                per_assignment_extra_info paei,
                per_all_assignments_f     paaf,
                per_periods_of_service    ppos,
                per_all_people_f          papf
         where  papf.business_group_id = p_business_group_id
         and    papf.current_employee_flag = 'Y'
         and    ppos.person_id = papf.person_id
         and    nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY')) between add_months(p_report_date, -12) + 1 and p_report_date
         and    papf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paaf.person_id = papf.person_id
         and    paaf.primary_flag = 'Y'
         and    paaf.effective_end_date = nvl(ppos.actual_termination_date, to_date('31-12-4712', 'DD-MM-YYYY'))
         and    paei.assignment_id = paaf.assignment_id
         and    paei.information_type = 'ZA_SPECIFIC_INFO'
         and    paei.aei_information7 = nvl(p_legal_entity_id, paei.aei_information7)
         and    paei.aei_information7 is not null
         and    nvl(paei.aei_information6, 'N') <> 'Y'
         and    haou.organization_id = paei.aei_information7
         and    nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)) = 'Permanent'
         and    nvl(per_za_employment_equity_pkg.get_termination_reason_new(paaf.business_group_id, p_report_date, ppos.leaving_reason), 'No Leaving Reason') <> 'No Leaving Reason'
         and    hl.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_LEV'
         and    hl.meaning = per_za_employment_equity_pkg.get_occupational_level(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
         and    hl.lookup_code <> '15' -- Not Applicable
         and    hl1.lookup_type = 'ZA_EE_FUNCTION_TYPE'
         and    hl1.lookup_code <> '15' -- Not Applicable
         and    hl1.meaning = per_za_employment_equity_pkg.get_functional_type(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id,2009)
--         and    hl2.lookup_type = 'ZA_EMP_EQ_OCCUPATIONAL_CAT'
--         and    hl2.meaning = per_za_employment_equity_pkg.get_occupational_category(p_report_date, paaf.assignment_id, paaf.job_id, paaf.grade_id, paaf.position_id, paaf.business_group_id)
--         and    hl2.lookup_code <> '15' -- Not Applicable
         group  by paaf.business_group_id,
                paei.aei_information7,
                haou.name,
                decode(papf.registered_disabled_flag,'F','Y','P','Y',papf.registered_disabled_flag), --3962073
                nvl(decode(paei.aei_information11,'P','Permanent','N','Non-Permanent'), per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id)),
                -- per_za_employment_equity_pkg.get_ee_employment_type_name(paaf.effective_end_date, paaf.period_of_service_id),
                ppos.leaving_reason,
                nvl(per_za_employment_equity_pkg.get_termination_reason_new(paaf.business_group_id, p_report_date, ppos.leaving_reason), 'No Leaving Reason'),
                p_report_code || decode(papf.PER_INFORMATION9,'N',null,'Y','F',null,
                    decode(papf.PER_INFORMATION11,null,null,
                    decode(sign(replace(nvl(substr(papf.PER_INFORMATION11,1,10),'0001/01/01'),'/','')
                               -to_char(l_nat_date,'YYYYMMDD'))
                           ,-1,null,'F'))
                    )
      ) tpa
      group by tpa.report_code,
               tpa.reporting_date,
               tpa.business_group_id,
               tpa.legal_entity_id,
               tpa.legal_entity,
               tpa.disability,
               tpa.employment_type,
               tpa.meaning_code,
               tpa.termination_reason;

      commit;

      -- Insert zeroes for any Termination Categories that weren't used
      for l_counter in 1..7 loop

         -- The hard coded names of the legislative Termination Categories (not stored anywhere)
         if    l_counter = 1 then
            l_reason := 'Resignation';
         elsif l_counter = 2 then
            l_reason := 'Non-Renewal of Contract';
         elsif l_counter = 3 then
            l_reason := 'Dismissal - Operational Requirements';
         elsif l_counter = 4 then
            l_reason := 'Dismissal - Misconduct';
         elsif l_counter = 5 then
            l_reason := 'Dismissal - Incapacity';
         elsif l_counter = 6 then
            l_reason := 'Retirement';
         else
            l_reason := 'Death';
         end if;

         insert into per_za_employment_equity
         (
            report_id,
            reporting_date,
            business_group_id,
            legal_entity_id,
            legal_entity,
            disability,
            employment_type,
            level_cat_code,
            level_cat,
            MA,
            MC,
            MI,
            MW,
            FA,
            FC,
            FI,
            FW,
            total
         )
         select 'EQ8'                 report_id,
                p_report_date         reporting_date,
                p_business_group_id   business_group_id,
                haou.organization_id  legal_entity_id,
                haou.name             legal_entity,
                'Y'                   disability,
                'Permanent'           employment_type,
                decode
                (
                   l_reason,
                   'Resignation', 1,
                   'Non-Renewal of Contract', 2,
                   'Dismissal - Operational Requirements', 3,
                   'Dismissal - Misconduct', 4,
                   'Dismissal - Incapacity', 5,
                   --'Other', 6,
                   'Retirement', 6,
                   'Death', 7,
                   null
                )                     level_cat_code,
               /*decode
               (
                l_reason,
                'Dismissal - Operational Requirements', 'retrenchment -Operational requirements',
                l_reason
               )              level_cat,*/
                l_reason       level_cat,
                0                     MA,
                0                     MC,
                0                     MI,
                0                     MW,
                0                     FA,
                0                     FC,
                0                     FI,
                0                     FW,
                0                     total
         from   hr_all_organization_units haou
         where not exists
         (
            select 'X'
            from   per_za_employment_equity pzee
            where  pzee.level_cat         = l_reason
            and    pzee.report_id         = 'EQ8'
            and    pzee.business_group_id = p_business_group_id  --Bug 4872110
            and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
            and    pzee.disability        = 'Y'
            and    pzee.employment_type   = 'Permanent'
         )
         and haou.business_group_id = p_business_group_id   --Bug 4872110
         and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);


         insert into per_za_employment_equity
         (
            report_id,
            reporting_date,
            business_group_id,
            legal_entity_id,
            legal_entity,
            disability,
            employment_type,
            level_cat_code,
            level_cat,
            MA,
            MC,
            MI,
            MW,
            FA,
            FC,
            FI,
            FW,
            total
         )
         select 'EQ8F'                 report_id,
                p_report_date         reporting_date,
                p_business_group_id   business_group_id,
                haou.organization_id  legal_entity_id,
                haou.name             legal_entity,
                'Y'                   disability,
                'Permanent'           employment_type,
                decode
                (
                   l_reason,
                   'Resignation', 1,
                   'Non-Renewal of Contract', 2,
                   'Dismissal - Operational Requirements', 3,
                   'Dismissal - Misconduct', 4,
                   'Dismissal - Incapacity', 5,
                   'Other', 6,
                   null
                )                     level_cat_code,
               /*decode
               (
                l_reason,
                'Dismissal - Operational Requirements', 'Dismissal - Operational Requirements (Retrenchment)',
                l_reason
               )              level_cat,*/
                l_reason       level_cat,
                0                     MA,
                0                     MC,
                0                     MI,
                0                     MW,
                0                     FA,
                0                     FC,
                0                     FI,
                0                     FW,
                0                     total
         from   hr_all_organization_units haou
         where not exists
         (
            select 'X'
            from   per_za_employment_equity pzee
            where  pzee.level_cat         = l_reason
            and    pzee.report_id         = 'EQ8F'
            and    pzee.business_group_id = p_business_group_id  --Bug 4872110
            and    pzee.legal_entity_id   = nvl(p_legal_entity_id, haou.organization_id)
            and    pzee.disability        = 'Y'
            and    pzee.employment_type   = 'Permanent'
         )
         and haou.business_group_id = p_business_group_id   --Bug 4872110
         and haou.organization_id   = nvl(p_legal_entity_id, haou.organization_id);

      end loop;

      commit;

   end if;

end populate_ee_table_new;

   procedure populate_ee_table_EEWF_new
   (
      p_report_date       in per_all_assignments_f.effective_end_date%type,
      p_business_group_id in per_all_assignments_f.business_group_id%type,
      p_legal_entity_id   in per_assignment_extra_info.aei_information7%type := null
   )  is

   begin
    DELETE FROM per_za_employment_equity
    Where REPORT_ID IN ('EQ2','EQ3','EQ4','EQ5','EQ6','EQ7','EQ8',
                        'EQ2F','EQ3F','EQ4F','EQ5F','EQ6F','EQ7F','EQ8F'
                       );

    populate_ee_table_new (
                       p_report_code       =>'EQ2'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table_new (
                       p_report_code       =>'EQ3'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table_new (
                       p_report_code       =>'EQ4'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table_new (
                       p_report_code       =>'EQ5'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table_new (
                       p_report_code       =>'EQ6'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table_new (
                       p_report_code       =>'EQ7'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

    populate_ee_table_new (
                       p_report_code       =>'EQ8'
                     , p_report_date       =>p_report_date
                     , p_business_group_id =>p_business_group_id
                     , p_legal_entity_id   =>p_legal_entity_id
                       );

      -- Inserts non-associated occupational categories with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select          substr(report_id,1,3),
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
      from   per_za_employment_equity pzee1
      Where  pzee1.business_group_id = p_business_group_id
      AND    pzee1.legal_entity_id = nvl(p_legal_entity_id, pzee1.legal_entity_id)
      AND    pzee1.report_id IN ('EQ1F','EQ2F','EQ3F','EQ4F','EQ5F','EQ6F','EQ7F','EQ8F')
      AND    not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.business_group_id   = pzee1.business_group_id           --Bug 4872110
         AND    pzee.legal_entity_id    = pzee1.legal_entity_id
         AND    pzee.report_id ||'F'     = pzee1.report_id
         AND    pzee1.level_cat_code     = pzee.level_cat_code
         AND    pzee1.level_cat          = pzee.level_cat
         and    nvl(pzee.disability,'X') = nvl(pzee1.disability,'X')
         and    pzee.employment_type     = pzee1.employment_type
      );


      -- Inserts non-associated occupational categories with zero values
      insert into per_za_employment_equity
      (
         report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         MA,
         MC,
         MI,
         MW,
         FA,
         FC,
         FI,
         FW,
         total
      )
      select          report_id||'F' report_id,
         reporting_date,
         business_group_id,
         legal_entity_id,
         legal_entity,
         disability,
         employment_type,
         level_cat_code,
         level_cat,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
      from   per_za_employment_equity pzee1
      Where  pzee1.business_group_id = p_business_group_id
      AND    pzee1.legal_entity_id = nvl(p_legal_entity_id, pzee1.legal_entity_id)
      AND    pzee1.report_id IN ('EQ1','EQ2','EQ3','EQ4','EQ5','EQ6','EQ7','EQ8')
      AND    not exists
      (
         select 'X'
         from   per_za_employment_equity pzee
         where  pzee.business_group_id   = pzee1.business_group_id           --Bug 4872110
         AND    pzee.legal_entity_id    = pzee1.legal_entity_id
         AND    pzee1.report_id ||'F'     = pzee.report_id
         AND    pzee1.level_cat_code     = pzee.level_cat_code
         AND    pzee1.level_cat          = pzee.level_cat
         and    nvl(pzee.disability,'X') = nvl(pzee1.disability,'X')
         and    pzee.employment_type     = pzee1.employment_type
      );

  commit;


   End populate_ee_table_EEWF_new;

end per_za_employment_equity_pkg; -- package body

/
