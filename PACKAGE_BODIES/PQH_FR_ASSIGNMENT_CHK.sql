--------------------------------------------------------
--  DDL for Package Body PQH_FR_ASSIGNMENT_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_ASSIGNMENT_CHK" As
/* $Header: pqasgchk.pkb 120.0 2005/05/29 01:25 appldev noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

g_fut_chk number;
procedure chk_Identifier(p_identifier in Varchar2)
IS
Cursor csr_identifier IS
Select null
from per_all_assignments_f asg,
     hr_soft_coding_keyflex scl
where asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and   scl.segment23 = p_identifier;
-- As in Update Case Never Identifier is gonna change and we are not supporting
-- Any PUI Updates we need't have to check the assignment_id <> current_assignment_id
-----
l_temp varchar2(10);
Begin
     If p_identifier is not null then
      Open csr_identifier;
      Fetch csr_identifier into l_temp;
      If csr_identifier%FOUND Then
       --
        fnd_message.set_name('PQH','PQH_FR_IDENTIFIER_EXIST');
        hr_multi_message.add();
       --
      End If;
      Close csr_identifier;
     End if;
--
End chk_Identifier;

procedure chk_percent_affected(p_percent_effected in varchar2, p_person_id in number, p_effective_date in date, p_assignment_id number default Null)
IS
l_percent_affected number;
l_fut_start_date date;

Cursor csr_future_eff is
select effective_start_date
from per_all_assignments_f assign
where effective_start_date > p_effective_date
and person_id = p_person_id
And assign.primary_flag = 'N';

Begin

 l_percent_affected := fnd_number.canonical_to_number(p_percent_effected);

 If (l_percent_affected <=0 Or l_percent_affected >100 ) Then
    ---
      fnd_message.set_name('PQH','PQH_FR_INVALID_PERCENTAGE');
      hr_multi_message.add();
    --
 End If;
  g_fut_chk := 0;
 chk_tot_percent_affected(p_percent_effected,p_person_id,p_effective_date,p_assignment_id);

open csr_future_eff;
loop
 fetch csr_future_eff into l_fut_start_date;
 exit when csr_future_eff%notfound ;
 g_fut_chk := 1;
 chk_tot_percent_affected(p_percent_effected,p_person_id,l_fut_start_date,p_assignment_id);
end loop;
 g_fut_chk := 0;
close csr_future_eff;

 --
End chk_percent_affected;

procedure chk_tot_percent_affected(p_percent_effected in varchar2, p_person_id in number, p_effective_date in date, p_assignment_id number default Null)
IS
l_percent_affected number;
l_tot_percent_affected number;
l_asg_percent_affected number;
l_proc varchar2(30);
Cursor csr_tot_percent_effected Is
Select Sum(nvl(scl.segment25,0)) Percenteffected
From  per_all_assignments_f assign,
      hr_soft_coding_keyflex scl
Where person_id = p_person_id
And assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
And assign.primary_flag = 'N'
And p_effective_date Between effective_start_date And effective_end_date
And assign.assignment_status_type_id = 1;

Cursor csr_asg_percent_effected Is
Select nvl(scl.segment25,0) Percenteffected
From  per_all_assignments_f assign,
      hr_soft_coding_keyflex scl
Where person_id = p_person_id
And assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
And assign.primary_flag = 'N'
And p_effective_date Between effective_start_date And effective_end_date
And assign.assignment_status_type_id = 1
and assign.assignment_id = p_assignment_id;

Begin
 l_proc := 'chk_tot_percent_affected';
 hr_utility.set_location(' Entering  '|| l_proc,10);
 l_percent_affected := fnd_number.canonical_to_number(p_percent_effected);

  if p_assignment_id is not null then
      Open csr_asg_percent_effected;
      Fetch csr_asg_percent_effected into l_asg_percent_affected;
      Close csr_asg_percent_effected;
  else
     l_asg_percent_affected := 0;
  end if;

  Open csr_tot_percent_effected;
  Fetch csr_tot_percent_effected into l_tot_percent_affected;
  If csr_tot_percent_effected%FOUND Then
  --
    l_tot_percent_affected := l_tot_percent_affected + l_percent_affected - l_asg_percent_affected;
    If (l_tot_percent_affected >100 ) Then
    --
      if nvl(g_fut_chk,0) = 0 then
         fnd_message.set_name('PQH','PQH_FR_TOT_PERCENTAGE');
      else
      fnd_message.set_name('PQH','PQH_FR_FUT_TOT_PERCENT');
      fnd_message.set_token('FUTDATE',to_char(p_effective_date));
      end if;
     hr_multi_message.add();
    --
    End If;
  --
  End If;
  Close csr_tot_percent_effected;
     --

  hr_utility.set_location(' Exiting  '|| l_proc,10);
 --
End chk_tot_percent_affected;

procedure chk_position(p_position_id in Number, p_person_id in Number,p_effective_date in DATE)
IS

Cursor csr_tit_pos IS
Select nvl(information1,'N')
from hr_all_positions_f
where position_id = p_position_id;
--
Cursor csr_person_info IS
Select per_information15
from per_all_people_f
where person_id =p_person_id
and p_effective_date between effective_start_date and effective_end_date;
---
l_titulaire_pos varchar2(10);
l_agent_type varchar2(10);

Begin

  Open csr_tit_pos;
    fetch csr_tit_pos into l_titulaire_pos;
  Close csr_tit_pos;

  Open csr_person_info;
    Fetch csr_person_info into l_agent_type;
  Close csr_person_info;

   If (l_agent_type = '01' ) then -- Functionnaire
     --
     If (l_titulaire_pos ='N') Then
     --
        fnd_message.set_name('PQH','PQH_FR_NOFONC_ON_NONTIT_POS');
        hr_multi_message.add();

     --
     End If;
  --
 End If;

End chk_position;

procedure chk_type(p_type in varchar2, p_person_id in Number, p_effective_date in DATE,p_position_id in Number)
IS
Cursor csr_person_info IS
Select per_information15
from per_all_people_f
where person_id =p_person_id
and p_effective_date between effective_start_date and effective_end_date;
--
Cursor csr_tit_pos IS
Select nvl(information1,'N')
from hr_all_positions_f
where position_id = p_position_id;
--
l_agent_type varchar2(10);
l_titulaire_pos varchar2(10);

Begin
---
-- For NonTitulaire : Getting placed on Titulare position and With Type Parmenant is not allowed
-- P Parmanent , T Temporary
  Open csr_person_info;
    Fetch csr_person_info into l_agent_type;
  Close csr_person_info;

  Open csr_tit_pos;
    fetch csr_tit_pos into l_titulaire_pos;
  Close csr_tit_pos;


   If (l_agent_type = '02' ) then -- Non Titulaire

     If (p_type = 'P') And (l_titulaire_pos = 'Y')   Then
   --
      fnd_message.set_name('PQH','PQH_FR_NOPERM_FOR_NONTIT');
      hr_multi_message.add();
   --
     End If;
    --
   End If;
---
End chk_type;

procedure chk_Primary_affectation(p_person_id in number, p_effective_date in date, p_admin_career_id in number)
IS

l_temp varchar2(10);
l_fut_start_date date;
-- Cursor to check if there exist any primary affectation at the effective date

Cursor is_primary_eff_exist_csr IS
Select null
from per_all_assignments_f asg, hr_soft_coding_keyflex scl
where segment26 = p_admin_career_id
and segment27 ='Y'
and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and asg.assignment_status_type_id <> 3;

-- Cursor to check if there exist any primary affectation at any future date

Cursor is_fut_primary_eff_exist_csr IS
Select effective_start_date
from per_all_assignments_f asg, hr_soft_coding_keyflex scl
where segment26 = p_admin_career_id
and segment27 ='Y'
and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and asg.effective_start_date > p_effective_date;

Begin

Open is_primary_eff_exist_csr;
  Fetch is_primary_eff_exist_csr into l_temp;
  If is_primary_eff_exist_csr%found then
  Close is_primary_eff_exist_csr;
   fnd_message.set_name('PQH', 'PQH_FR_TURN_OFF_EXISTING_PRI');
   hr_multi_message.add();
  End if;

Open is_fut_primary_eff_exist_csr;
loop
  Fetch is_fut_primary_eff_exist_csr into l_fut_start_date;
  Exit when is_fut_primary_eff_exist_csr%notfound;
   fnd_message.set_name('PQH','PQH_FR_FUT_PRIMARY_AFF');
   fnd_message.set_token('FUTUREDATE',to_char(l_fut_start_date));
   hr_multi_message.add();
end loop;

End chk_Primary_affectation;

procedure chk_situation(p_person_id in Number,
                        p_effective_date in DATE)
IS

Cursor csr_person_info IS
Select per_information15
from per_all_people_f
where person_id =p_person_id
and p_effective_date between effective_start_date and effective_end_date;

Cursor csr_situation_info IS
select ss.situation_type
from pqh_fr_emp_stat_situations ess,
     pqh_fr_stat_situations_v ss
where person_id = p_person_id
  and p_effective_date between actual_start_date and nvl(actual_end_date,provisional_end_date)
  and ess.statutory_situation_id = ss.statutory_situation_id;
--
l_agent_type varchar2(10);
l_situation_type varchar2(10);

Begin
---
  Open csr_person_info;
    Fetch csr_person_info into l_agent_type;
  Close csr_person_info;

    if (l_agent_type = '01') then
      Open csr_situation_info;
        Fetch csr_situation_info into l_situation_type;
      Close csr_situation_info;

      if l_situation_type <> 'IA' then
         if l_situation_type <> 'SC' then
           fnd_message.set_name('PQH', 'PQH_FR_NOT_ACT_SIT');
           hr_multi_message.add();
         end if;
      end if;
     end if;

End chk_situation;

   -- Enter further code below as specified in the Package spec.
END PQH_FR_ASSIGNMENT_CHK;

/
