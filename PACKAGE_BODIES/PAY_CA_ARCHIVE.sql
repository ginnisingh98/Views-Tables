--------------------------------------------------------
--  DDL for Package Body PAY_CA_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_ARCHIVE" as
/* $Header: pycaarch.pkb 120.8.12010000.2 2009/02/04 12:18:04 aneghosh ship $ */
--   /************************************************************************
--
--    Description : Package and procedure to build sql for payroll processes.
--
--    Change List
--    -----------
--    Date         Name        Vers   Bug No   Description
-- -----------  ----------    -----   -------  -----------------------------
-- 05-FEB-2009   aneghosh     115.66  8210261  Modified l_first_day_worked to
--                                             show correct hire date for a
--                                             re-hired employee. Also took
--                                             care of the fix for Bug 6396412
-- 31-OCT-2007   sapalani     115.65  6396412  When previous ROE exists without
--                                             LOA, the next working day after
--					       previous ROE date is made as
--					       first day worked for current ROE.
-- 16-MAR-2006   pganguly     115.64  4361007  The Box 17A will be calculated
--                                             based upon the 'ROE Vacation
--                                             Pay' balance rather than
--                                             'Vacation Paid'.
-- 06-MAR-2006   pganguly     115.63  5013548  Corrected the Box 17C Balance
--                                             name to 'ROE Other Monies
--                                             Sick Leave Credit'.
-- 09-NOV-2005   pganguly     115.62           Added -- in the comments
--                                             section.
-- 07-NOV-2005   pganguly     115.61  4481028  changed cursor cur_paf/cur_gre
--                                             to use date_earned rather than
--                                             effective_date.
-- 30-Apr-2005   ssmukher     115.60  4510534
-- 17-Aug-2005   ssmukher     115.59  4510534  Modified the procedure
--                                             archive_data to include the
--                                             logic for the additional new
--                                             ROE Insurable Earning amounts
--                                             ( 28 to 53 )
-- 08-Aug-2005   ssmukher     115.58  4510534
-- 16-FEB-2005   rigarg       115.57  3919951  Modified procedure get date as
--                                             ROE Date should be LOA/Term Date
-- 16-FEB-2005   rigarg       115.56  3919951  Added condition in action
--                                             creation code to check if
--                                             LOA/Term exists for "ROE by
--                                             Assignment Set"
-- 16-FEB-2005   rigarg       115.55  3919951  Modified procedure get date to
--                                             handle the LOA and Term date
--                                             effective from next day of ROE
--                                             Date.
-- 06-DEC-2004   rigarg       115.54  4030558  Modified derivation of
--                                             l_start_date when asg set is
--                                             passed.
-- 14-OCT-2004   rigarg       115.53  3931182  Modified cursor cur_paf.
-- 08-OCT-2004   rigarg       115.52  3930642  Corrected Get working date call.
-- 07-OCT-2004   rigarg       115.51  3930642  modified call to procedure
--                                             get_ei_amount_totals
--                                             to pass first day worked and
--                                             last pay date for 15A and 15B
--                                             similar to 15C.
-- 07-OCT-2004   rigarg       115.50  3930642  Get Last working Date was called
--                                             being called twice in deriving
--                                             last pay date. This has been
--                                             corrected now.
-- 04-OCT-2004   rigarg       115.49  3923867  Changed to logic to derive 15C
--                                             amounts using first day worked
--                                             and last pay date.
-- 01-OCT-2004   rigarg       115.48  3923912  Removed GSCC Failure.
-- 01-OCT-2004   rigarg       115.47  3923912  Removed Projected End date from
--                                             the cursors.
-- 30-SEP-2004   rigarg       115.46  3919951  Modified cursor cur_absence
--                                             to fetch records before effective
--                                             date.
-- 28-SEP-2004   rigarg       115.45  3898976  Modified cursor cur_paf which
--                                             will now fetch based on previous
--                                             ROE date.
-- 24-SEP-2004   rigarg       115.44  3892425  Added new cursor cur_abs to find
--                                             the first working day depending
--                                             previous ROE. And corrected
--                                             derivation of previous ROE Date
--                                             in the get_balance_start_date.
-- 03-SEP-2004   pganguly     115.43  3824732  Fixed Bug# 3824732. Changed the
--                                             cursor cur_paf so that it uses
--                                             l_effective_date to create the
--                                             assignment actions rather than
--                                             employee's hire date.
-- 12-APR-2004   pganguly     115.41  3556997  Added action_type 'B' in
--                                             cur_latest_aaid.
-- 09-MAR-2004   pganguly     115.39           Change the cursor cur_gre to
--                                             include action_type 'I'. Also
--                                             added one parameter p_bg_id to
--                                             populate_element_table proc.
-- 20-JAN-2004   pganguly     115.38  3353849  Changed the sql which was
--                                             flagged in the Perf Repository.
--                                             Changed the cursor cur_retry
--                                             added pay_payroll_action,pay
--                                             assignment_actions.
-- 20-JAN-2004   pganguly     115.37  3353849  Changed the sql which was
--                                             flagged in the Perf Repository.
--                                             Changed the cursor cur_edor
--                                             added pay_payroll_action,pay
--                                             assignment_actions.
-- 16-JAN-2003   pganguly     115.36  3378568  Fixed Bug# 3378568. Removed the
--                                             400 days check from the cursor
--                                             cur_max_date_start of function
--                                             last_period_of_service.
-- 22-OCT-2003   ssouresr     115.35           The function
--                                             last_period_of_service should be
--                                             called separately when the
--                                             assignment set is not null.
--                                             assignments belonging
--                                             to the assignment set were
--                                             not being archived
-- 03-OCT-2003   ssouresr     115.34           The archiver is modified so that
--                                             ROE is also generated for an
--                                             assignmentthat only has T4A
--                                             earnings. If both T4 and T4A
--                                             earnings exist the archiver
--                                             works as before.
-- 27-SEP-2003   ssouresr     115.33           The archiver is modified so that
--                                             the latest assignment is archived
--                                             for employees that have been
--                                             rehired. Also the latest
--                                             termination date is used as the
--                                             roe effective date.
-- 19-JUN-2003   pganguly     115.32           Changed the cursor cur_17_gres
--                                             so that it looks for T4A/RL2
--                                             GRES as well.
-- 06-JUN-2003   pganguly     115.31           Changed the functionality so
--                                             that ROE will be created for
--                                             employee's in T4 GREs only.
--                                             Box 17A/C earnings reported in
--                                             T4/T4A GREs for the final pay
--                                             period and the pay period after
--                                             that will be reported in the
--                                             first T4 GRE only.
-- 08-MAY-2003   pganguly     115.30  2923942  Changed the function get_dates.
--                                             This now returns a flag 'Y' for
--                                             terminated/loa employees. Added
--                                             a new parameter in the func:
--                                             pay_ca_roe_ei_pkg.
--                                             get_ei_amount_totals
-- 25-APR-2003   pganguly     115.29           For Box 17A/C changed the cond
--                                             intion from <> 0 to = 0 to
--                                             retrieve the latest asg action.
-- 24-MAR-2003   pganguly     115.27           Initialized l_value with 0
--                                             for each 17C Balances.
-- 12-MAR-2003   pganguly     115.26  2842174  In the archive_data proc, added
--                                             l_value := 0 before archiving
--                                             Box 17 Balances.
-- 05-MAR-2003   pganguly     115.24           Removed the to_char call from
--                                             the hr_utility.trace msg for
--                                             Box 17A l_value.
-- 03-MAR-2003   pganguly     115.23  2685760  Added the functionality to
--                                             archive Box 17A/C balances.
--  31-DEC-2002  pganguly     115.22  2732112  Changed the cursor
--                                             cur_asg_set_person_id, added
--                                             a date join while joining
--                                             per_assignments_f. Added no
--                                             copy for GSCC.
--  06-NOV-2002  ssouresr     115.21           Populated tables in archinit to
--                                             improve performance.
--  04-NOV-2002  pganguly     115.20           Fixed 2375610. Changed cursor
--                                             cur_payroll_form so that it
--                                             returns roe_issuer/correspon
--                                             dence_language in the correct
--                                             sequence.
--  20-MAY-2002  pganguly     115.19           Fixed 2325826.
--  07-MAY-2002  pganguly     115.18           Fixed 2325826, 2322306.
--  12-APR-2002  pganguly     115.17           Fixed bug# 2316949, 2311893,
--                                             2300361, 2296898, 2260309
--  05-APR-2002  pganguly     115.16           Commented out hr_utiity.raise
--                                             error in the cur_retry%NOTFound
--  04-APR-2002  pganguly     115.15           Fixed bug# 2296898, 2294049,
--                                             2046740.
--  02-APR-2001  pganguly     115.11           Changed the message numbers
--                                             from 78035,78036 to 74023,74024
--   20-MAR-2001 pganguly     115.10           When calling the
--                                             get_ei_amount_totals function
--                                             added 1 to previuos ROE date
--                                             so that it becomes the start
--                                             date of the next ROE.
--   05-JAN-2000 pganguly     115.9            Commented hr_utility.trace_on
--   27-DEC-2000 pganguly     115.8            Added a check while archiving
--                                             EI Earnings. If BOX15B is
--                                             returned then we archive 0
--                                             in all the places for Box
--                                             15C.
--   26-SEP-2000 pganguly     115.7            Uncommented the exit statement
--                                             and whenever sqlerror/oserror.
--   24-MAY-2000 pganguly     115.5            Corrected the loop count in
--                                             cur_employee_info as
--                                             social_insurance_number
--                                             was archived twice.
--   15-MAY-2000 pganguly     115.4            Corrected the Correspondence
--                                             Language Problem.
--   15-MAY-2000 pganguly     115.3            Changed the message numbers.
--   14-MAY-2000 pganguly     115.2            Added functionalities to
--                                             handle Retry and Amendment.
--                                             Also changed the ROE_PER_
--                                             NATIONAL_IDENTIFIER to
--                                             ROE_PER_SOCIAL_INSURANCE
--                                             NUMBER.
--    19-APR-2000 pganguly    115.1            Fixed Multiple Assignment
--                                             , Employee Address doesn't
--                                             Exists Problem.
--    14-MAR-2000  pganguly   115.0            Changes made for 11i.
--    30-NOV-1999 jgoswami    110.6            Added ROE_TAX_UNIT_CITY
--    30-NOV-1999 jgoswami    110.5            Added ROE_PER_CITY
--    29-NOV-1999 jgoswami    110.4            Changed get_date function added
--                                             parameter p_recall_date.
--                                             Added org_information9 instead
--                                             of tax unit name only.
--                                             Currently
--                                               ROE_PER_TELEPHONE_NUMBER       --                                             value is NULL
--    29-NOV-1999 jgoswami    110.3            change date format to
--                                             DD-MON-YYYY in
--                                             ROE_EXPECTED_DATE_OF_RECALL
--    23-NOV-1999  jgoswami   110.2            Added code for
--                                             Cur_business_number,
--                                             cur_payroll_form,
--                                             cur_recall in get_date function
--                                             cur_archive_info
--                                               - business_group_id
--                                             Code for ROE reason and Comment.
--    04-NOV-1999  pganguly                    Changing the date format.
--    09-AUG-1998  pganguly   110.0           Created.
--
--   ************************************************************************/
--  begin

procedure range_cursor(pactid in number,
                       sqlstr out nocopy varchar2) is
begin
declare
        cursor cur_payroll_actions is
        select
          legislative_parameters
        from
          pay_payroll_actions
        where
          payroll_action_id = pactid;

        l_legislative_parameters  pay_payroll_actions.legislative_parameters%TYPE;
        str                     varchar2(1000);
        l_person_id             per_people_f.person_id%TYPE;
        l_assignment_set_id     pay_payroll_actions.assignment_set_id%TYPE;
        l_assignment_amend      pay_assignment_actions.assignment_action_id%TYPE;

begin
     --  hr_utility.trace_on(null,'ROE');

        open cur_payroll_actions;
        fetch cur_payroll_actions into
          l_legislative_parameters;
        close  cur_payroll_actions;

        hr_utility.trace('l_legislative_parameters= ' || l_legislative_parameters);
        l_person_id :=
          pycadar_pkg.get_parameter('PERSON_ID',l_legislative_parameters);
        l_assignment_set_id :=
          pycadar_pkg.get_parameter('ASSIGNMENT_SET_ID',l_legislative_parameters);
        l_assignment_amend :=
          pycadar_pkg.get_parameter('ASSIGNMENT_ID',l_legislative_parameters);

        hr_utility.trace('PERSON_ID= ' || to_char(l_person_id));
        hr_utility.trace('ASSIGNMENT_SET_ID= ' || to_char(l_assignment_set_id));
        hr_utility.trace('AMEND ASSIGNMENT ACTION ID= ' || to_char(l_assignment_amend));

        if l_assignment_set_id is not null then

           str := 'select
                     distinct paf.person_id
                   from
                     hr_assignment_set_amendments hasa,
                     per_assignments_f paf,
                     pay_payroll_actions ppa
                   WHERE
                     hasa.assignment_set_id =
                       pycadar_pkg.get_parameter(''ASSIGNMENT_SET_ID'',ppa.legislative_parameters) and
                     hasa.include_or_exclude = ''I'' and
                     hasa.assignment_id = paf.assignment_id and
                     ppa.payroll_action_id = :pactid
                  ORDER BY paf.person_id';

           hr_utility.trace('Assignment set id is not null');

        else

          -- For one person only. The person_id will be stored
          -- in the legislative parameter.
          -- The first 10 characters of legislative_parameters
          -- has 'PERSON_ID= '

           str := 'select
             fnd_number.canonical_to_number(substr(legislative_parameters,11,(decode(instr(legislative_parameters,'' ''),0,10,instr(legislative_parameters,'' '')-11))))
           from pay_payroll_actions ppa
           where ppa.payroll_action_id=:pactid';

        end if;

        sqlstr := str;

end;

end range_cursor;

function get_user_entity(p_user_name in varchar2) return number is
begin
declare

        cursor cur_database_items is
        select fdi.user_entity_id
        from   ff_database_items fdi
        where  fdi.user_name = p_user_name;

        l_user_entity_id        ff_database_items.user_entity_id%TYPE;

begin

        open cur_database_items;

        fetch cur_database_items
        into  l_user_entity_id;

        if cur_database_items%notfound then

          close cur_database_items ;
          l_user_entity_id :=  -1;

        else

          close cur_database_items ;

        end if;

        return l_user_entity_id;
end;

end get_user_entity;

function get_working_date(p_business_group_id number,
                          p_asg_id number,
                          p_current_date date,
                          p_next_or_prev varchar2) return date is
begin

declare

  cursor cur_paf is
  select
    puc.user_column_name
  from
    per_assignments_f paf,
    hr_soft_coding_keyflex hsck,
    pay_user_columns puc
  where
    paf.assignment_id = p_asg_id and
    paf.business_group_id = p_business_group_id and
    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id and
    p_current_date between
      paf.effective_start_date and
      paf.effective_end_date and
    hsck.segment4 = puc.user_column_id;

  l_working_date date;
  l_user_column_name     pay_user_columns.user_column_name%TYPE;
  c_ws_tab_name   VARCHAR2(80)    := 'COMPANY WORK SCHEDULES';
  l_hour number := 0;
  v_curr_day varchar2(5);

  cursor cur_hr_org_work is
  select
    hoi.org_information2
  from
    hr_organization_units hou,
    hr_organization_information hoi
  where
    hou.business_group_id = p_business_group_id and
    hou.organization_id = hoi.organization_id and
    hoi.org_information_context = 'Canadian Work Schedule';

begin

  open cur_paf;
  fetch
    cur_paf
  into
    l_user_column_name;

  if cur_paf%NOTFOUND then

    close cur_paf;

    open cur_hr_org_work;
    fetch
      cur_hr_org_work
    into
      l_user_column_name;

    if cur_hr_org_work%NOTFOUND OR
       l_user_column_name IS NULL then

      close cur_hr_org_work;

      if p_next_or_prev = 'N' then
       return p_current_date + 1;
      else
        return p_current_date - 1;
      end if;

    else

       close cur_hr_org_work;

    end if;

  else

    close cur_paf;

  end if;

  if p_next_or_prev = 'N' then
    l_working_date := p_current_date + 1;
  else
    l_working_date := p_current_date - 1;
  end if;

  for i in 1..7 loop

    v_curr_day := to_char(l_working_date,'DY');

    l_hour := fnd_number.canonical_to_number(
                     hruserdt.get_table_value(p_business_group_id,
                                              c_ws_tab_name,
                                              l_user_column_name,
                                              v_curr_day));

   hr_utility.trace('l_hour = ' || to_char(l_hour));

   if l_hour <> 0 then
     exit;
   else
     if p_next_or_prev = 'N' then
       l_working_date := l_working_date + 1;
     else
       l_working_date := l_working_date - 1;
     end if;
   end if;

  end loop;

  hr_utility.trace('l working date = ' || to_char(l_working_date));
  return l_working_date;

end;

end; -- get_working_date

function get_defined_balance_id(p_balance_name      in varchar2,
                                p_dimension_name    in varchar2,
                                p_business_group_id in number)
         return number is
begin

declare

  cursor cur_get_def_bal_id is
  select
    pdb.defined_balance_id
  from
    pay_defined_balances pdb,
    pay_balance_types pbt,
    pay_balance_dimensions pbd1
  where
    pbt.balance_name = p_balance_name and
    pbt.business_group_id is null and
    pbt.legislation_code = 'CA' and
    pbt.balance_type_id = pdb.balance_type_id and
    pdb.balance_dimension_id = pbd1.balance_dimension_id and
    pbd1.dimension_name = p_dimension_name and
    pbd1.business_group_id is null and
    pbd1.legislation_code = 'CA';

  l_def_balance_id            pay_defined_balances.defined_balance_id%TYPE;

begin

  hr_utility.trace('Function get_defined_balance_id starts here !');

  open cur_get_def_bal_id;
  fetch cur_get_def_bal_id
  into l_def_balance_id;
  if cur_get_def_bal_id%NOTFOUND then
    close cur_get_def_bal_id;
    hr_utility.trace('get_defined_balance_id: Defined balance not found!');
    return -1;
  else
    close cur_get_def_bal_id;
    hr_utility.trace('get_defined_balance_id: Defined balance found = ' ||
                                              to_char(l_def_balance_id));
    return l_def_balance_id;
  end if;

end;

end get_defined_balance_id;

function balance_feed_exists(p_balance_name in varchar2,
                             p_business_group_id in number)
         return BOOLEAN is
begin

declare

  CURSOR cur_bal_feed_exists IS
  SELECT
    'X'
  FROM
    pay_balance_feeds_f pbf,
    pay_balance_types pbt,
    pay_input_values_f piv,
    pay_element_types_f pet
  WHERE
    pbt.balance_name = p_balance_name and
    pbt.business_group_id is NULL and
    pbf.balance_type_id = pbt.balance_type_id and
    pbf.input_value_id = piv.input_value_id and
    piv.element_type_id = pet.element_type_id;
    --pbt.balance_type_id = pet.element_information10;

  dummy    varchar2(1);

begin

  hr_utility.trace('Function balance_feed_exists');
  hr_utility.trace('balance_feed_exists p_balance_name = ' || p_balance_name);

  OPEN cur_bal_feed_exists;
  FETCH cur_bal_feed_exists
  INTO dummy;
  if cur_bal_feed_exists%FOUND then
    close cur_bal_feed_exists;
    hr_utility.trace('balance_feed_exists for = ' || p_balance_name);
    return TRUE;
  else
    close cur_bal_feed_exists;
    hr_utility.trace('Balance Feed doesn''t exist for = ' || p_balance_name);
    return FALSE;
  end if;

end;

end balance_feed_exists; -- balance_feed_exists


function get_date(p_person_id in number,
                  p_asg_id    in  number,
                  p_business_group_id in number,
                  p_effective_date in date,
                  p_recall_date out nocopy date,
                  p_roe_reason  out nocopy varchar2,
                  p_roe_comment out nocopy varchar2,
                  p_term_or_abs_flag out nocopy varchar2,
                  p_term_or_abs      out nocopy varchar2
                  ) return date is
begin

declare

        cursor cur_terminate is
        select pps.actual_termination_date      termination_date,
               NULL                    recall_date,
               pps.pds_information1     roe_reason,
               pps.pds_information2     roe_comment,
               pps.date_start
        from   per_periods_of_service pps
        where  pps.person_id=p_person_id
        and    pps.business_group_id = p_business_group_id
        and    p_effective_date - nvl(pps.actual_termination_date,p_effective_date) <= 31
        and    pps.date_start  <=  p_effective_date
        and    pps.actual_termination_date <= p_effective_date
        order by pps.date_start desc;

        cursor cur_absence(cp_effective_date   date) is
        select paav.date_start          date_start,
               paav.date_end            recall_date,
               paav.abs_information1    roe_reason,
               paav.abs_information2    roe_comment
        from   per_absence_attendances_v        paav
        where  paav.person_id=p_person_id
        and    paav.business_group_id = p_business_group_id
        and    paav.date_start <= cp_effective_date
        and    p_effective_date - paav.date_start <= 31;

        l_termination_date      date;
        l_absence_date          date;
        l_recall_date           date;
        l_date_start            date;
        l_roe_reason            varchar2(150);
        l_roe_comment           varchar2(150);
	l_effective_date        date;

begin
        hr_utility.trace('before terminate'||to_char(p_effective_date));
        open cur_terminate;

        fetch cur_terminate
        into  l_termination_date,
              l_recall_date,
              l_roe_reason,
              l_roe_comment,
              l_date_start;

        if l_termination_date is null or
           cur_terminate%notfound then

           close cur_terminate;

           hr_utility.trace('Cur terminate not found');

	   l_effective_date := get_working_date(p_business_group_id,
                                                p_asg_id,
                                                p_effective_date,
                                                'N');

           open cur_absence(l_effective_date);

           fetch cur_absence
           into  l_absence_date,
                 l_recall_date,
                 l_roe_reason,
                 l_roe_comment;

           if cur_absence%notfound
           or l_absence_date is null then

           hr_utility.trace('Cur absence not found');
             close cur_absence;
             p_recall_date := l_recall_date;
             p_roe_reason := l_roe_reason;
             p_roe_comment := l_roe_comment;
             p_term_or_abs_flag := 'N';
             p_term_or_abs      := NULL;
             return p_effective_date;

          else

             hr_utility.trace('Cur absence found');
             close cur_absence;
             p_recall_date := l_recall_date;
             p_roe_reason := l_roe_reason;
             p_roe_comment := l_roe_comment;
             p_term_or_abs_flag := 'Y';
             p_term_or_abs      := 'A';
             hr_utility.trace('l_absence_date: '||to_char(l_absence_date));

             return l_absence_date;

          end if;

        else

           p_recall_date := l_recall_date;
           p_roe_reason := l_roe_reason;
           p_roe_comment := l_roe_comment;
           p_term_or_abs_flag := 'Y';
           p_term_or_abs      := 'T';
           hr_utility.trace('.....in terminate...else..');
           close cur_terminate;
           return l_termination_date;

        end if;

end;

end get_date;

function get_balance_start_date(p_person_id     in number,
                                p_effective_date        in date)
                           return date is
begin

declare

        cursor  cur_aaid is
        select  paa.assignment_action_id
        from    pay_assignment_actions  paa,
                pay_payroll_actions     ppa,
                per_assignments_f       paf
        where   paf.person_id           = p_person_id
        and     paf.assignment_id       = paa.assignment_id
        and     paa.payroll_action_id   = ppa.payroll_action_id
        and     ppa.action_type         = 'X'
        and     ppa.action_status       = 'C'
        and     ppa.effective_date      < p_effective_date
        and     ppa.report_type         = 'ROE'
        order by ppa.effective_date desc;

        cursor  cur_dates (b_assignment_action_id    number) is
        select  fnd_date.canonical_to_date(fai.value)
        from    ff_archive_items   fai,
                ff_database_items  fdi
        where   fai.user_entity_id = fdi.user_entity_id
        and     fdi.user_name = 'ROE_DATE'
        and     fai.context1 = to_char(b_assignment_action_id);

        l_ass_act_id       number(15);
        l_start_date       date;

begin

        open    cur_aaid;
        fetch   cur_aaid
        into    l_ass_act_id;
        close   cur_aaid;

        open    cur_dates(l_ass_act_id);
        fetch   cur_dates
        into    l_start_date;

        if cur_dates%notfound then
          close cur_dates;
          return null;
        else
          close cur_dates;
          return l_start_date;
        end if;
end;

end get_balance_start_date;

procedure populate_box17c_bal_table is
begin

declare

begin

  pay_ca_archive.box17c_bal_table(1).code := 'A';
  pay_ca_archive.box17c_bal_table(1).balance_name
        := 'ROE Other Monies Anniversary Payout';

  pay_ca_archive.box17c_bal_table(2).code := 'B';
  pay_ca_archive.box17c_bal_table(2).balance_name
        := 'ROE Other Monies Bonus';

  pay_ca_archive.box17c_bal_table(3).code := 'E';
  pay_ca_archive.box17c_bal_table(3).balance_name
        := 'ROE Other Monies  Severance Pay';

  pay_ca_archive.box17c_bal_table(4).code := 'G';
  pay_ca_archive.box17c_bal_table(4).balance_name
        := 'ROE Other Monies  Gratuities';

  pay_ca_archive.box17c_bal_table(5).code := 'H';
  pay_ca_archive.box17c_bal_table(5).balance_name
        := 'ROE Other Monies Honorariums';

  pay_ca_archive.box17c_bal_table(6).code := 'I';
  pay_ca_archive.box17c_bal_table(6).balance_name
       := 'ROE Other Monies  Sick Leave Credit';

  pay_ca_archive.box17c_bal_table(7).code := 'N';
  pay_ca_archive.box17c_bal_table(7).balance_name
       := 'ROE Other Monies  Pensions';

  pay_ca_archive.box17c_bal_table(8).code := 'O';
  pay_ca_archive.box17c_bal_table(8).balance_name
       := 'ROE Other Monies Other';

  pay_ca_archive.box17c_bal_table(9).code := 'R';
  pay_ca_archive.box17c_bal_table(9).balance_name
       := 'ROE Other Monies  Retirement Leave Credits';

  pay_ca_archive.box17c_bal_table(10).code := 'S';
  pay_ca_archive.box17c_bal_table(10).balance_name
       := 'ROE Other Monies Settlement or Labour Arb Award';

  pay_ca_archive.box17c_bal_table(11).code := 'U';
  pay_ca_archive.box17c_bal_table(11).balance_name
       := 'ROE Other Monies Supplementary Unemployment Benefits';

  pay_ca_archive.box17c_bal_table(12).code := 'Y';
  pay_ca_archive.box17c_bal_table(12).balance_name
       := 'ROE Other  Monies Pay in Lieu of Notice';

end;

end; -- populate_box17c_bal_table;

procedure archinit(p_payroll_action_id in number) is
begin

DECLARE

  CURSOR cur_bg_id IS
  SELECT
    business_group_id
  FROM
    pay_payroll_actions
  WHERE
    payroll_action_id = p_payroll_action_id;

  l_bg_id   per_business_groups.business_group_id%TYPE;

BEGIN

  OPEN cur_bg_id;
  FETCH cur_bg_id
  INTO l_bg_id;
  CLOSE cur_bg_id;

  hr_utility.trace('Archive initialization');
  pay_ca_roe_ei_pkg.populate_element_table(l_bg_id);
  populate_box17c_bal_table;

END;

end archinit;

function archive_value(p_assactid in number,
                       p_user_name in varchar2) return varchar2 is

begin

declare

  cursor cur_archive_value is
  select fai.value
  from   ff_archive_items       fai,
         ff_database_items      fdi
  where  fdi.user_name      = p_user_name
  and    fdi.user_entity_id = fai.user_entity_id
  and    fai.context1       = p_assactid;

  l_value               ff_archive_items.value%type;

begin

  open  cur_archive_value;

  fetch cur_archive_value
  into  l_value;

  close cur_archive_value;

  return l_value;

end;

end;

procedure action_creation(pactid in number,
                       stperson in number,
                       endperson in number,
                       chunk in number) is
begin
declare

  cursor cur_payroll_actions is
  select
    legislative_parameters,
    effective_date,
    business_group_id
  from
    pay_payroll_actions
  where
    payroll_action_id = pactid;

  l_start_date    DATE;

  l_legislative_parameters pay_payroll_actions.legislative_parameters%TYPE;
  str                   varchar2(1000);
  l_person_id           per_people_f.person_id%type;
  l_assignment_set_id   pay_payroll_actions.assignment_set_id%type;
  l_effective_date      pay_payroll_actions.effective_date%type;
  l_effective_date1     pay_payroll_actions.effective_date%type;
  l_business_group_id   pay_payroll_actions.business_group_id%type;
  l_assignment_amend    pay_assignment_actions.assignment_action_id%TYPE;

  cursor cur_asg_set_person_id is
  select
    distinct paf.person_id person_id
  from
    hr_assignment_set_amendments hasa,
    per_assignments_f paf
  WHERE
    hasa.assignment_set_id = l_assignment_set_id and
    hasa.include_or_exclude = 'I' and
    hasa.assignment_id = paf.assignment_id and
    least(l_effective_date,paf.effective_end_date) between
      paf.effective_start_date and
      paf.effective_end_date;

  cursor cur_paf(b_person_id     per_people_f.person_id%type,
                 b_start_date    DATE,
                 b_end_date      DATE)
  is select
    paf.assignment_id   assignment_id,
    paf.payroll_id      payroll_id
  from
    per_assignments_f paf
  where
    paf.person_id = b_person_id
    and paf.person_id >= stperson
    and paf.person_id <= endperson
    and paf.assignment_type in ('E','C')
    and (paf.effective_end_date >= b_end_date
        or trunc(paf.effective_end_date) = hr_general.END_OF_TIME
        )
    and paf.effective_start_date <= b_start_date
  group by
    paf.assignment_id,
    paf.payroll_id;

  cursor cur_gre(p_assignment_id per_assignments_f.assignment_id%type,
                 p_payroll_id     per_assignments_f.payroll_id%type,
                 p_effective_date date) is
  select
    distinct paa.tax_unit_id    gre_id,
             'T4'               gre_type
  from
    pay_assignment_actions paa,
    pay_payroll_actions    ppa,
    hr_organization_information hoi
  where
    paa.assignment_id = p_assignment_id and
    ppa.payroll_action_id = paa.payroll_action_id and
    ppa.payroll_id = p_payroll_id and
    ppa.action_type in ( 'R','B','F','R','Q','I') and
    ppa.action_status = 'C' and
    p_effective_date - 400 <= ppa.date_earned and
    ppa.date_earned <=  p_effective_date and
    hoi.organization_id = paa.tax_unit_id and
    hoi.org_information_context = 'Canada Employer Identification' and
    hoi.org_information5 = 'T4/RL1'
  union all
  select
    distinct paa.tax_unit_id    gre_id,
             'T4A'              gre_type
  from
    pay_assignment_actions paa,
    pay_payroll_actions    ppa,
    hr_organization_information hoi
  where
    paa.assignment_id = p_assignment_id and
    ppa.payroll_action_id = paa.payroll_action_id and
    ppa.payroll_id = p_payroll_id and
    ppa.action_type in ( 'R','B','F','R','Q') and
    ppa.action_status = 'C' and
    p_effective_date - 400 <= ppa.date_earned and
    ppa.date_earned <=  p_effective_date and
    hoi.organization_id = paa.tax_unit_id and
    hoi.org_information_context = 'Canada Employer Identification' and
    hoi.org_information5 in ('T4A/RL1','T4A/RL2') and
    not exists
        (select 1
         from
           pay_assignment_actions paa_t4,
           pay_payroll_actions    ppa_t4,
           hr_organization_information hoi_t4
         where
           paa_t4.assignment_id = p_assignment_id and
           ppa_t4.payroll_action_id = paa_t4.payroll_action_id and
           ppa_t4.payroll_id = p_payroll_id and
           ppa_t4.action_type in ( 'R','B','F','R','Q') and
           ppa_t4.action_status = 'C' and
           p_effective_date - 400 <= ppa_t4.date_earned and
           ppa_t4.date_earned <=  p_effective_date and
           hoi_t4.organization_id = paa_t4.tax_unit_id and
           hoi_t4.org_information_context = 'Canada Employer Identification' and
           hoi_t4.org_information5 = 'T4/RL1');

  cursor cur_asg_action_id is
  select
    pay_assignment_actions_s.nextval
  from
    dual;

  cursor cur_prd_end_date(p_payroll_id number,
                          p_date date) is
  select
    ptp.end_date
  from
    per_time_periods ptp
  where
    ptp.payroll_id = p_payroll_id and
    p_date between
      ptp.start_date and ptp.end_date;

  l_lockingactid                number;
  l_assignment_id               number;
  l_tax_unit_id                 number;
  l_value                       ff_archive_items.value%type;
  l_user_entity_id              ff_user_entities.user_entity_id%type;
  l_archive_item_id             ff_archive_items.archive_item_id%type;
  l_object_version_number       number(9);
  l_some_warning                boolean;
  l_prev_roe_date               date;
  l_roe_date                    date;
  total_no_fields               number;
  l_recall_date                 date;
  l_roe_reason                  varchar2(150);
  l_roe_comment                 varchar2(150);
  l_end_date                    date;
  l_date_start                  date;

  TYPE tab_char240 is table of varchar2(240)
                        index by binary_integer;
  TYPE tab_num9 is table of number(9)
                        index by binary_integer;

  l_user_entity_amend           tab_num9;
  l_value_amend                 tab_char240;
  l_term_or_abs_flag            varchar2(1);
  l_term_or_abs                 varchar2(1);
  l_first_t4_gre                varchar2(1);
  multiple_gre                  boolean := FALSE;

  cursor cur_employee_hire_date is
  select max(service.date_start)        hire_date
  from   per_periods_of_service service,
         per_assignments_f asg
--  where  asg.assignment_id = l_assignment_id
  where  asg.person_id = l_person_id
  and    l_effective_date BETWEEN
           asg.effective_start_date
           AND asg.effective_end_date
  and    asg.person_id     = service.person_id(+)
  and    service.date_start <= l_effective_date;

  cursor cur_abs ( b_person_id     number,
                   b_date_start    date) is
  select abs.date_end date_end
  from   per_absence_attendances  abs
  where  abs.person_id     = b_person_id
  and    abs.date_start    = b_date_start;

  /* FUNCTION last_period_of_service (p_effective_date    date,
                                   p_person_id         number,
                                   p_business_group_id number)
  RETURN DATE IS
  BEGIN
  DECLARE

    l_date_start date;

    CURSOR cur_max_date_start IS
    SELECT max(date_start)
    FROM per_periods_of_service
    WHERE person_id = p_person_id
    AND   business_group_id = p_business_group_id
    AND   date_start <= p_effective_date;
    --AND   date_start >= p_effective_date - 400;

    BEGIN

       OPEN cur_max_date_start;
       FETCH cur_max_date_start INTO l_date_start;
       CLOSE cur_max_date_start;

       RETURN l_date_start;
    END;

  END; */

  FUNCTION check_retry_amend(p_person_id     number,
                            p_assignment_id number,
                            p_payroll_id    number,
                            p_gre_id        number,
                            p_roe_date      date) RETURN BOOLEAN IS
  begin

  declare

    v_assignment_id     number;
    v_payroll_id        number;
    v_gre_id            number;
    v_roe_date          number;

  cursor cur_retry is
  select
    paa.assignment_action_id locked_action_id
  from
    pay_payroll_actions ppa,
    pay_assignment_actions paa,
    ff_archive_items fai1,
    ff_archive_items fai2
  where
    ppa.report_type = 'ROE' and
    ppa.report_category = 'ROEC' and
    ppa.report_qualifier = 'ROEQ' and
    ppa.payroll_action_id = paa.payroll_action_id and
    paa.tax_unit_id = p_gre_id and
    paa.assignment_id = p_assignment_id and
    paa.assignment_action_id = fai1.context1 and
    fai1.user_entity_id =  v_roe_date and
    fnd_date.canonical_to_date(fai1.value) =
    fnd_date.canonical_to_date(to_char(p_roe_date,'yyyy/mm/dd hh24:mi:ss')) and
    fai1.context1 = fai2.context1 and
    fai2.user_entity_id = v_payroll_id and
    fai2.value = to_char(p_payroll_id);

  l_context1    number;
  dummy         varchar2(1);


  cursor cur_amend is
  select
    'x'
  from
    pay_action_interlocks
   where
     locked_action_id = l_context1;

  cursor cur_ppf is
  select
    full_name
  from
    per_people_f ppf
   where
    ppf.person_id = p_person_id and
    p_roe_date between ppf.effective_start_date and
      ppf.effective_end_date;

   l_full_name          per_people_f.full_name%TYPE;

   begin

   v_assignment_id :=   get_user_entity('ROE_ASSIGNMENT_ID');
   v_payroll_id    :=   get_user_entity('ROE_PAYROLL_ID');
   v_gre_id       := get_user_entity('ROE_GRE_ID');
   v_roe_date   := get_user_entity('ROE_DATE');

   open cur_ppf;
   fetch cur_ppf into l_full_name;
   close cur_ppf;

   hr_utility.set_location('check_retry_amend' , 5);
   open cur_retry;
   fetch cur_retry into l_context1;

   if (cur_retry%FOUND) then

     hr_utility.set_location('check_retry_amend' , 7);
     hr_utility.trace('l_context1 = '|| to_char(l_context1));
     close cur_retry;
     open cur_amend;
     fetch cur_amend into dummy;
     if cur_amend%FOUND then

       -- Record has already been locked by Mag Process.
       -- So it is an amend issue.

       close cur_amend;

       hr_utility.set_location('pay_ca_archive.cur_amend', 10);

       hr_utility.set_message(801,'PAY_74024_ROE_AMEND_RECORD');
       hr_utility.set_message_token('PERSON',l_full_name);
       --hr_utility.raise_error;
       RETURN FALSE;
     else
       close cur_amend;

       -- Record not found, so it is a
       -- Retry Issue

       hr_utility.set_location('pay_ca_archive.cur_amend', 20);
       hr_utility.set_message(801,'PAY_74023_ROE_RETRY_RECORD');
       hr_utility.set_message_token('PERSON',l_full_name);
       --hr_utility.raise_error;
       RETURN FALSE;

     end if;

   else

     close cur_retry;
     hr_utility.set_location('pay_ca_archive.cur_retry', 10);
     RETURN TRUE;

   end if;

  end;

  end;  -- End check_retry_amend

begin

  hr_utility.set_location('Package pay_ca_archive...action creation',1);

  open cur_payroll_actions;
  fetch cur_payroll_actions
  into
    l_legislative_parameters,
    l_effective_date,
    l_business_group_id;
  close  cur_payroll_actions;

  l_person_id :=
    pycadar_pkg.get_parameter('PERSON_ID',l_legislative_parameters);
  l_assignment_set_id :=
    pycadar_pkg.get_parameter('ASSIGNMENT_SET_ID',l_legislative_parameters);
  l_assignment_amend :=
    pycadar_pkg.get_parameter('ASSIGNMENT_ID',l_legislative_parameters);
  l_end_date := l_effective_date;

  hr_utility.trace('l_legislative_parameters '|| l_legislative_parameters);
  hr_utility.trace('Person ID = '|| to_char(l_person_id));
  hr_utility.trace('ASSIGNMENT_SET_ID= ' || to_char(l_assignment_set_id));
  hr_utility.trace('AMEND ASSIGNMENT ACTION ID= ' ||
                    to_char(l_assignment_amend));

  if l_assignment_set_id is null then

  -- Find the latest hire date of employee
  -- so that assignments that existed previous
  -- to this date are not archived

  /* l_date_start :=
    last_period_of_service (l_effective_date,
                            l_person_id,
                            l_business_group_id);

  hr_utility.trace('l_date_start = ' ||to_char(l_date_start)); */

  -- If assignment_set_id is null then the
  -- archiver is running for one person, the id of
  -- the person is stored in legislative_parameters.

  -- l_effective_date is stored in l_end_date before
  -- get_date is called as l_effective_date may be changed
  -- to termination_date or absence_date after calling
  -- get_date function.

  l_effective_date := get_date(l_person_id,
                               l_assignment_id,
                               l_business_group_id,
                               l_effective_date,
                               l_recall_date,
                               l_roe_reason,
                               l_roe_comment,
                               l_term_or_abs_flag,
                               l_term_or_abs);
  hr_utility.trace('l_effective_date: '||to_char(l_effective_date));

  l_roe_date   := l_effective_date;

  l_prev_roe_date := get_balance_start_date(l_person_id,
                                                 l_effective_date);


  if l_assignment_amend is not null then

    open cur_asg_action_id;
    fetch cur_asg_action_id into l_lockingactid;
    if cur_asg_action_id%NOTFOUND then
      close cur_asg_action_id;
      hr_utility.trace('Locking action id not found');
    else
      close cur_asg_action_id;
      hr_utility.trace('Locking action id found');
    end if;

    l_user_entity_amend(1) := get_user_entity('ROE_ASSIGNMENT_ID');
    l_value_amend(1) := archive_value(l_assignment_amend,'ROE_ASSIGNMENT_ID');

    l_user_entity_amend(2) := get_user_entity('ROE_PAYROLL_ID');
    l_value_amend(2) := archive_value(l_assignment_amend,'ROE_PAYROLL_ID');

    l_user_entity_amend(3) := get_user_entity('ROE_GRE_ID');
    l_value_amend(3) := archive_value(l_assignment_amend,'ROE_GRE_ID');

    l_user_entity_amend(4) := get_user_entity('PREV_ROE_DATE');
    l_value_amend(4) := archive_value(l_assignment_amend,'PREV_ROE_DATE');

    l_user_entity_amend(5) := get_user_entity('ROE_DATE');
    l_value_amend(5) := archive_value(l_assignment_amend,'ROE_DATE');

    hr_utility.trace('l_value_amend(1)'||l_value_amend(1));
    hr_utility.trace('l_value_amend(2)'||l_value_amend(2));
    hr_utility.trace('l_value_amend(3)'||l_value_amend(3));

    hr_nonrun_asact.insact(l_lockingactid,
        l_value_amend(1),
        pactid,
        chunk,
        l_value_amend(3)
        );

    total_no_fields := 5;

    for j in 1..total_no_fields loop

      ff_archive_api.create_archive_item(
            p_archive_item_id   => l_archive_item_id,
            p_user_entity_id    => l_user_entity_amend(j),
            p_archive_value     => l_value_amend(j),
            p_archive_type      => 'AAC',
            p_action_id         => l_lockingactid,
            p_legislation_code  => 'CA',
            p_object_version_number => l_object_version_number,
            p_some_warning              => l_some_warning);

    end loop;  -- tot_no_fields

  else

    l_start_date := get_balance_start_date(l_person_id, l_effective_date);

    IF l_start_date is NOT NULL THEN
      open cur_abs(l_person_id, l_start_date);
      fetch cur_abs into l_start_date;
      close cur_abs;
      if l_start_date is not null then
         l_start_date  := get_working_date(l_business_group_id,
                                           l_assignment_id,
                                           l_start_date,
                                           'N');
      else
         open cur_employee_hire_date;
         fetch cur_employee_hire_date
         into  l_start_date;
         close cur_employee_hire_date;
      end if;
      l_start_date  := GREATEST(l_start_date, l_effective_date - 400);
    ELSE
      l_start_date := l_effective_date - 400;
    END IF;

    hr_utility.trace('l_person_id = '|| l_person_id);
    hr_utility.trace('l_start_date = '|| l_start_date);
    hr_utility.trace('l_effective_date = '|| l_effective_date);

    for i in cur_paf(l_person_id, l_effective_date, l_start_date) loop

      hr_utility.trace('I.assignment ID = '|| to_char(i.assignment_id));
      hr_utility.trace('I.payroll ID = '|| to_char(i.payroll_id));
      hr_utility.set_location('Get the locking action id', 1);

      open cur_prd_end_date(i.payroll_id,
                            l_roe_date);
      fetch cur_prd_end_date
      into l_effective_date1;
      close cur_prd_end_date;

      hr_utility.trace('l_effective_date1 = '|| to_char(l_effective_date1));

      l_first_t4_gre := 'Y';

      for k in cur_gre(i.assignment_id,i.payroll_id,l_effective_date1) loop

        hr_utility.trace('k.GRE ID = '|| to_char(k.gre_id));
        hr_utility.trace('k.GRE TYPE = '|| k.gre_type);

          if (k.gre_type = 'T4' and l_first_t4_gre = 'Y') then
               multiple_gre   := TRUE;
               l_first_t4_gre := 'N';
          else
            multiple_gre := FALSE;
          end if;

        open cur_asg_action_id;
        fetch cur_asg_action_id into l_lockingactid;
        if cur_asg_action_id%NOTFOUND then
           close cur_asg_action_id;
           hr_utility.trace('Locking action id not found');
         else
           close cur_asg_action_id;
           hr_utility.trace('Locking action id found');
         end if;

         hr_nonrun_asact.insact(l_lockingactid,i.assignment_id,
                pactid,chunk,k.gre_id);

          IF multiple_gre THEN
             update pay_assignment_actions
             set
               serial_number = 'Y'
             where
               assignment_action_id = l_lockingactid;
          END IF;

         -- This portion of the code checks for Record already
         -- Exists or not. If Exists then we need to error out
         -- the assignment.
         --
         -- If Record already exists and isn't locked by Mag
         -- Process then we need to pass a error message saying
         -- the retry process should be tried for this assignment.
         --
         -- If it is locked by Mag process then we error out saying
         -- user need to amend the assignment.

          hr_utility.trace('Date: '||to_char(l_roe_date));

          if check_retry_amend(l_person_id,
                          i.assignment_id,
                          i.payroll_id,
                          k.gre_id,
                          l_roe_date) then

          -- The GRE, payroll,assignment_id will be archived
          -- in the action creation level. The archive_type
          -- flag in the pay_report_format_items will have ACC
          -- The start_date and end_date is also archived
          -- in the assignment_action creation level

             total_no_fields := 5;

             hr_utility.trace('GRE ID = '|| to_char(k.gre_id));

             for j in 1..total_no_fields loop

               if j = 1 then
                 l_value := i.assignment_id;
                 l_user_entity_id := get_user_entity('ROE_ASSIGNMENT_ID');
               elsif j = 2 then
                 l_value := i.payroll_id;
                 l_user_entity_id := get_user_entity('ROE_PAYROLL_ID');
               elsif j = 3 then
                 l_value := k.gre_id;
                 l_user_entity_id := get_user_entity('ROE_GRE_ID');
               elsif j = 4 then
                 l_value := to_char(l_prev_roe_date,'YYYY/MM/DD HH24:MI:SS');
                 l_user_entity_id := get_user_entity('PREV_ROE_DATE');
               elsif j = 5 then
                 l_value := to_char(l_roe_date,'YYYY/MM/DD HH24:MI:SS');
                 l_user_entity_id := get_user_entity('ROE_DATE');
               end if;

               ff_archive_api.create_archive_item(
                    p_archive_item_id   => l_archive_item_id,
                    p_user_entity_id    => l_user_entity_id,
                    p_archive_value             => l_value,
                    p_archive_type              => 'AAC',
                    p_action_id         => l_lockingactid,
                    p_legislation_code  => 'CA',
                    p_object_version_number => l_object_version_number,
                    p_some_warning              => l_some_warning);

               end loop;  -- tot_no_fields

            end if; -- check_retry_amend

            end loop;  -- cur_gre

            end loop;   -- cur_paf

          end if; -- End if (l_assignment_amend)

        else

          for p_id in cur_asg_set_person_id loop

          l_person_id := p_id.person_id;

          -- Find the latest hire date of employee
          -- so that assignments that existed previous
          -- to this date are not archived

          /* l_date_start :=
            last_period_of_service (l_end_date,
                                    l_person_id,
                                    l_business_group_id);

          hr_utility.trace('l_date_start = ' ||to_char(l_date_start)); */

          l_effective_date := get_date(l_person_id,
                                       l_assignment_id,
                                       l_business_group_id,
                                       l_end_date,
                                       l_recall_date,
                                       l_roe_reason,
                                       l_roe_comment,
                                       l_term_or_abs_flag,
                                       l_term_or_abs);
          hr_utility.trace('l_effective_date: '||to_char(l_effective_date));
          hr_utility.trace('l_end_date: '||to_char(l_end_date));

          l_roe_date   := l_effective_date;

          l_prev_roe_date := get_balance_start_date(l_person_id,
                                                 l_effective_date);


          l_start_date := l_prev_roe_date;


          IF l_start_date is NOT NULL THEN
             open cur_abs(l_person_id, l_start_date);
             fetch cur_abs into l_start_date;
             close cur_abs;
             if l_start_date is not null then
                l_start_date  := get_working_date(l_business_group_id,
                                                  l_assignment_id,
                                                  l_start_date,
                                                 'N');
             else
                open cur_employee_hire_date;
                fetch cur_employee_hire_date
                into  l_start_date;
                close cur_employee_hire_date;
             end if;
             l_start_date  := GREATEST(l_start_date, l_effective_date - 400);
          ELSE
             l_start_date := l_effective_date - 400;
          END IF;

          hr_utility.trace('l_person_id = '|| l_person_id);
          hr_utility.trace('l_start_date = '|| l_start_date);
          hr_utility.trace('l_effective_date = '|| l_effective_date);

     if l_term_or_abs in ('A','T') then
       for i in cur_paf(l_person_id, l_effective_date, l_start_date) loop

          hr_utility.trace('I.assignment ID = '|| to_char(i.assignment_id));
          hr_utility.trace('I.payroll ID = '|| to_char(i.payroll_id));
          hr_utility.set_location('Get the locking action id', 1);

          open cur_prd_end_date(i.payroll_id,
                                l_roe_date);
          fetch cur_prd_end_date
          into l_effective_date1;
          close cur_prd_end_date;

          hr_utility.trace('l_effective_date1 = '|| to_char(l_effective_date1));

          l_first_t4_gre := 'Y';

          for k in cur_gre(i.assignment_id,i.payroll_id,l_effective_date1) loop

          hr_utility.trace('k.GRE ID = '|| to_char(k.gre_id));
          hr_utility.trace('k.GRE TYPE = '|| k.gre_type);

          if (k.gre_type = 'T4' and l_first_t4_gre = 'Y') then
            multiple_gre   := TRUE;
            l_first_t4_gre := 'N';
          else
            multiple_gre := FALSE;
          end if;

          open cur_asg_action_id;
          fetch cur_asg_action_id into l_lockingactid;
          if cur_asg_action_id%NOTFOUND then
            close cur_asg_action_id;
            hr_utility.trace('Locking action id not found');
          else
            close cur_asg_action_id;
            hr_utility.trace('Locking action id found');
          end if;


          hr_nonrun_asact.insact(l_lockingactid,i.assignment_id,
             pactid,chunk,k.gre_id);

          IF multiple_gre THEN
             update pay_assignment_actions
             set
               serial_number = 'Y'
             where
               assignment_action_id = l_lockingactid;
          END IF;

          -- This portion of the code checks for Record already
          -- Exists or not. If Exists then we need to error out
          -- the assignment.
          --
          -- If Record already exists and isn't locked by Mag
          -- Process then we need to pass a error message saying
          -- the retry process should be tried for this assignment.
          --
          -- If it is locked by Mag process then we error out saying
          -- user need to amend the assignment.

          hr_utility.trace('Date: '||to_char(l_roe_date));

          if check_retry_amend(l_person_id,
                            i.assignment_id,
                            i.payroll_id,
                            k.gre_id,
                            l_roe_date) then

           -- The GRE, payroll,assignment_id will be archived
           -- in the action creation level. The archive_type
           -- flag in the pay_report_format_items will have ACC
           -- The start_date and end_date is also archived
           -- in the assignment_action creation level

           total_no_fields := 5;

           hr_utility.trace('GRE ID = '|| to_char(k.gre_id));

           for j in 1..total_no_fields loop

           if j = 1 then
             l_value := i.assignment_id;
             l_user_entity_id := get_user_entity('ROE_ASSIGNMENT_ID');
           elsif j = 2 then
             l_value := i.payroll_id;
             l_user_entity_id := get_user_entity('ROE_PAYROLL_ID');
           elsif j = 3 then
             l_value := k.gre_id;
             l_user_entity_id := get_user_entity('ROE_GRE_ID');
           elsif j = 4 then
             l_value := to_char(l_prev_roe_date,'YYYY/MM/DD HH24:MI:SS');
             l_user_entity_id := get_user_entity('PREV_ROE_DATE');
           elsif j = 5 then
             l_value := to_char(l_roe_date,'YYYY/MM/DD HH24:MI:SS');
             l_user_entity_id := get_user_entity('ROE_DATE');
           end if;

           ff_archive_api.create_archive_item(
                    p_archive_item_id   => l_archive_item_id,
                    p_user_entity_id    => l_user_entity_id,
                    p_archive_value             => l_value,
                    p_archive_type              => 'AAC',
                    p_action_id         => l_lockingactid,
                    p_legislation_code  => 'CA',
                    p_object_version_number => l_object_version_number,
                    p_some_warning              => l_some_warning);

           end loop;  -- tot_no_fields

           end if; -- check_retry_amend

           end loop;  -- cur_gre

           end loop;    -- cur_paf
	 end if;

           end loop; -- cur_asg_set_person_id

          hr_utility.trace('Action Creation:  assignment set is passed');

        end if; -- End if (Assignment set)
end;

hr_utility.trace_off;

end action_creation;


function func_expected_date_of_return (p_asg_id number,
                                       p_payroll_id number,
                                       p_gre_id number) return date is
begin
declare

  l_edor_uid      ff_user_entities.user_entity_id%TYPE;
  l_payroll_uid   ff_user_entities.user_entity_id%TYPE;

  cursor cur_edor is
  select
    fai2.value
  from
    pay_payroll_actions ppa,
    pay_assignment_actions paa,
    ff_archive_items fai1,
    ff_archive_items fai2
  where
    ppa.report_type = 'ROE' and
    ppa.report_category = 'ROEC' and
    ppa.report_qualifier = 'ROEQ' and
    ppa.payroll_action_id = paa.payroll_action_id and
    paa.tax_unit_id = p_gre_id and
    paa.assignment_id = p_asg_id and
    paa.assignment_action_id = fai1.context1 and
    fai1.user_entity_id = l_payroll_uid and
    fai1.value = to_char(p_payroll_id) and
    fai1.context1 = fai2.context1 and
    fai2.user_entity_id = l_edor_uid;


  l_value      ff_archive_items.value%TYPE;
  l_temp_date  date;

begin

  hr_utility.trace('func_expected_date_of_return');

  l_edor_uid := get_user_entity('ROE_EXPECTED_DATE_OF_RECALL');
  l_payroll_uid := get_user_entity('ROE_PAYROLL_ID');

  open cur_edor;
  fetch cur_edor
  into l_value;
  close cur_edor;

  hr_utility.trace('func_expected_date_of_return l_value = ' || l_value);
  l_temp_date := fnd_date.canonical_to_date(l_value);

  return l_temp_date;

end;
end; -- func_expected_date_of_return

procedure archive_data(p_assactid in number,
                       p_effective_date in date) is
begin
declare

  TYPE tab_varchar2 IS TABLE OF VARCHAR2(200)
                        INDEX BY BINARY_INTEGER;

  TYPE tab_number IS TABLE OF NUMBER
                        INDEX BY BINARY_INTEGER;

  tab_user_entity_name          tab_varchar2;

  cursor cur_abs ( b_person_id     number,
                   b_date_start    date) is
  select abs.date_end date_end
  from   per_absence_attendances  abs
  where  abs.person_id     = b_person_id
  and    abs.date_start    = b_date_start;

  cursor cur_archive_info is
  select
    paa.assignment_id,
    paa.tax_unit_id,
    ppa.effective_date,
    ppa.business_group_id,
    ppa.payroll_id,
    legislative_parameters,
    NVL(paa.serial_number,'N')
  from
    pay_payroll_actions ppa,
    pay_assignment_actions paa
  where
    paa.assignment_action_id = p_assactid and
    paa.payroll_action_id = ppa.payroll_action_id;

  cursor cur_prd_end_date(p_payroll_id number,
                          p_date date) is
  select
    ptp.end_date
  from
    per_time_periods ptp
  where
    ptp.payroll_id = p_payroll_id and
    p_date between
      ptp.start_date and ptp.end_date;

  l_assignment_id               pay_assignment_actions.assignment_id%type;
  l_tax_unit_id                 pay_assignment_actions.tax_unit_id%type;
  l_effective_date              pay_payroll_actions.effective_date%type;
  l_business_group_id           pay_payroll_actions.business_group_id%type;
  total_no_fields               number;
  l_payroll_id                  pay_payroll_actions.payroll_id%type;
  l_person_id                   per_people_f.person_id%TYPE;
  l_assignment_amend            pay_assignment_actions.assignment_action_id%TYPE;


  cursor cur_person_id(p_assignment_action_id number) is
  select
    paf.person_id person_id
  from
    pay_assignment_actions paa,
    per_assignments_f paf
  where
    paa.assignment_action_id = p_assignment_action_id and
    paa.assignment_id = paf.assignment_id and
    l_effective_date between paf.effective_start_date and
      paf.effective_end_date;

  cursor cur_pai is
  select
    pai.locking_action_id
  from
    pay_action_interlocks pai
  where
    pai.locked_action_id = l_assignment_amend;

  l_locking_action_id           pay_action_interlocks.locking_action_id%TYPE;

/* original
  cursor cur_employer_info(l_tax_unit_id number) is
  select hctu.name              name,
         hctu.address_line_1    address_line_1,
         hctu.address_line_2    address_line_2,
         hctu.address_line_3    address_line_3,
         hctu.province          province,
         hctu.country           country,
         hctu.postal_code       postal_code
  from   hr_ca_tax_units_v      hctu
  where  hctu.tax_unit_id=l_tax_unit_id;
*/

 cursor cur_employer_info(l_tax_unit_id number) is
  select nvl(hoi.org_information9,hctu.name)            name,
         hctu.address_line_1    address_line_1,
         hctu.address_line_2    address_line_2,
         hctu.address_line_3    address_line_3,
         hctu.town_or_city      city,
         hctu.province          province,
         hctu.country           country,
         hctu.postal_code       postal_code,
         hctu.telephone_number_1 telephone
  from   hr_ca_tax_units_v      hctu,
         hr_organization_information hoi
  where  hctu.tax_unit_id=l_tax_unit_id
         and hoi.organization_id = l_tax_unit_id
         and hoi.org_information_context = 'Canada Employer Identification';


  cursor cur_employee_info is
  select  people.first_name              first_name,
          people.last_name               last_name,
          people.national_identifier     social_insurance_number,
          people.middle_names            middle_names,
          decode (people.correspondence_language, 'FRC','F','E') correspondence_language
  from
          per_all_people_f       people
  ,       per_person_types       ptype
  ,       per_phones             phone
  ,       fnd_sessions           ses
  ,       hr_lookups             a
  ,       hr_lookups             c
  ,       hr_lookups             d
  ,       hr_lookups             e
  ,       hr_lookups             f
  ,       hr_lookups             g
  ,       hr_lookups             h
  ,       hr_lookups             i
  ,       per_all_assignments_f  ASSIGN
  where   l_effective_date BETWEEN
  ASSIGN.effective_start_date
  AND     ASSIGN.effective_end_date
  and     ASSIGN.assignment_id = l_assignment_id
  and     PEOPLE.person_id     = ASSIGN.person_id
  and     l_effective_date BETWEEN
                PEOPLE.effective_start_date
                AND PEOPLE.effective_end_date
  and     PTYPE.person_type_id = PEOPLE.person_type_id
  and     PHONE.parent_id (+) = PEOPLE.person_id
  AND     PHONE.parent_table (+)= 'PER_ALL_PEOPLE_F'
  and     PHONE.phone_type (+)= 'W1'
  AND     l_effective_date
  BETWEEN NVL(PHONE.date_from(+),l_effective_date)
  AND     NVL(PHONE.date_to(+),l_effective_date)
  and     a.lookup_type        = 'YES_NO'
  and     a.lookup_code        = nvl(PEOPLE.current_applicant_flag,'N')
  and     a.application_id     = 800
  and     c.lookup_type        = 'YES_NO'
  and     c.lookup_code        = nvl(PEOPLE.current_employee_flag,'N')
  and     c.application_id     = 800
  and     d.lookup_type        = 'YES_NO'
  and     d.lookup_code        = nvl(PEOPLE.registered_disabled_flag,'N')
  and     d.application_id     = 800
  and     e.lookup_type     (+)= 'HOME_OFFICE'
  and     e.lookup_code     (+)= PEOPLE.expense_check_send_to_address
  and     e.application_id  (+)= 800
  and     f.lookup_type     (+)= 'MAR_STATUS'
  and     f.lookup_code     (+)= PEOPLE.marital_status
  and     f.application_id  (+)= 800
  and     g.lookup_type     (+)= 'NATIONALITY'
  and     g.lookup_code     (+)= PEOPLE.nationality
  and     g.application_id  (+)= 800
  and     h.lookup_type     (+)= 'SEX'
  and     h.lookup_code     (+)= PEOPLE.sex
  and     h.application_id  (+)= 800
  and     i.lookup_type     (+)= 'TITLE'
  and     i.lookup_code     (+)= PEOPLE.title
  and     i.application_id  (+)= 800
  and     SES.session_id       = USERENV('SESSIONID');

  cursor cur_employee_address_info is
  select addr.address_line1             address_line_1,
         addr.address_line2             address_line_2,
         addr.address_line3             address_line_3,
         addr.town_or_city              city,
         addr.region_1                  province,
         addr.country                   country,
         addr.postal_code               postal_code,
         addr.telephone_number_1        telephone_number
  from  per_all_assignments_f assign,
        per_addresses         addr
  where assign.assignment_id = l_assignment_id
  and   l_effective_date BETWEEN
             assign.effective_start_date
             AND assign.effective_end_date
  and   assign.person_id  =  addr.person_id(+)
  and   addr.primary_flag(+) = 'Y'
  and     l_effective_date
  BETWEEN nvl(ADDR.date_from,l_effective_date)
  AND     nvl(ADDR.date_to,l_effective_date);

  cursor cur_employee_hire_date is
  select max(service.date_start)        hire_date
  from   per_periods_of_service service,
         per_assignments_f asg
  where  asg.assignment_id = l_assignment_id
  and    l_effective_date BETWEEN
           asg.effective_start_date
           AND asg.effective_end_date
  and    asg.person_id     = service.person_id(+)
  and    service.date_start <= l_effective_date;

  -- The assignment_number will be displayed
  -- as Employer's payroll reference number in ROE.

  cursor cur_asg_number is
  select paf.assignment_number     asg_number
  from   per_assignments_f         paf
  where  l_effective_date between paf.effective_start_date
                        AND paf.effective_end_date
  and    paf.assignment_id = l_assignment_id;

  --
  -- Revenue Canada Business Number
  --
--
  cursor cur_business_number(l_tax_unit_id number ) is
  select hoi.org_information1           business_number
  from   hr_organization_information    hoi
  where  l_tax_unit_id = hoi.organization_id
  and    ltrim(rtrim(hoi.org_information_context)) =
                        'Canada Employer Identification';

  --
  -- ROE specific information in the payroll form
  --

  cursor cur_payroll_form(p_pay_period_end_date date) is
  select people1.full_name                      contact_person,
         ppf.prl_information2                   contact_phone_number,
         people2.full_name                      roe_issuer,
         ppf.prl_information4                   correspondence_language,
         people1.first_name                     contact_first_name,
         people1.middle_names                   contact_middle_names,
         people1.last_name                      contact_last_name
  from   pay_payrolls_f         ppf,
         per_people_f           people1,
         per_people_f           people2
  where  ppf.payroll_id = l_payroll_id
  and    ppf.prl_information_category = 'CA'
  and    ppf.prl_information1  =  people1.person_id(+)
  and    ppf.prl_information3  =  people2.person_id(+)
  and    p_pay_period_end_date BETWEEN nvl(people1.effective_start_date,
                                      p_pay_period_end_date)
                AND nvl(people1.effective_end_date,p_pay_period_end_date)
  and    p_pay_period_end_date BETWEEN nvl(people2.effective_start_date,
                                      p_pay_period_end_date)
                AND nvl(people2.effective_end_date,p_pay_period_end_date)
  and    p_pay_period_end_date BETWEEN nvl(ppf.effective_start_date,
                                       p_pay_period_end_date)
                AND nvl(ppf.effective_end_date,p_pay_period_end_date);
  --
  -- Assignment Job
  --

  cursor cur_asg_job is
  select
        job.name                        name
  from
      per_all_assignments_f            assign
  ,   per_grades                       grade
  ,   per_jobs                         job
  ,   per_assignment_status_types      ast
  ,   pay_all_payrolls_f               payroll
  ,   per_time_periods                 timep
  ,   hr_locations                     loc
  ,   hr_all_organization_units        org
  ,   pay_people_groups                grp
  ,   per_all_vacancies                vac
  ,   per_all_people_f                 people1
  ,   per_all_people_f                 people2
  ,   per_all_positions                pos1
  ,   per_all_positions                pos2
  ,   per_all_positions                pos3
  ,   hr_lookups                       hr1
  ,   hr_lookups                       hr2
  ,   hr_lookups                       hr3
  ,   hr_lookups                       hr4
  ,   hr_lookups                       hr5
  ,   hr_lookups                       hr6
  ,   hr_lookups                       hr7
  ,   fnd_lookups                      fnd1
  ,   fnd_lookups                      fnd2
  where
      l_effective_date BETWEEN assign.effective_start_date
                             AND assign.effective_end_date
  and     assign.assignment_id           = l_assignment_id
  and     grade.grade_id              (+)= assign.grade_id
  and     job.job_id                  (+)= assign.job_id
  and     ast.assignment_status_type_id  = assign.assignment_status_type_id
  and     payroll.payroll_id          (+)= assign.payroll_id
  and     l_effective_date between
                nvl (payroll.effective_start_date,l_effective_date)
                and nvl (payroll.effective_end_date,l_effective_date)
  and     timep.payroll_id            (+)= assign.payroll_id
  and     l_effective_date between nvl (timep.start_date(+), l_effective_date)
                                 and nvl (timep.end_date(+), l_effective_date)
  and     loc.location_id             (+)= assign.location_id
  and     org.organization_id            = assign.organization_id
  and     grp.people_group_id         (+)= assign.people_group_id
  and     vac.vacancy_id              (+)= assign.vacancy_id
  and     hr1.lookup_code                = assign.assignment_type
  and     hr1.lookup_type                = 'EMP_APL'
  and     hr2.lookup_code             (+)= assign.probation_unit
  and     hr2.lookup_type             (+)= 'UNITS'
  and     hr3.lookup_code             (+)= assign.frequency
  and     hr3.lookup_type             (+)= 'FREQUENCY'
  and     fnd1.lookup_code               = assign.primary_flag
  and     fnd1.lookup_type               = 'YES_NO'
  and     fnd2.lookup_code            (+)= assign.manager_flag
  and     fnd2.lookup_type            (+)= 'YES_NO'
  and     people1.person_id           (+)= assign.recruiter_id
  and     people2.person_id           (+)= assign.supervisor_id
  and     pos1.position_id            (+)= assign.position_id
  and     hr4.lookup_code             (+)= pos1.frequency
  and     hr4.lookup_type             (+)= 'FREQUENCY'
  and     hr5.lookup_code             (+)= assign.employment_category
  and     hr5.lookup_type             (+)= 'EMP_CAT'
  and     hr6.lookup_code             (+)= assign.perf_review_period_frequency
  and     hr6.lookup_type             (+)= 'FREQUENCY'
  and     hr7.lookup_code             (+)= assign.sal_review_period_frequency
  and     hr7.lookup_type             (+)= 'FREQUENCY'
  and     pos2.position_id            (+)= pos1.successor_position_id
  and     pos3.position_id            (+)= pos1.relief_position_id;

   --
   -- Final pay period ending date
   --

   cursor cur_final_pay_period_date(p_pay_period_end_date date) is
   select min(ptp.start_date)           start_date,
          max(ptp.end_date)             end_date
   from   pay_payroll_actions           ppa,
          pay_assignment_actions        paa,
          per_time_periods              ptp,
          per_time_period_types         tptype
   where  paa.assignment_id        = l_assignment_id
   and    paa.tax_unit_id          = l_tax_unit_id
   and    paa.payroll_action_id    = ppa.payroll_action_id
   and    ppa.payroll_id           = l_payroll_id
   and    ppa.action_type          in ('R','Q')
   and    ppa.date_earned          <= p_pay_period_end_date
   and    ppa.payroll_id           = ptp.payroll_id
   and    p_pay_period_end_date BETWEEN ptp.start_date
                                AND ptp.end_date
   and    ptp.period_type          = tptype.period_type;


   cursor cur_last_pay_date is
   select max(ppa.date_earned)          last_day_paid
   from   pay_payroll_actions           ppa,
          pay_assignment_actions        paa
   where  paa.assignment_id        =    l_assignment_id
   and    paa.payroll_action_id    =    ppa.payroll_action_id
   and    ppa.action_type in            ('R','Q')
   and    paa.action_status        =    'C'
   and    ppa.date_earned          <=   l_effective_date
   and    ppa.payroll_id           =    l_payroll_id
   and    paa.tax_unit_id          =    l_tax_unit_id;


  l_value                       ff_archive_items.value%type;
  l_user_entity_id              ff_user_entities.user_entity_id%type;
  l_archive_item_id             ff_archive_items.archive_item_id%type;
  l_object_version_number       number(9);
  l_some_warning                boolean;

  l_prev_roe_date               date;
  l_roe_date                    date;
  tab_period_total              pay_ca_roe_ei_pkg.t_large_number_table;
  l_total_insurable             number;
  ret                           varchar2(10);
  l_total_type                  varchar2(15);
  l_no_of_periods               number;
  l_period_type                 varchar2(20);
  l_recall_date                 date;
  l_recall_date1                date;
  l_roe_reason                  varchar2(150);
  l_roe_comment                 varchar2(150);
  l_last_day_paid               date;
  l_last_day_paid1              date;
  l_last_day_paid2              date;
  l_legislative_parameters      pay_payroll_actions.legislative_parameters%TYPE;  l_assignment_set_id           hr_assignment_sets.assignment_set_id%TYPE;

  CURSOR cur_asg_set_name IS
  SELECT
    assignment_set_name
  FROM
    hr_assignment_sets
  WHERE assignment_set_id = l_assignment_set_id
  AND   business_group_id = l_business_group_id;

  l_asg_set_name                  hr_assignment_sets.assignment_set_name%TYPE;
  l_first_day_worked              date;
  l_final_pay_period_end_date     date;
  l_final_pay_period_start_date   date;
  l_roe_contact_person            per_people_f.full_name%TYPE;
  l_roe_contact_first_name        per_people_f.first_name%TYPE;
  l_roe_contact_middle_names      per_people_f.middle_names%TYPE;
  l_roe_contact_last_name         per_people_f.last_name%TYPE;
  l_roe_contact_phone_number      pay_payrolls_f.prl_information2%TYPE;
  l_roe_issuer                    pay_payrolls_f.prl_information4%TYPE;
  l_roe_correspondence_language   per_people_f.full_name%TYPE;
  l_pay_period_end_date           date;
  l_defined_balance_id            pay_defined_balances.defined_balance_id%TYPE;
  l_latest_aaid              pay_assignment_actions.assignment_action_id%TYPE
   := 0;
  l_latest_aaid_after_term   pay_assignment_actions.assignment_action_id%TYPE
   := 0;
  l_period_end_date_after_term    date;
  l_period_start_date_after_term  date;

  cursor cur_latest_aaid(l_pay_period_start_date date,
                         l_pay_period_end_date date,
                         p_tax_unit_id number) is
  select
    max(paa.assignment_action_id)
  from
    pay_assignment_actions paa,
    pay_payroll_actions ppa,
    per_assignments_f paf
  where
    paa.assignment_id = l_assignment_id and
    paa.tax_unit_id = p_tax_unit_id and
    paa.payroll_action_id = ppa.payroll_action_id and
    ppa.action_type in ('R','Q','V','B','F') and
    ppa.action_status = 'C' and
    ppa.date_earned between
      l_pay_period_start_date and
      l_pay_period_end_date and
    paa.assignment_id = paf.assignment_id and
    l_pay_period_end_date between paf.effective_start_date and
      paf.effective_end_date and
    paf.payroll_id = l_payroll_id;

  l_temp_value1  number := 0;
  l_temp_code1   varchar2(1);
  l_temp_value2  number := 0;
  l_temp_code2   varchar2(1);
  l_temp_value3  number := 0;
  l_temp_code3   varchar2(1);
  l_term_or_abs_flag varchar2(1);
  l_term_or_abs      varchar2(1);
  l_tax_group_id hr_organization_information.org_information4%TYPE;
  l_t4a_gre      varchar2(1);

  cursor cur_tax_group is
  select
    org_information4
  from
    hr_organization_information
  where
    organization_id = l_tax_unit_id and
    org_information_context = 'Canada Employer Identification';

  cursor cur_17_gres(p_tax_group_id varchar2) is
  select
    organization_id tax_unit_id
  from
    hr_organization_information
  where
    org_information4 = p_tax_group_id and
    org_information_context = 'Canada Employer Identification' and
    org_information5 in ('T4A/RL1','T4A/RL2') and
    l_t4a_gre = 'Y'
  union
  select
    l_tax_unit_id tax_unit_id
  from
    dual;

  l_serial_number      pay_assignment_actions.serial_number%TYPE;

begin

  hr_utility.trace('Archive data');

  open cur_archive_info;
  fetch cur_archive_info
  into  l_assignment_id,
        l_tax_unit_id,
        l_effective_date,
        l_business_group_id,
        l_payroll_id,
        l_legislative_parameters,
        l_t4a_gre;
  close cur_archive_info;

  l_person_id :=
    pycadar_pkg.get_parameter('PERSON_ID',l_legislative_parameters);
  l_assignment_set_id :=
    pycadar_pkg.get_parameter('ASSIGNMENT_SET_ID',l_legislative_parameters);
  l_assignment_amend :=
    pycadar_pkg.get_parameter('ASSIGNMENT_ID',l_legislative_parameters);

  if l_assignment_set_id is not null then

    open cur_person_id(p_assactid);
    fetch
      cur_person_id
    into
      l_person_id;
    close cur_person_id;

    open cur_asg_set_name;
    fetch cur_asg_set_name
    into  l_asg_set_name;
    close cur_asg_set_name;

  end if;

  l_prev_roe_date       :=
               fnd_date.canonical_to_date(archive_value(p_assactid,'PREV_ROE_DATE'));
  l_roe_date            :=
               fnd_date.canonical_to_date(archive_value(p_assactid,'ROE_DATE'));
  l_assignment_id       := archive_value(p_assactid,'ROE_ASSIGNMENT_ID');
  l_tax_unit_id         := archive_value(p_assactid,'ROE_GRE_ID');
  l_payroll_id          := archive_value(p_assactid,'ROE_PAYROLL_ID');


  l_effective_date := l_roe_date;

  -- The get_date function is called to check whether the
  -- employee is terminated or not. l_recall_date will be
  -- null if the employee is terminated.

   l_last_day_paid :=  get_date(l_person_id,
                               l_assignment_id,
                               l_business_group_id,
                               l_effective_date,
                               l_recall_date,
                               l_roe_reason,
                               l_roe_comment,
                               l_term_or_abs_flag,
                               l_term_or_abs);

    -- If the ROE Type is LOA, the last day paid
    -- is one day prior to LOA Start Date.
    IF l_term_or_abs = 'A' then
        l_last_day_paid :=  get_working_date(l_business_group_id,
                                             l_assignment_id,
                                             l_last_day_paid,
                                             'P');
    END IF;

  open cur_prd_end_date(l_payroll_id,
                        l_last_day_paid);
  fetch cur_prd_end_date
  into  l_pay_period_end_date;

  if cur_prd_end_date%NOTFOUND then
    l_pay_period_end_date := l_effective_date;
  end if;

  close cur_prd_end_date;

  -- if the check_retry_amend has returned false in action_creation
  -- the following local variables will have NULL so we just raise
  -- an error so the assignent action has error status, the error
  -- log will be found in the log/request file.

  if ((l_roe_date IS NOT NULL) AND
     (l_assignment_id is not null) AND
     (l_tax_unit_id is not null) AND
     (l_payroll_id is not null) ) then

  total_no_fields := 5;

  for cur_rec in cur_employee_info loop

    hr_utility.trace('cur_rec.first_name = '|| cur_rec.first_name);
    hr_utility.trace('cur_rec.middle_name = '|| cur_rec.middle_names);
    hr_utility.trace('cur_rec.last_name = '|| cur_rec.last_name);

    for cur_field in 1..total_no_fields loop

      if cur_field = 1 then

        l_value := cur_rec.first_name;
        l_user_entity_id := get_user_entity('ROE_PER_FIRST_NAME');

      elsif cur_field = 2 then

        l_value := cur_rec.last_name;
        l_user_entity_id := get_user_entity('ROE_PER_LAST_NAME');

      elsif cur_field = 3 then

        l_value := cur_rec.social_insurance_number;
        l_user_entity_id := get_user_entity('ROE_PER_SOCIAL_INSURANCE_NUMBER');

      elsif cur_field = 4 then

        l_value := cur_rec.middle_names;
        l_user_entity_id := get_user_entity('ROE_PER_MIDDLE_NAME');

      elsif cur_field = 5 then

        l_value := cur_rec.correspondence_language;
        l_user_entity_id := get_user_entity('ROE_EMPLOYEE_CORRESPONDENCE_LANGUAGE');

     end if;

     hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
     hr_utility.trace('l value = '|| l_value);

   ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

    end loop;  -- total_no_fields

  end loop;    -- cur_employee_info

  for i in cur_employer_info(l_tax_unit_id) loop

    for j in 1..9 loop

      if  j = 1 then

        l_value := i.name;
        l_user_entity_id := get_user_entity('ROE_TAX_UNIT_NAME');

      elsif  j = 2 then

        l_value := i.address_line_1;
        l_user_entity_id := get_user_entity('ROE_TAX_UNIT_ADDRESS_LINE_1');

      elsif  j = 3 then

        l_value := i.address_line_2;
        l_user_entity_id := get_user_entity('ROE_TAX_UNIT_ADDRESS_LINE_2');

       elsif  j = 4 then

          l_value := i.address_line_3;
          l_user_entity_id := get_user_entity('ROE_TAX_UNIT_ADDRESS_LINE_3');

       elsif  j = 5 then

          l_value := i.province;
          l_user_entity_id := get_user_entity('ROE_TAX_UNIT_PROVINCE');

       elsif  j = 6 then

          l_value := i.country;
          l_user_entity_id := get_user_entity('ROE_TAX_UNIT_COUNTRY');


       elsif  j = 7 then

          l_value := i.postal_code;
          l_user_entity_id := get_user_entity('ROE_TAX_UNIT_POSTAL_CODE');

       elsif  j = 8 then

          l_value := i.city;
          l_user_entity_id := get_user_entity('ROE_TAX_UNIT_CITY');

       elsif  j = 9 then

          l_value := i.telephone;
          l_user_entity_id := get_user_entity('ROE_TAX_UNIT_PHONE_NUMBER');

       end if;

    hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
    hr_utility.trace('l value = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

     end loop;

   end loop;


   total_no_fields := 8;

   for cur_rec in cur_employee_address_info loop

     for cur_field in 1..total_no_fields loop

       if  cur_field = 1 then

          l_value := cur_rec.address_line_1;
          l_user_entity_id := get_user_entity('ROE_PER_ADDRESS_LINE_1');

       elsif cur_field = 2 then

          l_value := cur_rec.address_line_2;
          l_user_entity_id := get_user_entity('ROE_PER_ADDRESS_LINE_2');

       elsif  cur_field = 3 then

          l_value := cur_rec.address_line_3;
          l_user_entity_id := get_user_entity('ROE_PER_ADDRESS_LINE_3');

       elsif  cur_field = 4 then

          l_value := cur_rec.province;
          l_user_entity_id := get_user_entity('ROE_PER_PROVINCE');

       elsif  cur_field = 5 then

          l_value := cur_rec.country;
          l_user_entity_id := get_user_entity('ROE_PER_COUNTRY');


       elsif  cur_field = 6 then

          l_value := cur_rec.postal_code;
          l_user_entity_id := get_user_entity('ROE_PER_POSTAL_CODE');

       elsif  cur_field = 7 then

--          l_value := cur_rec.telephone_number;
-- as per discussed with lucy and lewis putting null value
          l_value := null;
          l_user_entity_id := get_user_entity('ROE_PER_TELEPHONE_NUMBER');

       elsif  cur_field = 8 then

          l_value := cur_rec.city;
          l_user_entity_id := get_user_entity('ROE_PER_CITY');

       end if;

   hr_utility.trace('per user entity id = '|| to_char(l_user_entity_id));
   hr_utility.trace('per  l value = '|| l_value);

        ff_archive_api.create_archive_item(
          p_archive_item_id     => l_archive_item_id,
          p_user_entity_id      => l_user_entity_id,
          p_archive_value       => l_value,
          p_archive_type        => 'AAP',
          p_action_id           => p_assactid,
          p_legislation_code    => 'CA',
          p_object_version_number => l_object_version_number,
          p_some_warning                => l_some_warning);

        end loop;       --total_no_fields

  end loop;     -- cur_employee_address_info

  -- This loop will archive records which
  -- are supposed to have null values and
  -- will be populated by the archive view
  -- form. The total number of items that
  -- will be archived 11

  total_no_fields               := 11;

  l_value                       := null;

  tab_user_entity_name(1)       := 'ROE_BOX_17B_DATE1';
  tab_user_entity_name(2)       := 'ROE_BOX_17B_AMOUNT1';
  tab_user_entity_name(3)       := 'ROE_BOX_17B_DATE2';
  tab_user_entity_name(4)       := 'ROE_BOX_17B_AMOUNT2';
  tab_user_entity_name(5)       := 'ROE_BOX_17B_DATE3';
  tab_user_entity_name(6)       := 'ROE_BOX_17B_AMOUNT3';
  tab_user_entity_name(7)       := 'ROE_BOX_19_PAYMENT_START_DATE';
  tab_user_entity_name(8)       := 'ROE_BOX_19_PAYMENT_AMOUNT';
  tab_user_entity_name(9)       := 'ROE_BOX_19_DAY_WEEK';
  tab_user_entity_name(10)      := 'ROE_MANUAL';
  tab_user_entity_name(11)      := 'ROE_INCLUDE_EXCLUDE';

  for cur_rec in 1..total_no_fields loop

    l_user_entity_id := get_user_entity(tab_user_entity_name(cur_rec));

    hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
    hr_utility.trace('l value = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  end loop; -- total_no_fields

  open cur_asg_number;
  fetch cur_asg_number
  into  l_value;

  if cur_asg_number%NOTFOUND then
    l_value := NULL;
  end if;

  close cur_asg_number;

  l_user_entity_id := get_user_entity('ROE_ASG_NUMBER');

  hr_utility.trace('ROE_ASG_NUBER id = '|| to_char(l_user_entity_id));
  hr_utility.trace('ROE_ASG_NUBER value = '|| l_value);

  ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);


  for cur_rec in cur_business_number(l_tax_unit_id) loop

    l_value := cur_rec.business_number;
    l_user_entity_id := get_user_entity('ROE_CANADA_EMPLOYER_IDENTIFICATION_ORG_BUSINESS_NUMBER');

    hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
    hr_utility.trace('l value = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  end loop;     -- cur_business_number


  total_no_fields := 7;

  open cur_payroll_form(l_pay_period_end_date);
  fetch cur_payroll_form
  into  l_roe_contact_person,
        l_roe_contact_phone_number,
        l_roe_issuer,
        l_roe_correspondence_language,
        l_roe_contact_first_name,
        l_roe_contact_middle_names,
        l_roe_contact_last_name;

  if cur_payroll_form%NOTFOUND then
    l_roe_contact_person := NULL;
    l_roe_contact_phone_number := NULL;
    l_roe_issuer := NULL;
    l_roe_correspondence_language := NULL;
    l_roe_contact_first_name := NULL;
    l_roe_contact_middle_names := NULL;
    l_roe_contact_last_name := NULL;
  end if;

  close cur_payroll_form;

  for cur_field in 1..total_no_fields loop

    if cur_field = 1 then

      l_value := l_roe_contact_person;
      l_user_entity_id := get_user_entity('ROE_CONTACT_PERSON');

    elsif cur_field = 2 then

      l_value := l_roe_contact_phone_number;
      l_user_entity_id := get_user_entity('ROE_CONTACT_PHONE_NUMBER');

    elsif cur_field = 3 then

      l_value := l_roe_issuer;
      l_user_entity_id := get_user_entity('ROE_ISSUER');

    elsif cur_field = 4 then

      l_value := l_roe_correspondence_language;
      l_user_entity_id := get_user_entity('ROE_PER_CORRESPONDENCE_LANGUAGE');

    elsif cur_field = 5 then

      l_value := l_roe_contact_first_name;
      l_user_entity_id := get_user_entity('ROE_CONTACT_PER_FIRST_NAME');

    elsif cur_field = 6 then

      l_value := l_roe_contact_middle_names;
      l_user_entity_id := get_user_entity('ROE_CONTACT_PER_MIDDLE_NAMES');

    elsif cur_field = 7 then

      l_value := l_roe_contact_last_name;
      l_user_entity_id := get_user_entity('ROE_CONTACT_PER_LAST_NAME');

    end if;

    hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
    hr_utility.trace('l value = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

    end loop; -- total_no_fields


  for cur_rec in cur_asg_job loop

    l_value := cur_rec.name;
    l_user_entity_id := get_user_entity('ROE_ASG_JOB');

    hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
    hr_utility.trace('l value = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  end loop;

  open cur_final_pay_period_date(l_pay_period_end_date);
  fetch cur_final_pay_period_date
  into l_final_pay_period_start_date,
       l_final_pay_period_end_date;

  if cur_final_pay_period_date%NOTFOUND then
    l_final_pay_period_start_date := NULL;
    l_final_pay_period_end_date := NULL;
  else
    l_value := to_char(l_final_pay_period_end_date,'YYYY/MM/DD HH24:MI:SS');
  end if;

  close cur_final_pay_period_date;

  l_user_entity_id := get_user_entity('ROE_FINAL_PAY_PERIOD_ENDING_DATE');

  hr_utility.trace('ROE_FINAL_PAY_PERIOD_ENDING_DATE entity id = '
                                 || to_char(l_user_entity_id));
  hr_utility.trace('ROE_FINAL_PAY_PERIOD_ENDING_DATE value = '|| l_value);
  hr_utility.trace('l_final_pay_period_start_date = ' ||
      to_char(l_final_pay_period_start_date));

  ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);


  -- The get_date function is called to check whether the
  -- employee is terminated or not. l_recall_date will be
  -- null if the employee is terminated.

   l_last_day_paid :=  get_date(l_person_id,
                               l_assignment_id,
                               l_business_group_id,
                               l_effective_date,
                               l_recall_date,
                               l_roe_reason,
                               l_roe_comment,
                               l_term_or_abs_flag,
                               l_term_or_abs);

  -- if the employee has got a prev ROE and
  -- has come back from LOA then the start date would be
  -- Next working day after the employee has returned otherwise
  -- the hire date will be the start date.

  if l_prev_roe_date is not null then

     hr_utility.trace('l_prev_roe_date is not null ' ||
                      to_char(l_prev_roe_date,'dd-mon-yy'));

     -- if the prev ROE was used for LOA then the expected date
     -- of recall archived on the prev run would be the first day
     -- worked for this run.
     -- If the prev ROE was issued b'coz the employee was
     -- terminated then the latest hire date would be first day
     -- worked.

     -- Commented for bug 3892425
     --   l_first_day_worked := func_expected_date_of_return(l_assignment_id,
     --                                                      l_payroll_id,
     --                                                      l_tax_unit_id);

     -- Fix for Bug 3892425:
     -- To derive the first day worked after an employee returns from LOA
     -- fetch the absense end date
     -- for the person whose LOA start date is same as previous ROE date.

     open cur_abs(l_person_id, l_prev_roe_date);
     fetch cur_abs into l_first_day_worked;
     close cur_abs;

     if l_first_day_worked is not null then

       l_first_day_worked := get_working_date(l_business_group_id,
                                              l_assignment_id,
                                              l_first_day_worked,
                                              'N');
       l_value := to_char(l_first_day_worked,'YYYY/MM/DD HH24:MI:SS');

     else

 /*     --Fix for 6396412 (sapalani)

       open cur_employee_hire_date;
       fetch cur_employee_hire_date
       into  l_first_day_worked;
       close cur_employee_hire_date;

       l_first_day_worked := get_working_date(l_business_group_id,
                                              l_assignment_id,
                                              l_prev_roe_date,
                                              'N');
       l_value := to_char(l_first_day_worked,'YYYY/MM/DD HH24:MI:SS');

       -- End 6396412
  */
  --Fix for 8210261  (aneghosh)
       open cur_employee_hire_date;
       fetch cur_employee_hire_date
       into  l_first_day_worked;
       close cur_employee_hire_date;
         if  l_first_day_worked < get_working_date(l_business_group_id,
                                              l_assignment_id,
                                              l_prev_roe_date,
                                              'N')
        then
         l_first_day_worked := get_working_date(l_business_group_id,
                                              l_assignment_id,
                                              l_prev_roe_date,
                                              'N');
         end if;
     --End 8210261
       l_value := to_char(l_first_day_worked,'YYYY/MM/DD HH24:MI:SS');
     end if;

     l_user_entity_id := get_user_entity('ROE_EMP_PER_HIRE_DATE');

     hr_utility.trace('ROE_EMP_PER_HIRE_DATE = '|| to_char(l_user_entity_id));
     hr_utility.trace('First day worked = '|| l_value);

     ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  else

    hr_utility.trace('first day worked in hire date');

    for cur_rec in cur_employee_hire_date loop

    l_value := to_char(cur_rec.hire_date,'YYYY/MM/DD HH24:MI:SS');
    l_user_entity_id := get_user_entity('ROE_EMP_PER_HIRE_DATE');

    hr_utility.trace('ROE_EMP_PER_HIRE_DATE = '|| to_char(l_user_entity_id));
    hr_utility.trace('First day worked  = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

    end loop;  -- cur_employee_hire_date

  end if;

  -- If the person has been terminated then the last date paid
  -- is actual termination date but if the employee has gone for
  -- LOA then the last date paid becomes one day before/ prev
  -- working date the actual LOA start date. l_recall_date
  -- will be null if the employee is terminated.

  if l_term_or_abs = 'T' then

    l_value := to_char(l_effective_date,'YYYY/MM/DD HH24:MI:SS');
    l_user_entity_id := get_user_entity('ROE_PAY_EARNED_END_DATE');

    hr_utility.trace('ROE_PAY_EARNED_END_DATE id = '|| to_char(l_user_entity_id));
    hr_utility.trace('ROE_PAY_EARNED_END_DATE value = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  else

    -- If the employee has returned from the LOA and the return
    -- date is less than the final_pay_period_end_date then the
    -- last day paid is final_pay_period_ending_date else it
    -- is the day b4 LOA start date.

    if l_recall_date <= l_final_pay_period_end_date then

      hr_utility.trace('recall date is less than final period ending date');
      l_value := to_char(l_final_pay_period_end_date,'YYYY/MM/DD HH24:MI:SS');

    else

      hr_utility.trace('recall date is greater than final period ending date');
      l_last_day_paid1 := get_working_date(l_business_group_id,
                                        l_assignment_id,
                                        l_last_day_paid,
                                        'P');

      l_value := to_char(l_last_day_paid1,'YYYY/MM/DD HH24:MI:SS');

    end if;

    l_user_entity_id := get_user_entity('ROE_PAY_EARNED_END_DATE');

    hr_utility.trace('ROE_PAY_EARNED_END_DATE id = '||
                      to_char(l_user_entity_id));
    hr_utility.trace('ROE_PAY_EARNED_END_DATE = '|| l_value);

    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  end if;

  --
  -- ROE reason and Comment
  --

   l_effective_date := get_date(l_person_id,
                               l_assignment_id,
                               l_business_group_id,
                               l_effective_date,
                               l_recall_date,
                               l_roe_reason,
                               l_roe_comment,
                               l_term_or_abs_flag,
                               l_term_or_abs);

   for cur_field in 1..4 loop

   if cur_field = 1 then

    l_value := l_roe_reason;
    l_user_entity_id := get_user_entity('ROE_REASON');

  elsif cur_field = 2 then

    l_value := l_roe_comment;
    l_user_entity_id := get_user_entity('ROE_COMMENTS');

  elsif cur_field = 3 then

        if l_recall_date is not null then

          l_recall_date1 := get_working_date(l_business_group_id,
                                            l_assignment_id,
                                            l_recall_date,
                                            'N');
        else

          l_recall_date1 := l_recall_date;

        end if;

        hr_utility.trace('l_recall_date ' ||
                        to_char(l_recall_date1,'dd-mon-yy'));
        l_value := to_char(l_recall_date1,'YYYY/MM/DD HH24:MI:SS');
        l_user_entity_id := get_user_entity('ROE_EXPECTED_DATE_OF_RECALL');

  elsif cur_field = 4 then

    if l_recall_date is not null then
      l_value := 'Y';
    else
      if (l_roe_reason = 'E' or
         l_roe_reason = 'G' or
         l_roe_reason = 'M')then
           l_value := 'N';
      elsif (l_roe_reason = 'A' or
             l_roe_reason = 'B' or
             l_roe_reason = 'C' or
             l_roe_reason = 'D' or
             l_roe_reason = 'F' or
             l_roe_reason = 'H' or
             l_roe_reason = 'J' or
             l_roe_reason = 'K' or
             l_roe_reason = 'N' or
             l_roe_reason = 'P') then
        l_value := 'U';
      elsif l_roe_reason is null then
        l_value := null;
      end if;
    end if;

    l_user_entity_id := get_user_entity('ROE_UNKNOWN_NOT_RETURNING');

  end if;

  hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
  hr_utility.trace('l value = '|| l_value);

  hr_utility.trace('l person_id = '|| to_char(l_person_id));
  hr_utility.trace('l bg_id = '|| to_char(l_business_group_id));
  hr_utility.trace('l effective date = '|| to_char(l_effective_date));
  hr_utility.trace('l recall date = '|| to_char(l_recall_date));
  hr_utility.trace('l reason = '|| l_roe_reason);
  hr_utility.trace('l comment = '|| l_roe_comment);


    ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  end loop;


  -- Archiving the Box 17A ROE Vacation Pay Balance

  open cur_tax_group;
  fetch cur_tax_group
  into  l_tax_group_id;
  close cur_tax_group;

  hr_utility.trace('l_tax_group_id = ' || l_tax_group_id);
  hr_utility.trace('l_t4a_gre = ' || l_t4a_gre);

  l_value := '0';

  l_user_entity_id := get_user_entity('ROE_BOX_17A');

  if balance_feed_exists('ROE Vacation Pay',l_business_group_id) then

    hr_utility.trace('Archive Data: Balance Feed Exists for ROE Vacation Pay');

    l_defined_balance_id := get_defined_balance_id(
              'ROE Vacation Pay',
              'Assignment within Government Reporting Entity Period to Date',
              l_business_group_id);

    hr_utility.trace('l_defined_balance_id = ' || to_char(l_defined_balance_id));
    for gres in cur_17_gres(l_tax_group_id) loop

    hr_utility.trace('gres.tax_unit_id = ' || to_char(gres.tax_unit_id));
    hr_utility.trace('17A l_final_pay_period_start_date = ' || to_char(l_final_pay_period_start_date));
    hr_utility.trace('17A l_final_pay_period_end_date = ' || to_char(l_final_pay_period_end_date));

    pay_balance_pkg.set_context('TAX_UNIT_ID',gres.tax_unit_id);

    open cur_latest_aaid(l_final_pay_period_start_date,
                         l_final_pay_period_end_date,
                         gres.tax_unit_id);
    fetch cur_latest_aaid
    into  l_latest_aaid;
    if cur_latest_aaid%NOTFOUND then
      close cur_latest_aaid;
    else
      close cur_latest_aaid;
    end if;

    hr_utility.trace('l_latest_aaid = ' || to_char(l_latest_aaid));

    if l_latest_aaid is not null then
      l_value := l_value + NVL(pay_balance_pkg.get_value(l_defined_balance_id,
                                       l_latest_aaid),0);
    end if;

    hr_utility.trace('Vacation Paid l_value = ' || l_value);
    hr_utility.trace('l_final_pay_period_end_date = ' ||
      to_char(l_final_pay_period_end_date));

    open cur_final_pay_period_date(l_final_pay_period_end_date + 1);
    fetch cur_final_pay_period_date
    into l_period_start_date_after_term,
         l_period_end_date_after_term;

    if cur_final_pay_period_date%NOTFOUND then
      l_period_start_date_after_term := NULL;
      l_period_end_date_after_term := NULL;
    end if;

    close cur_final_pay_period_date;

    open cur_latest_aaid(l_period_start_date_after_term,
                         l_period_end_date_after_term,
                         gres.tax_unit_id);
    fetch cur_latest_aaid
    into  l_latest_aaid_after_term;
    if cur_latest_aaid%NOTFOUND then
      close cur_latest_aaid;
    else
      close cur_latest_aaid;
    end if;

    hr_utility.trace('Box 17A l_latest_aaid_after_term = ' ||
      to_char(l_latest_aaid_after_term));

    if l_latest_aaid_after_term is not null then
      l_value := l_value + NVL(pay_balance_pkg.get_value(l_defined_balance_id,
                                       l_latest_aaid_after_term),0);
    end if;

    hr_utility.trace('ROE_BOX_17A = ' || l_value);

   end loop; -- cur_17_gres

   end if; -- End if balance_feed_exists

  ff_archive_api.create_archive_item(
    p_archive_item_id     => l_archive_item_id,
    p_user_entity_id      => l_user_entity_id,
    p_archive_value       => l_value,
    p_archive_type        => 'AAP',
    p_action_id           => p_assactid,
    p_legislation_code    => 'CA',
    p_object_version_number => l_object_version_number,
    p_some_warning                => l_some_warning);

  -- End of archiving Box 17A Balance

  -- Start of archiving ROE Box 17C, Only the First three
  -- balances with highest value with their codes with be
  -- archived.


  -- l_latest_aaid will have the latest assignment_action_id
  -- if box 17A is populated otherwise it will have 0 as this
  -- is initialized with 0.

  hr_utility.trace('l_final_pay_period_start_date = ' ||
    to_char(l_final_pay_period_start_date));


  hr_utility.trace('l_tax_unit_id = ' || to_char(l_tax_unit_id));

  for tot_no_bal in 1..12 loop

    l_value := '0';
    if balance_feed_exists(
          pay_ca_archive.box17c_bal_table(tot_no_bal).balance_name,
                           l_business_group_id) then

      l_defined_balance_id := get_defined_balance_id(
              pay_ca_archive.box17c_bal_table(tot_no_bal).balance_name,
              'Assignment within Government Reporting Entity Period to Date',
              l_business_group_id);

      hr_utility.trace('Box 17C l_defined_balance_id = ' ||
                        to_char(l_defined_balance_id));

      for gres in cur_17_gres(l_tax_group_id) loop

        pay_balance_pkg.set_context('TAX_UNIT_ID',gres.tax_unit_id);

        open cur_latest_aaid(l_final_pay_period_start_date,
                         l_final_pay_period_end_date,
                         gres.tax_unit_id);
        fetch cur_latest_aaid
        into  l_latest_aaid;
        if cur_latest_aaid%NOTFOUND then
          close cur_latest_aaid;
        else
          close cur_latest_aaid;
        end if;

        hr_utility.trace('l_latest_aaid = ' || to_char(l_latest_aaid));

        if l_latest_aaid is not null then
          l_value := l_value +
                       NVL(pay_balance_pkg.get_value(l_defined_balance_id,
                       l_latest_aaid),0);
        end if;

        hr_utility.trace(
           pay_ca_archive.box17c_bal_table(tot_no_bal).balance_name || ' = '
                                                                 || l_value);

        hr_utility.trace('Box 17C l_final_pay_period_end_date = ' ||
          to_char(l_final_pay_period_end_date));

        open cur_final_pay_period_date(l_final_pay_period_end_date + 1);
        fetch cur_final_pay_period_date
        into l_period_start_date_after_term,
             l_period_end_date_after_term;

        if cur_final_pay_period_date%NOTFOUND then
          l_period_start_date_after_term := NULL;
          l_period_end_date_after_term := NULL;
        end if;

       close cur_final_pay_period_date;

       hr_utility.trace('Box 17C l_period_end_date_after_term = ' ||
          to_char(l_period_end_date_after_term));

       open cur_latest_aaid(l_period_start_date_after_term,
                            l_period_end_date_after_term,
                            gres.tax_unit_id);
       fetch cur_latest_aaid
       into  l_latest_aaid_after_term;
       if cur_latest_aaid%NOTFOUND then
         close cur_latest_aaid;
       else
         close cur_latest_aaid;
       end if;

       hr_utility.trace('Box 17C l_latest_aaid_after_term = ' ||
         to_char(l_latest_aaid_after_term));

       if l_latest_aaid_after_term is not null then
         l_value := l_value +
                     NVL(pay_balance_pkg.get_value(l_defined_balance_id,
                                       l_latest_aaid_after_term),0);
       end if;

       hr_utility.trace('Box 17C l_value = ' || l_value);

       end loop; -- cur_17_gres

      -- We will archive only the first three highest Balances

      if to_number(l_value) > 0 then

        if to_number(l_value) >= l_temp_value1 then
          l_temp_value3  := l_temp_value2;
          l_temp_code3 := l_temp_code2;
          l_temp_value2 := l_temp_value1;
          l_temp_code2 := l_temp_code1;
          l_temp_value1 := to_number(l_value);
          l_temp_code1 := pay_ca_archive.box17c_bal_table(tot_no_bal).code;
        else
          if to_number(l_value) >= l_temp_value2 then
            l_temp_value3  := l_temp_value2;
            l_temp_code3 := l_temp_code2;
            l_temp_value2 := to_number(l_value);
            l_temp_code2 := pay_ca_archive.box17c_bal_table(tot_no_bal).code;
          else
            l_temp_value3 := to_number(l_value);
            l_temp_code3 := pay_ca_archive.box17c_bal_table(tot_no_bal).code;
          end if;
        end if;

      end if; -- End if l_value > 0

    end if; -- End if Balance Feed Exists;

  end loop; -- End loop Balances


  hr_utility.trace('l_temp_code1 = ' || l_temp_code1);
  hr_utility.trace('l_temp_value1 = ' || to_char(l_temp_value1));
  hr_utility.trace('l_temp_code2 = ' || l_temp_code2);
  hr_utility.trace('l_temp_value2 = ' || to_char(l_temp_value2));
  hr_utility.trace('l_temp_code3 = ' || l_temp_code3);
  hr_utility.trace('l_temp_value3 = ' || to_char(l_temp_value3));

  tab_user_entity_name(1)       := 'ROE_BOX_17C_DESC1';
  tab_user_entity_name(2)       := 'ROE_BOX_17C_AMOUNT1';
  tab_user_entity_name(3)       := 'ROE_BOX_17C_DESC2';
  tab_user_entity_name(4)       := 'ROE_BOX_17C_AMOUNT2';
  tab_user_entity_name(5)       := 'ROE_BOX_17C_DESC3';
  tab_user_entity_name(6)       := 'ROE_BOX_17C_AMOUNT3';

  for tot_box_17c in 1..6 loop

    l_user_entity_id := get_user_entity(tab_user_entity_name(tot_box_17c));

    if tot_box_17c = 1 then
      l_value := l_temp_code1;
    elsif tot_box_17c = 2 then
      l_value := to_char(l_temp_value1);
    elsif tot_box_17c = 3 then
      l_value := l_temp_code2;
    elsif tot_box_17c = 4 then
      l_value := to_char(l_temp_value2);
    elsif tot_box_17c = 5 then
      l_value := l_temp_code3;
    elsif tot_box_17c = 6 then
      l_value := to_char(l_temp_value3);
    end if;

    ff_archive_api.create_archive_item(
      p_archive_item_id     => l_archive_item_id,
      p_user_entity_id      => l_user_entity_id,
      p_archive_value       => l_value,
      p_archive_type        => 'AAP',
      p_action_id           => p_assactid,
      p_legislation_code    => 'CA',
      p_object_version_number => l_object_version_number,
      p_some_warning                => l_some_warning);

  end loop;

  -- End of archiving Box 17C Balance

  --
  -- Get the EI hours and EI earnings
  --

  -- EI Hours - Begin

  l_total_type := 'EI Hours';

  ret := pay_ca_roe_ei_pkg.get_ei_amount_totals
                 (
                 p_total_type           =>      l_total_type,
                 p_assignment_id        =>      l_assignment_id,
                 p_gre                  =>      l_tax_unit_id,
                 p_payroll_id           =>      l_payroll_id,
                 p_start_date           =>      NVL(l_first_day_worked, l_prev_roe_date + 1),
                 p_end_date             =>      NVL(l_final_pay_period_end_date, l_roe_date),
                 p_total_insurable      =>      l_total_insurable,
                 p_no_of_periods        =>      l_no_of_periods,
                 p_period_total         =>      tab_period_total,
                 p_period_type          =>      l_period_type,
                 p_term_or_abs_flag     =>      l_term_or_abs_flag
                 );

   l_value := l_total_insurable;
   l_user_entity_id := get_user_entity('ROE_TOTAL_INSURABLE_HOURS');

   hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
   hr_utility.trace('l value = '|| l_value);

   ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);


  -- EI Hours - End

  hr_utility.trace('End of archiving EI Hours');

  -- EI Earnings - Begin

     l_total_type := 'EI Earnings';

     ret := pay_ca_roe_ei_pkg.get_ei_amount_totals
                 (
                 p_total_type           =>      l_total_type,
                 p_assignment_id        =>      l_assignment_id,
                 p_gre                  =>      l_tax_unit_id,
                 p_payroll_id           =>      l_payroll_id,
                 p_start_date           =>      NVL(l_first_day_worked, l_prev_roe_date + 1),
                 p_end_date             =>      NVL(l_final_pay_period_end_date, l_roe_date),
                 p_total_insurable      =>      l_total_insurable,
                 p_no_of_periods        =>      l_no_of_periods,
                 p_period_total         =>      tab_period_total,
                 p_period_type          =>      l_period_type,
                 p_term_or_abs_flag     =>      l_term_or_abs_flag
                 );

  hr_utility.trace('ret = ' || ret);

  tab_user_entity_name(1)       := 'ROE_INSURABLE_EARNING_1';
  tab_user_entity_name(2)       := 'ROE_INSURABLE_EARNING_2';
  tab_user_entity_name(3)       := 'ROE_INSURABLE_EARNING_3';
  tab_user_entity_name(4)       := 'ROE_INSURABLE_EARNING_4';
  tab_user_entity_name(5)       := 'ROE_INSURABLE_EARNING_5';
  tab_user_entity_name(6)       := 'ROE_INSURABLE_EARNING_6';
  tab_user_entity_name(7)       := 'ROE_INSURABLE_EARNING_7';
  tab_user_entity_name(8)       := 'ROE_INSURABLE_EARNING_8';
  tab_user_entity_name(9)       := 'ROE_INSURABLE_EARNING_9';
  tab_user_entity_name(10)      := 'ROE_INSURABLE_EARNING_10';
  tab_user_entity_name(11)      := 'ROE_INSURABLE_EARNING_11';
  tab_user_entity_name(12)      := 'ROE_INSURABLE_EARNING_12';
  tab_user_entity_name(13)      := 'ROE_INSURABLE_EARNING_13';
  tab_user_entity_name(14)      := 'ROE_INSURABLE_EARNING_14';
  tab_user_entity_name(15)      := 'ROE_INSURABLE_EARNING_15';
  tab_user_entity_name(16)      := 'ROE_INSURABLE_EARNING_16';
  tab_user_entity_name(17)      := 'ROE_INSURABLE_EARNING_17';
  tab_user_entity_name(18)      := 'ROE_INSURABLE_EARNING_18';
  tab_user_entity_name(19)      := 'ROE_INSURABLE_EARNING_19';
  tab_user_entity_name(20)      := 'ROE_INSURABLE_EARNING_20';
  tab_user_entity_name(21)      := 'ROE_INSURABLE_EARNING_21';
  tab_user_entity_name(22)      := 'ROE_INSURABLE_EARNING_22';
  tab_user_entity_name(23)      := 'ROE_INSURABLE_EARNING_23';
  tab_user_entity_name(24)      := 'ROE_INSURABLE_EARNING_24';
  tab_user_entity_name(25)      := 'ROE_INSURABLE_EARNING_25';
  tab_user_entity_name(26)      := 'ROE_INSURABLE_EARNING_26';
  tab_user_entity_name(27)      := 'ROE_INSURABLE_EARNING_27';
/* Added by ssmukher for bug 4510534 */
  tab_user_entity_name(28)      := 'ROE_INSURABLE_EARNING_28';
  tab_user_entity_name(29)      := 'ROE_INSURABLE_EARNING_29';
  tab_user_entity_name(30)      := 'ROE_INSURABLE_EARNING_30';
  tab_user_entity_name(31)      := 'ROE_INSURABLE_EARNING_31';
  tab_user_entity_name(32)      := 'ROE_INSURABLE_EARNING_32';
  tab_user_entity_name(33)      := 'ROE_INSURABLE_EARNING_33';
  tab_user_entity_name(34)      := 'ROE_INSURABLE_EARNING_34';
  tab_user_entity_name(35)      := 'ROE_INSURABLE_EARNING_35';
  tab_user_entity_name(36)      := 'ROE_INSURABLE_EARNING_36';
  tab_user_entity_name(37)      := 'ROE_INSURABLE_EARNING_37';
  tab_user_entity_name(38)      := 'ROE_INSURABLE_EARNING_38';
  tab_user_entity_name(39)      := 'ROE_INSURABLE_EARNING_39';
  tab_user_entity_name(40)      := 'ROE_INSURABLE_EARNING_40';
  tab_user_entity_name(41)      := 'ROE_INSURABLE_EARNING_41';
  tab_user_entity_name(42)      := 'ROE_INSURABLE_EARNING_42';
  tab_user_entity_name(43)      := 'ROE_INSURABLE_EARNING_43';
  tab_user_entity_name(44)      := 'ROE_INSURABLE_EARNING_44';
  tab_user_entity_name(45)      := 'ROE_INSURABLE_EARNING_45';
  tab_user_entity_name(46)      := 'ROE_INSURABLE_EARNING_46';
  tab_user_entity_name(47)      := 'ROE_INSURABLE_EARNING_47';
  tab_user_entity_name(48)      := 'ROE_INSURABLE_EARNING_48';
  tab_user_entity_name(49)      := 'ROE_INSURABLE_EARNING_49';
  tab_user_entity_name(50)      := 'ROE_INSURABLE_EARNING_50';
  tab_user_entity_name(51)      := 'ROE_INSURABLE_EARNING_51';
  tab_user_entity_name(52)      := 'ROE_INSURABLE_EARNING_52';
  tab_user_entity_name(53)      := 'ROE_INSURABLE_EARNING_53';
  tab_user_entity_name(54)      := 'ROE_TOTAL_INSURABLE_EARNINGS';
  tab_user_entity_name(55)      := 'ROE_PAY_PERIOD_TYPE';

  for cur_field in 1..55 loop

  if cur_field = 55 then

    l_value := l_period_type;
    l_user_entity_id := get_user_entity(tab_user_entity_name(cur_field));

  elsif cur_field = 54 then

    l_value := l_total_insurable;
    l_user_entity_id := get_user_entity(tab_user_entity_name(cur_field));

  else

/* Commented by ssmukher for Bug 4510534
    if ret = 'BOX15B' then
      hr_utility.trace('15B');
      l_value := '0';
    else
      hr_utility.trace('BOX15C');
      l_value := tab_period_total(cur_field);
    end if;
*/
    l_value := tab_period_total(cur_field);
    l_user_entity_id := get_user_entity(tab_user_entity_name(cur_field));

  end if;

  hr_utility.trace('user entity id = '|| to_char(l_user_entity_id));
  hr_utility.trace('l value = '|| l_value);

   ff_archive_api.create_archive_item(
        p_archive_item_id       => l_archive_item_id,
        p_user_entity_id        => l_user_entity_id,
        p_archive_value         => l_value,
        p_archive_type          => 'AAP',
        p_action_id             => p_assactid,
        p_legislation_code      => 'CA',
        p_object_version_number => l_object_version_number,
        p_some_warning          => l_some_warning);

  end loop;

  hr_utility.trace('End of archiving EI Earnings');

  -- As all the archiving is done now we lock
  -- the mag assignment_action_id of the l_assignment_amend
  -- with the new assignment-action_id

  if l_assignment_amend is not null then

    open cur_pai;
    fetch cur_pai into l_locking_action_id;
    close cur_pai;

    hr_nonrun_asact.insint(p_assactid,l_locking_action_id);

  end if;

  -- If the assignment set is passed we need to delete the
  -- assignment_id from the assignment set/and the assignment
  -- set it self where there is not record left in hr_assignment
  -- _set_amendments.

  IF l_assignment_set_id IS NOT NULL THEN

    pay_ca_archive.delete_asg_set_records(l_asg_set_name,
                                          l_assignment_id,
                                          l_business_group_id);
  ELSE

     -- If it's a Record of Employment for a sigle employee then
     -- we need to delete the assignment from the assignment sets.
     -- from both the assignment sets.

     pay_ca_archive.delete_asg_set_records('LOA_ASG_SET',
                                          l_assignment_id,
                                          l_business_group_id);

     pay_ca_archive.delete_asg_set_records('TERMINATION_ASG_SET',
                                          l_assignment_id,
                                          l_business_group_id);

  END IF;

  ELSE

    hr_utility.raise_error;

  END IF; -- check_retry_amend has failed or not.

end;

end archive_data;

function asg_set_exists (p_asg_set in varchar2,
                         p_business_group_id in number) return NUMBER IS
--
cursor c_set_check is
  SELECT assignment_set_id
  FROM    hr_assignment_sets
  WHERE   UPPER(assignment_set_name) = UPPER(p_asg_set)
  AND     business_group_id = p_business_group_id;
--
l_assignment_set_id hr_assignment_sets.assignment_set_id%TYPE;
--
begin
--
  OPEN  c_set_check;
  FETCH c_set_check
  INTO  l_assignment_set_id;

  IF c_set_check%FOUND then
     CLOSE c_set_check;
     RETURN l_assignment_set_id;
  ELSE
     CLOSE c_set_check;
     RETURN -1;
  END IF;
--
end asg_set_exists;
--
procedure create_asg_set_records(p_assignment_set_name in varchar2,
                                 p_assignment_id  in number,
                                 p_business_group_id in number) IS
begin

declare

  cursor c_sequence is
  SELECT hr_assignment_sets_s.nextval
  FROM dual;

  l_assignment_set_id hr_assignment_sets.assignment_set_id%TYPE;

  CURSOR c_already_in_set is
  SELECT 'X'
  FROM   hr_assignment_set_amendments
  WHERE  assignment_id = p_assignment_id
  AND    assignment_set_id = l_assignment_set_id
  AND    include_or_exclude = 'I';

  l_dummy VARCHAR2(1);
  l_rowid        VARCHAR2(30);

--
begin

  -- If Assignment set already exists then we need to add the assigment
  -- into the assigment set, ELSE we need to create the assignment set
  -- and then add the assignment to it.

  l_assignment_set_id := asg_set_exists(p_assignment_set_name,
                                        p_business_group_id);

  hr_utility.trace('l_assignment_set_id = ' || to_char(l_assignment_set_id));

  IF l_assignment_set_id <> -1 THEN

  OPEN c_already_in_set;
  FETCH c_already_in_set
  INTO l_dummy;
  IF c_already_in_set%NOTFOUND THEN

    CLOSE c_already_in_set;

    hr_utility.trace('Assignment id: ' || to_char(p_assignment_id) ||
           ' does not exist in the assignment set');

     hr_assignment_set_amds_pkg.insert_row(
       p_rowid               => l_rowid
      ,p_assignment_id       => p_assignment_id
      ,p_assignment_set_id   => l_assignment_set_id
      ,p_include_or_exclude  => 'I');
  ELSE
     hr_utility.trace('Assignment id: ' || to_char(p_assignment_id) ||
           ' already exists in the assignment set');
     CLOSE c_already_in_set;

  END IF;

  ELSE -- Assignment set doesn't exists so we need to create the assignment
       -- set as well.

    OPEN c_sequence;
    FETCH c_sequence into l_assignment_set_id;
    CLOSE c_sequence;

    hr_assignment_sets_pkg.insert_row(
      p_rowid               => l_rowid,
      p_assignment_set_id   => l_assignment_set_id,
      p_business_group_id   => p_business_group_id,
      p_payroll_id          => '',
      p_assignment_set_name => p_assignment_set_name,
      p_formula_id          => null);

     hr_assignment_set_amds_pkg.insert_row(
       p_rowid               => l_rowid
      ,p_assignment_id       => p_assignment_id
      ,p_assignment_set_id   => l_assignment_set_id
      ,p_include_or_exclude  => 'I');

  END IF;

end;
--
end create_asg_set_records;
--
procedure delete_asg_set_records(p_assignment_set_name in VARCHAR2,
                                 p_assignment_id  in NUMBER,
                                 p_business_group_id NUMBER) IS
--
begin

declare

  CURSOR cur_asg_set_id IS
  SELECT assignment_set_id
  FROM   hr_assignment_sets
  WHERE  UPPER(assignment_set_name) = UPPER(p_assignment_set_name)
  AND    business_group_id = p_business_group_id;

  l_assignment_set_id  hr_assignment_sets.assignment_set_id%TYPE;

  CURSOR c_already_in_set IS
  SELECT 'X'
  FROM   hr_assignment_set_amendments
  WHERE  assignment_id = p_assignment_id
  AND    assignment_set_id = l_assignment_set_id
  AND    include_or_exclude = 'I';

  CURSOR cur_last_row IS
  SELECT 'X'
  FROM hr_assignment_set_amendments
  WHERE assignment_set_id = l_assignment_set_id;

--
l_dummy VARCHAR2(1);
--
begin
--
  hr_utility.trace(' Begin pay_ca_archive.delete_asg_set_records');

  OPEN cur_asg_set_id;
  FETCH cur_asg_set_id
  INTO l_assignment_set_id;

  IF cur_asg_set_id%FOUND then

   hr_utility.trace(' In delete_asg_set_records,  cur_asg_set_id found !');
   hr_utility.trace(' In delete_asg_set_records,  l_assignment_set_id =  '
                      || to_char(l_assignment_set_id));

   CLOSE cur_asg_set_id;
   OPEN  c_already_in_set;
   FETCH c_already_in_set
   INTO  l_dummy;

   IF c_already_in_set%FOUND THEN

     hr_utility.trace(' In delete_asg_set_records,  c_already_in_set found !');
     CLOSE c_already_in_set;

     DELETE FROM
       hr_assignment_set_amendments
     WHERE
       assignment_set_id = l_assignment_set_id and
       assignment_id = p_assignment_id;

     -- If this is the last row in hr_assignment_set_amendments
     -- then we need to delete the assignment set as well from
     -- hr_assignment_sets.

     OPEN cur_last_row;
     FETCH cur_last_row
     INTO  l_dummy;

     IF cur_last_row%ROWCOUNT = 0 then

       hr_utility.trace('In delete_asg_set_records cur_last_row = ' ||
                          to_char(cur_last_row%ROWCOUNT));

       CLOSE cur_last_row;

       DELETE FROM hr_assignment_sets
       where assignment_set_id = l_assignment_set_id;

     ELSE

       close cur_last_row;

     END IF;

   ELSE

      close c_already_in_set;

   END IF;

  ELSE

    CLOSE cur_asg_set_id;

  END IF;

END;
--
end delete_asg_set_records;
--
end pay_ca_archive;

/
