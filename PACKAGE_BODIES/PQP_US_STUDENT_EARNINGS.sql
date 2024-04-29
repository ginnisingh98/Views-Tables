--------------------------------------------------------
--  DDL for Package Body PQP_US_STUDENT_EARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_US_STUDENT_EARNINGS" as
/* $Header: pqustrfe.pkb 120.0 2005/05/29 02:15:16 appldev noship $
  +============================================================================+
  |   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved     |
  |                                                                            |
  |   Description : Package and procedures to support Batch Element Entry      |
  |                 process for Student Eearnings.                             |
  |                                                                            |
  |   Change List                                                              |
  +=============+=========+=======+========+===================================+
  | Date        |Name     | Ver   |Bug No  |Description                        |
  +=============+=========+=======+========+===================================+
  | 23-SEP-2004 |tmehra   |115.0  |        |Created                            |
  | 03-FEB-2004 |hgattu   |115.5  |4158766 |record type changes                |
  | 10-FEB-2005 |hgattu   |115.6  |4094250 |                                   |
  | 14-FEB-2005 |hgattu   |115.7  |4180797 |                                   |
  |             |         |       |4181127 |                                   |
  | 16-FEB-2005 |hgattu   |115.8  |4187138 |                                   |
  | 18-FEB-2005 |hgattu   |115.9  |4192747 |                                   |
  | 25-FEB-2005 |rpinjala |115.10 |        |Retro-pay actions added.           |
  |             |         |       |        |removed entry_type (E,V,B)         |
  | 25-FEB-2005 |rpinjala |115.11 |        |Retro-pay changes.                 |
  | 21-MAR-2005 |rpinjala |115.12 |        |Added comments to the header       |
  |             |         |       |        |                                   |
  |             |         |       |        |                                   |
  +=============+=========+=======+========+===================================+
*/
-- =============================================================================
-- Package body Global Variables
-- =============================================================================
  g_debug boolean;
  g_pkg   Varchar2(150) := 'PQP_US_Student_Earnings.';
-- =============================================================================
-- ~ Transfer_Student_Earnings
-- =============================================================================
procedure Transfer_Student_Earnings
          (errbuf              out nocopy varchar2
          ,retcode             out nocopy number
          ,p_begin_date_paid    in varchar2
          ,p_end_date_paid      in varchar2
          ,p_earnings_type      in varchar2
          ,p_selection_criteria in varchar2
          ,p_business_group_id  in varchar2
          ,p_is_asg_set         in varchar2
          ,p_assignment_set     in varchar2
          ,p_is_ssn             in varchar2
          ,p_ssn                in varchar2
          ,p_is_person_group    in varchar2
          ,p_person_group_id    in varchar2
          ,p_element_selection  in varchar2
          ,p_is_element_name    in varchar2
          ,p_element_type_id    in varchar2
          ,p_is_element_set     in varchar2
          ,p_element_set_id     in varchar2
          ) is

  -- ==========================================================================
  -- Cursor to get the run result value for given input_value_id and
  -- element_type_id along with assignment_action_id for (P)rocessed actions.
  -- ==========================================================================
     cursor c_get_run_value (p_asg_action_id    in number
                            ,p_element_type_id  in number
                            ,p_effective_date   in date
                            ,p_input_value_name in varchar2) is
     select prv.result_value
       from pay_run_results       prr
           ,pay_run_result_values prv
      where prr.assignment_action_id = p_asg_action_id
        and prr.element_type_id      = p_element_type_id
        and prv.input_value_id in
           (select distinct input_value_id
              from pay_input_values_f
             where element_type_id = p_element_type_id
               and p_effective_date between effective_start_date
                                        and effective_end_date
               and name = p_input_value_name)
        and prv.run_result_id        = prr.run_result_id;

     -- To Get the party id of the person as of the date or award earnings
     cursor c_party_id (c_asssignment_id in number
                       ,c_effective_date in date) Is
     select per.party_id
       from per_people_f per,
            per_assignments_f paf
      where per.person_id              = paf.person_id
        and paf.assignment_id          = c_asssignment_id
        and c_effective_date between per.effective_start_date
                                 and per.effective_end_date
        and c_effective_date between paf.effective_start_date
                                 and paf.effective_end_date;
      -- Ref. Cursors
      type    prigrpcur is ref cursor;
      pri_grp_cur prigrpcur;
      type    empcurtyp is ref cursor;
      pri_cur empcurtyp;

      -- Booleans
      l_batch_header_created     boolean := false;
      -- Numbers Variables
      l_ct                       number  :=0;
      l_new_batch                number  :=0;
      l_object_version_number    number  :=0;
      l_batch_line_id            number  :=0;
      l_transaction_id           number;
      l_msg_count                number;
      l_auth_id                  number  := null;
      l_auth_amt                 number  := null;
      l_fund_id                  number;
      l_authorization_number     number;
      l_paid_amount              number;
      l_person_id                number  := null;
      l_intial_value             number  :=1;
      -- Varchar2 Variables
      l_earnings_type            varchar2(20);
      l_sqlstmt                  varchar2(2500);
      l_selcrs                   varchar2(4500);
      l_grp_selcrs               varchar2(4500);
      l_return_status            varchar2(200);
      l_msg_data                 varchar2(200);
      plsql_block                varchar2(2500);
      l_fund_code                varchar2(30):= null;
      l_stusys_ssn               varchar2(30);
      l_chk_earnings_type        varchar2(20);
      l_grp_party_list_id        varchar2(9000);
      -- Dates
      l_effective_date           date;
      l_st_date                  date;
      l_end_date                 date;
      l_date_earned              date;
      -- Type declarations variables
      l_grp_party_id             per_people_f.party_id%type := null;
      l_chk_grp_party_id         per_people_f.party_id%type := null;
      l_ssn                      per_people_f.national_identifier%type  := null;
      l_assignment_id            per_assignments_f.assignment_id%type;
      l_assignment_action_id     pay_assignment_actions.assignment_action_id%type;
      l_element_type_id          pay_element_types_f.element_type_id%type;
      l_tax_unit_id              pay_assignment_actions.tax_unit_id%type;
      l_payroll_id               pay_payroll_actions.payroll_id%type;

      l_proc_name   constant     varchar2(150):= g_pkg||'Transfer_Student_Earnings';

      -- =======================================================================
      -- Function to dynamically generate the the sql to get the person ids for
      -- the given person group id. Please note that these person ids are not
      -- same as per_people_f person_id instead these belong to student system.
      -- =======================================================================
      function get_person_id
               (p_group_id in number) return varchar2 is
         plsql_block varchar2(2000);
         partyids    varchar2(2000);
         l_status    varchar2(20);
         l_proc_name constant varchar2(150) := g_pkg||'get_person_id';
      begin
        hr_utility.set_location('Entering: '||l_proc_name, 5);
        plsql_block :=
        ' declare
            l_sql varchar2(2000);
          begin
            l_sql :=
            igs_pe_dynamic_persid_group.igs_get_dynamic_sql
            (p_groupid    => :1
            ,p_status     => :2
            );
            :3 := l_sql;
          end;' ;
          execute immediate plsql_block
          using p_group_id
               ,out l_status
               ,out partyids;
       hr_utility.set_location('Leaving: '||l_proc_name, 80);
       return partyids;
      end get_person_id;

begin

  hr_utility.set_location('Entering: '||l_proc_name, 5);
  if hr_utility.debug_enabled then
   g_debug := true;
  end if;

  -- Translating the earnings type code as used in by the Student Financial Aid
  -- Module. For HRMS its PQP_US_STUDENT_EARNINGS_TYPE and for OSS Fin. Aid its
  -- IGF_AW_FUND_SOURCE.

  if p_earnings_type = 'IWS' then
   l_earnings_type := 'INSTITUTIONAL';

  elsif p_earnings_type = 'FWS' then
   l_earnings_type := 'FEDERAL';

  elsif p_earnings_type = 'SWS' then
   l_earnings_type := 'STATE';

  elsif p_earnings_type = 'GSS' then
   l_earnings_type := 'ENDOWMENT';

  elsif p_earnings_type = 'ESE' then
   l_earnings_type := 'OUTSIDE';

  else
   l_earnings_type := p_earnings_type;
  end if;

  if g_debug then
    hr_utility.set_location('Selection Criteria : '||p_selection_criteria, 15);
    hr_utility.set_location('Element Selection  : '||p_element_selection, 15);
    hr_utility.set_location('Business Group Id  : '||p_business_group_id, 15);
    hr_utility.set_location('Element Type Id    : '||p_element_type_id, 15);
    hr_utility.set_location('SSN                : '||p_ssn, 15);
    hr_utility.set_location('l_earnings_type    : '||l_earnings_type, 15);
  end if;

  if p_selection_criteria = 'Assignment Set' then

    if p_element_selection = 'Element Name' then
       l_selcrs :=
          'select paa.assignment_id
                 ,paa.assignment_action_id
                 ,paa.tax_unit_id
                 ,ppa.date_earned
                 ,ppa.payroll_id
                 ,prr.element_type_id

             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
                 ,pay_run_results        prr
            where ppa.action_status        = ''C''
              and paa.action_status        = ''C''
              and paa.payroll_action_id    = ppa.payroll_action_id
              and ppa.business_group_id    = :1
              and ppa.action_type in
                  (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
              and ppa.date_earned between :2
                                      and :3
              and prr.assignment_action_id = paa.assignment_action_id
              and prr.status   in (''P'',''PA'')
              and prr.element_type_id = :4
               and exists
                   (select 1
                      from hr_assignment_set_amendments hasa
                     where hasa.assignment_set_id = :5
                       and hasa.assignment_id = paa.assignment_id
                       and upper(hasa.include_or_exclude) = ''I'')';

       open pri_cur for l_selcrs
                    using to_number(p_business_group_id)
                   ,fnd_date.canonical_to_date(p_begin_date_paid)
                   ,fnd_date.canonical_to_date(p_end_date_paid)
                   ,to_number(p_element_type_id)
                   ,to_number(p_assignment_set);
    else
       l_selcrs :=
          'select paa.assignment_id
                 ,paa.assignment_action_id
                 ,paa.tax_unit_id
                 ,ppa.date_earned
                 ,ppa.payroll_id
                 ,prr.element_type_id

             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
                 ,pay_run_results        prr
            where ppa.action_status        = ''C''
              and paa.action_status        = ''C''
              and paa.payroll_action_id    = ppa.payroll_action_id
              and ppa.business_group_id    = :1
              and ppa.action_type in
                  (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
              and ppa.date_earned between :2
                                      and :3
              and prr.assignment_action_id = paa.assignment_action_id
              and prr.status  in (''P'',''PA'')
              and prr.element_type_id in
                    (select distinct petr.element_type_id
                       from pay_element_type_rules petr
                      where petr.element_set_id     = :4
                        and petr.include_or_exclude = ''I''
                     union all
                     select distinct pet1.element_type_id
                       from pay_element_types_f pet1
                      where pet1.classification_id in
                             (select classification_id
                                from pay_ele_classification_rules
                               where element_set_id = :5)
                     minus
                     select distinct petr.element_type_id
                       from pay_element_type_rules petr
                      where petr.element_set_id     = :6
                        and petr.include_or_exclude = ''E''
                    )
               and exists
                   (select 1
                      from hr_assignment_set_amendments hasa
                     where hasa.assignment_set_id = :7
                       and hasa.assignment_id = paa.assignment_id
                       and upper(hasa.include_or_exclude) = ''I'')';

       open pri_cur for l_selcrs
                    using to_number(p_business_group_id)
                   ,fnd_date.canonical_to_date(p_begin_date_paid)
                   ,fnd_date.canonical_to_date(p_end_date_paid)
                   ,to_number(p_element_set_id)
                   ,to_number(p_element_set_id)
                   ,to_number(p_element_set_id)
                   ,to_number(p_assignment_set);

    end if;-- if p_element_selection

  elsif p_selection_criteria = 'OSS Student Person Group' then

      -- Call OSS Dynamic SQL to get the party_ids for groupid
      l_grp_selcrs := get_person_id(to_number(p_person_group_id));
      open pri_grp_cur for l_grp_selcrs;
      loop
        fetch pri_grp_cur into l_grp_party_id;
        exit when pri_grp_cur%notfound;
        -- Exit,if previous and current partyId is same
        if nvl(l_grp_party_id, l_chk_grp_party_id) = l_chk_grp_party_id then
           exit;
        end if;
        -- if l_intial_value  is 1 then adding the ( to form the in statement
        if l_intial_value = 1 then
           l_grp_party_list_id := '(' ||l_grp_party_id ;
        else
           l_grp_party_list_id := l_grp_party_list_id||','||l_grp_party_id;
        end if;
        l_intial_value := l_intial_value+1;
        l_chk_grp_party_id := l_grp_party_id;
      end loop;

      close pri_grp_cur;

      if l_grp_party_list_id is not null then

         l_grp_party_list_id := l_grp_party_list_id ||')';
         hr_utility.set_location('Group PartyId List: '||l_grp_party_list_id, 15);

         if p_element_selection = 'Element Name' then

           l_selcrs :=
            'select paa.assignment_id
                 ,paa.assignment_action_id
                 ,paa.tax_unit_id
                 ,ppa.date_earned
                 ,ppa.payroll_id
                 ,prr.element_type_id

             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
                 ,pay_run_results        prr
            where ppa.action_status     = ''C''
              and paa.action_status     = ''C''
              and paa.payroll_action_id = ppa.payroll_action_id
              and ppa.business_group_id = ' || p_business_group_id || '
              and ppa.action_type in
                   (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
              and ppa.date_earned
                    between '||''''|| fnd_date.canonical_to_date(p_begin_date_paid) ||''''|| '
                        and '||''''|| fnd_date.canonical_to_date(p_end_date_paid) ||''''|| '
              and prr.assignment_action_id = paa.assignment_action_id
              and prr.status in (''P'',''PA'')
              and prr.element_type_id = '|| p_element_type_id ||'
              and exists
                  (select 1
                     from per_people_extra_info pei,
                          per_people_f per ,
                          per_assignments_f paf
                    where pei.person_id = per.person_id
                      and paf.person_id = per.person_id
                      and paf.assignment_id = paa.assignment_id
                      and ppa.date_earned between per.effective_start_date
                                              and per.effective_end_date
                      and ppa.date_earned between paf.effective_start_date
                                              and paf.effective_end_date
                      and paf.assignment_type =''E''
                      and paf.primary_flag=''Y''
                      and pei.information_type = ''PQP_OSS_PERSON_DETAILS''
                      and per.party_id  in ' || l_grp_party_list_id || '
                      and per.business_group_id= ' || p_business_group_id || '
                   )';
            open pri_cur for l_selcrs;

         else
            l_selcrs :=
            'select paa.assignment_id
                   ,paa.assignment_action_id
                   ,paa.tax_unit_id
                   ,ppa.date_earned
                   ,ppa.payroll_id
                   ,prr.element_type_id

               from pay_assignment_actions paa
                   ,pay_payroll_actions    ppa
                   ,pay_run_results        prr
              where ppa.action_status     = ''C''
                and paa.action_status     = ''C''
                and paa.payroll_action_id = ppa.payroll_action_id
                and ppa.business_group_id = ' || p_business_group_id || '
                and ppa.action_type in
                     (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
                and ppa.date_earned
                      between '||''''|| fnd_date.canonical_to_date(p_begin_date_paid) ||''''|| '
                          and '||''''|| fnd_date.canonical_to_date(p_end_date_paid) ||''''|| '
                and prr.assignment_action_id = paa.assignment_action_id
                and prr.status IN (''P'',''PA'')
                and prr.element_type_id in
                   (select distinct petr.element_type_id
                      from pay_element_type_rules petr
                     where petr.element_set_id     = ' || p_element_set_id || '
                       and petr.include_or_exclude = ''I''
                    union all
                    select distinct pet1.element_type_id
                      from pay_element_types_f pet1
                     where pet1.classification_id in
                           (select classification_id
                              from pay_ele_classification_rules
                             where element_set_id = ' || p_element_set_id || ')
                    minus
                    select distinct petr.element_type_id
                      from pay_element_type_rules petr
                     where petr.element_set_id     = ' || p_element_set_id || '
                       and petr.include_or_exclude = ''E''
                    )
               and exists
                   (select 1
                      from per_people_extra_info pei,
                           per_people_f          per ,
                           per_assignments_f     paf
                     where pei.person_id = per.person_id
                       and paf.person_id = per.person_id
                       and paf.assignment_id = paa.assignment_id
                       and ppa.date_earned between per.effective_start_date
                                               and per.effective_end_date
                       and ppa.date_earned between paf.effective_start_date
                                               and paf.effective_end_date
                       and paf.assignment_type  =''E''
                       and paf.primary_flag     =''Y''
                       and pei.information_type = ''PQP_OSS_PERSON_DETAILS''
                       and per.party_id  in ' || l_grp_party_list_id || '
                       and per.business_group_id=' || p_business_group_id || ' )';

            open pri_cur for l_selcrs ;

         end if;--if p_element_selection
      end if;-- if l_grp_party_list_id

  elsif p_selection_criteria = 'ALL' then

      if p_element_selection = 'Element Name' then
         l_selcrs :=
          'select paa.assignment_id
                 ,paa.assignment_action_id
                 ,paa.tax_unit_id
                 ,ppa.date_earned
                 ,ppa.payroll_id
                 ,prr.element_type_id

             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
                 ,pay_run_results        prr
            where ppa.action_status        = ''C''
              and paa.action_status        = ''C''
              and paa.payroll_action_id    = ppa.payroll_action_id
              and ppa.business_group_id    = :1
              and ppa.action_type in
                  (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
              and ppa.date_earned between :2
                                      and :3
              and prr.assignment_action_id = paa.assignment_action_id
              and prr.status IN (''P'',''PA'')
              and prr.element_type_id = :4
              and exists
                   (select 1
                      from per_people_extra_info pei,
                           per_assignments_f paf
                     where pei.person_id        = paf.person_id
                       and pei.information_type = ''PQP_OSS_PERSON_DETAILS''
                       and paf.assignment_id    = paa.assignment_id)';

         open pri_cur for l_selcrs
                      using to_number(p_business_group_id)
                     ,fnd_date.canonical_to_date(p_begin_date_paid)
                     ,fnd_date.canonical_to_date(p_end_date_paid)
                     ,to_number(p_element_type_id);
      else
         l_selcrs :=
          'select paa.assignment_id
                 ,paa.assignment_action_id
                 ,paa.tax_unit_id
                 ,ppa.date_earned
                 ,ppa.payroll_id
                 ,prr.element_type_id

             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
                 ,pay_run_results        prr
            where ppa.action_status        = ''C''
              and paa.action_status        = ''C''
              and paa.payroll_action_id    = ppa.payroll_action_id
              and ppa.business_group_id    = :1
              and ppa.action_type IN
                   (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
              and ppa.date_earned between :2
                                      and :3
              and prr.assignment_action_id = paa.assignment_action_id
              and prr.status  in (''P'',''PA'')
              and prr.element_type_id in
                   (select distinct petr.element_type_id
                      from pay_element_type_rules petr
                     where petr.element_set_id     = :4
                       and petr.include_or_exclude = ''I''
                    union all
                    select distinct pet1.element_type_id
                      from pay_element_types_f pet1
                     where pet1.classification_id in
                            (select classification_id
                               from pay_ele_classification_rules
                              where element_set_id = :5)
                    minus
                    select distinct petr.element_type_id
                      from pay_element_type_rules petr
                     where petr.element_set_id     = :6
                       and petr.include_or_exclude = ''E''
                   )
              and exists
                   (select 1
                      from per_people_extra_info pei,
                           per_assignments_f paf
                     where pei.person_id        = paf.person_id
                       and pei.information_type = ''PQP_OSS_PERSON_DETAILS''
                       and paf.assignment_id    = paa.assignment_id)';
         open pri_cur for l_selcrs
                      using to_number(p_business_group_id)
                     ,fnd_date.canonical_to_date(p_begin_date_paid)
                     ,fnd_date.canonical_to_date(p_end_date_paid)
                     ,to_number(p_element_set_id)
                     ,to_number(p_element_set_id)
                     ,to_number(p_element_set_id);
      end if;--if p_element_selection

  elsif p_selection_criteria = 'Social Security Number' then

      if p_element_selection = 'Element Name' then
         l_selcrs :=
          'select paa.assignment_id
                 ,paa.assignment_action_id
                 ,paa.tax_unit_id
                 ,ppa.date_earned
                 ,ppa.payroll_id
                 ,prr.element_type_id

             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
                 ,pay_run_results        prr
            where ppa.action_status        = ''C''
              and paa.action_status        = ''C''
              and paa.payroll_action_id    = ppa.payroll_action_id
              and ppa.business_group_id    = :1
              and ppa.action_type in
                   (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
              and ppa.date_earned between :2
                                      and :3
              and prr.assignment_action_id = paa.assignment_action_id
              and prr.status  IN (''P'',''PA'')
              and prr.element_type_id = :4
              and exists
                   (select 1
                      from per_people_extra_info pei,
                           per_people_f per ,
                           per_assignments_f paf
                     where pei.person_id = per.person_id
                       and paf.person_id = per.person_id
                       and paf.assignment_id = paa.assignment_id
                       and ppa.date_earned between per.effective_start_date
                                               and per.effective_end_date
                       and ppa.date_earned between paf.effective_start_date
                                               and paf.effective_end_date
                       and paf.assignment_type  = ''E''
                       and paf.primary_flag     = ''Y''
                       and pei.information_type = ''PQP_OSS_PERSON_DETAILS''
                       and per.national_identifier = :5
                       and per.business_group_id   = :6 )';

         open pri_cur for l_selcrs
                      using  to_number(p_business_group_id)
                     ,fnd_date.canonical_to_date(p_begin_date_paid)
                     ,fnd_date.canonical_to_date(p_end_date_paid)
                     ,to_number(p_element_type_id)
                     ,p_ssn
                     ,to_number(p_business_group_id);
      else
         l_selcrs :=
          'select paa.assignment_id
                 ,paa.assignment_action_id
                 ,paa.tax_unit_id
                 ,ppa.date_earned
                 ,ppa.payroll_id
                 ,prr.element_type_id

             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
                 ,pay_run_results        prr
            where ppa.action_status     = ''C''
              and paa.action_status     = ''C''
              and paa.payroll_action_id = ppa.payroll_action_id
              and ppa.business_group_id = :1
              and ppa.action_type in
                   (''Q'',''B'',''V'',''R'',''O'',''G'',''L'')
              and ppa.date_earned between :2
                                      and :3
              and prr.assignment_action_id = paa.assignment_action_id
              and prr.status IN (''P'',''PA'')
              and prr.element_type_id in
                  (select distinct petr.element_type_id
                     from pay_element_type_rules petr
                    where petr.element_set_id     = :4
                      and petr.include_or_exclude = ''I''
                   union all
                   select distinct pet1.element_type_id
                     from pay_element_types_f pet1
                    where pet1.classification_id in
                           (select classification_id
                              from pay_ele_classification_rules
                             where element_set_id = :5)
                   minus
                   select distinct petr.element_type_id
                     from pay_element_type_rules petr
                    where petr.element_set_id     = :6
                      and petr.include_or_exclude = ''E''
                  )
               and exists
                   (select 1
                      from per_people_extra_info pei,
                           per_people_f per ,
                           per_assignments_f paf
                     where pei.person_id = per.person_id
                       and paf.person_id = per.person_id
                       and paf.assignment_id = paa.assignment_id
                       and ppa.date_earned between per.effective_start_date
                                               and per.effective_end_date
                       and ppa.date_earned between paf.effective_start_date
                                               and paf.effective_end_date
                       and paf.assignment_type  =''E''
                       and paf.primary_flag     = ''Y''
                       and pei.information_type = ''PQP_OSS_PERSON_DETAILS''
                       and per.national_identifier = :7
                       and per.business_group_id   = :8
                    )';

         open pri_cur for l_selcrs
                      using  to_number(p_business_group_id)
                     ,fnd_date.canonical_to_date(p_begin_date_paid)
                     ,fnd_date.canonical_to_date(p_end_date_paid)
                     ,to_number(p_element_set_id)
                     ,to_number(p_element_set_id)
                     ,to_number(p_element_set_id)
                     ,p_ssn
                     ,to_number(p_business_group_id);

      end if; --if p_element_selection

  end if; --if p_selection_criteria

  if g_debug then
     hr_utility.set_location(' Start of Main Loop ', 20);

  end if;

  loop -- Start: Main Cursor
     fetch pri_cur into l_assignment_id,
                        l_assignment_action_id,
                        l_tax_unit_id,
                        l_date_earned,
                        l_payroll_id,
                        l_element_type_id;
     exit when pri_cur%notfound;
     --
     if g_debug then
       hr_utility.set_location('Assignment Id: '||l_assignment_id, 21);
       hr_utility.set_location('Assignment Action Id: '||l_assignment_action_id, 21);
       hr_utility.set_location('Tax Unit Id: '||l_tax_unit_id, 21);
       hr_utility.set_location('Payroll ID: '||l_payroll_id, 21);
       hr_utility.set_location('Element Type Id: '||l_element_type_id, 21);
     end if;
     -- Process the record if the Earnings Type matches
     for c_rec in c_get_run_value (l_assignment_action_id
                                  ,l_element_type_id
                                  ,l_date_earned
                                  ,'Student Earnings Type')
     loop
        l_chk_earnings_type := c_rec.result_value;
     end loop;
     if nvl(p_earnings_type, l_chk_earnings_type) <> l_chk_earnings_type then
        -- raise error;
        hr_utility.set_location('l_chk_earnings_type: '||l_chk_earnings_type, 21);
        hr_utility.set_location('p_earnings_type: '||p_earnings_type, 21);
        exit;
     end if;
     -- Get Authorization Number
     l_authorization_number := null;
     for c_rec in c_get_run_value (l_assignment_action_id
                                  ,l_element_type_id
                                  ,l_date_earned
                                  ,'Authorization ID')
     loop
         l_authorization_number := c_rec.result_value;
     end loop;
     -- Get Paid Amount
     l_paid_amount := 0;
     for c_rec in c_get_run_value (l_assignment_action_id
                                  ,l_element_type_id
                                  ,l_date_earned
                                  ,'Pay Value')
     loop
          l_paid_amount := l_paid_amount + c_rec.result_value;
     end loop;
     -- Get Person Id from Student System, i.e. party_id
     open c_party_id (c_asssignment_id => l_assignment_id
                     ,c_effective_date => l_date_earned);
     fetch c_party_id into  l_person_id;
     hr_utility.set_location('Stu Party Id: '||l_person_id, 22);

     if c_party_id%found then
        if g_debug then
          hr_utility.set_location('Payroll Id: '||l_payroll_id, 22);
          hr_utility.set_location('Date Earned: '||l_date_earned, 22);
          hr_utility.set_location('Authorization Number: '||l_authorization_number, 22);
          hr_utility.set_location('Party Id: '||l_person_id, 22);
          hr_utility.set_location('Paid Amount: '||l_paid_amount, 22);
          hr_utility.set_location('Tax Unit Id: '||l_tax_unit_id, 22);
        end if;
        --
        plsql_block :=
        'declare
           pay_rec igf_se_payment_pub.payment_rec_type;
         begin
           pay_rec.transaction_id          := :1;
           pay_rec.payroll_id              := :2;
           pay_rec.payroll_date            := :3;
           pay_rec.authorization_id        := :4;
           pay_rec.person_id               := :5;
           pay_rec.paid_amount             := :6;
           pay_rec.organization_unit_name  := :7;
           pay_rec.source                  := :8;

           igf_se_payment_pub.create_payment(
            p_init_msg_list        => Fnd_Api.G_TRUE
           ,p_payment_rec          => pay_rec
           ,x_transaction_id       => :9
           ,x_return_status        => :10
           ,x_msg_count            => :11
           ,x_msg_data             => :12
           );
        end;';
        execute immediate plsql_block
                using
                l_transaction_id
               ,l_assignment_action_id
               ,l_date_earned
               ,l_authorization_number
               ,l_person_id
               ,l_paid_amount
               ,l_tax_unit_id
               ,'ORACLE_HRMS'
               ,out l_transaction_id
               ,out l_return_status
               ,out l_msg_count
               ,out l_msg_data;

     end if;
     Close c_party_id;

     if g_debug then
        hr_utility.set_location(' l_transaction_id: '||l_transaction_id, 70);
        hr_utility.set_location(' l_return_status : '||l_return_status, 70);
     end if;
     l_transaction_id := null; l_msg_data := null;
     l_return_status  := null;
  end loop; -- end: main cursor
  close pri_cur;
  hr_utility.set_location('leaving: '||l_proc_name, 80);
  commit;

end Transfer_Student_Earnings;

end;

/
