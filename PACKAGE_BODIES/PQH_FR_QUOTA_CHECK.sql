--------------------------------------------------------
--  DDL for Package Body PQH_FR_QUOTA_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_QUOTA_CHECK" as
/* $Header: pqqutchk.pkb 120.1 2005/06/07 05:21 sankjain noship $ */

g_package  Varchar2(30) := 'PQH_FR_QUOTA_CHECK.';
g_business_group_id number;

 TYPE quota_rec IS
   RECORD (corp_id number,
           corp_name pqh_corps_definitions.name%type,
           grade_id number,
           grade_name per_grades.name%type,
           cur_per_app number,
           effective_date date);

TYPE quota_grid_table IS TABLE OF quota_rec
   INDEX BY BINARY_INTEGER;


g_quota_grid quota_grid_table;

procedure delete_rows is
l_proc varchar2(60) := g_package||'delete_rows';
begin
hr_utility.set_location('Entering into '||l_proc,10);
g_quota_grid.delete;
hr_utility.set_location('Leaving '||l_proc,10);
end ;

Procedure Update_grid(p_corp_id in number,
                      p_corp_name in varchar2,
                      p_grade_id in number,
                      p_grade_name in varchar2,
                      p_effective_date in date) is

l_number_of_rows number;
l_flag varchar2(1);
l_next_row number;
l_proc varchar2(60) := g_package||'Update_grid';
Begin
hr_utility.set_location('Entering into '||l_proc,10);

if NVL(g_quota_grid.LAST, 0) = 0 then
hr_utility.set_location('First row in the grid',10);
   g_quota_grid(1).corp_id := p_corp_id;
   g_quota_grid(1).corp_name := p_corp_name;
   g_quota_grid(1).grade_id := p_grade_id;
   g_quota_grid(1).grade_name := p_grade_name;
   g_quota_grid(1).cur_per_app := 1;
   g_quota_grid(1).effective_date := p_effective_date;
else
   l_number_of_rows := g_quota_grid.COUNT;
   FOR table_row IN 1 .. l_number_of_rows
   LOOP
      if ( g_quota_grid(table_row).corp_id = p_corp_id and
           g_quota_grid(table_row).grade_id = p_grade_id ) then

          g_quota_grid(table_row).cur_per_app := g_quota_grid(table_row).cur_per_app + 1;
          if g_quota_grid(table_row).effective_date > p_effective_date then
             g_quota_grid(table_row).effective_date := p_effective_date;
          end if;
          l_flag := 'Y';
          exit;
      else

          l_flag := 'N';

      end if;

   END LOOP;
   if l_flag = 'N' then
     l_next_row := NVL(g_quota_grid.LAST, 0) + 1;
     g_quota_grid(l_next_row).corp_id := p_corp_id;
     g_quota_grid(l_next_row).corp_name := p_corp_name;
     g_quota_grid(l_next_row).grade_id := p_grade_id;
     g_quota_grid(l_next_row).grade_name := p_grade_name;
     g_quota_grid(l_next_row).cur_per_app := 1;
     g_quota_grid(l_next_row).effective_date := p_effective_date;
   end if;

end if;
hr_utility.set_location('Leaving '||l_proc,10);
end Update_grid;

Function population_corp(p_corp_id number,
                         p_business_group_id number,
                         p_effective_date date) return number is

l_proc varchar2(60) := g_package||'population_corp';
l_corp_population number;
l_effective_date date;
l_corp_id number;

Begin
hr_utility.set_location('Entering into '||l_proc,5);
l_effective_date := p_effective_date;
l_corp_id := p_corp_id;

  Select count(asg.assignment_id)
 into   l_corp_population
 From Per_all_assignments_f asg,
      pqh_corps_definitions corp,
      per_all_people_f per
 Where asg.primary_flag = 'Y'
 And asg.business_group_id = p_business_group_id
 And asg.assignment_status_type_id in (1,2)
 And l_effective_date between asg.effective_start_date And asg.effective_end_date
 And asg.grade_ladder_pgm_id = corp.ben_pgm_id
 And corp.corps_definition_id = l_corp_id
 And per.person_id = asg.person_id
 And l_effective_date between per.effective_start_date And per.effective_end_date
 And per.per_information15 = '01';

hr_utility.set_location('Poplation for Corp'||to_char(l_corp_id)||': '||to_char(l_corp_population),5);
hr_utility.set_location('Leaving from '||l_proc,5);
Return l_corp_population;

End population_corp;

Function population_grade(p_corp_id number,
                        p_grade_id number,
                        p_business_group_id number,
                        p_effective_date date) return number is

l_grade_population number;
l_proc varchar2(60) := g_package||'population_grade';
l_effective_date date;
l_corp_id number;
l_grade_id number;
Begin
hr_utility.set_location('Entering into '||l_proc,5);

Select count(asg.assignment_id)
into l_grade_population
From Per_all_assignments_f asg,
     pqh_corps_definitions corp,
     per_all_people_f per
Where asg.primary_flag = 'Y'
And asg.business_group_id = p_business_group_id
And asg.assignment_status_type_id in (1,2)
And p_effective_date between asg.effective_start_date And asg.effective_end_date
And asg.grade_ladder_pgm_id = corp.ben_pgm_id
And corp.corps_definition_id = p_corp_id
And grade_id = p_grade_id
And per.person_id = asg.person_id
And p_effective_date between per.effective_start_date And per.effective_end_date
And per.per_information15 = '01';

hr_utility.set_location('Poplation for Grade '||to_char(p_grade_id)||' in corp '||to_char(p_corp_id)||': '||to_char(l_grade_population),5);

hr_utility.set_location('Leaving from '||l_proc,5);
Return l_grade_population;
End population_grade;

Function Quota_applicable (p_corp_id number,
                           p_effective_date date) return varchar2 is
l_proc varchar2(60) := g_package||'Quota_applicable';
l_quota_flag varchar2(1);
Begin

hr_utility.set_location('Entering into '||l_proc,5);

select nvl(pei.pgi_information1,'N') Quota_flag
into l_quota_flag
from ben_pgm_extra_info pei,
     pqh_corps_definitions corps
where pei.information_type = 'PQH_FR_CORP_INFO'
and pei.pgm_id = corps.ben_pgm_id
and corps.corps_definition_id = p_corp_id;


hr_utility.set_location('Leaving from '||l_proc,5);

return l_quota_flag;
  exception
      when no_data_found then
           return 'N';
End Quota_applicable;

Function Quota_occupancy (p_corp_id number,
                           p_grade_id number,
                           p_business_group_id number,
                           p_effective_date date) return number is
Cursor grade_condition is
Select Information4 Percentage,
Information8 cond_type,
Information30 Grade_ids
From pqh_corps_extra_info
Where corps_definition_id = p_corp_id
And information3 = p_grade_id
And information_type = 'GRADE';

l_percentage pqh_corps_extra_info.information30%type;
l_cond_type pqh_corps_extra_info.information30%type;
l_grade_ids pqh_corps_extra_info.information30%type;
l_Quota_occupancy number;
l_corps_population number;
l_grades_population number;
l_start number;
l_occurance number;
l_comma_pos number;
l_cond_grade_id number;
l_proc varchar2(60) := g_package||'Quota_occupancy';
Begin
hr_utility.set_location('Entering into '||l_proc,5);
    Open grade_condition;
    fetch grade_condition into l_percentage,l_cond_type,l_grade_ids;
    Close grade_condition;

    if l_percentage is null then
	hr_utility.set_location('No Quota defined for the Grade '||to_char(p_grade_id),5);
	 l_Quota_occupancy := null;
    elsif l_cond_type = 'CORPS' then
         hr_utility.set_location('Quota defined in percentage of Corp for Grade '||to_char(p_grade_id),5);
	 l_corps_population := population_corp(p_corp_id,
                         p_business_group_id ,
                        p_effective_date);
         l_quota_occupancy := floor(((l_percentage * l_corps_population)/100));
    elsif l_cond_type = 'COMB_GRADES' then
         hr_utility.set_location('Quota defined in percentage of combination of Grades for Grade '||to_char(p_grade_id),5);
         l_start:= 1;
         l_occurance := 1;
         l_comma_pos := instr(l_grade_ids,',',l_start,l_occurance);
         l_grades_population := 0;
         while l_comma_pos > 0
         loop

           l_cond_grade_id := to_number(substr(l_grade_ids,l_start,(l_comma_pos-l_start)));

           l_start := l_comma_pos+1;
           l_comma_pos := instr(l_grade_ids,',',l_start,l_occurance);
           l_grades_population := l_grades_population + population_grade(p_corp_id,
                        l_cond_grade_id,
                        p_business_group_id,
                        p_effective_date );

          end loop;
          l_cond_grade_id := to_number(substr(l_grade_ids,l_start));
          l_grades_population := l_grades_population + population_grade(p_corp_id,
                        l_cond_grade_id,
                        p_business_group_id,
                        p_effective_date );
          l_quota_occupancy := round(((l_percentage * l_grades_population)/100),0);

     end if;
hr_utility.set_location('Leaving from '||l_proc,5);
return l_Quota_occupancy;
end Quota_occupancy;

procedure quota_grid_formation(p_elctbl_chc_id in number,
                              p_effective_date date) is

l_proc varchar2(60) := g_package||'quota_grid_formation';
l_elctbl_chc_id number;
l_person_id number;
l_prop_prom_date date;

cursor elctbl_chc_det is
select pil.person_id person_id,
       corp.corps_definition_id corp_id,
       corp.name corp_name,
       elc.pgm_id program_id,
       grades.grade_id grade_id,
       grades.name grade_name,
       pil.business_group_id business_group_id
From ben_elig_per_elctbl_chc elc, ben_per_in_ler pil,
     ben_pl_f pl, per_grades grades,
     pqh_corps_definitions corp
Where elc.elig_per_elctbl_chc_id = l_elctbl_chc_id
and elc.per_in_ler_id = pil.per_in_ler_id
And grades.grade_id = pl.mapping_table_pk_id
And pl.mapping_table_name = 'PER_GRADES'
and p_effective_date between pl.effective_start_date and pl.effective_end_date
And corp.ben_pgm_id = elc.pgm_id
And pl.pl_id = elc.pl_id
and PER_IN_LER_STAT_CD = 'STRTD';

l_elctbl_chc_det_rec elctbl_chc_det%rowtype;

cursor person_cur_info is
select grade_ladder_pgm_id pgm_id,
       grade_id grade_id,
       per.per_information15 agent_type
from per_all_assignments_f asg,
     per_all_people_f per
where asg.person_id = l_elctbl_chc_det_rec.person_id
and primary_flag = 'Y'
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and p_effective_date between per.effective_start_date and per.effective_end_date
and per.person_id = asg.person_id;

Cursor business_group_info is
Select business_group_id, legislation_code
from   per_business_groups
where business_group_id = l_elctbl_chc_det_rec.business_group_id;

l_person_info person_cur_info%rowtype;
l_business_group_info business_group_info%rowtype;

begin
hr_utility.set_location('Entering into '||l_proc,5);
l_elctbl_chc_id := p_elctbl_chc_id;

if l_elctbl_chc_id is not null then

open elctbl_chc_det;
fetch elctbl_chc_det into l_elctbl_chc_det_rec;
close elctbl_chc_det;

end if;

open business_group_info;
fetch business_group_info into l_business_group_info;
close business_group_info;

if l_business_group_info.legislation_code = 'FR' then

 if Quota_applicable(l_elctbl_chc_det_rec.corp_id,p_effective_date) = 'Y' then

  open person_cur_info;
  fetch person_cur_info into l_person_info;
  close person_cur_info;

if l_person_info.agent_type = '01' then
  if (l_person_info.pgm_id <> l_elctbl_chc_det_rec.program_id
    or l_person_info.grade_id <> l_elctbl_chc_det_rec.grade_id ) then
     hr_utility.set_location('Before Update Grid Call',5);
    Update_grid(p_corp_id => l_elctbl_chc_det_rec.corp_id,
            p_corp_name => l_elctbl_chc_det_rec.corp_name,
            p_grade_id => l_elctbl_chc_det_rec.grade_id,
            p_grade_name => l_elctbl_chc_det_rec.grade_name,
            p_effective_date => p_effective_date );

   else
     hr_utility.set_location('No change in Grade',5);
   end if;
end if;

 end if;
end if;
hr_utility.set_location('Leaving from '||l_proc,5);
end quota_grid_formation;

procedure check_quota(p_business_group_id in number, p_return_status out nocopy varchar2) is

l_proc varchar2(60) := g_package||'check_quota';
l_number_of_rows number;
l_grade_cur_pop number;
l_quota_allowed number;
l_already_app number;
l_quota_allowed_char varchar2(10);
--l_return_status varchar2(1) := 'Y';
begin
hr_utility.set_location('Entering into '||l_proc, 10);
hr_multi_message.enable_message_list;
l_number_of_rows := g_quota_grid.COUNT;

if l_number_of_rows > 0 then
 For table_row in 1..l_number_of_rows
 loop
 if Quota_applicable(g_quota_grid(table_row).corp_id,g_quota_grid(table_row).effective_date) = 'Y' then

   hr_utility.set_location('checking Quota for Grade'||g_quota_grid(table_row).grade_name, 10);

     l_grade_cur_pop := population_grade(p_corp_id => g_quota_grid(table_row).corp_id ,
                                      p_grade_id => g_quota_grid(table_row).grade_id ,
                                      p_business_group_id => p_business_group_id,
                                      p_effective_date => g_quota_grid(table_row).effective_date);
     l_quota_allowed := Quota_occupancy (p_corp_id => g_quota_grid(table_row).corp_id ,
                                      p_grade_id => g_quota_grid(table_row).grade_id ,
                                      p_business_group_id => p_business_group_id,
                                      p_effective_date => g_quota_grid(table_row).effective_date);

      select count(elc.elig_per_elctbl_chc_id )
      into l_already_app
      from  ben_elig_per_elctbl_chc elc,
            ben_per_in_ler pil,
            ben_pl_f pl,
            pqh_corps_definitions corp
      where nvl(elc.approval_status_cd,'PQH_GSP_NP') = 'PQH_GSP_NP'
      and elc.in_pndg_wkflow_flag = 'Y'
      and pil.per_in_ler_id = elc.per_in_ler_id
      and pil.per_in_ler_stat_cd = 'STRTD'
      and corp.corps_definition_id = g_quota_grid(table_row).corp_id
      and elc.pgm_id = corp.ben_pgm_id
      and pl.mapping_table_name = 'PER_GRADES'
      and pl.mapping_table_pk_id = g_quota_grid(table_row).grade_id
      and g_quota_grid(table_row).effective_date between pl.effective_start_date and pl.effective_end_date
      and elc.pl_id = pl.pl_id
      and elc.business_group_id = p_business_group_id;


      if l_quota_allowed is not null then
          if ((l_quota_allowed - (l_grade_cur_pop + l_already_app + g_quota_grid(table_row).cur_per_app)) < 0 ) then

               if sign((l_quota_allowed - (l_grade_cur_pop + l_already_app ))) = -1 then
                   l_quota_allowed_char := '0';
               else
                    l_quota_allowed_char:= to_char((l_quota_allowed - (l_grade_cur_pop + l_already_app )));
               end if;

              fnd_message.set_name('PQH','PQH_FR_QUOTA_CHK_FAIL');
              fnd_message.set_token('CORP', g_quota_grid(table_row).corp_name);
              fnd_message.set_token('GRADE', g_quota_grid(table_row).grade_name);
              fnd_message.set_token('EFFDATE',to_char(g_quota_grid(table_row).effective_date));
              fnd_message.set_token('QUOTA_ALLOWED', l_quota_allowed_char);
              fnd_message.set_token('APPROVED', g_quota_grid(table_row).cur_per_app);
              hr_multi_message.add();
--              l_return_status := 'N';
           end if;
      end if;
  end if;
 end loop;
end if;
p_return_status := hr_multi_message.get_return_status_disable;
hr_utility.set_location('Leaving '||l_proc, 10);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates Quota check failed.
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
     if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end check_quota;

procedure check_quota(p_business_group_id in number,
                     p_effective_date in date,
                     p_corp_id in number,
                     p_grade_id in number,
                     p_return_status out nocopy varchar2) is

l_grade_cur_pop number;
l_quota_allowed number;
l_already_app number;
l_corp_name pqh_corps_definitions.name%type;
l_grade_name per_grades.name%type;
l_proc varchar2(60) := g_package||'check_quota 2';
l_return_status varchar2(1) := 'Y';
l_corp_id number;
Begin
hr_utility.set_location('Entering into '||l_proc, 10);

 select name, corps_definition_id  into l_corp_name, l_corp_id
  from pqh_corps_definitions
  where ben_pgm_id  = p_corp_id;

if Quota_applicable(l_corp_id,p_effective_date) = 'Y' then
  l_grade_cur_pop := population_grade(p_corp_id => l_corp_id ,
                                      p_grade_id => p_grade_id ,
                                      p_business_group_id => p_business_group_id,
                                      p_effective_date => p_effective_date);
  l_quota_allowed := Quota_occupancy (p_corp_id => l_corp_id ,
                                      p_grade_id => p_grade_id ,
                                      p_business_group_id => p_business_group_id,
                                      p_effective_date => p_effective_date);

  select count(elc.elig_per_elctbl_chc_id )
  into l_already_app
  from  ben_elig_per_elctbl_chc elc,
      ben_per_in_ler pil,
      ben_pl_f pl,
      pqh_corps_definitions corp
  where elc.approval_status_cd = 'PQH_GSP_A'
  and pil.per_in_ler_id = elc.per_in_ler_id
  and pil.per_in_ler_stat_cd = 'STRTD'
  and corp.corps_definition_id = l_corp_id
  and elc.pgm_id = corp.ben_pgm_id
  and pl.mapping_table_name = 'PER_GRADES'
  and pl.mapping_table_pk_id = p_grade_id
  and p_effective_date between pl.effective_start_date and pl.effective_end_date
  and elc.pl_id = pl.pl_id
  and elc.business_group_id = p_business_group_id;

  select name into l_grade_name
 from per_grades where
 grade_id = p_grade_id;

  if l_quota_allowed is not null then
     if ((l_quota_allowed - (l_grade_cur_pop + l_already_app + 1)) < 0 ) then

/*        fnd_message.set_name('PQH','PQH_FR_CAR_QUOTA_CHK_FAIL');
        fnd_message.set_token('CORP', l_corp_name);
        fnd_message.set_token('GRADE', l_grade_name);
        fnd_message.set_token('EFFDATE',p_effective_date);
        hr_multi_message.add(); */
        l_return_status := 'N';
     end if;
   end if;
end if;
p_return_status := l_return_status;
hr_utility.set_location('Leaving '||l_proc, 10);
End check_quota;
End PQH_FR_QUOTA_CHECK;

/
