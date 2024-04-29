--------------------------------------------------------
--  DDL for Package Body PER_IT_QH_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IT_QH_TAX" as
/* $Header: peitqhtx.pkb 120.0 2005/05/31 10:29:03 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_it_qh_tax.';
--
procedure update_it_tax_data
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
) is
  l_proc varchar2(72) := g_package||'update_it_tax_data';
  l_cagr_segment1               per_cagr_grades_def.segment1%type;
  l_cagr_segment2               per_cagr_grades_def.segment2%type;
  l_cagr_segment3               per_cagr_grades_def.segment3%type;
  l_concat_segments             hr_soft_coding_keyflex.concatenated_segments%type;
  l_new_cagr_grade_def_id       per_cagr_grades_def.cagr_grade_def_id%type;
  l_old_cagr_grade_def_id       per_cagr_grades_def.cagr_grade_def_id%type;
  l_collective_agreement_id     per_coll_agree_grades_v.collective_agreement_id%type;
  l_d_grade_type_name           per_coll_agree_grades_v.d_grade_type_name%type;
  l_business_group_id           per_coll_agree_grades_v.business_group_id%type;
  l_dynamic_insert_allowed      per_coll_agree_grades_v.dynamic_insert_allowed%type;
  l_id_flex_num                 fnd_id_flex_structures_vl.id_flex_num%type;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_legislation_code='IT' then
    --
       Begin
         If p_rec.tax_field1 is not null Then
           update per_all_people_f
	   set per_information2 = p_rec.tax_field1
           where person_id = p_person_id
           and   p_effective_date between effective_start_date and effective_end_date;
         End If;
         select id_flex_num into l_id_flex_num
         from fnd_id_flex_structures_vl
         where id_flex_structure_name = 'IT_CAGR'
         and id_flex_code = 'CAGR';
         EXCEPTION
           when no_data_found then
           null;
       End;
       hr_kflex_utility.ins_or_sel_keyflex_comb
                        (p_appl_short_name      =>  'PER'
                        ,p_flex_code            =>  'CAGR'
                        ,p_flex_num             =>  l_id_flex_num
                        ,p_segment1             =>  p_rec.tax_field3
                        ,p_segment2             =>  p_rec.tax_field4
                        ,p_segment3             =>  p_rec.tax_field5
                        ,p_ccid                 =>  l_new_cagr_grade_def_id
                        ,p_concat_segments_out  =>  l_concat_segments);
       Begin
         select cagr_grade_def_id into l_old_cagr_grade_def_id
         from per_all_assignments_f
	 where person_id = p_person_id
         and assignment_id = p_assignment_id
         and cagr_id_flex_num = l_id_flex_num
	 and p_effective_date between effective_start_date and effective_end_date
	 and rownum = 1;
         if l_old_cagr_grade_def_id <> l_new_cagr_grade_def_id then
            if(p_rec.tax_field6 is not null) then ---bug 3878097
                update per_all_assignments_f
	            set cagr_grade_def_id = l_new_cagr_grade_def_id,
	            collective_agreement_id = p_rec.tax_field6,
                    cagr_id_flex_num = l_id_flex_num
	            where person_id = p_person_id
                    and assignment_id = p_assignment_id
                    and cagr_id_flex_num = l_id_flex_num
	            and p_effective_date between effective_start_date and effective_end_date;
            else ---bug 3878097
                update per_all_assignments_f
	            set cagr_grade_def_id = null,    -- added to not populate id_flex_num if no collective agreement id is found
	            collective_agreement_id = p_rec.tax_field6,
                    cagr_id_flex_num = null
	            where person_id = p_person_id
                    and assignment_id = p_assignment_id
                    and cagr_id_flex_num = l_id_flex_num
	            and p_effective_date between effective_start_date and effective_end_date;
            end if; ---bug 3878097
         end if;
         EXCEPTION
            when no_data_found then
            if(p_rec.tax_field6 is not null) then ---bug 3878097
                update per_all_assignments_f
                set cagr_grade_def_id = l_new_cagr_grade_def_id,
	            collective_agreement_id = p_rec.tax_field6,
                cagr_id_flex_num = l_id_flex_num
	            where person_id = p_person_id
                and assignment_id = p_assignment_id
	            and p_effective_date between effective_start_date and effective_end_date;
            else ---bug 3878097
                update per_all_assignments_f
                    set cagr_grade_def_id = null,
	            collective_agreement_id = p_rec.tax_field6,
                    cagr_id_flex_num = null
	            where person_id = p_person_id
                    and assignment_id = p_assignment_id
	            and p_effective_date between effective_start_date and effective_end_date;
            end if; ---bug 3878097
       End;
  End if;
--
  hr_utility.set_location('Leaving:'|| l_proc, 1000);
--
end update_it_tax_data;
--
--

procedure it_tax_query
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
) is
  l_proc varchar2(72) := g_package||'it_tax_query';
  l_cagr_segment1               per_cagr_grades_def.segment1%type;
  l_cagr_segment2               per_cagr_grades_def.segment2%type;
  l_cagr_segment3               per_cagr_grades_def.segment3%type;
  l_new_cagr_grade_def_id       per_cagr_grades_def.cagr_grade_def_id%type;
  l_old_cagr_grade_def_id       per_cagr_grades_def.cagr_grade_def_id%type;
  l_id_flex_num                 fnd_id_flex_structures_vl.id_flex_num%type;
--
begin
--
  if p_legislation_code='IT' then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
       Begin
         select per_information2 into p_rec.tax_field1
         from per_all_people_f
         where person_id = p_person_id
         and   p_effective_date between effective_start_date and effective_end_date
         and rownum = 1;
         EXCEPTION
           when no_data_found then
           null;
       End;
       Begin
         select id_flex_num into l_id_flex_num
         from fnd_id_flex_structures_vl
         where id_flex_structure_name = 'IT_CAGR'
         and id_flex_code = 'CAGR';
         EXCEPTION
           when no_data_found then
           null;
       End;
       Begin
	 select cagr_grade_def_id into l_old_cagr_grade_def_id
         from  per_all_assignments_f
	 where person_id = p_person_id
         and assignment_id = p_assignment_id
         and cagr_id_flex_num = l_id_flex_num
         and   p_effective_date between effective_start_date and effective_end_date
	 and rownum = 1;

         select segment1, segment2, segment3 into l_cagr_segment1, l_cagr_segment2, l_cagr_segment3
         from per_cagr_grades_def
         where cagr_grade_def_id = l_old_cagr_grade_def_id
         and id_flex_num = l_id_flex_num
	 and rownum = 1;
	 p_rec.tax_field3 := l_cagr_segment1;
	 p_rec.tax_field4 := l_cagr_segment2;
	 p_rec.tax_field5 := l_cagr_segment3;
         EXCEPTION
            when no_data_found then
            null;
       End;
  end if;
--
  hr_utility.set_location('Leaving:'|| l_proc, 1000);
--
end it_tax_query;

end per_it_qh_tax;

/
