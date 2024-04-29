--------------------------------------------------------
--  DDL for Package Body PQP_US_STUDENT_BEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_US_STUDENT_BEE" as
/* $Header: pqusstbe.pkb 120.0 2005/05/29 02:14:39 appldev noship $
  +============================================================================+
  |   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved     |
  |                                                                            |
  |   Description : Package and procedures to support Batch Element Entry      |
  |                 process for Student Eearnings.                             |
  |                                                                            |
  |   Change List                                                              |
  +=============+========+=======+========+====================================+
  | Date        |Name    |Ver    |Bug No  |Description                         |
  +=============+========+=======+========+====================================+
  | 23-SEP-2004 |tmehra  |115.0  |        |Created                             |
  | 10-DEC-2004 |hgattu  |115.5  |4094250 |                                    |
  | 14-FEB-2005 |hgattu  |115.6  |4180797 |                                    |
  |             |        |       |4181127 |                                    |
  | 18-FEB-2005 |hgattu  |115.7  |        | Aligned                            |
  | 07-MAR-2005 |rpinjala|115.9  |4219848 |                                    |
  | 25-APR-2005 |rpinjala|115.11 |        |Added loop for processing multiple  |
  |             |        |       |        |awards for a student.               |
  | 26-APR-2005 |rpinjala|115.12 |        |removed the close stu_cur cursor.   |
  | 26-APR-2005 |rpinjala|115.12 |4350673 |Default values for the input values |
  |             |        |       |        |Ded. Processing and separate check  |
  |             |        |       |        |                                    |
  |             |        |       |        |                                    |
  +=============+========+=======+========+====================================+
*/

-- =============================================================================
-- Package body Global Variables
-- =============================================================================
  g_debug boolean;
  g_pkg constant varchar2(150) :='PQP_US_Student_BEE.';
-- =============================================================================
-- Package body Cursors
-- =============================================================================

  -- Cursor to get lookup meaning.
  cursor csr_lookup_meaning
        (p_lookup_type in varchar2
        ,p_lookup_code in varchar2)is
  select meaning
    from fnd_lookup_values_vl
   where lookup_type = p_lookup_type
     and upper(lookup_code) = upper(p_lookup_code);

  -- Cursor to get the input value id(s) for an element.
  cursor  csr_ipv_id (c_ele_type_id    in number
                     ,c_effective_date in date) is
  select piv.input_value_id
        ,piv.name
        ,piv.display_sequence
        ,piv.lookup_type
        ,piv.max_value
        ,piv.min_value
        ,piv.default_value
        ,piv.warning_or_error
   from pay_input_values_f piv
  where piv.element_type_id = c_ele_type_id
    and c_effective_date between piv.effective_start_date
                             and piv.effective_end_date
     order by piv.display_sequence;
   -- Cursor to get all Student Earnings Element in a given date range.
   Cursor csr_chk_ele (c_assignment_id  in number
                      ,c_bg_id          in number
                      ,c_start_date     in date
                      ,c_end_date       in date ) is
   Select  distinct
			        pel.element_type_id
          ,pee.element_entry_id
          ,pel.element_link_id
     From  pay_element_entries_f   pee
          ,pay_element_links_f     pel
          ,per_all_assignments_f   paf
     Where (c_end_date between pee.effective_start_date
                           and pee.effective_end_date
            or
            pee.effective_end_date between c_start_date
                                       and c_end_date
            )
      and pee.assignment_id     = c_assignment_id
      and (c_end_date between pel.effective_start_date
                          and pel.effective_end_date
            or
            pel.effective_end_date between c_start_date
                                       and c_end_date
            )
      and pee.element_link_id   = pel.element_link_id
      and pel.element_type_id   in
           (Select pet.element_type_id
              From pay_element_types_f pet
             Where pet.element_information_category = 'US_EARNINGS'
               and pet.business_group_id = c_bg_id
               and pet.element_information1 ='SE'
               and c_end_date between pet.effective_start_date
                                  and pet.effective_end_date)
      and paf.assignment_id     = pee.assignment_id
      and paf.business_group_id = c_bg_id
      and pel.business_group_id = c_bg_id
      and c_end_date between paf.effective_start_date
                         and paf.effective_end_date
      order by pee.element_entry_id desc;

   -- Cursor to get the Screen entry value for the input values
   Cursor csr_entry_val (c_element_entry_id in Number
                        ,c_start_date       in Date
                        ,c_end_date         in Date
                        ,c_input_value_id   in Number
                        ) Is
   Select pev.screen_entry_value
     from pay_element_entry_values_f pev
    where pev.input_value_id   = c_input_value_id
      and pev.element_entry_id = c_element_entry_id
      and (c_end_date between pev.effective_start_date
                          and pev.effective_end_date
           or
          (pev.effective_end_date   >= c_start_date and
           pev.effective_start_date <= c_end_date)
           )
      order by pev.effective_start_date desc;

   -- Get the ipv id for an ipv name of an element
   cursor  ipv_id (c_ele_type_id in number
                  ,c_ipv_name    in varchar2) is
   select piv.input_value_id
         ,piv.name
     from pay_input_values_f piv
    where piv.element_type_id = c_ele_type_id
      and piv.name = c_ipv_name
      order by piv.display_sequence;
   -- Get the latest start and end date for the element entry id.
   Cursor entry_date (c_element_entry_id in Number
                     ,c_assignment_id    in Number) is
   select max(pee.effective_start_date)
         ,max(pee.effective_end_date)
     from pay_element_entries_f pee
    where pee.assignment_id = c_assignment_id
      and pee.element_entry_id = c_element_entry_id;

   -- Define the record structure for holding the elements input names.
   type input_values_rec is record
        (input_value_id     number(10)
        ,name               pay_input_values_f.name%type
        ,screen_entry_value pay_element_entry_values_f.screen_entry_value%type
        ,display_sequence   pay_input_values_f.display_sequence%type
        ,lookup_type        pay_input_values_f.lookup_type%type
        ,default_value      pay_input_values_f.default_value%type
        ,max_value          pay_input_values_f.max_value%type
        ,min_value          pay_input_values_f.min_value%type
        ,warning_or_error   pay_input_values_f.warning_or_error%type
        );
   -- Record type declaration
   type t_input_values is table of input_values_rec
                       index by binary_integer;

-- =============================================================================
-- Get_Lookup_Meaning: function returns the values of the look up meaning
-- =============================================================================
function Get_Lookup_Meaning
         (p_lookup_type in varchar2
         ,p_lookup_code in varchar2
         ) return varchar2 is
  l_lookup_meaning  fnd_lookup_values_vl.meaning%type;
  l_proc_name   varchar2(150) := g_pkg ||'Get_Lookup_Meaning';
begin
    hr_utility.set_location('Entering: '||l_proc_name, 5);
    open csr_lookup_meaning
         (p_lookup_type => p_lookup_type
         ,p_lookup_code => p_lookup_code);
    fetch csr_lookup_meaning into l_lookup_meaning;
    close csr_lookup_meaning;
    hr_utility.set_location('Leaving: '||l_proc_name, 80);
    return l_lookup_meaning;

end Get_Lookup_Meaning;
-- =============================================================================
-- Check_Input_Values:
-- =============================================================================
Procedure Check_Input_Values(p_ipv_rec_new In Out NoCOpy t_input_values
                            ,p_ipv_rec_old In Out NoCOpy t_input_values
                            ) Is

 l_proc_name   varchar2(150) := g_pkg ||'Check_Input_Values';

Begin
    hr_utility.set_location('Entering: '||l_proc_name, 5);
    For i in 1..15
    Loop
      For j in 1..15
      Loop
       If Upper(p_ipv_rec_old(i).name) = Upper(p_ipv_rec_new(j).name) Then
          If p_ipv_rec_new(j).screen_entry_value is Null Then
             hr_utility.set_location('Old IPV: '||p_ipv_rec_old(i).screen_entry_value, 5);
             hr_utility.set_location('New IPV: '||p_ipv_rec_new(j).screen_entry_value, 5);
             p_ipv_rec_new(j).screen_entry_value
                 := p_ipv_rec_old(i).screen_entry_value;
             Exit;
          End If;
       End If;
      End Loop;
    End Loop;
    hr_utility.set_location('Leaving: '||l_proc_name, 60);
End Check_Input_Values;
-- =============================================================================
-- ~ Init_Ipv_Rec: Used to re-set the values of the input names, before using it
-- ~ another element type id.
-- =============================================================================
Procedure Init_Ipv_Rec
          (p_ipv_rec_old in out nocopy t_input_values) is

Begin
  for i in 1..15
  loop
     p_ipv_rec_old(i).screen_entry_value := null;
     p_ipv_rec_old(i).input_value_id     := null;
     p_ipv_rec_old(i).name               := null;
     p_ipv_rec_old(i).display_sequence   := null;
     p_ipv_rec_old(i).lookup_type        := null;
     p_ipv_rec_old(i).default_value      := null;
     p_ipv_rec_old(i).max_value          := null;
     p_ipv_rec_old(i).min_value          := null;
  end loop;

End Init_Ipv_Rec;
-- =============================================================================
-- ~ Chk_If_Entry_Exists: Check if entry exist for the award ID already.
-- =============================================================================
procedure Chk_If_Entry_Exists
         (p_assignment_id     in number
         ,p_business_group_id in number
         ,p_effective_date    in date
         ,p_element_type_id   in number
         ,p_auth_id           in varchar2
         ,p_award_max_amt     in number
         ,p_ipv_val_tab       in out nocopy t_input_values
         ,p_award_paid        in out nocopy boolean
         ,p_award_amt_adj     in out nocopy boolean
          ) is

  l_ipv_rec_old       t_input_values;

  l_proc_name         constant varchar2(150) := g_pkg||'Chk_If_Entry_Exists';
  l_start_date        Date;
  l_end_date          Date;
  l_ele_entry_st_date Date;
  l_ele_entry_ed_date Date;
  l_new_Maxdiff_amt   Number;
  l_authId_ipv_id     pay_input_values_f.input_value_id%TYPE;
  l_awdId_name        pay_input_values_f.name%TYPE;
  l_authId_ipv_value  pay_element_entry_values_f.screen_entry_value%TYPE;

  l_maxAmt_ipvId      pay_input_values_f.input_value_id%TYPE;
  l_maxAmt_name       pay_input_values_f.name%TYPE;
  l_maxAmt_ipv_value  pay_element_entry_values_f.screen_entry_value%TYPE;
  l_count number;

Begin

  hr_utility.set_location('Entering: '||l_proc_name, 5);
  p_award_paid    := false;
  p_award_amt_adj := false;
  -- We have to back one year for the assignment to see if the same auth id
  -- was already given to the student and end dated already.
  l_start_date    := add_months(p_effective_date,-12);
  l_end_date      := p_effective_date;
  l_count         := 0;

  Init_Ipv_Rec(l_ipv_rec_old);

  hr_utility.set_location(' l_start_date: '|| l_start_date,6);
  hr_utility.set_location(' l_end_date: '|| l_end_date,6);

  -- Check for all the past one years Student Earnings to see if the student
  -- has been paid for this work authorization already.
  For prv_awds in csr_chk_ele
                    (c_assignment_id  => p_assignment_id
                    ,c_bg_id          => p_business_group_id
                    ,c_start_date     => l_start_date
                    ,c_end_date       => l_end_date )
  Loop
     -- Check if the element has an input call Authorization ID
     If g_debug Then
     hr_utility.set_location(' Element Type Id: '|| prv_awds.element_type_id,6);
     hr_utility.set_location(' Element Entry Id: '|| prv_awds.element_entry_id,6);
     hr_utility.set_location(' Element Link Id: '|| prv_awds.element_link_id,6);
     End If;
     Open ipv_id (prv_awds.element_type_id
                 ,'Authorization ID');
    Fetch ipv_id Into l_authId_ipv_id, l_awdId_name;
    Close ipv_id;

    Open ipv_id (prv_awds.element_type_id
                ,'Maximum Amount');
    Fetch ipv_id Into l_maxAmt_ipvId,l_maxAmt_name;
    Close ipv_id;
    If g_debug Then
     hr_utility.set_location(' l_maxAmt_name: '|| l_maxAmt_name,9);
     hr_utility.set_location(' l_maxAmt_ipvId: '|| l_maxAmt_ipvId,9);
     hr_utility.set_location(' l_awdId_name: '|| l_awdId_name,7);
     hr_utility.set_location(' l_authId_ipv_id: '|| l_authId_ipv_id,7);
    End If;
    If l_maxAmt_ipvId Is Null or l_authId_ipv_id Is Null Then
       Goto Next_Element;
    End If;
    -- Get the Auth Id screen entry value
    Open csr_entry_val (c_element_entry_id => prv_awds.element_entry_id
                       ,c_start_date       => l_start_date
                       ,c_end_date         => l_end_date
                       ,c_input_value_id   => l_authId_ipv_id
                        );
    Fetch csr_entry_val Into l_authId_ipv_value;
    Close csr_entry_val;
    hr_utility.set_location(' l_authId_ipv_value: '|| l_authId_ipv_value,8);

    -- Get the Max. Auth Amount screen entry value
    Open csr_entry_val(c_element_entry_id => prv_awds.element_entry_id
                      ,c_start_date       => l_start_date
                      ,c_end_date         => l_end_date
                      ,c_input_value_id   => l_maxAmt_ipvId);
    Fetch csr_entry_val Into l_maxAmt_ipv_value;
    Close csr_entry_val;
    hr_utility.set_location(' l_maxAmt_ipv_value: '|| l_maxAmt_ipv_value,10);

    -- Check if the Student had already gotten the authorization paid in the
    -- past one year.
    If l_authId_ipv_value is not null and
       l_authId_ipv_value <> p_auth_id Then
       Goto Next_Element;
    End If;

    -- Get the start and end date for the element entry id.
    Open  entry_date(prv_awds.element_entry_id
                    ,p_assignment_id);
    Fetch entry_date Into l_ele_entry_st_date, l_ele_entry_ed_date;
    Close entry_date;
    If g_debug Then
     hr_utility.set_location(' l_ele_entry_st_date: '|| l_ele_entry_st_date,10);
     hr_utility.set_location(' l_ele_entry_ed_date: '|| l_ele_entry_ed_date,10);
    End If;
    -- Auth Id are same, now check the amounts.
    If p_award_max_amt > to_number(l_maxAmt_ipv_value)  and
       l_ele_entry_ed_date < l_end_date Then
       l_new_Maxdiff_amt := (p_award_max_amt - to_number(l_maxAmt_ipv_value));
       p_award_amt_adj := True;
       hr_utility.set_location(' p_award_amt_adj: TRUE', 11);
       For i in 1..15
       Loop
         if p_ipv_val_tab(i).name ='Maximum Amount' Then
            p_ipv_val_tab(i).screen_entry_value := l_new_Maxdiff_amt;
            exit;
         End if;
       End Loop;
    Elsif p_award_max_amt = to_number(l_maxAmt_ipv_value)  and
          l_ele_entry_ed_date < l_end_date Then
          p_award_paid := True;
          hr_utility.set_location(' p_award_paid: TRUE', 11);
          Exit;
    Elsif p_award_max_amt = to_number(l_maxAmt_ipv_value)  and
          p_effective_date Between l_ele_entry_st_date and
                                   l_ele_entry_ed_date Then
          hr_utility.set_location(' Entry Already Exists', 11);
          p_award_paid := True;
          Exit;
    End If;

    If p_element_type_id = prv_awds.element_type_id Then
       If g_debug Then
       hr_utility.set_location(' p_element_type_id: '||p_element_type_id, 12);
       hr_utility.set_location(' prv_awds.element_type_id: '||prv_awds.element_type_id, 12);
       End If;
       l_ipv_rec_old := p_ipv_val_tab;
    Else
       -- Means the element type is diff. even though the both the
       -- the same name for auth id and max amount.
       For ipv_rec in csr_ipv_id
                     (c_ele_type_id    => prv_awds.element_type_id
                     ,c_effective_date => p_effective_date)
       Loop
        l_count := l_count + 1;
        l_ipv_rec_old(l_count).input_value_id   := ipv_rec.input_value_id;
        l_ipv_rec_old(l_count).name             := ipv_rec.name;
        l_ipv_rec_old(l_count).display_sequence := ipv_rec.display_sequence;
        l_ipv_rec_old(l_count).lookup_type      := ipv_rec.lookup_type;
        l_ipv_rec_old(l_count).default_value    := ipv_rec.default_value;
        l_ipv_rec_old(l_count).max_value        := ipv_rec.max_value;
        l_ipv_rec_old(l_count).min_value        := ipv_rec.min_value;
        l_ipv_rec_old(l_count).warning_or_error := ipv_rec.warning_or_error;
       End Loop;
       l_count := 0;
    End If; -- If p_element_type_id
    --
    For i in 1..15
    Loop
       Open csr_entry_val
           (c_element_entry_id => prv_awds.element_entry_id
           ,c_start_date       => l_ele_entry_st_date
           ,c_end_date         => l_ele_entry_ed_date
           ,c_input_value_id   => l_ipv_rec_old(i).input_value_id);
       Fetch csr_entry_val Into l_ipv_rec_old(i).screen_entry_value;
       If g_debug Then
       hr_utility.set_location(' IPV Name: '||l_ipv_rec_old(i).name, 13);
       hr_utility.set_location(' IPV Value: '||l_ipv_rec_old(i).screen_entry_value, 13);
       end if;
       Close csr_entry_val;
    End loop;
    Check_Input_Values(p_ipv_val_tab,l_ipv_rec_old);
    Exit;
    <<Next_Element>>

    l_count := 0; l_new_Maxdiff_amt:= 0;
    Init_Ipv_Rec(l_ipv_rec_old);
    l_authId_ipv_id    := Null; l_awdId_name       := Null;
    l_maxAmt_ipvId     := Null; l_maxAmt_name      := Null;
    l_authId_ipv_value := Null; l_maxAmt_ipv_value := Null;
    l_ele_entry_st_date:= Null; l_ele_entry_ed_date:= Null;

  End Loop; --For prv_awds
  hr_utility.set_location('Leaving: '||l_proc_name, 80);
exception
  when others then
  hr_utility.set_location('Leaving: '||l_proc_name, 90);

End Chk_If_Entry_Exists;

-- =============================================================================
-- ~ Create_Student_Batch_Entry: create student earnings batch header
-- =============================================================================
procedure Create_Student_Batch_Entry
         (errbuf              out nocopy varchar2
         ,retcode             out nocopy number
         ,p_effective_date     in varchar2
         ,p_earnings_type      in varchar2
         ,p_selection_criteria in varchar2
         ,p_business_group_id  in varchar2
         ,p_is_asg_set         in varchar2
         ,p_assignment_set     in varchar2
         ,p_is_ssn             in varchar2
         ,p_ssn                in varchar2
         ,p_is_person_group    in varchar2
         ,p_person_group_id    in varchar2
         ,p_element_type_id    in varchar2
         ) is

  -- ===========================================================================
  -- Cursor to get the Assignment ID and Assignment Number
  -- if the selection criteria is Person Group
  -- ===========================================================================
    cursor get_stu_details (c_ssn               in varchar2
                           ,c_business_group_id in number
                           ,c_effective_date    in date) is
    select paf.assignment_id,
           paf.assignment_number
      from per_people_f per,
           per_assignments_f paf
     where per.national_identifier = c_ssn
       and paf.assignment_type = 'E'
       and paf.primary_flag    = 'Y'
       and c_effective_date between per.effective_start_date
                                and per.effective_end_date
       and paf.person_id = per.person_id
       and per.business_group_id = c_business_group_id
       and c_effective_date between paf.effective_start_date
                                and paf.effective_end_date;

  -- ===========================================================================
  -- Cursor to get the element name for  element_type_id
  -- ===========================================================================
     cursor get_element_name (p_element_type_id number,
                              p_effective_date date) is
     select element_name
       from pay_element_types_f
      where element_type_id = p_element_type_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
  -- Type declarations
    type                       empcurtyp is ref cursor;
    pri_cur                    empcurtyp;
    stu_cur                    empcurtyp;
    l_ipv                      t_input_values;

  -- Boolean variables
    l_batch_header_created     boolean;
    l_award_paid               boolean;
    l_award_amt_adj            boolean;
  -- Varchar variables
    l_fund_code                varchar2(30);
    l_stusys_ssn               varchar2(30);
    l_earnings_type            varchar2(20);
    l_sqlstmt                  varchar2(1500);
    l_selcrs                   varchar2(1500);
    l_error_msg                varchar2(2000);

  -- Number variables
    l_ct                       number;
    l_new_batch                number;
    l_object_version_number    number;
    l_batch_line_id            number;
    l_auth_id                  number;
    l_auth_amt                 number;
    l_fund_id                  number;
    l_count                    number;
    l_st_date                  date;
    l_end_date                 date;
    l_effective_date           date;

  -- Type casted variables
    l_assignment_id            per_assignments_f.assignment_id%type;
    l_assignment_number        per_assignments_f.assignment_number%type;
    l_element_name             pay_element_types_f.element_name%type;
    l_person_id                per_people_f.person_id%type;
    l_ssn                      per_people_f.national_identifier%type;
    l_party_id                 per_people_f.party_id%type;
    l_proc_name    constant    varchar2(150) :=
                                'PQP_US_Student_BEE.Create_Student_Batch_Entry';

    -- =========================================================================
    -- Function to dynamically generate the the sql to get the person ids for
    -- the given person group id. Please note that these person ids are not same
    -- as per_people_f person_id instead these belong to student system.
    -- =========================================================================
    function Get_Person_ID
             (p_group_id in number
              ) return varchar2 is

     plsql_block varchar2(2000);
     partyids    varchar2(2000);
     l_status    varchar2(20);

    begin
     plsql_block :=
     'declare
       l_sql varchar2(2000);
      begin
      l_sql :=
      IGS_PE_Dynamic_Persid_Group.IGS_Get_Dynamic_Sql
      (p_groupid    => :1
      ,p_status     => :2
      );
      :3 := l_sql;
      end;' ;
     execute immediate plsql_block
     using p_group_id
          ,out l_status
          ,out partyids;

     return partyids;

    end Get_Person_ID;

begin -- Main

  hr_utility.set_location('Entering: '||l_proc_name, 5);
  if hr_utility.debug_enabled then
   g_debug := true;
  end if;

  hr_utility.set_location('p_effective_date: '||p_effective_date, 5);
  hr_utility.set_location('p_selection_criteria: '||p_selection_criteria, 5);
  hr_utility.set_location('p_business_group_id: '||p_business_group_id, 5);
  hr_utility.set_location('p_assignment_set: '||p_assignment_set, 5);
  hr_utility.set_location('p_ssn: '||p_ssn, 5);
  hr_utility.set_location('p_person_group_id: '||p_person_group_id, 5);
  hr_utility.set_location('p_element_type_id: '||p_element_type_id, 5);

  -- ===========================================================================
  -- ~ Assign default values to the local variables.
  -- ===========================================================================
  hr_utility.set_location('Assign default value to local variables ', 5);
  l_ct                   := 0;     l_person_id  := null;
  l_new_batch            := 0;     l_ssn        := null;
  l_object_version_number:= 0;     l_fund_code  := null;
  l_batch_line_id        := 0;     l_auth_id    := null;
  l_auth_amt             := null;  l_party_id   := null;
  l_batch_header_created := false;

  l_effective_date := fnd_date.canonical_to_date(p_effective_date);

  hr_utility.set_location('p_earnings_type: '||p_earnings_type, 10);
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
   l_earnings_type := 'FEDERAL';

  end if;

  hr_utility.set_location('l_earnings_type: '||l_earnings_type, 10);

  if p_selection_criteria = 'Assignment Set' then

     hr_utility.set_location('p_selection_criteria: '||p_selection_criteria, 11);
     -- If the selection criteria is an Assignment set then get all the employee
     -- assignments of those who are student employees within the assignment set.
     l_selcrs :=
       'select per.national_identifier,
               paf.assignment_id,
               paf.assignment_number,
               per.party_id
          from per_assignments_f paf,
               per_people_f per
         where paf.person_id = per.person_id
           and paf.assignment_type =''E''
           and paf.primary_flag=''Y''
           and :1 between paf.effective_start_date
                      and paf.effective_end_date
           and :2 between per.effective_start_date
                      and per.effective_end_date
           and per.business_group_id=:3
           and exists
               (select 1
                  from hr_assignment_set_amendments hasa
                  where hasa.assignment_set_id = :4
                    and hasa.assignment_id = paf.assignment_id
                    and upper(hasa.include_or_exclude) = ''I'')
           and exists
                (select 1
                   from per_people_extra_info pei
                  where pei.person_id        = per.person_id
                    and pei.information_type = ''PQP_OSS_PERSON_DETAILS'')';

     open pri_cur  for l_selcrs
                 using l_effective_date
                      ,l_effective_date
                      ,p_business_group_id
                      ,to_number(p_assignment_set);

  elsif p_selection_criteria = 'OSS Student Person Group' then

     hr_utility.set_location('p_selection_criteria: '||p_selection_criteria, 12);
     -- If the selection criteris is an OSS Person Group, then call the dynamic
     -- sql to get the list of student party ids and match those with the
     -- party id in per_all_people_f.
     l_selcrs := get_person_id(to_number(p_person_group_id));
     open pri_cur for l_selcrs;

  elsif p_selection_criteria = 'ALL' then

     hr_utility.set_location('p_selection_criteria: '||p_selection_criteria, 13);
     -- To get the awards details from OSS for all the student employees
     -- within the business group id.
     l_selcrs :=
       'select per.national_identifier,
               paf.assignment_id,
               paf.assignment_number,
               per.party_id
          from per_assignments_f paf,
               per_people_f per
         where paf.person_id = per.person_id
           and :1 between paf.effective_start_date
                                    and paf.effective_end_date
           and :2 between per.effective_start_date
                                    and per.effective_end_date
           and per.business_group_id=:3
           and paf.assignment_type =''E''
           and paf.primary_flag=''Y''
           and exists
                (select 1
                   from per_people_extra_info pei
                  where pei.person_id        = per.person_id
                    and pei.information_type = ''PQP_OSS_PERSON_DETAILS'')';

     open pri_cur for l_selcrs
                using l_effective_date
                     ,l_effective_date
                     ,p_business_group_id;

  elsif p_selection_criteria = 'Social Security Number' then

     hr_utility.set_location('p_selection_criteria: '||p_selection_criteria, 14);
     -- Get the Student award details for the given social security number.
     l_selcrs :=
       'select per.national_identifier,
               paf.assignment_id,
               paf.assignment_number,
               per.party_id
          from per_people_f      per,
               per_assignments_f paf
         where per.national_identifier = :1
           and :2 between per.effective_start_date
                      and per.effective_end_date
           and paf.person_id = per.person_id
           and :3 between paf.effective_start_date
                      and paf.effective_end_date
           and per.business_group_id=:4
           and paf.assignment_type =''E''
           and paf.primary_flag=''Y''
           and exists  (select 1
                          from per_people_extra_info pei
                         where pei.person_id        = per.person_id
                           and pei.information_type = ''PQP_OSS_PERSON_DETAILS'')';

     open pri_cur for l_selcrs
                using p_ssn
                     ,l_effective_date
                     ,l_effective_date
                     ,p_business_group_id;
  end if;

  l_batch_header_created := false;
  hr_utility.set_location('Delete the PL/SQL table and create null records ', 15);
  l_ipv.delete;
  for i in 1..15
  loop
     l_ipv(i).screen_entry_value := null;
     l_ipv(i).input_value_id     := null;
     l_ipv(i).name               := null;
     l_ipv(i).display_sequence   := null;
     l_ipv(i).lookup_type        := null;
     l_ipv(i).default_value      := null;
     l_ipv(i).max_value          := null;
     l_ipv(i).min_value          := null;
  end loop;
  -- Get the input value names for the earnings element
  l_count := 0;
  hr_utility.set_location('Assign the input names to the PL/SQL table ', 15);
  for ipv_rec in csr_ipv_id(c_ele_type_id    => p_element_type_id
                           ,c_effective_date => l_effective_date)
  loop
      l_count := l_count + 1;
      l_ipv(l_count).input_value_id   := ipv_rec.input_value_id;
      l_ipv(l_count).name             := ipv_rec.name;
      l_ipv(l_count).display_sequence := ipv_rec.display_sequence;
      l_ipv(l_count).lookup_type      := ipv_rec.lookup_type;
      l_ipv(l_count).default_value    := ipv_rec.default_value;
      l_ipv(l_count).max_value        := ipv_rec.max_value;
      l_ipv(l_count).min_value        := ipv_rec.min_value;
      l_ipv(l_count).warning_or_error := ipv_rec.warning_or_error;
  end loop;

  -- The Main Cursor Loop starts here.
  loop
    if p_selection_criteria = 'OSS Student Person Group' then
       fetch pri_cur into l_party_id;
    else
       fetch pri_cur into l_ssn,
                          l_assignment_id,
                          l_assignment_number,
                          l_party_id;
    end if;
    --
    if g_debug then
      hr_utility.set_location('Assignment Set ID'||p_assignment_set, 15);
      hr_utility.set_location('SSN :'||l_ssn, 15);
      hr_utility.set_location('Assignment ID :'||l_assignment_id, 15);
      hr_utility.set_location('Assignment Number: '||l_assignment_number, 15);
      hr_utility.set_location('Party ID: '||l_party_id, 15);
      hr_utility.set_location('Person ID: '||l_person_id, 15);
      hr_utility.set_location('Element Name: '||l_element_name, 15);
    end if;
    -- If no more students left then, exit.
    exit when pri_cur%notfound;

    -- Create the BEE header and set the flag value to true.
    if not l_batch_header_created then

      hr_utility.set_location('Create the BEE header', 16);
      -- Create the Batch Element Entry Header need execute this code only once.
      pay_batch_element_entry_api.create_batch_header
      (p_session_date         => l_effective_date
      ,p_batch_name           => 'OSS Batch '||rtrim(fnd_global.conc_request_id)
      ,p_business_group_id    => to_number(p_business_group_id)
      ,p_action_if_exists     => 'R'
      ,p_batch_reference      => 'OSS Batch '||rtrim(fnd_global.conc_request_id)
      ,p_batch_source         => 'Student Systems Fin Aid'
      ,p_batch_id             => l_new_batch
      ,p_object_version_number=> l_object_version_number
       );
      for cele in get_element_name (to_number(p_element_type_id)
                                   ,l_effective_date)
      loop
          l_element_name := cele.element_name;
      end loop;
      l_batch_header_created := true;

    end if;
    --
    if stu_cur%ISOPEN then
       close stu_cur;
    end if;
    if p_selection_criteria = 'OSS Student Person Group' then
       -- If selection criteria is OSS Person Group ,then we have only party_id
       -- now so we need to have different query for this criteria and get
       -- the same financial aid details
       l_sqlstmt :=
          'select authorization_id,
                  authorized_amt,
                  fund_id,
                  authorization_start_date,
                  authorization_end_date,
                  social_security_number
             from igf_se_authorization_v
            where person_id            = nvl(:1, person_id)
              and sys_fund_source_code = nvl(:2, sys_fund_source_code)';

       open stu_cur for l_sqlstmt
                  using l_party_id
                       ,l_earnings_type;
    else
       l_sqlstmt :=
         'select authorization_id,
                 authorized_amt,
                 fund_id,
                 authorization_start_date,
                 authorization_end_date,
                 social_security_number
             from igf_se_authorization_v
           where social_security_number = nvl(:1, social_security_number)
             and person_id              = nvl(:2, person_id)
             and sys_fund_source_code   = nvl(:3, sys_fund_source_code)';

       open stu_cur for l_sqlstmt
                  using l_ssn
                       ,l_party_id
                       ,l_earnings_type;
    end if;
    --

    loop -- loop thru all the work study awards
      fetch stu_cur into  l_auth_id,
                          l_auth_amt,
                          l_fund_id,
                          l_st_date,
                          l_end_date,
                          l_stusys_ssn;
      --
      exit when stu_cur%notfound;
      --
      if g_debug then
        hr_utility.set_location('Authorization ID: '||l_auth_id, 20);
        hr_utility.set_location('Amount: '||l_auth_amt, 20);
        hr_utility.set_location('FundId: '||l_fund_id, 20);
        hr_utility.set_location('Auth Start Date: '||l_st_date, 20);
        hr_utility.set_location('SSN: '||l_stusys_ssn, 20);
        hr_utility.set_location('Auth End Date: '||l_end_date, 20);
      end if;
      --
      if stu_cur%found then
         -- Get assignment details in case if the selection criteria
         -- is Person Group.
         if p_selection_criteria = 'OSS Student Person Group' then
            for c1 in get_stu_details ( l_stusys_ssn
                                       ,p_business_group_id
                                       ,l_effective_date
                                       )
            loop
              l_assignment_id     := c1.assignment_id;
              l_assignment_number := c1.assignment_number;
            end loop;
         end if;
         hr_utility.set_location('Assign input values from OSS: ', 25);
         -- Assign the proper values to each input value of the element entry
         for i in 1..15
         loop
            if    l_ipv(i).name = 'Amount' then
                  l_ipv(i).screen_entry_value := null;

            elsif l_ipv(i).name = 'Jurisdiction' then
                  l_ipv(i).screen_entry_value := null;

            elsif l_ipv(i).name = 'Deduction Processing' then
                  l_ipv(i).screen_entry_value := get_lookup_meaning
                                                  ('US_DEDUCTION_PROCESSING'
                                                   ,l_ipv(i).default_value);
            elsif l_ipv(i).name = 'Separate Check' then
                  l_ipv(i).screen_entry_value := get_lookup_meaning
                                                  ('YES_NO'
                                                   ,l_ipv(i).default_value);

            elsif l_ipv(i).name = 'Authorization ID' then
                  l_ipv(i).screen_entry_value := l_auth_id;

            elsif l_ipv(i).name = 'Student Earnings Type' then
                  l_ipv(i).screen_entry_value
                     := get_lookup_meaning('PQP_US_STUDENT_EARNINGS_TYPE'
                                           ,p_earnings_type);
            elsif l_ipv(i).name = 'Authorization Start Date' then
                  l_ipv(i).screen_entry_value := l_st_date;

            elsif l_ipv(i).name = 'Authorization End Date' then
                  l_ipv(i).screen_entry_value := l_end_date;

            elsif l_ipv(i).name = 'Fund ID' then
                  l_ipv(i).screen_entry_value := l_fund_id;

            elsif l_ipv(i).name = 'Maximum Amount' then
                  l_ipv(i).screen_entry_value := l_auth_amt;
            end if;
         end loop;
         -- Check if the Auth. Id is already created.
         Chk_If_Entry_Exists
         (p_assignment_id     => l_assignment_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => l_effective_date
         ,p_element_type_id   => p_element_type_id
         ,p_ipv_val_tab       => l_ipv
         ,p_auth_id           => l_auth_id
         ,p_award_max_amt     => l_auth_amt
         ,p_award_paid        => l_award_paid
         ,p_award_amt_adj     => l_award_amt_adj
         );
         If not l_award_paid Then
         -- Increment the batch sequence
         l_ct := l_ct + 1;
         hr_utility.set_location('Calling : PAY_Batch_Element_Entry_API.Create_Batch_Line', 26);
         PAY_Batch_Element_Entry_API.Create_Batch_Line
         (p_session_date         => l_effective_date
         ,p_batch_id             => l_new_batch
         ,p_assignment_id        => l_assignment_id
         ,p_assignment_number    => l_assignment_number
         ,p_batch_sequence       => l_ct
         ,p_effective_date       => l_effective_date
         ,p_effective_start_date => l_effective_date
         ,p_element_name         => l_element_name
         ,p_element_type_id      => to_number(p_element_type_id)
         ,p_value_1              => l_ipv(1).screen_entry_value
         ,p_value_2              => l_ipv(2).screen_entry_value
         ,p_value_3              => l_ipv(3).screen_entry_value
         ,p_value_4              => l_ipv(4).screen_entry_value
         ,p_value_5              => l_ipv(5).screen_entry_value
         ,p_value_6              => l_ipv(6).screen_entry_value
         ,p_value_7              => l_ipv(7).screen_entry_value
         ,p_value_8              => l_ipv(8).screen_entry_value
         ,p_value_9              => l_ipv(9).screen_entry_value
         ,p_value_10             => l_ipv(10).screen_entry_value
         ,p_value_11             => l_ipv(11).screen_entry_value
         ,p_value_12             => l_ipv(12).screen_entry_value
         ,p_value_13             => l_ipv(13).screen_entry_value
         ,p_value_14             => l_ipv(14).screen_entry_value
         ,p_value_15             => l_ipv(15).screen_entry_value
         ,p_batch_line_id        => l_batch_line_id
         ,p_object_version_number=> l_object_version_number
          );
         End If;
      end if; --if stu_cur%found
      hr_utility.set_location('Re-set the entry values for next record ', 27);
      for i in 1..15
      loop
         l_ipv(i).screen_entry_value := null;
      end loop;

    end loop; -- loop for each auth id for a student

  end loop;
  close pri_cur;

  hr_utility.set_location('leaving: '||l_proc_name, 80);
  -- Commit the records in the BEE tables.
  commit;

exception
  when others then
   l_error_msg := sqlerrm;
   Hr_Utility.set_location('SQLCODE :'||SQLCODE,90);
   Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   Hr_Utility.raise_error;


end Create_Student_Batch_Entry;

end;

/
