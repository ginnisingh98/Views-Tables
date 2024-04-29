--------------------------------------------------------
--  DDL for Package Body PER_CANCEL_HIRE_OR_APL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CANCEL_HIRE_OR_APL_PKG" AS
/* $Header: pecanhir.pkb 120.8.12010000.11 2009/07/12 08:08:43 sidsaxen ship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := 'per_cancel_hire_or_apl_pkg.';
--
-- procedure created for bug 8405711 to get the preivous person type of the person
--
--  ---------------------------------------------------------------------------
--  |------------------------< get_prev_person_type >-------------------------|
--  ---------------------------------------------------------------------------
--
procedure get_prev_person_type(p_business_group_id in number,
                               p_person_id in number,
                               p_effective_date in date,
                               p_current_person_type in varchar2,
                               p_system_person_type out NOCOPY varchar2)
is

 --
 -- Declare Type
 --
 type t_person_types is table of per_person_types.system_person_type%type;

 --
 -- Declare cursor
 --
 Cursor csr_person_types is
  select  ppt.system_person_type
  from per_person_type_usages_f ptu, per_person_types ppt
  where ptu.person_type_id = ppt.person_type_id
  and person_id = p_person_id
  and ppt.business_group_id = p_business_group_id
  and ppt.system_person_type <> p_current_person_type
  and p_effective_date between ptu.effective_start_date and ptu.effective_end_date
  and ppt.system_person_type in ('EMP','EX_EMP','APL','EX_APL','CWK','EX_CWK');

 Cursor csr_prev_person_types is
  select  ppt.system_person_type
  from per_person_type_usages_f ptu, per_person_types ppt
  where ptu.person_type_id = ppt.person_type_id
  and person_id = p_person_id
  and ppt.business_group_id = p_business_group_id
  and ppt.system_person_type in ('EMP','EX_EMP','APL','EX_APL','CWK','EX_CWK')
  and ptu.effective_end_date =
   (select effective_start_date - 1
   from per_person_type_usages_f ptu1, per_person_types ppt1
   where ptu1.person_type_id = ppt1.person_type_id
   and ptu1.person_id = p_person_id
   and ppt1.system_person_type = p_current_person_type
   and p_effective_date between effective_start_date and effective_end_date)
  order by effective_end_date desc, effective_start_date desc;

 Cursor csr_prev_ppl_person_types is
  select  ppt.system_person_type
  from per_all_people_f papf, per_person_types ppt
  where papf.person_type_id = ppt.person_type_id
  and person_id = p_person_id
  and ppt.business_group_id = p_business_group_id
  and ppt.system_person_type in
   ('EMP',
    'EX_EMP',
    'APL',
    'EX_APL',
    'EMP_APL',
    'EX_EMP_APL',
    'OTHER')
  and papf.effective_end_date =
   (select effective_start_date - 1
   from per_person_type_usages_f ptu1, per_person_types ppt1
   where ptu1.person_type_id = ppt1.person_type_id
   and ptu1.person_id = p_person_id
   and ppt.business_group_id = p_business_group_id
   and ppt1.system_person_type = p_current_person_type
   and p_effective_date between effective_start_date and effective_end_date)
  order by effective_end_date desc, effective_start_date desc;
 --
 -- Declare local variables
 --
 l_person_types t_person_types;
 l_proc varchar2(20) :='get_prev_person_type';

begin

 hr_utility.set_location('Entering :'||g_package||l_proc,10);
 hr_utility.set_location('P_business_group_id :'||P_business_group_id,11);
 hr_utility.set_location('p_person_id :'||p_person_id,12);
 hr_utility.set_location('p_current_person_type :'||p_current_person_type,13);
 hr_utility.set_location('p_effective_date :'||p_effective_date,14);

 open csr_person_types;
 fetch csr_person_types bulk collect into l_person_types;
 if l_person_types.count = 0 then --csr_person_types%notfound then
  open csr_prev_person_types;
  fetch csr_prev_person_types into p_system_person_type;
  close csr_prev_person_types;
 end if;
 close csr_person_types;

 hr_utility.set_location('p_system_person_type :'||p_system_person_type,20);
 if p_system_person_type is null then
  FOR v_counter IN l_person_types.FIRST .. l_person_types.LAST
  LOOP
   if l_person_types(v_counter) = 'EMP' then
    p_system_person_type:= 'EMP';
    exit;
   end if;
  END LOOP;
 end if;

 hr_utility.set_location('p_system_person_type :'||p_system_person_type,30);
 if p_system_person_type is null then
  FOR v_counter IN l_person_types.FIRST .. l_person_types.LAST
  LOOP
   if l_person_types(v_counter) = 'APL' then
    p_system_person_type:= 'APL';
    FOR v_counter IN l_person_types.FIRST .. l_person_types.LAST
    LOOP
     IF l_person_types(v_counter) = 'EX_EMP' THEN
      p_system_person_type:= 'EX_EMP_APL';
      exit;
     END IF;
    END LOOP;
    exit;
   end if;
  END LOOP;
 end if;

 hr_utility.set_location('p_system_person_type :'||p_system_person_type,40);
 if p_system_person_type is null then
  FOR v_counter IN l_person_types.FIRST .. l_person_types.LAST
  LOOP
   if l_person_types(v_counter) = 'EX_EMP' then
    p_system_person_type:= 'EX_EMP';
    FOR v_counter1 IN l_person_types.FIRST .. l_person_types.LAST
    LOOP
     IF l_person_types(v_counter1) = 'APL' THEN
      p_system_person_type:= 'EX_EMP_APL';
      exit;
     END IF;
    END LOOP;
    exit;
   end if;
  END LOOP;
 end if;

 hr_utility.set_location('p_system_person_type :'||p_system_person_type,50);
 if p_system_person_type is null then
  FOR v_counter IN l_person_types.FIRST .. l_person_types.LAST
  LOOP
   if l_person_types(v_counter) = 'EX_APL' then
    p_system_person_type:= 'EX_APL';
    exit;
   end if;
  END LOOP;
 end if;

 hr_utility.set_location('p_system_person_type :'||p_system_person_type,60);
 if p_system_person_type is null then
  open csr_prev_ppl_person_types;
  fetch csr_prev_ppl_person_types into p_system_person_type;
  if csr_prev_ppl_person_types%notfound then
   p_system_person_type := 'OTHER';
  end if;
  close csr_prev_ppl_person_types;
 end if;

 hr_utility.set_location('p_system_person_type :'||p_system_person_type,99);
 hr_utility.set_location('Leaving :'||l_proc,100);

end get_prev_person_type;
--
--
--
/*===========================================================================*
 |                                                                           |
 |                              LOCK_CWK_ROWS                                |
 |                                                                           |
*============================================================================*/
--
PROCEDURE lock_cwk_rows
  (p_person_id         IN per_all_people_f.person_id%TYPE
  ,p_business_group_id IN per_all_people_f.business_group_id%TYPE
  ,p_effective_date    IN DATE) IS
  --
  l_rowid VARCHAR2(18);
  --
  -- Comments cursor
  --
  cursor comments is
    select h.rowid
    from   hr_comments h
    ,      per_assignments_f paf
    where  h.comment_id = paf.comment_id
    and    paf.business_group_id + 0 = p_business_group_id
    and    paf.person_id             = p_person_id
    and    paf.effective_start_date >= p_effective_date
    for    update of h.comment_id;
  --
  -- payment cursor
  --
  cursor payment is
    select rowid
    from   pay_personal_payment_methods ppm
    where  ppm.business_group_id = p_business_group_id
    and    exists (select 'exists'
                   from per_all_assignments_f paf
                   where paf.business_group_id    +0= p_business_group_id
                   and   paf.person_id            = p_person_id
                   and   paf.assignment_id        = ppm.assignment_id
		   --start bug 5987416
                   --and   ppm.effective_start_date>= p_effective_date
		   --end bug 5987416
		   )
    and   ppm.effective_start_date               >= p_effective_date
    for   update of ppm.assignment_id;
  --
  -- Budget values cursor
  --
  cursor budget_values is
    select pab.rowid
    from   per_assignment_budget_values_f pab
    ,      per_assignments_f paf
    where  pab.business_group_id + 0 = paf.business_group_id + 0
    and    paf.business_group_id + 0 = p_business_group_id
    and    pab.assignment_id         = paf.assignment_id
    and    paf.person_id             = p_person_id
    and    paf.effective_end_date   >=p_effective_date
    and    pab.effective_end_date   >=p_effective_date
    for    update of pab.assignment_id;
  --
  -- recruiter cursor
  --
  cursor recruiter is
    select rowid
    from   per_assignments_f p
    where  p.recruiter_id = p_person_id
    and    (p.business_group_id = p_business_group_id OR
            nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    for    update of assignment_id;
  --
  -- events cursor
  --
  cursor events_or_interviews is
    select pb.rowid
    from   per_events pe
    ,      per_bookings pb
    where  pe.business_group_id = pb.business_group_id
    and    (pb.business_group_id = p_business_group_id OR
           nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    and    pe.event_id           = pb.event_id
    and    pe.event_or_interview in ('I','E')
    and    pb.person_id          = p_person_id
    for    update of pb.event_id;
  --
  -- vacancies cursor
  --
  cursor vacancies is
    select rowid
    from   per_vacancies pv
    where (pv.business_group_id  = p_business_group_id OR
           nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    and   pv.recruiter_id      = p_person_id
    and   pv.date_from        >= p_effective_date
    for update of pv.vacancy_id;
  --
  -- requisitions cursor
  --
  cursor requisitions is
    select rowid
    from  per_requisitions pr
    where (pr.business_group_id = p_business_group_id OR
           nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    and   pr.person_id         = p_person_id
    for   update of person_id;
  --
  cursor supervisor is
    select rowid
    from   per_assignments_f p
    where  (p.business_group_id = p_business_group_id OR
           nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    and    p.supervisor_id = p_person_id
    for    update of assignment_id;
  --
  cursor per_rows is
    select ppf.rowid
    from   per_people_f ppf
    where  ppf.person_id = p_person_id
    for update of ppf.person_id;
  --
  --CWK  assignments cursor
  --
  cursor cwk_ass is
    select paf.rowid
    from per_assignments_f paf
    where paf.business_group_id + 0 = p_business_group_id
    and   paf.person_id            = p_person_id
    and   paf.assignment_type      = 'C'
    for update of paf.assignment_id;
  --
  -- CWK periofs of placement
  --
  cursor csr_periods_of_placement is
    select pp.rowid
    from   per_periods_of_placement pp
    where  pp.person_id  = p_person_id
    for update of person_id;
  --
  cursor csr_assignment_rate_values is
    select pgr.rowid
    from   pay_grade_rules_f pgr
    where  exists (select 'x'
                   from   per_assignments_f paf
                   where  pgr.grade_or_spinal_point_id = paf.assignment_id
                   and    paf.business_group_id + 0    = p_business_group_id
                   and    paf.person_id                = p_person_id)
    for update of pgr.grade_or_spinal_point_id;
  --
  cursor csr_grade_steps is
    select spp.rowid
    from   per_spinal_point_placements_f spp
    where spp.business_group_id = p_business_group_id and
    exists (select 'x'
                   from   per_assignments_f paf
                   where  spp.assignment_id = paf.assignment_id
                   and    paf.business_group_id + 0    = p_business_group_id
                   and    paf.person_id                = p_person_id)
    for update of spp.assignment_id;
  --
  cursor csr_cost_allocations is
    select pca.rowid
    from   pay_cost_allocations_f pca
    where  exists (select 'x'
                   from   per_assignments_f paf
                   where  pca.assignment_id = paf.assignment_id
                   and    paf.business_group_id + 0    = p_business_group_id
                   and    paf.person_id                = p_person_id)
    for update of pca.assignment_id;
--
BEGIN
  --
  open per_rows;
  <<person>>
  loop
    fetch per_rows into l_rowid;
    exit when per_rows%notfound;
  end loop person;
  close per_rows;
  --
  open csr_cost_allocations;
  <<cost_allocations>>
  loop
    fetch csr_cost_allocations into l_rowid;
    exit when csr_cost_allocations%NOTFOUND;
  end loop cost_allocations;
  close csr_cost_allocations;
  --
  open csr_grade_steps;
  <<grade_steps>>
  loop
    fetch csr_grade_steps into l_rowid;
    exit when csr_grade_steps%NOTFOUND;
  end loop grade_steps;
  close csr_grade_steps;
  --
  open csr_periods_of_placement;
  <<placements>>
  loop
    fetch csr_periods_of_placement into l_rowid;
    exit when csr_periods_of_placement%NOTFOUND;
  end loop placements;
  close csr_periods_of_placement;
  --
  open csr_assignment_rate_values;
  <<assignment_rates>>
  loop
    fetch csr_assignment_rate_values into l_rowid;
    exit when csr_assignment_rate_values%NOTFOUND;
  end loop assignment_rates;
  --
  open supervisor;
  <<super>>
  loop
    fetch supervisor into l_rowid;
    exit when supervisor%NOTFOUND;
  end loop super;
  close supervisor;
  --
  open recruiter;
  <<recr>>
  loop
    fetch recruiter into l_rowid;
    exit when recruiter%NOTFOUND;
  end loop recr;
  close recruiter;
  --
  open events_or_interviews;
  <<event>>
  loop
    fetch events_or_interviews into l_rowid;
    exit when events_or_interviews%NOTFOUND;
  end loop event;
  close events_or_interviews;
  --
  open vacancies;
  <<vacancy>>
  loop
    fetch vacancies into l_rowid;
    exit when vacancies%NOTFOUND;
  end loop vacancy;
  close vacancies;
  --
  open requisitions;
  <<req>>
  loop
    fetch requisitions into l_rowid;
    exit when requisitions%NOTFOUND;
  end loop req;
  close requisitions;
  --
  open budget_values;
  <<budget_val>>
  loop
    fetch budget_values into l_rowid;
    exit when budget_values%NOTFOUND;
  end loop budget_val;
  close budget_values;
  --
  open payment;
  <<paym>>
  loop
    fetch payment into l_rowid;
    exit when payment%NOTFOUND;
  end loop pay;
  close payment;
  --
  open comments;
  <<comment>>
  loop
    fetch comments into l_rowid;
    exit when comments%NOTFOUND;
  end loop comment;
  close comments;
  --
  open cwk_ass;
  <<placements>>
  loop
    fetch cwk_ass into l_rowid;
    exit when cwk_ass%NOTFOUND;
  end loop placements;
  close cwk_ass;
  --
END lock_cwk_rows;
--
procedure lock_per_rows(p_person_id NUMBER,
                       p_primary_id NUMBER,
                       p_primary_date DATE,
                       p_business_group_id NUMBER,
                       p_person_type VARCHAR2)is
l_rowid VARCHAR2(18);
l_assignment_id NUMBER;
--
-- Person cursor
--
cursor per_rows is
      select ppf.rowid
      from   per_people_f ppf
      where  ppf.person_id = p_person_id
      for update of ppf.person_id;
--
-- Period cursor
--
cursor period_rows is
      select pps.rowid
      from   per_periods_of_service pps
      where  pps.person_id = p_person_id
      for    update of pps.person_id;
--
-- applicant cursor
--
cursor applicant_rows is
      select pap.rowid
      from   per_applications pap
      where  pap.person_id = p_person_id
      for    update of pap.person_id;
--
-- supervisor cursor.
--
cursor supervisor is
select rowid
from   per_assignments_f p
where  (p.business_group_id = p_business_group_id OR
nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and    p.supervisor_id = p_person_id
for    update of assignment_id;
--
-- recruiter cursor
--
cursor recruiter is
select rowid
from   per_assignments_f p
where  p.recruiter_id = p_person_id
and    (p.business_group_id = p_business_group_id OR
   nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
for    update of assignment_id;
--
-- events cursor
--
cursor events_or_interviews(p_type varchar2) is
select pb.rowid
from   per_events pe
,      per_bookings pb
where  pe.business_group_id = pb.business_group_id
and    (pb.business_group_id = p_business_group_id OR
    nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and    pe.event_id           = pb.event_id
and    pe.event_or_interview = p_type
and    pb.person_id          = p_person_id
for    update of pb.event_id;
--
-- vacancies cursor
--
cursor vacancies is
select rowid
from   per_vacancies pv
where (pv.business_group_id  = p_business_group_id OR
   nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and   pv.recruiter_id      = p_person_id
and   pv.date_from        >= p_primary_date
for update of pv.vacancy_id;
--
-- requisitions cursor
--
cursor requisitions is
select rowid
from  per_requisitions pr
where (pr.business_group_id = p_business_group_id OR
     nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and   pr.person_id         = p_person_id
for   update of person_id;
--
-- absenses cursor
--
cursor absenses is
select rowid
from   per_absence_attendances paa
where  paa.business_group_id +0 = p_business_group_id
and    paa.person_id         = p_person_id
and    paa.date_start       >= p_primary_date
for    update of person_id;
--
-- payment cursor
--
cursor payment is
select rowid
from   pay_personal_payment_methods ppm
where  ppm.business_group_id = p_business_group_id
and    exists (select 'exists'
               from per_all_assignments_f paf
               where paf.business_group_id    +0= p_business_group_id
               and   paf.person_id            = p_person_id
               and   paf.assignment_id        = ppm.assignment_id
               and   paf.period_of_service_id = p_primary_id
	       --start bug 5987416
               --and   ppm.effective_start_date>= p_primary_date
	       --end bug 5987416
              )
and   ppm.effective_start_date               >= p_primary_date
for   update of ppm.assignment_id;
--
-- Budget values cursor
--
cursor budget_values is
select pab.rowid
from   per_assignment_budget_values_f pab
,      per_assignments_f paf
where  pab.business_group_id + 0    = paf.business_group_id + 0
and    paf.business_group_id + 0    = p_business_group_id
and    pab.assignment_id        = paf.assignment_id
and    paf.person_id            = p_person_id
and    paf.effective_end_date  >=p_primary_date
and    pab.effective_end_date  >=p_primary_date
for    update of pab.assignment_id;
--
-- letters cursor
--
cursor letters is
select p.rowid
from   per_letter_request_lines p
,      per_assignments_f paf
where  p.assignment_id = paf.assignment_id
and    paf.business_group_id + 0    = p_business_group_id
and    paf.person_id            = p_person_id
and    paf.application_id       = p_primary_id
and    paf.effective_end_date  >=p_primary_date
for    update of p.assignment_id;
--
-- Comments cursor
--
cursor comments is
select h.rowid
from   hr_comments h
,      per_assignments_f paf
where  h.comment_id = paf.comment_id
and    paf.business_group_id + 0    = p_business_group_id
and    paf.person_id            = p_person_id
and    paf.application_id       = p_primary_id
and    paf.effective_end_date  >=p_primary_date
for    update of h.comment_id;
--
--appl  assignments cursor
--
cursor appl_ass is
select paf.rowid
from per_assignments_f paf
where paf.business_group_id + 0    = p_business_group_id
and   paf.person_id            = p_person_id
and   paf.assignment_type      = 'A'
and   paf.application_id       = p_primary_id
for update of paf.assignment_id;
--
--emp  assignments cursor
--
cursor emp_ass is
select paf.rowid
from per_assignments_f paf
where paf.business_group_id + 0    = p_business_group_id
and   paf.person_id            = p_person_id
and   paf.assignment_type      = 'E'
and   paf.application_id       = p_primary_id
for update of paf.assignment_id;

begin
-- Person loop
  open per_rows;
  <<person>>
  loop
    fetch per_rows into l_rowid;
    exit when per_rows%notfound;
  end loop person;
  close per_rows;
  --
  if p_person_type = 'EMP' then
    --
    open period_rows;
    <<period>>
    loop
       fetch period_rows into l_rowid;
       exit when period_rows%NOTFOUND;
    end loop period;
    close period_rows;
    --
    open supervisor;
    <<super>>
    loop
      fetch supervisor into l_rowid;
      exit when supervisor%NOTFOUND;
    end loop super;
    close supervisor;
    --
    open recruiter;
    <<recr>>
    loop
      fetch recruiter into l_rowid;
      exit when recruiter%NOTFOUND;
    end loop recr;
    close recruiter;
    --
    open events_or_interviews('E');
    <<event>>
    loop
      fetch events_or_interviews into l_rowid;
      exit when events_or_interviews%NOTFOUND;
    end loop event;
    close events_or_interviews;
    --
    open vacancies;
    <<vacancy>>
    loop
      fetch vacancies into l_rowid;
      exit when vacancies%NOTFOUND;
    end loop vacancy;
    close vacancies;
    --
    open requisitions;
    <<req>>
    loop
      fetch requisitions into l_rowid;
      exit when requisitions%NOTFOUND;
    end loop req;
    close requisitions;
    --
    open absenses;
    <<absences>>
    loop
      fetch absenses into l_rowid;
      exit when absenses%NOTFOUND;
    end loop absences;
    close absenses;
    --
    open budget_values;
    <<budget_val>>
    loop
      fetch budget_values into l_rowid;
      exit when budget_values%NOTFOUND;
    end loop budget_val;
    close budget_values;
    --
    open payment;
    <<paym>>
    loop
      fetch payment into l_rowid;
      exit when payment%NOTFOUND;
    end loop pay;
    close payment;
    --
    open comments;
    <<comment>>
    loop
      fetch comments into l_rowid;
      exit when comments%NOTFOUND;
    end loop comment;
    close comments;
    --
    open emp_ass;
    <<assignments>>
    loop
      fetch emp_ass into l_rowid;
      exit when emp_ass%NOTFOUND;
    end loop assignments;
    close emp_ass;
    --
    open appl_ass;
    <<applications>>
    loop
      fetch appl_ass into l_rowid;
      exit when appl_ass%NOTFOUND;
    end loop applications;
    close appl_ass;
    --
  elsif p_person_type='APL' then
    --
    open applicant_rows;
    <<appl>>
    loop
      fetch applicant_rows into l_rowid;
      exit when applicant_rows%NOTFOUND;
    end loop appl;
    close applicant_rows;
    -- lock assignment rows etc
    open appl_ass;
    <<ass>>
    loop
      fetch appl_ass into l_rowid;
      exit when appl_ass%notfound;
    end loop ass;
    close appl_ass;
    -- lock comments rows
    open comments;
    <<comment>>
    loop
      fetch comments into l_rowid;
      exit when comments%NOTFOUND;
    end loop comment;
    close comments;
    -- lock letters
    open letters;
    <<letter>>
    loop
      fetch letters into l_rowid;
      exit when letters%NOTFOUND;
    end loop letter;
    close letters;
    -- lock budgets
    open budget_values;
    <<budget>>
    loop
      fetch budget_values into l_rowid;
      exit when budget_values%NOTFOUND;
    end loop budget;
    close budget_values;
    -- lock events
    open events_or_interviews('E');
    <<event>>
    loop
      fetch events_or_interviews into l_rowid;
      exit when events_or_interviews%NOTFOUND;
    end loop event;
    close events_or_interviews;
    -- lock interview
    open events_or_interviews('I');
    <<interview>>
    loop
      fetch events_or_interviews into l_rowid;
      exit when events_or_interviews%NOTFOUND;
    end loop interview;
    close events_or_interviews;
    --
  end if;
end lock_per_rows;
--
--
--
procedure pre_cancel_checks(p_person_id NUMBER
                           ,p_where  IN OUT NOCOPY VARCHAR2
                           ,p_business_group_id NUMBER
                           ,p_system_person_type VARCHAR2
                           ,p_primary_id NUMBER
                           ,p_primary_date DATE
                           ,p_cancel_type VARCHAR2) is
--
-- Bug 2964027 starts here.
-- Cursor to seelct assignment actions on or after the hire date.
--
cursor csr_assign_actions_exist is
select 'Y'
from   per_all_assignments_f a
where  a.person_id = p_person_id
--
-- 115.51 (START)
--
AND    a.period_of_service_id = p_primary_id
--
-- 115.51 (END)
--
AND    ((a.effective_start_date = p_primary_date
         and a.primary_flag <> 'Y'
         and not exists ( select b.assignment_id
                          from   per_all_assignments_f b
                          where  nvl(b.effective_end_date,hr_api.g_eot)
                                  = (p_primary_date-1)
                          and    b.assignment_id = a.assignment_id) )
         OR  a.effective_start_date > p_primary_date );
-- Bug 2964027 ends here.
--
-- Supervisor
--
cursor supervisor is
select rowid
from   per_assignments_f p
where  (p.business_group_id = p_business_group_id OR
nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and    p.supervisor_id = p_person_id;
--
-- recruiter cursor
--
cursor recruiter is
select rowid
from   per_assignments_f p
where  p.recruiter_id = p_person_id
and    (p.business_group_id = p_business_group_id OR
     nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y');
--
-- reviews or Events cursor
--
cursor reviews_or_events(p_type varchar2) is
select 'Events exist'
                from   per_events pe
                ,      per_bookings pb
                where  pe.business_group_id = pb.business_group_id
                and    (pb.business_group_id = p_business_group_id OR
                      nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                and    pe.event_id           = pb.event_id
                and    pe.event_or_interview = p_type
                and    pb.person_id          = p_person_id;
--
-- Interviews cursor
--
cursor interviews is
select 'Interviews exist'
from   per_events pe
where  (pe.business_group_id  = p_business_group_id OR
      nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and    pe.event_or_interview = 'I'
and    pe.internal_contact_person_id = p_person_id;
--
-- vacancies cursor
--
cursor vacancy is
select rowid
from   per_vacancies pv
where (pv.business_group_id  = p_business_group_id OR
    nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and   pv.recruiter_id      = p_person_id
and   pv.date_from        >= p_primary_date;
--
-- requisitions cursor
--
cursor requisition is
select rowid
from per_requisitions pr
where (pr.business_group_id = p_business_group_id OR
     nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and   pr.person_id         = p_person_id;
--
-- budget_values cursor
--
cursor budget_values is
select rowid
from per_assignment_budget_values_f pab
where pab.business_group_id = p_business_group_id and
exists (select 'budget_values exist'
               from per_all_assignments_f paf
               where  pab.business_group_id    +0= paf.business_group_id + 0
               and    paf.business_group_id    +0= p_business_group_id
               and    pab.assignment_id        = paf.assignment_id
               and    paf.person_id            = p_person_id
               and    paf.period_of_service_id = p_primary_id
               and    paf.effective_end_date  >= p_primary_date
       	       --start bug 5987416
               --and    pab.effective_end_date  >= p_primary_date
	       )
AND   pab.effective_end_date  >= p_primary_date;
--end bug 5987416
--
-- payment cursor
--
cursor payment is
select rowid
from pay_personal_payment_methods ppm
where  ppm.business_group_id                  = p_business_group_id
and    exists (select 'exists'
               from per_all_assignments_f paf
               where paf.business_group_id    +0= p_business_group_id
               and   paf.person_id            = p_person_id
               and   paf.assignment_id        = ppm.assignment_id
               and   paf.period_of_service_id = p_primary_id
	       --start bug 5987416
               --and   ppm.effective_start_date>= p_primary_date
	       --end bug 5987416
              )
and   ppm.effective_start_date               >= p_primary_date;
--
-- pay actions cursor. Start Bug 2841901
--
cursor csr_payactions is
   SELECT null
              FROM   pay_payroll_actions pac,
                     pay_assignment_actions act,
                     per_assignments_f asg
              WHERE  asg.person_id = p_person_id
--
-- 115.51 (START)
--
                AND  asg.period_of_service_id = p_primary_id
--
-- 115.51 (END)
--
                AND  act.assignment_id = asg.assignment_id
                AND  pac.payroll_action_id = act.payroll_action_id
--
--Start Bug 4724223
--
                AND  pac.action_type NOT IN ('X','BEE')
                AND  p_primary_date BETWEEN asg.effective_start_date
                                    AND asg.effective_end_date
--
--End Bug 4724223
--
                AND  pac.effective_date >= p_primary_date;
--
--End Bug 2841901
--
-- Start changes for bug 8405711
Cursor csr_application_change_exists is
 select 'exists'
 from per_applications pa
 where pa.business_group_id = business_group_id
  and pa.person_id = p_person_id
  and pa.date_received >= p_primary_date
  and pa.application_id <> nvl(
	(select application_id
	 from per_applications
	 where business_group_id = p_business_group_id
	 and person_id = p_person_id
	 and p_primary_date - 1 between date_received and nvl(date_end,to_date('31/12/4712','dd/mm/yyyy'))
	 ),pa.application_id) ;
-- end changes for bug 8405711

-- Start Bug 3285486
  CURSOR csr_get_ptu_id(p_system_person_type varchar2) IS
    SELECT ptu.person_type_usage_id
    FROM   per_person_types pt,
           per_person_type_usages_f ptu
    WHERE  pt.business_group_id     = p_business_group_id
    AND    pt.person_type_id        = ptu.person_type_id
    AND    p_primary_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
    AND    ptu.person_id            = p_person_id
    AND    pt.system_person_type = p_system_person_type;

l_person_type_usage_id NUMBER;
-- End bug 3285486

l_dummy VARCHAR2(30);

--
begin
-- Start Bug 3285486
  OPEN  csr_get_ptu_id(p_system_person_type);
  FETCH csr_get_ptu_id INTO l_person_type_usage_id;

  IF csr_get_ptu_id%NOTFOUND THEN
    --
    CLOSE csr_get_ptu_id;
    --
    -- # 3690364 - changed application_id from 801 to 800
    hr_utility.set_message(800,'HR_289548_PEM_EMP_PERSON_ID');
    hr_utility.raise_error;
    --
  END IF;
  CLOSE csr_get_ptu_id;
-- end Bug 3285486
  if p_cancel_type = 'HIRE' then
    if p_where = 'BEGIN' then
--

      hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',1);
--
-- Start Bug 3285486. commented the call to hr_person.chk_future_person_type
-- added the new call to hr_person_type_usage_info.FutSysPerTypeChgExists
  /*    if hr_person.chk_future_person_type(p_system_person_type
                                          ,p_person_id
                                          ,p_business_group_id
                                          ,p_primary_date) then*/
  IF hr_person_type_usage_info.FutSysPerTypeChgExists
       (p_person_type_usage_id => l_person_type_usage_id
       ,p_effective_date       => p_primary_date
       ,p_person_id            => p_person_id ) THEN
-- End Bug 3285486.
--
         hr_utility.set_message(801,'HR_7078_EMP_ENTER_CANCEL_TYPE');
         hr_utility.raise_error;
--
       end if;

      -- start changes for bug 8405711
      -- if whether there exists any future application for this person or not
      --
      open csr_application_change_exists;
      fetch csr_application_change_exists into l_dummy;

      if csr_application_change_exists%FOUND then
        close csr_application_change_exists;
        hr_utility.set_message(800,'PER_449844_APL_ACTIONS_EXISTS');
        hr_utility.set_message_token('PERSON_STATUS','hire');
	hr_utility.set_message_token('PERSON_TYPE','Employee');
        hr_utility.raise_error;
      end if;

      close csr_application_change_exists;
      --
      -- end changes for bug 8405711
--
-- BUG 2964027 STARTS HERE.
      open csr_assign_actions_exist;
--
      fetch csr_assign_actions_exist into l_dummy;
--
      if csr_assign_actions_exist%FOUND then
        close csr_assign_actions_exist;
        hr_utility.set_message(800,'PER_289566_ASG_ACTIONS_EXISTS');
        hr_utility.raise_error;
      end if;
--
      close csr_assign_actions_exist;
-- BUG 2964027 ENDS HERE.
--
      hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',2);
       if not hr_person.chk_prev_person_type(p_system_person_type
                                          ,p_person_id
                                          ,p_business_group_id
                                          ,p_primary_date) then
--
         hr_utility.set_message(801,'HR_7077_NO_CANCEL_HIRE');
         hr_utility.raise_error;
--
      end if;

-- check for pay actions.Start Bug 2841901

       hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',3);
       open csr_payactions;
       fetch csr_payactions into l_dummy;
       --
       if csr_payactions%found then
         close csr_payactions;
--
-- Bug# 2989638 Start Here
-- Description : Added new message to display proper error message
--
--
         hr_utility.set_message(800,'HR_289529_EMP_FUT_PAY_EXIST');
--
-- Bug# 2989638 End Here
--
         hr_utility.raise_error;
       end if;
       --
       close csr_payactions;
--  End Bug 2841901
--
      p_where := 'SUPERVISOR';
--
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',4);
     if p_where = 'SUPERVISOR' then
--
       open supervisor;
--
       fetch supervisor into l_dummy;
--
       if supervisor%FOUND then
         hr_utility.set_message(801,'HR_EMP_IS_SUPER');
         close supervisor;
         return;
       else
         close supervisor;
       end if;
     p_where:= 'RECRUITER';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',5);
     if p_where = 'RECRUITER' then
--
       open recruiter;
--
       fetch recruiter into l_dummy;
--
       if recruiter%FOUND then
         hr_utility.set_message(801,'HR_EMP_IS_RECRUITER');
         close recruiter;
         return;
       else
         close recruiter;
       end if;
     p_where:= 'EVENT';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',6);
     if p_where = 'EVENT' then
--
       open reviews_or_events(p_type =>'E');
--
       fetch reviews_or_events into l_dummy;
--
       if reviews_or_events%FOUND then
         hr_utility.set_message(801,'HR_EMP_HAS_EVENTS');
         close reviews_or_events;
         return;
       else
         close reviews_or_events;
       end if;
--
     p_where := 'INTERVIEW';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',7);
     if p_where = 'INTERVIEW' then
--
       open interviews;
--
       fetch interviews into l_dummy;
--
       if interviews%FOUND then
         hr_utility.set_message(801,'HR_EMP_IS_INTERVIEWER');
         close interviews;
         return;
       else
         close interviews;
       end if;
       p_where := 'REVIEW';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',8);
     if p_where = 'REVIEW' then
--
       open reviews_or_events(p_type =>'I');
--
       fetch reviews_or_events into l_dummy;
--
       if reviews_or_events%FOUND then
         hr_utility.set_message(801,'HR_EMP_DUE_REVIEW');
         close reviews_or_events;
         return;
       else
         close reviews_or_events;
       end if;
       p_where := 'VACANCY';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',9);
     if p_where = 'VACANCY' then
--
       open vacancy;
--
       fetch vacancy into l_dummy;
--
       if vacancy%FOUND then
         hr_utility.set_message(801,'HR_EMP_VAC_RECRUITER');
         close vacancy;
         return;
       else
         close vacancy;
       end if;
     p_where:= 'REQUISITION';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',10);
     if p_where = 'REQUISITION' then
--
       open requisition;
--
       fetch requisition into l_dummy;
--
       if requisition%FOUND then
         hr_utility.set_message(801,'HR_EMP_REQUISITIONS');
         close requisition;
         return;
       else
         close requisition;
       end if;
     p_where:= 'BUDGET_VALUE';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',11);
     if p_where = 'BUDGET_VALUE' then
--
       open budget_values;
--
       fetch budget_values into l_dummy;
--
       if budget_values%FOUND then
         hr_utility.set_message(801,'HR_EMP_BUDGET_VALUES');
         close budget_values;
         return;
       else
         close budget_values;
       end if;
     p_where:= 'PAYMENT';
     end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',12);
     if p_where = 'PAYMENT' then
--
       open payment;
--
       fetch payment into l_dummy;
--
       if payment%FOUND then
         hr_utility.set_message(801,'HR_EMP_PAYMENT_METHODS');
         close payment;
         return;
       else
         close payment;
       end if;
     p_where:= 'END';
     else
       app_exception.invalid_argument('cancel_hire',
                                  'P_WHERE',p_where);
     end if;
--
--
--
   elsif p_cancel_type = 'APL' then
--
     if p_where = 'BEGIN' then
--
       hr_utility.set_location('APP1.B_PRE_DEL_CHECK',1);
       hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',13);
--
-- Start Bug 3285486. commented the call to hr_person.chk_future_person_type
-- added the new call to hr_person_type_usage_info.FutSysPerTypeChgExists
--
   /*    if hr_person.chk_future_person_type(p_system_person_type
                                          ,p_person_id
                                          ,p_business_group_id
                                          ,p_primary_date) then*/
  IF hr_person_type_usage_info.FutSysPerTypeChgExists
       (p_person_type_usage_id => l_person_type_usage_id
       ,p_effective_date       => p_primary_date
       ,p_person_id            => p_person_id ) THEN
--
-- End Bug 3285486
--
         hr_utility.set_message(800,'HR_7080_ALL_APP_NO_CANCEL');
         hr_utility.raise_error;
--
       end if;
--
       hr_utility.set_location('APP1.B_PRE_DEL_CHECK',2);
       hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',14);
--
       if  not hr_person.chk_prev_person_type(p_system_person_type
                                               ,p_person_id
                                               ,p_business_group_id
                                               ,p_primary_date) then
--
         hr_utility.set_message(800,'HR_7081_ALL_APP_NO_CANCEL');
         hr_utility.raise_error;
--
       end if;
--
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',15);

     else
       app_exception.invalid_argument('cancel_apl',
                                  'P_WHERE',p_where);
     end if;
  else
     app_exception.invalid_argument('cancel_hire_or_apl',
                                  'P_CANCEL_TYPE',p_cancel_type);
  end if;
     hr_utility.set_location('cancel_hire_or_apl.pre_cancel_checks',16);
  exception
   when hr_utility.hr_error then
      raise;
   when others then
     hr_utility.oracle_error(sqlcode);
     hr_utility.raise_error;
end pre_cancel_checks;
--
--
-- fix 7410493
--
-- ----------------------------------------------------------------------------
-- |-----------------------< cancel_emp_apl_hire >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_emp_apl_hire
(
   p_person_id NUMBER
  ,p_date_start DATE
  ,p_end_of_time DATE
  ,p_business_group_id NUMBEr
  ,p_period_of_service_id NUMBER)  is


    p_assignment_id  NUMBER;
    l_asg number;
    l_person_end_date date;
    p_date_start1 date;
    p_rowid ROWID;
    l_period_of_service_id NUMBER;
    l_assignment_id NUMBER;
    l_person_type_id NUMBER;
    l_asg_status_id      irc_assignment_statuses.assignment_status_id%type;
    l_asg_status_ovn     irc_assignment_statuses.object_version_number%type;
    l_asg_status_type_id per_all_assignments_f.assignment_status_type_id%type;
    l_dummy varchar2(10);

cursor budget_values1 is
select rowid
from per_assignment_budget_values_f pab
where pab.business_group_id = p_business_group_id and

exists (select 'budget_values exist'
               from per_all_assignments_f paf
               where  pab.business_group_id    +0= paf.business_group_id + 0
               and    paf.business_group_id    +0= p_business_group_id
               and    pab.assignment_id        = paf.assignment_id
               and    paf.person_id            = p_person_id
               and    paf.period_of_service_id = l_period_of_service_id
               and    paf.effective_end_date  >= p_date_start
	       --for bug 5949102
               --and    pab.effective_end_date  >= p_date_start
	       )
and    pab.effective_end_date  >= p_date_start;

-- payment cursor
--
cursor payment1 is
select rowid
from pay_personal_payment_methods ppm
where  ppm.business_group_id                  = p_business_group_id
and    exists (select 'exists'
               from per_all_assignments_f paf
               where paf.business_group_id    +0= p_business_group_id
               and   paf.person_id            = p_person_id
               and   paf.assignment_id        = ppm.assignment_id
               and   paf.period_of_service_id = l_period_of_service_id
	       --for 5949102
               --and ppm.effective_start_date>= p_date_start
              )
              --end 5949102
and   ppm.effective_start_date               >= p_date_start;


cursor assignments is

select rowid, assignment_id, assignment_status_type_id
from per_all_assignments_f paf1
where paf1.business_group_id    +0 = p_business_group_id
and   paf1.person_id             =  p_person_id
and paf1.assignment_type ='A'
and paf1.effective_end_date = p_date_start -1
and exists ( select '1' from
 per_all_assignments_f paf2
 where paf2.business_group_id    +0= p_business_group_id
and   paf2.person_id            = p_person_id
and PAF2.assignment_type ='E'
and paf2.effective_start_date = p_date_start
and paf1.assignment_id = paf2.assignment_id
and   paf2.period_of_service_id = l_period_of_service_id );


-- Cusror for iRecruitment assignment status
cursor irc_asg_status is
       select iass.assignment_status_id, iass.object_version_number
         from irc_assignment_statuses iass
        where iass.assignment_status_id =
              (select max(iass.assignment_status_id)
                 from irc_assignment_statuses iass
                where iass.assignment_id = l_assignment_id
                  and iass.assignment_status_type_id = l_asg_status_type_id);

-- assignment cursor for entries update
--
--
cursor ass1 is
 select assignment_id,effective_start_date
 from   per_all_assignments_f papf1
 where  papf1.person_id = p_person_id
 and    papf1.business_group_id +0 = p_business_group_id
 and    papf1.period_of_service_id is NULL
 and    papf1.assignment_type in ('A')
 and    (p_date_start -1) =( select max(effective_end_date)
                             from per_all_assignments_f papf2
                             where papf1.assignment_id =papf2.assignment_id);

cursor ass2 is
 select assignment_id,effective_start_date,ROWID
 from   per_all_assignments_f
 where  person_id = p_person_id
 and    business_group_id +0 = p_business_group_id
 and    period_of_service_id is NULL
 and    assignment_type in ('A')
 and    effective_end_date =  p_end_of_time;

 -- primary assignment update
 cursor csr_prm_asg is
 select assignment_id
 from per_all_assignments_f
 where person_id= p_person_id
 and business_group_id= p_business_group_id
 and assignment_type='E'
 and primary_flag='Y'
 and effective_end_date= p_date_start -1
 and period_of_service_id=l_period_of_service_id;
--
cursor c_assignments is
select paf.assignment_id, paf.effective_start_date
  from per_all_assignments_f paf
 where paf.person_id = p_person_id
   and paf.business_group_id +0 = p_business_group_id
  and paf.assignment_type not in ('B','O');  -- issue 3 raised .


-- applications cursor
--
cursor applications is
select rowid
from per_applications pap
where exists (select 'row exists'
 from   per_all_assignments_f paf
 where  paf.person_id = p_person_id
 and    paf.business_group_id +0 = p_business_group_id
 and    paf.period_of_service_id is NULL
 and    paf.effective_end_date = p_date_start - 1
 and    pap.application_id = paf.application_id);
--
-- period cursor
--
--
-- Period cursor
--
cursor period is
      select pps.rowid
      from   per_periods_of_service pps
      where  pps.person_id = p_person_id
      and period_of_service_id = l_period_of_service_id;
--
-- person cursor
--
cursor person is
select p.rowid, effective_end_date from per_people_f p
where  p.person_id = p_person_id
and   p.effective_start_date >= p_date_start;

-- new_person
--
cursor new_person is
select p.rowid from per_people_f p
where p.person_id = p_person_id
and   p.effective_end_date = p_date_start -1;

-- fix for bug 5005157 starts here.
cursor pay_proposals2(p_assignment_id NUMBER) is
select ppp.pay_proposal_id, ppp.object_version_number
from per_pay_proposals ppp
where p_assignment_id = ppp.assignment_id;

 cursor csr_get_salary(p_assignment_id NUMBER) is
  select element_entry_id
  from   pay_element_entries_f
  where  assignment_id = p_assignment_id
  and    creator_type = 'SP'
  and    p_date_start between
         effective_start_date and effective_end_date;


cursor csr_chk_rec_exists(p_assignment_id NUMBER) is
  select element_entry_id
  from   pay_element_entries_f
  where  assignment_id = p_assignment_id
  and    creator_type = 'SP'
  and    (p_date_start - 1) between
         effective_start_date and effective_end_date;


CURSOR csr_get_ptu_id IS
    SELECT ptu.person_type_usage_id
    FROM   per_person_types pt,
           per_person_type_usages_f ptu
    WHERE  pt.business_group_id     = p_business_group_id
    AND    pt.person_type_id        = ptu.person_type_id
    AND    p_date_start BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
    AND    ptu.person_id            = p_person_id
    AND    pt.system_person_type = 'EX_APL';

-- Cursor to seelct assignment actions on or after the hire date.
--
cursor csr_assign_actions_exist is
select 'Y'
from   per_all_assignments_f a
where  a.person_id = p_person_id

AND    a.period_of_service_id = l_period_of_service_id
AND    ((a.effective_start_date = p_date_start
         and a.primary_flag <> 'Y'
         and not exists ( select b.assignment_id
                          from   per_all_assignments_f b
                          where  nvl(b.effective_end_date,hr_api.g_eot)
                                  = (p_date_start-1)
                          and    b.assignment_id = a.assignment_id) )
         OR  a.effective_start_date > p_date_start );


cursor csr_payactions is

   SELECT null
              FROM   pay_payroll_actions pac,
                     pay_assignment_actions act,
                     per_assignments_f asg
              WHERE  asg.person_id = p_person_id
               AND  asg.period_of_service_id = l_period_of_service_id
               AND  act.assignment_id = asg.assignment_id
                AND  pac.payroll_action_id = act.payroll_action_id
                AND  pac.action_type NOT IN ('X','BEE')
                AND  p_date_start BETWEEN asg.effective_start_date
                                    AND asg.effective_end_date
                 AND  pac.effective_date >= p_date_start;


l_person_type_usage_id NUMBER;
 l_element_entry_id1             number;
 l_element_entry_id              number;
 l_pk_id NUMBER;
 l_ovn   NUMBER;
 l_business_group_id NUMBER;
 l_sal_warning BOOLEAN;

 FUNCTION get_period_of_service (p_person_id IN INTEGER
                               ,p_start_date IN DATE) RETURN INTEGER is
  --
  v_dummy INTEGER;
  --
begin
  select pps.period_of_service_id
  into   v_dummy
  from   per_periods_of_service pps
  where  p_start_date = pps.date_start
  and     pps.person_id = p_person_id;
--
  return v_dummy;
exception
  when no_data_found then
    hr_utility.set_message(801,'HR_6346_EMP_ASS_NO_POS');
    hr_utility.raise_error;
end;


  begin

  hr_utility.set_location('cancel_emp_apl_hire ',10);

  -- FIRST PERFROM ALL THE CHECKS TO SEE IF THE CANCEL HIRE PROCESS CAN BE
  -- MADE WITH OUT ANY ISSUE.
/*
  OPEN  csr_get_ptu_id;
  FETCH csr_get_ptu_id INTO l_person_type_usage_id;

  IF csr_get_ptu_id%NOTFOUND THEN
    --
    CLOSE csr_get_ptu_id;
    --
    -- # 3690364 - changed application_id from 801 to 800
    hr_utility.set_message(800,'HR_289548_PEM_EMP_PERSON_ID');
    hr_utility.raise_error;
    --
  END IF;
  CLOSE csr_get_ptu_id;

 hr_utility.set_location('cancel_emp_apl_hire ',11);

IF hr_person_type_usage_info.FutSysPerTypeChgExists
       (p_person_type_usage_id => l_person_type_usage_id
       ,p_effective_date       => p_date_start
       ,p_person_id            => p_person_id ) THEN
-- End Bug 3285486.
--
         hr_utility.set_message(801,'HR_7078_EMP_ENTER_CANCEL_TYPE');
         hr_utility.raise_error;
--
       end if;
*/
if p_period_of_service_id is null then
   l_period_of_service_id:=  get_period_of_service(p_person_id => p_person_id
                       ,p_start_date =>p_date_start);
      hr_utility.set_location('cancel_emp_apl_hire ',20);
  else
    l_period_of_service_id := p_period_of_service_id;
      hr_utility.set_location('cancel_emp_apl_hire',30);
  end if;
    hr_utility.set_location('cancel_emp_apl_hire ',40);

 hr_utility.set_location('cancel_emp_apl_hire ',12);

     open csr_assign_actions_exist;
      fetch csr_assign_actions_exist into l_dummy;

      if csr_assign_actions_exist%FOUND then
        close csr_assign_actions_exist;
        hr_utility.set_message(800,'PER_289566_ASG_ACTIONS_EXISTS');
        hr_utility.raise_error;
      end if;
      close csr_assign_actions_exist;

 hr_utility.set_location('cancel_emp_apl_hire ',14);

  open csr_payactions;
       fetch csr_payactions into l_dummy;
       --
       if csr_payactions%found then
         close csr_payactions;
         hr_utility.set_message(800,'HR_289529_EMP_FUT_PAY_EXIST');
         hr_utility.raise_error;
       end if;
       --
       close csr_payactions;
 hr_utility.set_location('cancel_emp_apl_hire ',15);
  --
  l_business_group_id := p_business_group_id;-- fix for bug 5005157 .


     open assignments;
<<assignment>>
  loop
  -- VT #438579 03/05/79 added assignment_id
      hr_utility.set_location('cancel_emp_apl_hire ',50);
  fetch assignments into p_rowid,l_assignment_id,l_asg_status_type_id; -- Bug 3564129
  exit when assignments%NOTFOUND;

   hr_utility.set_location('l_assignment_id '||l_assignment_id,60);

   hr_utility.set_location('cancel_emp_apl_hire ',70);

  -- VT #438579 03/05/97 added delete

  delete from per_spinal_point_placements_f spp
  where spp.assignment_id = l_assignment_id;

  delete from pay_cost_allocations_f pca
  where pca.assignment_id = l_assignment_id;

    hr_utility.set_location('cancel_emp_apl_hire ',80);
  -- Start of fix 3564129

  open irc_asg_status;
    fetch irc_asg_status into l_asg_status_id, l_asg_status_ovn;
  if irc_asg_status%found then
     --
     IRC_ASG_STATUS_API.delete_irc_asg_status
         (p_assignment_status_id  => l_asg_status_id
         ,p_object_version_number => l_asg_status_ovn);
     --
  end if;
  close irc_asg_status;
  -- fix for bug 5005157 starts here.
    hr_utility.set_location('cancel_emp_apl_hire ',90);
   open pay_proposals2(l_assignment_id);
   <<pay_proposals>>
    loop
    fetch pay_proposals2 into l_pk_id, l_ovn;
    exit when pay_proposals2%NOTFOUND;
      hr_maintain_proposal_api.delete_salary_proposal(p_pay_proposal_id  => l_pk_id
                        ,p_business_group_id  => l_business_group_id
                        ,p_object_version_number => l_ovn
                        ,p_validate   => FALSE
                        ,p_salary_warning  =>  l_sal_warning);
    end loop pay_proposals;
    close pay_proposals2;
   hr_utility.set_location('cancel_emp_apl_hire ',100);
    open csr_get_salary(l_assignment_id);
    fetch csr_get_salary into l_element_entry_id;
    if csr_get_salary%found then
      close csr_get_salary;

      open csr_chk_rec_exists(l_assignment_id);
      fetch csr_chk_rec_exists into l_element_entry_id1;

   if csr_chk_rec_exists%found then
      close csr_chk_rec_exists;
      --
      hr_entry_api.delete_element_entry
        ('DELETE'
        ,p_date_start - 1
        ,l_element_entry_id);
      else
      close csr_chk_rec_exists;
       hr_entry_api.delete_element_entry
        ('ZAP'
        ,p_date_start
        ,l_element_entry_id);
 end if;
    else
       close csr_get_salary;
    end if;


  hr_utility.set_location('cancel_emp_apl_hire ',110);

  delete from per_all_assignments_f paf
  where paf.assignment_id=l_assignment_id
  and paf.person_id=p_person_id
  and paf.effective_start_date=p_date_start;

    hr_utility.set_location('cancel_emp_apl_hire ',120);


     update per_all_assignments_f
     set effective_end_date = p_end_of_time
     where assignment_id=l_assignment_id
     and  person_id=p_person_id
     and  effective_end_date= p_date_start -1;

    hr_utility.set_location('cancel_emp_apl_hire ',121);


  end loop assignment;
  close assignments;

  hr_utility.set_location('cancel_emp_apl_hire ',130);

  open applications;
<<application>>
  loop

 hr_utility.set_location('cancel_emp_apl_hire ',140);
  fetch applications into p_rowid;

  exit when applications%NOTFOUND;

  update per_applications pap
  set pap.date_end = NULL
  where pap.rowid = p_rowid;

  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','cancel_hire_or_apl');
    hr_utility.set_message_token('STEP',11);
    hr_utility.raise_error;
  end if;
  end loop application;
  close applications;

 hr_utility.set_location('cancel_emp_apl_hire ',150);

 open ass2;
<<entries>>
 loop
      hr_utility.set_location('cancel_emp_apl_hire',280);
  fetch ass2 into p_assignment_id,p_date_start1,p_rowid;
  exit when ass2%NOTFOUND;
 hr_utility.set_location('cancel_emp_apl_hire ',160);
--
  hrentmnt.maintain_entries_asg(p_assignment_id
            ,p_business_group_id
            ,'CNCL_HIRE'
            ,NULL
            ,NULL
            ,NULL
            ,'ZAP'
            ,p_date_start
            ,p_end_of_time);
--
  end loop entries;
  close ass2;
--
open ass1;

 loop
      hr_utility.set_location('cancel_emp_apl_hire ',280);
  fetch ass1 into p_assignment_id,p_date_start1;
  exit when ass1%NOTFOUND;
 hr_utility.set_location('p_assignment_id  '||p_assignment_id,160);
 hr_utility.set_location('p_date_start1  '||p_date_start1,160);

     update per_all_assignments_f
     set effective_end_date = p_end_of_time
     where assignment_id=p_assignment_id
     and  person_id=p_person_id
     and  effective_end_date= p_date_start -1;
--
  --
  end loop;
  close ass1;
--
 hr_utility.set_location('cancel_hire_or_apl ',250);
-- this cursor is to delete the asg changes from hire date onwards
-- and will update the primary flag to Y so that the asg data will
-- retain as how it was..

open csr_prm_asg;
fetch csr_prm_asg into l_asg;
close csr_prm_asg;

delete from per_all_assignments_f
where person_id= p_person_id
and assignment_id = l_asg
and effective_start_date > = p_date_start;

update per_all_assignments_f
    set effective_end_date = p_end_of_time

WHERE person_id= p_person_id
and assignment_id = l_asg
AND effective_end_date = p_date_start -1
and primary_flag='Y';

  open person;
<<per>>
  loop
 hr_utility.set_location('cancel_emp_apl_hire ',300);
  fetch person into p_rowid, l_person_end_date;
  exit when person%notfound;

        delete from per_people_f
        where rowid = p_rowid;
     --
  end loop person;
  close person;

      hr_utility.set_location('cancel_emp_apl_hire ',350);


       open new_person;
    <<new_per>>
      loop
 hr_utility.set_location('cancel_emp_apl_hire ',370);
      fetch new_person into p_rowid;
      exit when new_person%notfound;


          hr_utility.set_location('cancel_emp_apl_hire ',400);

         update per_people_f
         set effective_end_date = p_end_of_time
         where rowid = p_rowid;

          hr_utility.set_location('cancel_emp_apl_hire ',450);
       end loop new_person;
      close new_person;

  hr_utility.set_location('cancel_emp_apl_hire ',500);

 -- this is to cancel the person type so that we can revert
 -- back to previous person type i.e emp-apl
   OPEN  csr_get_ptu_id;
   FETCH csr_get_ptu_id INTO l_person_type_usage_id;

  IF csr_get_ptu_id%FOUND THEN
    --
     hr_utility.set_location('cancel_emp_apl_hire', 510);
    CLOSE csr_get_ptu_id;

     hr_per_type_usage_internal.cancel_emp_apl_ptu
	(p_effective_date 	=> p_date_start
	,p_person_id 		=> p_person_id
	,p_system_person_type 	=> 'EX_APL');

  else

  CLOSE csr_get_ptu_id;
  end if;

 hr_utility.set_location('cancel_emp_apl_hire', 521);

     hr_per_type_usage_internal.cancel_emp_apl_ptu
	(p_effective_date 	=> p_date_start
	,p_person_id 		=> p_person_id
	,p_system_person_type 	=> 'EMP');

  hr_utility.set_location('cancel_emp_apl_hire : END ' ,550);
  --

 update per_applications pap
  set pap.date_end = NULL
  where  application_id in ( select distinct (application_id)
         from  per_all_assignments_f
         where person_id= p_person_id
         and assignment_type = 'A'
         and sysdate between effective_start_date and effective_end_date
         );

  per_cancel_hire_or_apl_pkg.update_person_list(p_person_id => p_person_id);
--
for asg_rec in c_assignments loop
  --
  hr_utility.set_location('cancel_emp_apl_hire', 551);
  --
  hr_security_internal.add_to_person_list(
                       p_effective_date => asg_rec.effective_start_date
                      ,p_assignment_id  => asg_rec.assignment_id);
  --
  hr_utility.set_location('cancel_emp_apl_hire', 552);
  --
end loop;

  end cancel_emp_apl_hire;

--
-- fix 7410493
/*===========================================================================*
 |                                                                           |
 |                              upd_person_type_usage_end_date               |
 |                                                                           |
*============================================================================*/
/*Procedure to update the end date person type OTHER
  when cancel placement is done.Added for the bug 6460093*/

procedure upd_person_type_usage_end_date
(
   p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_system_person_type             in     varchar2


 ) is

   cursor csr_upded_person_type_usages
  (
     p_effective_date                 in     date
    ,p_person_id                      in     number
    ,p_system_person_type             in     varchar2
   ) is
    select ptu.person_type_usage_id
          ,ptu.object_version_number
      from per_person_type_usages_f ptu
     where p_effective_date between ptu.effective_start_date and ptu.effective_end_date
       and ptu.person_id = p_person_id
       and ptu.person_type_id in
             (select ppt.person_type_id
                from per_person_types ppt
               where ((   p_system_person_type = 'OTHER'
                        and ppt.system_person_type = 'OTHER' )));

     l_csr_upd_per_type_usages  csr_upded_person_type_usages%rowtype;

     l_effective_end_date	date := hr_general.end_of_time;
    begin

    hr_utility.set_location('Entering Upd_Person_Type_Usage_End_Date',491);

    open csr_upded_person_type_usages(
	p_person_id  => p_person_id,
	p_effective_date => p_effective_date,
	p_system_person_type => p_system_person_type);

	fetch csr_upded_person_type_usages into l_csr_upd_per_type_usages;
    if csr_upded_person_type_usages%found then

      hr_utility.set_location('Entering Upd_Person_Type_Usage_End_Date',492);

       update per_person_type_usages_f ptu
       set effective_end_date = l_effective_end_date
       where ptu.effective_end_date = p_effective_date
       and ptu.person_id             = p_person_id
       and ptu.person_type_usage_id  = l_csr_upd_per_type_usages.person_type_usage_id
       and ptu.object_version_number = l_csr_upd_per_type_usages.object_version_number;

    end if;
  close csr_upded_person_type_usages;

  hr_utility.set_location('Leaving Upd_Person_Type_Usage_End_Date',493);
end upd_person_type_usage_end_date;

/*Procedure Added for the bug 6460093*/


procedure do_cancel_hire(p_person_id NUMBER
                        ,p_date_start DATE
                        ,p_end_of_time DATE
                        ,p_business_group_id NUMBER
                        ,p_period_of_service_id NUMBER) is
--
p_assignment_id NUMBER;
p_start_date DATE;
p_rowid ROWID;
l_period_of_service_id NUMBER;
-- VT #438579 03/05/97
l_assignment_id NUMBER;
l_back2back BOOLEAN;
l_person_type_id NUMBER;
-- Start of fix 3564129
l_asg_status_id      irc_assignment_statuses.assignment_status_id%type;
l_asg_status_ovn     irc_assignment_statuses.object_version_number%type;
l_asg_status_type_id per_all_assignments_f.assignment_status_type_id%type;
-- End of fix 3564129
--

l_system_person_type per_person_types.system_person_type%type; --added for bug 8405711

-- supervisor cursor.
--
cursor supervisor1 is
select rowid
from   per_assignments_f p
where  (p.business_group_id = p_business_group_id OR
nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and    p.supervisor_id = p_person_id;
--
-- recruiter cursor
--
cursor recruiter1 is
select rowid
from   per_assignments_f p
where  p.recruiter_id = p_person_id
and    (p.business_group_id = p_business_group_id OR
     nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y');
--
-- events cursor
--
cursor events is
select rowid
from per_bookings pb
where (pb.business_group_id = p_business_group_id OR
      nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and   pb.person_id = p_person_id
and   exists ( select 'row exists'
               from per_events pe
               where pe.business_group_id + 0 = p_business_group_id
               and   pe.event_id = pb.event_id
               and   pe.event_or_interview in ('I','E')
               and   pe.date_start >= p_date_start);
--
-- vacancies cursor
--
cursor vacancies is
select rowid
from   per_vacancies pv
where (pv.business_group_id = p_business_group_id OR
     nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and   pv.recruiter_id      = p_person_id
and   pv.date_from        >= p_date_start;
--
-- requisitions cursor
--
cursor requisitions1 is
select rowid
from per_requisitions pr
where (pr.business_group_id = p_business_group_id OR
      nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
and   pr.person_id         = p_person_id;
--
-- absenses cursor
--
cursor absenses1 is
select rowid
from per_absence_attendances paa
where  paa.business_group_id +0 = p_business_group_id
and    paa.person_id         = p_person_id
and    paa.date_start       >= p_date_start;
--
-- budget_values cursor
--
cursor budget_values1 is
select rowid
from per_assignment_budget_values_f pab
where pab.business_group_id = p_business_group_id and
exists (select 'budget_values exist'
               from per_all_assignments_f paf
               where  pab.business_group_id    +0= paf.business_group_id + 0
               and    paf.business_group_id    +0= p_business_group_id
               and    pab.assignment_id        = paf.assignment_id
               and    paf.person_id            = p_person_id
               and    paf.period_of_service_id = l_period_of_service_id
               and    paf.effective_end_date  >= p_date_start
	       --start bug 5987416
               --and    pab.effective_end_date  >= p_date_start
	       )
and    pab.effective_end_date  >= p_date_start;
--end bug 5987416
--
-- payment cursor
--
cursor payment1 is
select rowid
from pay_personal_payment_methods ppm
where  ppm.business_group_id                  = p_business_group_id
and    exists (select 'exists'
               from per_all_assignments_f paf
               where paf.business_group_id    +0= p_business_group_id
               and   paf.person_id            = p_person_id
               and   paf.assignment_id        = ppm.assignment_id
               and   paf.period_of_service_id = l_period_of_service_id
	       --start bug 5987416
               -- and   ppm.effective_start_date>= p_date_start
	       --end bug 5987416
              )
and   ppm.effective_start_date               >= p_date_start;
--
-- comments cursor
--
cursor comments1 is
select rowid
from hr_comments h
where exists (select 'comments exist'
               from    per_all_assignments_f paf
               where  h.comment_id = paf.comment_id
               and   paf.business_group_id    +0= p_business_group_id
               and   paf.person_id            = p_person_id
               and   paf.period_of_service_id = l_period_of_service_id);
--
-- assignments cursor
--
-- VT #438579 03/05/79 added assignment_id
cursor assignments is
select rowid, assignment_id, assignment_status_type_id -- Bug 3564129
from per_all_assignments_f paf
where paf.business_group_id    +0= p_business_group_id
and   paf.person_id            = p_person_id
and   paf.period_of_service_id = l_period_of_service_id;
--
-- Start of fix 3564129
-- Cusror for iRecruitment assignment status
cursor irc_asg_status is
       select iass.assignment_status_id, iass.object_version_number
         from irc_assignment_statuses iass
        where iass.assignment_status_id =
              (select max(iass.assignment_status_id)
                 from irc_assignment_statuses iass
                where iass.assignment_id = l_assignment_id
                  and iass.assignment_status_type_id = l_asg_status_type_id);
-- End of fix 3564129
--
-- assignment cursor for entries update
--
--Added the assignment type condition of 'A' for fix of #3390818
--
cursor ass1 is
 select assignment_id,effective_start_date,ROWID
 from   per_all_assignments_f
 where  person_id = p_person_id
 and    business_group_id +0 = p_business_group_id
 and    period_of_service_id is NULL
 and    assignment_type in ('E','A')   -- 3194314
 and    effective_end_date = p_date_start - 1
 for update of effective_end_date;
--
--
cursor csr_alus is -- fix for the bug 7578210
 select assignment_id,effective_start_date,ROWID
 from   per_all_assignments_f
 where  person_id = p_person_id
 and    business_group_id +0 = p_business_group_id
 and    period_of_service_id = l_period_of_service_id
 and    assignment_type in ('E');
--
--
cursor c_assignments is
select paf.assignment_id, paf.effective_start_date
  from per_all_assignments_f paf
 where paf.person_id = p_person_id
   and paf.business_group_id +0 = p_business_group_id
   and    assignment_type not in ('B','O');                       --modified for bug #6449599 and bug # 7572514
--
-- applications cursor
--
cursor applications is
select rowid
from per_applications pap
where exists (select 'row exists'
 from   per_all_assignments_f paf
 where  paf.person_id = p_person_id
 and    paf.business_group_id +0 = p_business_group_id
 and    paf.period_of_service_id is NULL
 and    paf.effective_end_date = p_date_start - 1
 and    pap.application_id = paf.application_id);
--
-- period cursor
--
--
-- Period cursor
--
cursor period is
      select pps.rowid
      from   per_periods_of_service pps
      where  pps.person_id = p_person_id
      and period_of_service_id = l_period_of_service_id;
--
-- person cursor
--
cursor person is
select p.rowid, effective_end_date from per_people_f p
where  p.person_id = p_person_id
and   p.effective_start_date >= p_date_start;
--
-- 3194314
--
cursor csr_emp_ptu_id is
  select ptu.person_type_id
   from per_person_type_usages_f ptu
       ,per_person_types ppt
  where ptu.person_id = p_person_id
    and ptu.effective_start_date = p_date_start
    and ptu.person_type_id = ppt.person_type_id
    and ppt.system_person_type = 'EMP';

l_emp_ptu_id number;

--
--3848352 start
--
cursor csr_apl_ptu_id is
  select ptu.person_type_id
   from per_person_type_usages_f ptu
       ,per_person_types ppt
  where ptu.person_id = p_person_id
    and ptu.effective_end_date = p_date_start - 1
    and ptu.person_type_id = ppt.person_type_id
    and ppt.system_person_type = 'APL';

l_apl_ptu_id number;
l_dummy number;
l_apl_flag varchar2(1);
--
--3848352 end
--
--
cursor csr_is_cwk(cp_date_start date) is  -- 3194314
  select pp.period_of_placement_id, pp.date_start
    from per_periods_of_placement pp
   where pp.person_id = p_person_id
     and pp.actual_termination_date = cp_date_start - 1;

l_pp_id number;
l_cwk_date_start date;

-- <<
l_person_end_date date; --#1998140
--
-- new_person
--
cursor new_person is
select p.rowid from per_people_f p
where p.person_id = p_person_id
and   p.effective_end_date = p_date_start -1;

-- fix for bug 5005157 starts here.
cursor pay_proposals2(p_assignment_id NUMBER) is
select ppp.pay_proposal_id, ppp.object_version_number
from per_pay_proposals ppp
where p_assignment_id = ppp.assignment_id;

 cursor csr_get_salary(p_assignment_id NUMBER) is
  select element_entry_id
  from   pay_element_entries_f
  where  assignment_id = p_assignment_id
  and    creator_type = 'SP'
  and    p_start_date between
         effective_start_date and effective_end_date;


cursor csr_chk_rec_exists(p_assignment_id NUMBER) is
  select element_entry_id
  from   pay_element_entries_f
  where  assignment_id = p_assignment_id
  and    creator_type = 'SP'
  and    (p_start_date - 1) between
         effective_start_date and effective_end_date;


 l_element_entry_id1             number;
 l_element_entry_id              number;
 l_pk_id NUMBER;
 l_ovn   NUMBER;
 l_business_group_id NUMBER;
 l_sal_warning BOOLEAN;
-- fix for bug 5005157 ends here.


--
FUNCTION get_period_of_service (p_person_id IN INTEGER
                               ,p_start_date IN DATE) RETURN INTEGER is
  --
  v_dummy INTEGER;
  --
begin
  select pps.period_of_service_id
  into   v_dummy
  from   per_periods_of_service pps
  where  p_start_date = pps.date_start
  and     pps.person_id = p_person_id;
--
  return v_dummy;
exception
  when no_data_found then
    hr_utility.set_message(801,'HR_6346_EMP_ASS_NO_POS');
    hr_utility.raise_error;
end;
begin
  --
  hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',10);
  --
  l_business_group_id := p_business_group_id;-- fix for bug 5005157 .
  if p_period_of_service_id is null then
   l_period_of_service_id:=  get_period_of_service(p_person_id => p_person_id
                       ,p_start_date =>p_date_start);
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',20);
  else
    l_period_of_service_id := p_period_of_service_id;
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',30);
  end if;
  open supervisor1;
<<supervisor>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',40);
  fetch supervisor1 into p_rowid;
  exit when supervisor1%NOTFOUND;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',50);
  update per_all_assignments_f paf
  set    paf.supervisor_id         = NULL
  where  paf.rowid     = p_rowid;
--
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',1);
    hr_utility.raise_error;
  end if;
  end loop supervisor;
  close supervisor1;
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',60);
  open recruiter1;
<<recruiter>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',70);
  fetch recruiter1 into p_rowid;
  exit when recruiter1%NOTFOUND;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',80);
  update per_all_assignments_f paf
  set    paf.recruiter_id          = NULL
  where  paf.rowid     = p_rowid;
--
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',2);
    hr_utility.raise_error;
  end if;
  end loop recruiter;
  close recruiter1;
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',90);
  open events;
<<event>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',100);
  fetch events into p_rowid;
  exit when events%NOTFOUND;
  delete from per_bookings pb
  where  pb.rowid = p_rowid;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',110);
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',3);
    hr_utility.raise_error;
  end if;
  end loop event;
  close events;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',120);
--
  open vacancies;
<<vacancy>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',130);
  fetch vacancies into p_rowid;
  exit when vacancies%NOTFOUND;
--
  update per_all_vacancies pv
  set    pv.recruiter_id      = NULL
  where  pv.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',4);
    hr_utility.raise_error;
  end if;
  end loop vacancy;
  close vacancies;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',140);
  open requisitions1;
<<requisition>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',150);
  fetch requisitions1 into p_rowid;
  exit when requisitions1%NOTFOUND;
  update per_requisitions pr
  set pr.person_id = NULL
  where  pr.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',5);
    hr_utility.raise_error;
  end if;
  end loop requisition;
  close requisitions1;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',160);
  open absenses1;
<<absence>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',170);
  fetch absenses1 into p_rowid;
  exit when absenses1%NOTFOUND;
  delete from per_absence_attendances paa
  where paa.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',6);
    hr_utility.raise_error;
  end if;
  end loop absense;
  close absenses1;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',180);
  open budget_values1;
<<budget_value>>
  loop
  fetch budget_values1 into p_rowid;
  exit when budget_values1%NOTFOUND;
  delete from per_assignment_budget_values_f pab
  where  pab.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',7);
    hr_utility.raise_error;
  end if;
  end loop budget_value;
  close budget_values1;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',190);
  open payment1;
<<pay>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',200);
  fetch payment1 into p_rowid;
  exit when payment1%NOTFOUND;
  delete from pay_personal_payment_methods ppm
  where  ppm.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',8);
    hr_utility.raise_error;
  end if;
  end loop pay;
  close payment1;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',210);
  open comments1;
<<comment>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',220);
  fetch comments1 into p_rowid;
  exit when comments1%NOTFOUND;
  delete from hr_comments h
  where  h.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',9);
    hr_utility.raise_error;
  end if;
  end loop comment;
  close comments1;
--
    hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',230);
       -- delete the alus before performing the following operation on the
      -- asg data so that we dont lose the child (element entries ) records
-- fix for the bug 7415677
      open csr_alus;

 loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',282);
  fetch csr_alus into p_assignment_id,p_start_date,p_rowid;
  exit when csr_alus%NOTFOUND;
   hr_utility.set_location('p_assignment_id ' ||p_assignment_id,280);
   hr_utility.set_location('p_start_date ' ||p_start_date,280);
  hrentmnt.maintain_entries_asg(p_assignment_id
            ,p_business_group_id
            ,'CNCL_HIRE'
            ,NULL
            ,NULL
            ,NULL
            ,'ZAP'
            ,p_start_date
            ,p_end_of_time);
--
  end loop;
  close csr_alus;

 hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',283);
--
-- fix for the bug 7578210 .
--
  open assignments;
<<assignment>>
  loop
  -- VT #438579 03/05/79 added assignment_id
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',240);
  fetch assignments into p_rowid,l_assignment_id,l_asg_status_type_id; -- Bug 3564129
  exit when assignments%NOTFOUND;
  -- VT #438579 03/05/97 added delete
  delete from per_spinal_point_placements_f spp
  where spp.assignment_id = l_assignment_id;
  delete from pay_cost_allocations_f pca
  where pca.assignment_id = l_assignment_id;
  -- Start of fix 3564129
  open irc_asg_status;
  fetch irc_asg_status into l_asg_status_id, l_asg_status_ovn;
  if irc_asg_status%found then
     --
     IRC_ASG_STATUS_API.delete_irc_asg_status
         (p_assignment_status_id  => l_asg_status_id
         ,p_object_version_number => l_asg_status_ovn);
     --
  end if;
  close irc_asg_status;
  -- fix for bug 5005157 starts here.
   open pay_proposals2(l_assignment_id);
   <<pay_proposals>>
    loop
    fetch pay_proposals2 into l_pk_id, l_ovn;
    exit when pay_proposals2%NOTFOUND;
      hr_maintain_proposal_api.delete_salary_proposal(p_pay_proposal_id  => l_pk_id
                        ,p_business_group_id  => l_business_group_id
                        ,p_object_version_number => l_ovn
                        ,p_validate   => FALSE
                        ,p_salary_warning  =>  l_sal_warning);
    end loop pay_proposals;
    close pay_proposals2;
    open csr_get_salary(l_assignment_id);
    fetch csr_get_salary into l_element_entry_id;
    if csr_get_salary%found then
      close csr_get_salary;

      open csr_chk_rec_exists(l_assignment_id);
      fetch csr_chk_rec_exists into l_element_entry_id1;

   if csr_chk_rec_exists%found then
      close csr_chk_rec_exists;
      --
      hr_entry_api.delete_element_entry
        ('DELETE'
        ,p_start_date - 1
        ,l_element_entry_id);
      else
      close csr_chk_rec_exists;
       hr_entry_api.delete_element_entry
        ('ZAP'
        ,p_start_date
        ,l_element_entry_id);
 end if;
    else
       close csr_get_salary;
    end if;
  -- fix for bug 5005157 ends here.


  -- End of fix 3564129
  delete from per_all_assignments_f paf
  where paf.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',10);
    hr_utility.raise_error;
  end if;
  end loop assignment;
  close assignments;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',250);
  open applications;
<<application>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',260);
  fetch applications into p_rowid;
  exit when applications%NOTFOUND;
  update per_applications pap
  set pap.date_end = NULL
  where pap.rowid = p_rowid;
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',11);
    hr_utility.raise_error;
  end if;
  end loop application;
  close applications;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',270);
open ass1;
<<entries>>
 loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',280);
  fetch ass1 into p_assignment_id,p_start_date,p_rowid;
  exit when ass1%NOTFOUND;
  update per_all_assignments_f paf
  set   paf.effective_end_date   = p_end_of_time
  where paf.rowid = p_rowid;
--
  hrentmnt.maintain_entries_asg(p_assignment_id
            ,p_business_group_id
            ,'CNCL_HIRE'
            ,NULL
            ,NULL
            ,NULL
            ,'ZAP'
            ,p_start_date
            ,p_end_of_time);
--
  end loop entries;
  close ass1;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',290);
  l_back2back := per_periods_of_service_pkg_v2.IsBackToBackContract
     ( p_person_id => p_person_id, p_hire_date_of_current_pds => p_date_start);

  open period;
  <<service>>
   loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',300);
   fetch period  into p_rowid;
   exit when period%notfound;
   delete from per_periods_of_service
   where rowid = p_rowid;
   if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',11);
    hr_utility.raise_error;
   end if;
   end loop service;
   if period%rowcount <1 then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
     hr_utility.set_message_token('STEP',12);
     hr_utility.raise_error;
  end if;
 close period;
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',310);
  -- 3194314
    open csr_is_cwk(p_date_start);
    fetch csr_is_cwk into l_pp_id, l_cwk_date_start;
    close csr_is_cwk;
    hr_utility.trace('CWK pp_id = '||l_pp_id);
  --
   -- 3848352 start
    l_apl_flag := NULL;
    open csr_apl_ptu_id;
    fetch csr_apl_ptu_id into l_dummy;
    if csr_apl_ptu_id%found then
       l_apl_flag  := 'Y';
    end if;
    close csr_apl_ptu_id;
    hr_utility.trace('l_apl_flag = '||l_apl_flag);
   -- 3848352 end

  -- <<
  open person;
<<per>>
  loop
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',320);
  fetch person into p_rowid, l_person_end_date;
  exit when person%notfound;
  if l_back2back
  then
     if l_person_end_date = hr_general.end_of_time then --#1998140

        select person_type_id into l_person_type_id
        from per_person_types
        where business_group_id = p_business_group_id
        and system_person_type = 'EX_EMP'
        and default_flag = 'Y';

        hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',322);

        update per_people_f
        set person_type_id = l_person_type_id,
            effective_start_date = p_date_start,  -- in case DT updates exist
            current_employee_flag = null,
            current_emp_or_apl_flag = l_apl_flag, -- 3848352 --null,
            current_applicant_flag = l_apl_flag -- 3848352 --null
        where rowid = p_rowid;
     --
     else -- #1998140
     --
        hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',323);

        delete from per_people_f
        where rowid = p_rowid;
     --
     end if;

  elsif  l_pp_id is not null then -- 3194314

    if l_person_end_date = hr_general.end_of_time then --#1998140

    -- 3848352 start
     if hr_person_type_usage_info.is_person_of_type
         ( p_effective_date => p_date_start
          ,p_person_id => p_person_id
          ,p_system_person_type => 'EX_APL'
          )
     and l_apl_flag is not null then
       select person_type_id into l_person_type_id
       from per_person_types
       where business_group_id = p_business_group_id
       and system_person_type = 'APL'
       and default_flag = 'Y';
     ELSE
       -- start changes for bug 8405711
       get_prev_person_type(p_business_group_id,
         p_person_id => p_person_id,
         p_effective_date => p_date_start,
         p_current_person_type => 'EMP',
         p_system_person_type => l_system_person_type);

       l_person_type_id :=  hr_person_type_usage_info.get_default_person_type_id
        (p_business_group_id, l_system_person_type);
       /*select person_type_id into l_person_type_id
       from per_person_types
       where business_group_id = p_business_group_id
       and system_person_type = 'OTHER'  -- EX_CWK but this is not maintained
       and default_flag = 'Y'; */
       -- end changes for bug 8405711
     end if;
      -- 3848352 end

       hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',324);

    --
    -- 3847884 Changed from p_start_date to p_date_start
    --
       update per_people_f
       set person_type_id = l_person_type_id,
        current_employee_flag = null,
        current_emp_or_apl_flag = l_apl_flag, -- 3848352 -- null,
        current_applicant_flag = l_apl_flag, -- 3848352 --null,
        per_information7 = null,
        employee_number = null,
        start_date = l_cwk_date_start,
        effective_start_date = p_date_start, -- p_start_date,   -- in case DT updates exist
        original_date_of_hire = null
       where rowid = p_rowid;
     --
     else -- #1998140
     --
        hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',325);

        delete from per_people_f
        where rowid = p_rowid;
     --
     end if;

  -- <<
  else
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',330);
     delete from per_people_f
     where rowid = p_rowid;
  end if;
  --
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',340);
--  if sql%ROWCOUNT <1 then
  if sql%notfound then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',13);
    hr_utility.raise_error;
  end if;
  end loop per;
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',350);
  if person%rowcount <1 then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
    hr_utility.set_message_token('STEP',14);
    hr_utility.raise_error;
  end if;
  close person;
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',360);
  -- 3194314
  -- this should not get exected when b2b cwk/emp
  if l_pp_id is null then
       open new_person;
    <<new_per>>
      loop
          hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',370);
      fetch new_person into p_rowid;
      exit when new_person%notfound;
      if NOT l_back2back
      then
          hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',380);
         update per_people_f
         set effective_end_date = p_end_of_time
         where rowid = p_rowid;
      end if;
      --
          hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',390);
      if sql%ROWCOUNT <1 then
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
        hr_utility.set_message_token('STEP',15);
        hr_utility.raise_error;
      end if;
      end loop new_per;
          hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',400);
      if new_person%rowcount <1 then
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','do_cancel_hire');
        hr_utility.set_message_token('STEP',16);
        hr_utility.raise_error;
      end if;
          hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',410);
      close new_person;

  end if; -- 3194314 is b2b?
--
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',420);
  -- 115.1 Change by M Bocutt
  --
  -- If we have an EMP PTU record that started on the hire date
  -- then delete it.
  --
-- PTU : Code added

      hr_utility.set_location('cancel_hire_or_apl.p_date_start = '||to_char(p_date_start,'DD/MM/YYYY'),420);
      hr_utility.set_location('cancel_hire_or_apl.p_person_id = '||to_char(p_person_id),420);

  if  l_pp_id is not null then -- 3194314

     hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',424);

     open csr_emp_ptu_id;
     fetch csr_emp_ptu_id into l_emp_ptu_id;
     if csr_emp_ptu_id%FOUND and l_emp_ptu_id is not null then

        hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',425);
--fix for bug 6671352 starts here.
        /*hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_date_start
         ,p_person_id            => p_person_id
         ,p_person_type_id       => l_emp_ptu_id
         ,p_datetrack_delete_mode => 'ZAP'
         );*/
 hr_per_type_usage_internal.cancel_person_type_usage
	(p_effective_date 	=> p_date_start
	,p_person_id 		=> p_person_id
	,p_system_person_type 	=> 'EMP');

     end if;
	--fix for bug 6671352 ends here.
     close csr_emp_ptu_id;
     --
     --3848352 start
     --
     open csr_apl_ptu_id;
     fetch csr_apl_ptu_id into l_apl_ptu_id;
     if csr_apl_ptu_id%FOUND and l_apl_ptu_id is not null then

        hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',425);
        hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_date_start -1
         ,p_person_id            => p_person_id
         ,p_person_type_id       => l_apl_ptu_id
         ,p_datetrack_delete_mode => 'DELETE_NEXT_CHANGE'
         );
     end if;
     close csr_apl_ptu_id;
     --
     -- 3848352 end
     --
  else

     hr_per_type_usage_internal.cancel_person_type_usage
	(p_effective_date 	=> p_date_start
	,p_person_id 		=> p_person_id
	,p_system_person_type 	=> 'EMP');

       -- Added for the bug 6899072 starts here
       -- This finds out any system person type of OTHER records
       -- which is end dated while creating a employment
       -- and updates the end date to end of time while
       -- cancelling the hire

	upd_person_type_usage_end_date
	(p_effective_date 	=> p_date_start-1
	,p_person_id 		=> p_person_id
	,p_system_person_type 	=> 'OTHER');

	-- Change for the bug 6899072 ends here

      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',430);
      --
      --5450847 start : Need to maintain APL record if any. Delete the EX_APL
      --                record and update EED of APL record to EOTime.
      --
      open csr_apl_ptu_id;
      fetch csr_apl_ptu_id into l_apl_ptu_id;
      if csr_apl_ptu_id%FOUND and l_apl_ptu_id is not null then

         hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',432);
         hr_per_type_usage_internal.maintain_person_type_usage
          (p_effective_date       => p_date_start -1
          ,p_person_id            => p_person_id
          ,p_person_type_id       => l_apl_ptu_id
          ,p_datetrack_delete_mode => 'DELETE_NEXT_CHANGE'
          );
      end if;
      close csr_apl_ptu_id;
      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',433);
      --
      -- 5450847 end
      --

  end if;

  if l_back2back then

      hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire',435);

  hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_date_start
         ,p_person_id            => p_person_id
         ,p_person_type_id       => l_person_type_id
         );

  end if;
-- PTU : End of changes

--  hr_per_type_usage_internal.maintain_ptu(
--                 p_validate => false,
--                 p_person_id => p_person_id,
--                 p_action => 'CANCEL HIRE',
--                 p_period_of_service_id => p_period_of_service_id,
--                 p_actual_termination_date => NULL,
--                 p_business_group_id => p_business_group_id,
--                 p_date_start => p_date_start,
--                 p_leaving_reason => null,
--                 p_old_date_start => null,
--                 p_old_leaving_reason => null);
--
per_cancel_hire_or_apl_pkg.update_person_list(p_person_id => p_person_id);
--
for asg_rec in c_assignments loop
  --
  hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire', 501);
  --
  hr_security_internal.add_to_person_list(
                       p_effective_date => asg_rec.effective_start_date
                      ,p_assignment_id  => asg_rec.assignment_id);
  --
  hr_utility.set_location('cancel_hire_or_apl.do_cancel_hire', 502);
  --
end loop;
--
end do_cancel_hire;
--
procedure do_cancel_appl(p_person_id NUMBER
                        ,p_date_received DATE
                        ,p_end_of_time DATE
                        ,p_business_group_id NUMBER
                        ,p_application_id NUMBER) is
--
-- applicant assignment cursor
-- determine the assignment_id for all the assignments of the application
--
cursor appl_asg is
select distinct assignment_id
from per_assignments_f
where application_id = p_application_id;
--
-- events cursor -- This is only really finding applicant interviews
--                  since in all other cases pe.assignment_id is null
--
cursor events_or_interviews(p_assignment_id NUMBER) is
select pe.event_id
from   per_events pe
where  pe.date_start        >= p_date_received
and    p_assignment_id     = pe.assignment_id;
--
-- bookings cursor
--
cursor bookings2 is
select pb.booking_id
from   per_events pe,
       per_bookings pb
where  pb.event_id           = pe.event_id
and    pe.date_start        >= p_date_received
and    pb.person_id          = p_person_id
and    pe.emp_or_apl         = 'A';
--
-- Budget values cursor
--
cursor budget_values2(p_assignment_id NUMBER) is
select pab.rowid
from per_assignment_budget_values_f pab
where  pab.assignment_id        = p_assignment_id;
--
-- letters cursor
--
cursor letters2(p_assignment_id NUMBER) is
select p.letter_request_line_id
from per_letter_request_lines p
where  p.assignment_id = p_assignment_id;
--
-- Comments cursor
--
cursor comments2(p_assignment_id NUMBER) is
select h.comment_id
from hr_comments h
,    per_assignments_f paf
where  h.comment_id = paf.comment_id
and paf.assignment_id = p_assignment_id;
--
-- assignments cursor
--
cursor assignments is
select paf.rowid
from per_assignments_f paf
where paf.person_id            = p_person_id
and   paf.application_id       = p_application_id;
--
-- applications cursor
--
cursor applications is
select rowid
from per_applications pap
where pap.date_received = p_date_received
and   pap.person_id = p_person_id;
--
-- person cursor
--
cursor people is
select rowid
from per_people_f
where person_id = p_person_id
and effective_start_date >= p_date_received;
--
-- new person cursor
--
cursor new_people is
select rowid
from per_people_f
where person_id = p_person_id
and effective_end_date = p_date_received - 1;
--
--
-- NEW CURSORS FOR CANCEL_APPL  BEGIN   adhunter feb-2001
--
-- PTU changes: this cursor not required.
-- person type usages cursor
--
--cursor person_type_usages2 is
--select ptu.person_type_usage_id, ptu.object_version_number
--from per_person_type_usages_f ptu, per_person_types ppt
--where person_id = p_person_id
--and ptu.person_type_id = ppt.person_type_id
--and ppt.system_person_type = 'APL'
--and ptu.effective_start_date = p_date_received;
--
-- secondary assignment statuses cursor
--
cursor sec_asg_statuses2(p_assignment_id NUMBER) is
select sas.rowid
from per_secondary_ass_statuses sas
where sas.assignment_id = p_assignment_id;
--
-- assignment extra info cursor
--
cursor asg_extra_info2(p_assignment_id NUMBER) is
select paei.assignment_extra_info_id, paei.object_version_number
from per_assignment_extra_info paei
where p_assignment_id = paei.assignment_id;
--
-- pay proposals cursor
--
cursor pay_proposals2(p_assignment_id NUMBER) is
select ppp.pay_proposal_id, ppp.object_version_number
from per_pay_proposals ppp
where p_assignment_id = ppp.assignment_id;
--
-- work incidents cursor
--
cursor work_incidents2(p_assignment_id NUMBER) is
select pwi.incident_id, pwi.object_version_number
from per_work_incidents pwi
where p_assignment_id = pwi.assignment_id;
--
-- asg proposal answers cursor
--
cursor asg_prop_answer2(p_assignment_id NUMBER) is
select papa.rowid
from per_assign_proposal_answers papa
where p_assignment_id = papa.assignment_id;
--
-- disabilities cursor
--
-- FIX 1977389 - commented out
-- cursor disabilities2(p_assignment_id NUMBER) is
-- select pdf.disability_id, pdf.object_version_number
-- from per_disabilities_f pdf
-- where p_assignment_id = pdf.assignment_id
-- order by pdf.effective_start_date desc;
-- END FIX.
--
-- person comments when apl cursor
--
cursor person_apl_comments2 is
select distinct h.comment_id --fix for bug 7157204.
from hr_comments h, per_people_f ppf
where ppf.business_group_id = p_business_group_id
and ppf.person_id = p_person_id
and ppf.effective_start_date >= p_date_received
and ppf.comment_id = h.comment_id;
--
-- Assignments from previous
--
-- NEW CURSORS FOR CANCEL_APPL
-- Bug 8405711: Cursor return the effective_start_date if the action performs
-- on the day where a record is already present.
cursor chk_action_perform_date is
select effective_start_date
from per_people_f
where person_id = p_person_id
and effective_start_date = hr_general.effective_date;

-- Bug 8405711: Cursor get the future records along with end-dated record
-- on the previous day, in the case if the action performs on future date.
cursor people_b2b_with_prev_record is
select rowid,effective_end_date,effective_start_date,current_applicant_flag
from per_people_f
where person_id = p_person_id
and (effective_start_date > p_date_received
or effective_end_date = hr_general.effective_date - 1);

--
-- NEW CURSORS FOR CANCEL_APPL END
--
-- Bug 4095559: Cursor return whether B2B of EX_EMP/EX_CWK.APL
  cursor csr_b2b_apl is
  select count(ptu.person_type_id)
   from per_person_type_usages_f ptu
       ,per_person_types ppt
  where ptu.person_id = p_person_id
    and ptu.effective_start_date = p_date_received
    and ptu.person_type_id = ppt.person_type_id
    and ppt.system_person_type <> 'APL';

-- Bug 4095559: Cursor to update per_people_f B2B of EX_EMP/EX_CWK.APL
--    new_people_b2b for person records with ESD as date_received
cursor new_people_b2b is
select rowid,effective_end_date,effective_start_date,current_applicant_flag
from per_people_f
where person_id = p_person_id
and effective_start_date = p_date_received;

-- Bug 4095559: Cursor to update per_people_f B2B of EX_EMP/EX_CWK.APL
--    people_b2b for person records with ESD future to date_received
cursor people_b2b is
select rowid,effective_end_date,effective_start_date,current_applicant_flag
from per_people_f
where person_id = p_person_id
and effective_start_date > p_date_received;

-- Bug 4095559: Cursor to get the latest person_type_id B2B of
-- EX_EMP/EX_CWK.APL
cursor latest_ptid is
select person_type_id
from per_person_type_usages_f
where person_id = p_person_id
order by EFFECTIVE_END_DATE desc, EFFECTIVE_START_DATE desc;
--
-- Cursor to re-evaluate the security.
cursor csr_asg_sec is
select paf.assignment_id, paf.effective_start_date
  from per_all_assignments_f paf
 where paf.person_id = p_person_id
   and paf.assignment_type <> 'B'; -- Added For Bug # 6630290
--

-- start changes for bug 8405711
-- cursor to evaluate whether the person became B2B Apl on the hire day
cursor chk_prv_APL_exists is
  select person_type_id
  from per_person_type_usages_f ptu
  where ptu.person_id = p_person_id
  and ptu.effective_end_date = p_date_received - 1
  and exists (
          select ppt.person_type_id
          from per_person_types ppt
          where ppt.system_person_type = 'APL'
          and ppt.business_group_id = p_business_group_id
          and ppt.person_type_id = ptu.person_type_id)
  and exists (select ppt1.person_type_id
              from per_person_types ppt1, per_person_type_usages_f ptu1
              where ptu1.person_type_id = ppt1.person_type_id
               and ppt1.business_group_id = p_business_group_id
               and ptu1.person_id = p_person_id
               and ppt1.system_person_type in ('EMP','CWK')
               and ptu1.effective_start_date = p_date_received);

l_prv_person_type_id number;
-- end changes for bug 8405711

l_rowid VARCHAR2(18);
l_pk_id NUMBER;
l_ovn   NUMBER;
l_start_date DATE;
l_end_date DATE;
l_business_group_id NUMBER;
l_sal_warning BOOLEAN;
l_assignment_id NUMBER;
l_ptu_count number;  -- Bug 4095559
l_b2b_apl boolean default false;  -- Bug 4095559
l_person_type_id  number; -- Bug 4095559
l_effective_end_date date; -- Bug 4095559
l_effective_start_date date; -- Bug 4095559
l_current_applicant_flag VARCHAR2(30); -- Bug 4095559
l_fut_per_chg boolean default false;  -- Bug 4095559
--
l_system_person_type per_person_types.system_person_type%type; --added for bug 8405711
l_action_perform_date date; --Bug 8405711

begin
--
  l_business_group_id := p_business_group_id;
  --
  open appl_asg;
<<apl_asg>>
  loop
  fetch appl_asg into l_assignment_id;
  exit when appl_asg%NOTFOUND;
--
--
--
    open events_or_interviews(l_assignment_id);
  <<event>>
    loop
    fetch events_or_interviews into l_pk_id;
    exit when events_or_interviews%NOTFOUND;
      delete from per_events pe
      where  pe.event_id = l_pk_id;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',2);
      hr_utility.raise_error;
    end if;
    end loop event;
    close events_or_interviews;
--
--
    open budget_values2(l_assignment_id);
  <<budget_val>>
   loop
    fetch budget_values2 into l_rowid;
    exit when budget_values2%NOTFOUND;
    delete from per_assignment_budget_values_f pab
    where  pab.rowid = l_rowid;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',3);
      hr_utility.raise_error;
    end if;
    end loop budget_val;
    close budget_values2;
--
--
    open comments2(l_assignment_id);
  <<comments>>
    loop
    fetch comments2 into l_pk_id;
    exit when comments2%NOTFOUND;
    delete from hr_comments h
    where  h.comment_id = l_pk_id;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',4);
      hr_utility.raise_error;
    end if;
    end loop comments;
    close comments2;
--
--
    open letters2(l_assignment_id);
  <<letters>>
    loop
    fetch letters2 into l_pk_id;
    exit when letters2%NOTFOUND;
      delete from per_letter_request_lines plrl
      where plrl.letter_request_line_id = l_pk_id;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',5);
      hr_utility.raise_error;
    end if;
    end loop letters;
    close letters2;
--
--
    open sec_asg_statuses2(l_assignment_id);
  <<sec_asg_statuses>>
    loop
    fetch sec_asg_statuses2 into l_rowid;
    exit when sec_asg_statuses2%NOTFOUND;
      per_secondary_ass_statuses_pkg.delete_row(l_rowid);
    end loop sec_asg_statuses;
    close sec_asg_statuses2;
--
--
    open asg_extra_info2(l_assignment_id);
  <<asg_extra_info>>
    loop
    fetch asg_extra_info2 into l_pk_id, l_ovn;
    exit when asg_extra_info2%NOTFOUND;
      hr_assignment_extra_info_api.delete_assignment_extra_info(
                                  p_validate => FALSE
                                 ,p_assignment_extra_info_id => l_pk_id
                                 ,p_object_version_number => l_ovn);
    end loop asg_extra_info;
    close asg_extra_info2;
--
--
    open pay_proposals2(l_assignment_id);
  <<pay_proposals>>
    loop
    fetch pay_proposals2 into l_pk_id, l_ovn;
    exit when pay_proposals2%NOTFOUND;
      hr_maintain_proposal_api.delete_salary_proposal(p_pay_proposal_id  => l_pk_id
                        ,p_business_group_id  => l_business_group_id
                        ,p_object_version_number => l_ovn
                        ,p_validate   => FALSE
                        ,p_salary_warning  =>  l_sal_warning);
    end loop pay_proposals;
    close pay_proposals2;
--
--
    open work_incidents2(l_assignment_id);
  <<work_incidents>>
    loop
    fetch work_incidents2 into l_pk_id, l_ovn;
    exit when work_incidents2%NOTFOUND;
      per_work_incident_api.delete_work_incident(
                                p_validate  => FALSE
                               ,p_incident_id => l_pk_id
                               ,p_object_version_number => l_ovn);
    end loop work_incidents;
    close work_incidents2;
--
--
    open asg_prop_answer2(l_assignment_id);
  <<asg_prop_answer>>
    loop
    fetch asg_prop_answer2 into l_rowid;
    exit when asg_prop_answer2%NOTFOUND;
      delete from per_assign_proposal_answers papa
      where papa.rowid = l_rowid;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',6);
      hr_utility.raise_error;
    end if;
    end loop asg_prop_answer;
    close asg_prop_answer2;
--
--
--  FIX 1977389 - commented out.
--    open disabilities2(l_assignment_id);
--  <<disabilities>>
--    loop
--    fetch disabilities2 into l_pk_id, l_ovn;
--    exit when disabilities2%NOTFOUND;
--      per_disability_api.delete_disability(
--                               p_validate  => FALSE
--                              ,p_effective_date => p_date_received
--                              ,p_datetrack_mode => 'ZAP'
--                              ,p_disability_id  => l_pk_id
--                              ,p_object_version_number => l_ovn
--                              ,p_effective_start_date => l_start_date
--                              ,p_effective_end_date   => l_end_date );
--    end loop disabilities;
--    close disabilities2;
--  END FIX.
--
end loop apl_asg;
close appl_asg;
--
-- now deletes which don't need to be in appl_asg loop since they don't
-- drive off assignment_id
--
    open bookings2;
  <<bookings>>
    loop
    fetch bookings2 into l_pk_id;
    exit when bookings2%NOTFOUND;
      delete from per_bookings pb
      where  pb.booking_id = l_pk_id;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',7);
      hr_utility.raise_error;
    end if;
    end loop bookings;
    close bookings2;
--
--
    open person_apl_comments2;
  <<person_apl_comments>>
    loop
    fetch person_apl_comments2 into l_pk_id;
    exit when person_apl_comments2%NOTFOUND;
      delete from hr_comments h
      where h.comment_id = l_pk_id;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',8);
      hr_utility.raise_error;
    end if;
    end loop person_apl_comments;
    close person_apl_comments2;
--
-- assignment, application, people records should be deleted last in this
-- order to avoid integrity constraint errors.
--
    open assignments;
  <<assign>>
    loop
    fetch assignments into l_rowid;
    exit when assignments%NOTFOUND;
    delete from per_assignments_f paf
    where paf.rowid = l_rowid;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',9);
      hr_utility.raise_error;
    end if;
    end loop assign;
    close assignments;
--
--
    open applications;
  <<application>>
    loop
    fetch applications into l_rowid;
    exit when applications%NOTFOUND;
    delete from  per_applications pap
    where pap.rowid = l_rowid;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',10);
      hr_utility.raise_error;
    end if;
    end loop application;
    close applications;
--
-- Bug 4095559 : Getting the B2B flag
--
  open csr_b2b_apl;
  fetch csr_b2b_apl into l_ptu_count;
  close csr_b2b_apl;

  IF l_ptu_count > 0
  THEN
    l_b2b_apl:=TRUE;
  ELSE
    l_b2b_apl:=FALSE;
  END IF;
-- Bug 4095559 : Execute the existing logic, if it is not B2B
if NOT l_b2b_apl then
    open people;
  <<per>>
    loop
    fetch people into l_rowid;
    exit when people%notfound;
    delete from per_people_f
    where rowid = l_rowid;
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',11);
      hr_utility.raise_error;
    end if;
    end loop per;
    if people%rowcount <1 then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',12);
      hr_utility.raise_error;
    end if;
    close people;
--
--
     open new_people;
  <<new_per>>
    loop
    fetch new_people into l_rowid;
    exit when new_people%notfound;
    update per_people_f
    set effective_end_date = p_end_of_time
    where rowid = l_rowid;
    --
    if sql%ROWCOUNT <1 then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',13);
      hr_utility.raise_error;
    end if;
    end loop new_per;
    if new_people%rowcount <1 then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',14);
      hr_utility.raise_error;
    end if;
    close new_people;
-- Bug 4095559 Starts
-- Desc: : Execute the new logic, if it is B2B
  else
    -- start changes for bug 8405711
    get_prev_person_type(p_business_group_id,
      p_person_id => p_person_id,
      p_effective_date => p_date_received,
      p_current_person_type => 'APL',
      p_system_person_type => l_system_person_type);

    l_person_type_id :=  hr_person_type_usage_info.get_default_person_type_id
     (p_business_group_id, l_system_person_type);

    open chk_action_perform_date;
    fetch chk_action_perform_date into l_action_perform_date;
    close chk_action_perform_date;

    -- if l_action_perform_date is not null, means the action performs on the future day.
    IF l_action_perform_date IS NOT NULL THEN
	    open people_b2b;
	  <<per_b2b>>
	    loop
	    fetch people_b2b into l_rowid,l_effective_end_date,
			l_effective_start_date,l_current_applicant_flag;
	    exit when people_b2b%notfound;
		 l_fut_per_chg := TRUE;   -- set to TRUE if the future person change exists
	-- Get the latest person Type Id to update the person table.
		 --commented for bug 8405711
		 /*open latest_ptid;
		 fetch latest_ptid into l_person_type_id;
		 close latest_ptid;*/
	-- Upadte the person table with the person type id
		 /*update per_people_f
		 set PERSON_TYPE_ID=l_person_type_id
		 where rowid = l_rowid;*/

	    delete from per_people_f
	    where rowid = l_rowid;

	    if sql%notfound THEN
		 hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
		 hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
		 hr_utility.set_message_token('STEP',15);
		 hr_utility.raise_error;
	    end if;
	    end loop per_b2b;
	/*    if people_b2b%rowcount <1 then
		 hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
		 hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
		 hr_utility.set_message_token('STEP',16);
		 hr_utility.raise_error;
	    end if;*/
	    close people_b2b;
    ELSE
	    open people_b2b_with_prev_record;
        <<per_b2b_with_prev_record>>
	    loop
	    fetch people_b2b_with_prev_record into l_rowid,l_effective_end_date,
			l_effective_start_date,l_current_applicant_flag;
	    exit when people_b2b_with_prev_record%notfound;

         delete from per_people_f
	    where rowid = l_rowid;

	    if sql%notfound then
		 hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
		 hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
		 hr_utility.set_message_token('STEP',15);
		 hr_utility.raise_error;
	    end if;
	    end loop per_b2b_with_prev_record;
         CLOSE people_b2b_with_prev_record;
    END IF;
    -- end changes for bug 8405711

    open new_people_b2b;
  <<new_per_b2b>>
    loop
    fetch new_people_b2b into l_rowid,l_effective_end_date,
          l_effective_start_date,l_current_applicant_flag;
    exit when new_people_b2b%notfound;

    --start changes for bug 8405711
    /* if l_effective_end_date = hr_general.effective_date -1 then
      delete from per_people_f
      where rowid = l_rowid;
    elsif */
    IF l_current_applicant_flag = 'Y' then
      update per_people_f
      set applicant_number = null,
          current_applicant_flag=null,
          current_emp_or_apl_flag=DECODE (l_system_person_type,'EMP','Y',null),
          PERSON_TYPE_ID=l_person_type_id,
          effective_end_date=hr_general.end_of_time
      where rowid = l_rowid;
    END IF;
-- Get the latest person Type Id to update the person table.
      /*open latest_ptid;
      fetch latest_ptid into l_person_type_id;
      close latest_ptid;*/
-- Updating the person table, if there is future changes
/*     if l_fut_per_chg then
      update per_people_f
      set applicant_number = null,
          current_applicant_flag=null,
          current_emp_or_apl_flag=DECODE (l_system_person_type,'EMP','Y',null),
          PERSON_TYPE_ID=l_person_type_id
      where rowid = l_rowid;
-- Updating the person table, if there is NO future changes
     else
      update per_people_f
      set applicant_number = null,
          current_applicant_flag=null,
          current_emp_or_apl_flag=DECODE (l_system_person_type,'EMP','Y',null),
          PERSON_TYPE_ID=l_person_type_id,
          effective_end_date=hr_general.end_of_time
      where rowid = l_rowid;
     end if;
    end if;*/
--
    --end changes for bug 8405711
    if sql%notfound then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',17);
      hr_utility.raise_error;
    end if;
    end loop new_per_b2b;
    if new_people_b2b%rowcount <1 then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',18);
      hr_utility.raise_error;
    end if;
    close new_people_b2b;

  end if;
-- Bug 4095559 Ends
--
--
/* PTU changes: this is no longer necessary since PTU records
   will be maintained differently.

    open person_type_usages2;
  <<person_type_usages>>
    loop
    fetch person_type_usages2 into l_pk_id, l_ovn;
    exit when person_type_usages2%NOTFOUND;
      hr_per_type_usage_internal.delete_person_type_usage
                  (p_validate  => FALSE
                  ,p_person_type_usage_id  => l_pk_id
                  ,p_effective_date  => p_date_received
                  ,p_datetrack_mode  => 'ZAP'
                  ,p_object_version_number  => l_ovn
                  ,p_effective_start_date  => l_start_date
                  ,p_effective_end_date  => l_end_date );
    end loop person_type_usages;
    if person_type_usages2%rowcount <1 then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_appl');
      hr_utility.set_message_token('STEP',15);
      hr_utility.raise_error;
    end if;
   close person_type_usages2;
*/
-- Bug 4095559 Starts
-- Desc: Delete the PTU records directly, if it is B2B
if NOT l_b2b_apl then
   hr_per_type_usage_internal.cancel_person_type_usage
	 (p_effective_date 	=> p_date_received
 	 ,p_person_id 		=> p_person_id
	 ,p_system_person_type 	=> 'APL');

else
-- Bug 4095559 : Delete the Applicant record from PTU

  -- start changes for bug 8405711
  open chk_prv_APL_exists;
  fetch chk_prv_APL_exists into l_prv_person_type_id;
  if chk_prv_APL_exists%found then
    close chk_prv_APL_exists;

    -- When the person became B2B Applicant on his hired Day then
    -- system will convert the APL record to EX_APL type.
    update per_person_type_usages_f ptu
    set person_type_id = hr_person_type_usage_info.get_default_person_type_id
                         (p_business_group_id, 'EX_APL')
    where ptu.person_id = p_person_id
    and ptu.effective_start_date = p_date_received
    and person_type_id in (
          select ppt.person_type_id
          from per_person_types ppt
          where business_group_id = p_business_group_id
          and ppt.system_person_type = 'APL');
  ELSE
    close chk_prv_APL_exists;
    -- end changes for bug 8405711

    -- updated for bug 8405711, to delete all the APL entries after the Application start date
    delete from per_person_type_usages_f ptu
    where ptu.person_id = p_person_id
    and ptu.effective_start_date >= p_date_received
    and ptu.person_type_id in (
          select ppt.person_type_id
          from per_person_types ppt
          where ppt.system_person_type = 'APL'
	  and business_group_id = p_business_group_id);

    -- start changes for bug 8405711
    update per_person_type_usages_f ptu
    set effective_end_date = to_date('31/12/4712','dd/mm/yyyy')
    where ptu.person_id = p_person_id
    and ptu.person_type_id in (
          select ppt.person_type_id
          from per_person_types ppt
          where ppt.system_person_type = 'EX_APL'
	  and business_group_id = p_business_group_id)
    and ptu.effective_end_date = p_date_received - 1;
    -- end changes for bug 8405711

  end if; --added for bug 8405711

end if;
-- Bug 4095559 Ends
--
per_cancel_hire_or_apl_pkg.update_person_list (p_person_id => p_person_id);
--
for asg_sec_rec in csr_asg_sec loop
  --
  hr_security_internal.add_to_person_list(
                       p_effective_date => asg_sec_rec.effective_start_date,
                       p_assignment_id  => asg_sec_rec.assignment_id);
  --
end loop;
--
end do_cancel_appl;
--
procedure update_person_list (p_person_id NUMBER) is
begin
--
-- Delete all rows from per_person_list
--
  hr_security_internal.clear_from_person_list(p_person_id);
--
end update_person_list;
--
/*===========================================================================*
 |                                                                           |
 |                       PRE_CANCEL_PLACEMENT_CHECKS                         |
 |                                                                           |
*============================================================================*/
--
PROCEDURE pre_cancel_placement_checks
  (p_person_id           IN     NUMBER
  ,p_business_group_id   IN     NUMBER
  ,p_effective_date      IN     DATE
  ,p_date_start          IN     DATE
  ,p_supervisor_warning  IN OUT NOCOPY BOOLEAN
  ,p_recruiter_warning   IN OUT NOCOPY BOOLEAN
  ,p_event_warning       IN OUT NOCOPY BOOLEAN
  ,p_interview_warning   IN OUT NOCOPY BOOLEAN
  ,p_review_warning      IN OUT NOCOPY BOOLEAN
  ,p_vacancy_warning     IN OUT NOCOPY BOOLEAN
  ,p_requisition_warning IN OUT NOCOPY BOOLEAN
  ,p_budget_warning      IN OUT NOCOPY BOOLEAN
  ,p_payment_warning     IN OUT NOCOPY BOOLEAN) IS
  --
  l_proc                 VARCHAR2(72) := g_package||'pre_cancel_placement_checks';
  --
  l_dummy                VARCHAR2(30);
  l_dummy_id             NUMBER;
  l_effective_date       DATE;
  l_effective_start_date DATE;
  l_person_type_usage_id NUMBER;
  --
  -- Multi Assignment Check
  --
  CURSOR csr_multi_asg_check IS
    SELECT assignment_id
    FROM   per_assignments_f paf
    WHERE  (paf.business_group_id = p_business_group_id OR
            NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    paf.person_id = p_person_id;
  --
  -- Check person is a CWK
  --
   CURSOR csr_chk_person_is_cwk IS
    SELECT per.person_id,
           per.effective_start_date
    FROM   per_people_f per
    WHERE  per.person_id             = p_person_id
    AND    per.current_npw_flag      = 'Y'
    AND    per.effective_start_date >= p_date_start;
  --
  -- Supervisor
  --
  CURSOR csr_supervisor IS
    SELECT ROWID
    FROM   per_assignments_f p
    WHERE  (p.business_group_id = p_business_group_id OR
            NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    p.supervisor_id      = p_person_id;
  --
  -- recruiter cursor
  --
  CURSOR csr_recruiter IS
    SELECT ROWID
    FROM   per_assignments_f p
    WHERE  p.recruiter_id       = p_person_id
    AND    (p.business_group_id = p_business_group_id OR
            NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y');
  --
  -- reviews or Events cursor
  --
  CURSOR csr_reviews_or_events(p_type varchar2) IS
    SELECT 'Events exist'
    FROM   per_events pe,
           per_bookings pb
    WHERE  pe.business_group_id = pb.business_group_id
    AND    (pb.business_group_id = p_business_group_id OR
            NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    pe.event_id           = pb.event_id
    AND    pe.event_or_interview = p_type
    AND    pb.person_id          = p_person_id;
  --
  -- Interviews cursor
  --
  CURSOR csr_interviews IS
    SELECT 'Interviews exist'
    FROM   per_events pe
    WHERE  (pe.business_group_id  = p_business_group_id OR
            NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    pe.event_or_interview = 'I'
    AND    pe.internal_contact_person_id = p_person_id;
  --
  -- vacancies cursor
  --
  CURSOR csr_vacancy IS
    SELECT ROWID
    FROM   per_vacancies pv
    WHERE (pv.business_group_id  = p_business_group_id OR
           NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND   pv.recruiter_id        = p_person_id
    AND   pv.date_from          >= l_effective_date;
  --
  -- requisitions cursor
  --
  CURSOR csr_requisition IS
    SELECT ROWID
    FROM   per_requisitions pr
    WHERE (pr.business_group_id = p_business_group_id OR
           NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    pr.person_id         = p_person_id;
  --
  -- budget_values cursor
  --
  CURSOR csr_budget_values IS
    SELECT ROWID
    FROM per_assignment_budget_values_f pab
    WHERE pab.business_group_id = p_business_group_id and
    EXISTS (SELECT 'budget_values exist'
                   FROM   per_all_assignments_f paf
                   WHERE  pab.business_group_id    +0= paf.business_group_id + 0
                   AND    paf.business_group_id    +0= p_business_group_id
                   AND    pab.assignment_id        = paf.assignment_id
                   AND    paf.person_id            = p_person_id
                   AND    paf.period_of_placement_date_start = p_date_start
                   AND    paf.effective_end_date  >= l_effective_date
		   --START for 5987416
                   --AND    pab.effective_end_date  >= l_effective_date
		   )
     AND    pab.effective_end_date  >= l_effective_date;
     --end for 5987416

  --
  -- payment cursor
  --
  CURSOR csr_payment IS
    SELECT ROWID
    FROM pay_personal_payment_methods ppm
    WHERE  ppm.business_group_id                  = p_business_group_id
    AND    EXISTS (SELECT 'exists'
                   FROM per_all_assignments_f paf
                   WHERE paf.business_group_id    +0= p_business_group_id
                   AND   paf.person_id            = p_person_id
                   AND   paf.assignment_id        = ppm.assignment_id
                   AND   paf.period_of_placement_date_start = p_date_start
		   --start bug 5987416
                   --AND   ppm.effective_start_date>= l_effective_date
		   --end bug 5987416
		   )
    AND   ppm.effective_start_date               >= l_effective_date;
  --
  CURSOR csr_get_ptu_id IS
    SELECT ptu.person_type_usage_id
    FROM   per_person_types pt,
           per_person_type_usages_f ptu
    WHERE  pt.business_group_id     = p_business_group_id
    AND    pt.person_type_id        = ptu.person_type_id
    AND    l_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
    AND    ptu.person_id            = p_person_id
    AND    pt.system_person_type = 'CWK';
  --
  -- start changes for bug 8405711
  Cursor csr_application_change_exists is
   select 'exists'
   from per_applications pa
   where pa.business_group_id = business_group_id
    and pa.person_id = p_person_id
    and pa.date_received >= p_date_start
    and nvl(pa.application_id,0) <> nvl(
	(select application_id
	 from per_applications
	 where business_group_id = p_business_group_id
	 and person_id = p_person_id
	 and p_date_start - 1 between date_received and nvl(date_end,to_date('31/12/4712','dd/mm/yyyy'))
	 ),pa.application_id) ;

  -- end changes for bug 8405711
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Retrieve the person type usage ID for the CWK,
  -- for later use in this procedure.
  --
  OPEN  csr_get_ptu_id;
  FETCH csr_get_ptu_id INTO l_person_type_usage_id;

  IF csr_get_ptu_id%NOTFOUND THEN
    --
    CLOSE csr_get_ptu_id;
    --
    hr_utility.set_message(801,'HR_289751_CWK_SYS_PER_TYPE_ERR');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc,15);
  --
  CLOSE csr_get_ptu_id;
  --
  -- start changes for bug 8405711
  -- if whether there exists any future application for this person or not
  --
  open csr_application_change_exists;
  fetch csr_application_change_exists into l_dummy;

  if csr_application_change_exists%FOUND then
    close csr_application_change_exists;
    hr_utility.set_message(800,'PER_449844_APL_ACTIONS_EXISTS');
    hr_utility.set_message_token('PERSON_STATUS','placement');
    hr_utility.set_message_token('PERSON_TYPE','Contingent Worker');
    hr_utility.raise_error;
  else
    close csr_application_change_exists;
  end if;
  -- end changes for bug 8405711

  --
  -- Check that the person in a CWK employee
  -- if they are not then raise an error.
  --
  OPEN  csr_chk_person_is_cwk;
  FETCH csr_chk_person_is_cwk INTO l_dummy_id, l_effective_start_date;
  --
  IF csr_chk_person_is_cwk%NOTFOUND THEN
    --
    CLOSE csr_chk_person_is_cwk;
    --
    hr_utility.set_message(801,'HR_289747_MUST_BE_CWK');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE csr_chk_person_is_cwk;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Check that the CWK Employee has only ONE assignment.
  -- If they do not then raise an error asking the user to delete
  -- the person.
  --
  OPEN  csr_multi_asg_check;
  FETCH csr_multi_asg_check INTO l_dummy_id;
  --
  IF csr_multi_asg_check%ROWCOUNT > 1 THEN
    --
    CLOSE csr_multi_asg_check;
    --
    hr_utility.set_message(801,'HR_289748_MULTIPLE_CWK_ASG');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE csr_multi_asg_check;
  --
  hr_utility.set_location(l_proc,30);
  --
  -- Check that the CWK has no future person type changes.
  --
  IF hr_person_type_usage_info.FutSysPerTypeChgExists  -- 3194314: adding person id
       (p_person_type_usage_id => l_person_type_usage_id
       ,p_effective_date       => p_date_start
       ,p_person_id            => p_person_id ) THEN
-- #3684683 modified the application id to 800
    hr_utility.set_message(800,'HR_289749_CWK_FUTURE_PT_CHGE');
    hr_utility.raise_error;

  END IF;
  --
  hr_utility.set_location(l_proc,40);
  --
  -- Check that the CWK has at least one previous person type.
  --
  IF NOT hr_person.chk_prev_person_type
    (p_system_person_type   => 'CWK'
    ,p_person_id            => p_person_id
    ,p_business_group_id    => p_business_group_id
    ,p_effective_start_date => l_effective_start_date) THEN
    --
    hr_utility.set_message(800,'HR_289750_NO_PREVIOUS_CWK');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc,50);
  --
  -- Check to see if the CWK is a supervisor for another worker.
  -- If they are set the supervisor_warning out parameter
  -- to TRUE.
  --
  OPEN csr_supervisor;
  --
  FETCH csr_supervisor INTO l_dummy;
  --
  IF csr_supervisor%FOUND THEN
    --
    p_supervisor_warning := TRUE;
    --
  ELSE
    --
    p_supervisor_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_supervisor;
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Check to see if the CWK is a recruiter for another worker.
  -- If they are set the recruiter_warning out parameter
  -- to TRUE.
  --
  OPEN  csr_recruiter;
  FETCH csr_recruiter INTO l_dummy;
  --
  IF csr_recruiter%FOUND THEN
    --
    p_recruiter_warning := TRUE;
    --
  ELSE
    --
    p_recruiter_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_recruiter;
  --
  hr_utility.set_location(l_proc,70);
  --
  -- Check to see if the CWK has any events.
  -- If they do set the event_warning out parameter
  -- to TRUE.
  --
  OPEN csr_reviews_or_events(p_type =>'E');
  FETCH csr_reviews_or_events INTO l_dummy;
  --
  IF csr_reviews_or_events%FOUND THEN
    --
    p_event_warning := TRUE;
    --
  ELSE
    --
    p_event_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_reviews_or_events;
  --
  hr_utility.set_location(l_proc,80);
  --
  -- Check to see if the CWK has any interviews.
  -- If they do set the interview_warning out parameter
  -- to TRUE.
  --
  OPEN  csr_interviews;
  FETCH csr_interviews INTO l_dummy;
  --
  IF csr_interviews%FOUND THEN
    --
    p_interview_warning := TRUE;
    --
  ELSE
    --
    p_interview_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_interviews;
  --
  hr_utility.set_location(l_proc,90);
  --
  OPEN  csr_reviews_or_events(p_type =>'I');
  FETCH csr_reviews_or_events into l_dummy;
  --
  IF csr_reviews_or_events%FOUND THEN
    --
    p_review_warning := TRUE;
    --
  ELSE
    --
    p_review_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_reviews_or_events;
  --
  hr_utility.set_location(l_proc,100);
  --
  -- Check to see if the CWK is the recruiter for any vacancies.
  -- If they do set the vacancy_warning out parameter
  -- to TRUE.
  --
  OPEN csr_vacancy;
  FETCH csr_vacancy INTO l_dummy;
  --
  IF csr_vacancy%FOUND THEN
    --
    p_vacancy_warning := TRUE;
    --
  ELSE
    --
    p_vacancy_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_vacancy;
  --
  hr_utility.set_location(l_proc,110);
  --
  -- Check to see if the CWK has any requisitions.
  -- If they do set the requisition_warning out parameter
  -- to TRUE.
  --
  OPEN  csr_requisition;
  FETCH csr_requisition INTO l_dummy;
  --
  IF csr_requisition%FOUND THEN
    --
    p_requisition_warning := TRUE;
    --
  ELSE
    --
    p_requisition_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_requisition;
  --
  hr_utility.set_location(l_proc,120);
  --
  -- Check to see if the CWK has any budget values.
  -- If they do set the budget_warning out parameter
  -- to TRUE.
  --
  OPEN csr_budget_values;
  FETCH csr_budget_values into l_dummy;
  --
  IF csr_budget_values%FOUND THEN
    --
    p_budget_warning := TRUE;
    --
  ELSE
    --
    p_budget_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_budget_values;
  --
  hr_utility.set_location(l_proc,130);
  --
  OPEN csr_payment;
  FETCH csr_payment INTO l_dummy;
  --
  -- Check to see if the CWK has any personal payment
  -- methods values.If they do set the budget_warning
  -- out parameter to TRUE.
  --
  IF csr_payment%FOUND THEN
    --
    p_payment_warning := TRUE;
    --
  ELSE
    --
    p_payment_warning := FALSE;
    --
  END IF;
  --
  CLOSE csr_payment;
  --
  hr_utility.set_location(l_proc,130);
  --
  EXCEPTION
    --
    WHEN hr_utility.hr_error THEN
      raise;
    --
    WHEN OTHERS THEN
      --
     hr_utility.oracle_error(sqlcode);
     hr_utility.raise_error;
  --
END pre_cancel_placement_checks;
--
/*===========================================================================*
 |                                                                           |
 |                          DO_CANCEL_PLACEMENT                              |
 |                                                                           |
*============================================================================*/
--
PROCEDURE do_cancel_placement
  (p_person_id            IN per_people_f.person_id%TYPE
  ,p_business_group_id    IN per_people_f.business_group_id%TYPE
  ,p_effective_date       IN DATE
  ,p_date_start           IN DATE) AS
  --
  -- Declare local variables
  --
  l_proc             VARCHAR2(72) := g_package||'do_cancel_placement';
  --
  l_assignment_id    NUMBER;
  l_end_of_time      DATE := hr_general.end_of_time;
  l_effective_date   DATE;
  l_rowid            ROWID;
  l_dummy_id         NUMBER;
  l_person_type_id   NUMBER;
  l_date_start       DATE;
  l_person_end_date  DATE;
  l_pop_back_to_back BOOLEAN;
  l_pos_back_to_back BOOLEAN;
  l_new_person_found BOOLEAN;
  l_person_rec_found      BOOLEAN;
  l_effective_start_date  DATE := NULL;
  l_effective_end_date    DATE := NULL;
  l_person_type_usage_id  per_person_type_usages_f.person_type_usage_id%TYPE;
  l_object_version_number per_person_type_usages_f.object_version_number%TYPE;
  c_effective_start_date date; --Added for the bug 6460093
  --
  -- events cursor
  --
  CURSOR csr_events IS
    SELECT ROWID
    FROM   per_bookings pb
    WHERE (pb.business_group_id = p_business_group_id OR
           NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    pb.person_id = p_person_id
    AND    EXISTS (SELECT 'row exists'
                   FROM   per_events pe
                   WHERE  pe.business_group_id + 0 = p_business_group_id
                   AND    pe.event_id = pb.event_id
                   AND    pe.event_or_interview in ('I','E')
                   AND    pe.date_start >= l_date_start);
  --
  -- requisitions cursor
  --
  CURSOR csr_requisitions IS
    SELECT ROWID
    FROM per_requisitions pr
    WHERE (pr.business_group_id = p_business_group_id OR
           NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND   pr.person_id         = p_person_id;
  --
  -- budget_values cursor
  --
  CURSOR csr_budget_values IS
    SELECT ROWID
    FROM per_assignment_budget_values_f pab
    WHERE pab.business_group_id = p_business_group_id and
    EXISTS (SELECT 'budget_values exist'
                   FROM   per_all_assignments_f paf
                   WHERE  pab.business_group_id    +0= paf.business_group_id + 0
                   AND    paf.business_group_id    +0= p_business_group_id
                   AND    pab.assignment_id        = paf.assignment_id
                   AND    paf.person_id            = p_person_id
                   AND    paf.period_of_placement_date_start = p_date_start
                   AND    paf.effective_end_date  >= l_effective_date
		   --start for 5987416
                   --AND    pab.effective_end_date  >= l_effective_date
		   )
    AND    pab.effective_end_date  >= l_effective_date;
    --end bug 5987416
  --
  -- payment cursor
  --
  CURSOR csr_payment IS
    SELECT ROWID
    FROM pay_personal_payment_methods ppm
    WHERE  ppm.business_group_id                  = p_business_group_id
    AND    EXISTS (SELECT 'exists'
                   FROM per_all_assignments_f paf
                   WHERE paf.business_group_id    +0= p_business_group_id
                   AND   paf.person_id            = p_person_id
                   AND   paf.assignment_id        = ppm.assignment_id
                   AND   paf.period_of_placement_date_start = p_date_start
		   --start bug 5987416
                   --AND   ppm.effective_start_date>= l_effective_date
		   --end bug 5987416
		   )
    AND   ppm.effective_start_date               >= l_effective_date;
  --
  -- supervisor cursor.
  --
  CURSOR csr_supervisor IS
    SELECT ROWID
    FROM   per_assignments_f p
    WHERE  (p.business_group_id = p_business_group_id OR
            NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    p.supervisor_id = p_person_id;
  --
  -- recruiter cursor
  --
  CURSOR csr_recruiter IS
    SELECT ROWID
    FROM   per_assignments_f p
    WHERE  p.recruiter_id = p_person_id
    AND    (p.business_group_id = p_business_group_id OR
            NVL(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y');
  --
  -- vacancies cursor
  --
  CURSOR csr_vacancies IS
    SELECT ROWID
    FROM   per_vacancies pv
    WHERE (pv.business_group_id = p_business_group_id OR
           nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
    AND    pv.recruiter_id      = p_person_id
    AND    pv.date_from        >= p_date_start;
  --
  -- comments cursor
  --
  CURSOR csr_comments IS
    SELECT ROWID
    FROM hr_comments h
    WHERE EXISTS (SELECT 'comments exist'
                  FROM   per_all_assignments_f paf
                  WHERE  h.comment_id = paf.comment_id
                  AND    paf.business_group_id +0 = p_business_group_id
                  AND    paf.person_id            = p_person_id
                  AND    paf.period_of_placement_date_start = p_date_start);
  --
  -- assignments cursor
  --
  -- VT #438579 03/05/79 added assignment_id
  --
  CURSOR csr_assignments1 IS
    SELECT ROWID,
           assignment_id
    FROM   per_all_assignments_f paf
    WHERE  paf.business_group_id +0 = p_business_group_id
    AND    paf.person_id            = p_person_id
    AND    paf.period_of_placement_date_start = p_date_start;
  --
  -- assignment cursor for entries update
  --
  CURSOR csr_assignments2 IS
    SELECT assignment_id,
           effective_start_date,
           ROWID
    FROM   per_all_assignments_f
    WHERE  person_id            = p_person_id
    AND    business_group_id +0 = p_business_group_id
    AND    effective_end_date   = p_date_start - 1
    AND    assignment_type      = 'C'   -- 3194314
    FOR UPDATE OF effective_end_date;
  --
  -- applications cursor
  --
  CURSOR csr_applications IS
    SELECT ROWID
    FROM per_applications pap
    WHERE EXISTS (SELECT 'row exists'
                  FROM   per_all_assignments_f paf
                  WHERE  paf.person_id            = p_person_id
                  AND    paf.business_group_id +0 = p_business_group_id
                  AND    paf.effective_end_date   = p_date_start - 1
                  AND    pap.application_id       = paf.application_id);
  --
  -- person cursor
  --
  CURSOR csr_person IS
    SELECT p.rowid,
           effective_end_date
    FROM   per_people_f p
    WHERE  p.person_id            = p_person_id
    AND    p.effective_start_date >= p_date_start;
  --
  -- new_person
  --
  CURSOR csr_new_person IS
    SELECT p.rowid
    FROM   per_people_f p
    WHERE  p.person_id          = p_person_id
    AND    p.effective_end_date = p_date_start -1;
  --
  CURSOR csr_assignment_rate_values IS
    SELECT pgr.rowid
    FROM   pay_grade_rules_f pgr
    WHERE  EXISTS (SELECT 'X'
                   FROM   per_assignments_f paf
                   WHERE  pgr.grade_or_spinal_point_id = paf.assignment_id
                   and    paf.business_group_id + 0    = p_business_group_id
                   AND    paf.person_id                = p_person_id);
  --
  CURSOR csr_periods_of_placement IS
    SELECT pp.rowid
    FROM   per_periods_of_placement pp
    WHERE  pp.person_id  = p_person_id
    AND    pp.date_start = p_date_start;
  --
  CURSOR csr_pop_back_to_back (p_date_start IN DATE) IS
    SELECT pp.period_of_placement_id
    FROM   per_periods_of_placement pp
    WHERE  pp.person_id  = p_person_id
    AND    pp.actual_termination_date = p_date_start -1;
  --
  CURSOR csr_pos_back_to_back (p_date_start IN DATE) IS
    SELECT ps.period_of_service_id
    FROM   per_periods_of_service ps
    WHERE  ps.person_id  = p_person_id
    AND    ps.actual_termination_date = p_date_start -1;
  --

  -- Change  for the bug 6460093 starts here
  CURSOR csr_pdped_start is
  SELECT pop.date_start
    FROM per_periods_of_placement pop
  WHERE pop.person_id = p_person_id
    AND p_effective_date between pop.date_start and
    nvl(pop.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY'));

  -- Change  for the bug 6460093 ends here

  CURSOR csr_get_person_type (p_system_person_type IN CHAR) IS
    SELECT person_type_id
    FROM   per_person_types
    WHERE  business_group_id = p_business_group_id
    AND    system_person_type = p_system_person_type
    AND    default_flag = 'Y';

  --
  --
  -- Changes start for the bug 7110731

  CURSOR csr_get_cwk_type (p_sys_person_type IN CHAR) IS
    SELECT pt.person_type_id
    FROM   per_person_types pt, per_person_type_usages_f ptu
    WHERE  pt.person_type_id = ptu.person_type_id
    AND    pt.business_group_id = p_business_group_id
    AND    pt.system_person_type = p_sys_person_type
    AND    ptu.person_id = p_person_id
    AND    p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date;

  l_person_type_id1 number;

  -- Changes end for the bug 7110731
  --

  CURSOR csr_get_ptu_details IS
    SELECT ptu.person_type_usage_id,
           ptu.object_version_number
    FROM   per_person_type_usages_f ptu,
           per_person_types pt
    WHERE  ptu.person_id = p_person_id
    AND    pt.person_type_id = ptu.person_type_Id
    AND    pt.system_person_type = 'CWK'
    AND    p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date;
  --
  cursor csr_asg_sec is
  select paf.assignment_id, paf.effective_start_date
    from per_all_assignments_f paf
   where paf.person_id = p_person_id
     and paf.business_group_id +0 = p_business_group_id
     and paf.assignment_type <> 'B'; -- Added For Bug # 6630290

BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  hr_utility.set_location(l_proc||' date_start = '||p_date_start,11);
  hr_utility.set_location(l_proc||' eff date   = '||p_effective_date,12);
  --
  l_effective_date := TRUNC(p_effective_date);
  l_date_start     := TRUNC(p_effective_date);
  --
  hr_utility.set_location(l_proc,20);
  --
  FOR supervisor_rec IN csr_supervisor LOOP
    --
    hr_utility.set_location(l_proc,60);
    --
    UPDATE per_all_assignments_f paf
    SET    paf.supervisor_id = NULL
    WHERE  paf.rowid         = supervisor_rec.rowid;
    --
    IF sql%notfound THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_placement');
      hr_utility.set_message_token('STEP',1);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,70);
  --
  FOR recruiter_rec IN csr_recruiter LOOP
    --
    hr_utility.set_location(l_proc,80);
    --
    UPDATE per_all_assignments_f paf
    SET    paf.recruiter_id  = NULL
    WHERE  paf.rowid         = recruiter_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_placement');
      hr_utility.set_message_token('STEP',2);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,90);
  --
  FOR vacancies_rec IN csr_vacancies LOOP
    --
    hr_utility.set_location(l_proc,100);
    --
    UPDATE per_all_vacancies pv
    SET    pv.recruiter_id = NULL
    WHERE  pv.rowid        = vacancies_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_placement');
      hr_utility.set_message_token('STEP',3);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,110);
  --
  FOR assignment_rate_rec in csr_assignment_rate_values LOOP
    --
    hr_utility.set_location(l_proc,120);
    --
    DELETE from pay_grade_rules_f pgr
    WHERE  pgr.rowid = assignment_rate_rec.rowid;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,130);
  --
  FOR comments_rec IN csr_comments LOOP
    --
    hr_utility.set_location(l_proc,140);
    --
    DELETE FROM hr_comments h
    WHERE  h.rowid = comments_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','cancel_placement');
      hr_utility.set_message_token('STEP',4);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,150);
  --
  FOR requisition_rec IN csr_requisitions LOOP
    --
    hr_utility.set_location(l_proc,160);
    --
    UPDATE per_requisitions pr
    SET    pr.person_id = NULL
    WHERE  pr.rowid = requisition_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_placement');
      hr_utility.set_message_token('STEP',5);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,170);
  --
  FOR events_rec IN csr_events LOOP
    --
    hr_utility.set_location(l_proc,180);
    --
    DELETE FROM per_bookings pb
    WHERE  pb.rowid = events_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_placement');
      hr_utility.set_message_token('STEP',6);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,190);
  --
  FOR budget_rec IN csr_budget_values LOOP
    --
    hr_utility.set_location(l_proc,200);
    --
    DELETE FROM per_assignment_budget_values_f pab
    WHERE  pab.rowid = budget_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_placement');
      hr_utility.set_message_token('STEP',7);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP budget_value;
  --
  hr_utility.set_location(l_proc,210);
  --
  FOR payment_rec IN csr_payment LOOP
    --
    hr_utility.set_location(l_proc,220);
    --
    DELETE FROM pay_personal_payment_methods ppm
    WHERE  ppm.rowid = payment_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','do_cancel_placement');
      hr_utility.set_message_token('STEP',8);
      hr_utility.raise_error;
      --
    end if;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,230);
  --
  FOR assignment1_rec IN csr_assignments1 LOOP
    --
    hr_utility.set_location(l_proc,240);
    --
    DELETE FROM per_spinal_point_placements_f spp
    WHERE spp.assignment_id = assignment1_rec.assignment_id;
    --
    hr_utility.set_location(l_proc,250);
    --
    DELETE FROM pay_cost_allocations_f pca
    WHERE pca.assignment_id = assignment1_rec.assignment_id;
    --
    hr_utility.set_location(l_proc,260);
    --
    DELETE FROM per_all_assignments_f paf
    WHERE paf.rowid = assignment1_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','cancel_placement');
      hr_utility.set_message_token('STEP',9);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,270);
  --
  FOR applicantions_rec IN csr_applications LOOP
    --
    hr_utility.set_location(l_proc,280);
    --
    UPDATE per_applications pap
    SET    pap.date_end = NULL
    WHERE  pap.rowid = applicantions_rec.rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','cancel_placement');
      hr_utility.set_message_token('STEP',10);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,320);
  --
  -- Change for the bug 6460093 starts here
  OPEN csr_pdped_start;
  FETCH csr_pdped_start into c_effective_start_date;
  CLOSE csr_pdped_start;
  -- Change for the bug 6460093 ends here

  OPEN csr_periods_of_placement;
  --
  LOOP
    --
    hr_utility.set_location(l_proc,330);
    --
    FETCH csr_periods_of_placement INTO l_rowid;
    --
    EXIT WHEN csr_periods_of_placement%NOTFOUND;
    --
    DELETE FROM per_periods_of_placement
    WHERE rowid = l_rowid;
    --
    IF SQL%NOTFOUND THEN
      --
      CLOSE csr_periods_of_placement;
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','cancel_placement');
      hr_utility.set_message_token('STEP',11);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,340);
  --
  IF csr_periods_of_placement%ROWCOUNT <1 THEN
    --
    CLOSE csr_periods_of_placement;
    --
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','cancel_placement');
    hr_utility.set_message_token('STEP',12);
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE csr_periods_of_placement;
  --
  hr_utility.set_location(l_proc,350);
  --
  -- Check that there is not a previous period of placement
  -- record that ended the day before the current period of placement
  -- record. I.e is a back to back hire.
  --
  OPEN csr_pop_back_to_back(p_date_start => p_date_start);
  FETCH csr_pop_back_to_back INTO l_dummy_id;
  --
  IF csr_pop_back_to_back%FOUND THEN
    --
    hr_utility.set_location(l_proc,353);
    --
    l_pop_back_to_back := TRUE;
    --
  ELSE
    --
    -- As there no back to back records for period of placements
    -- check that there is not a record for period of service
    -- that ends the day before the period of placement record
    -- being canceled.
    --
    hr_utility.set_location(l_proc,355);
    --
    l_pop_back_to_back := FALSE;
    --
    OPEN  csr_pos_back_to_back (p_date_start => p_date_start);
    FETCH csr_pos_back_to_back INTO l_dummy_id;
    --
    IF csr_pos_back_to_back%FOUND THEN
      --
      hr_utility.set_location(l_proc,356);
      --
      l_pos_back_to_back := TRUE;
      --
    ELSE
      --
      hr_utility.set_location(l_proc,357);
      --
      l_pos_back_to_back := FALSE;
      --
    END IF;
    --
    CLOSE csr_pos_back_to_back;
    --
  END IF;
  --
  CLOSE csr_pop_back_to_back;
  --
  if NOT l_pop_back_to_back then  -- 3194314
    FOR assignment2_rec IN csr_assignments2 LOOP
      --
      hr_utility.set_location(l_proc,300);
      --
      UPDATE per_all_assignments_f paf
      SET   paf.effective_end_date = l_end_of_time
      WHERE paf.rowid = assignment2_rec.rowid;
      --
      hr_utility.set_location(l_proc,310);
      --
    END LOOP;
  end if;
  --
  hr_utility.set_location(l_proc,360);
  --
  FOR person_rec IN csr_person LOOP
    --
    l_person_rec_found := TRUE;
    --
    hr_utility.set_location(l_proc,370);
    --
    IF l_pop_back_to_back THEN
      --
      hr_utility.set_location(l_proc,380);
      --
      IF person_rec.effective_end_date = hr_general.end_of_time THEN
        --
        hr_utility.set_location(l_proc,390);
        --
        OPEN  csr_get_person_type (p_system_person_type => 'EX_CWK');
        FETCH csr_get_person_type INTO l_person_type_id;
        --
        CLOSE csr_get_person_type;
        --

        --changes start for bug 7110731
        OPEN csr_get_cwk_type (p_sys_person_type => 'CWK');
        FETCH csr_get_cwk_type INTO l_person_type_id1;
        CLOSE csr_get_cwk_type;

        UPDATE per_person_type_usages_f
        SET    person_type_id = l_person_type_id
        WHERE  person_id      = p_person_id
        AND    person_type_id= l_person_type_id1
        AND    p_date_start BETWEEN effective_start_date
                                AND effective_end_date;
        --changes end for bug 7110731

         UPDATE per_people_f   -- 3194314
            SET current_npw_flag = null
               ,effective_start_date = p_date_start   -- in case DT udpates exist
         WHERE rowid = person_rec.rowid;
        --
      ELSE -- #1998140
        --
        hr_utility.set_location(l_proc,400);
        --
        DELETE FROM per_people_f
        WHERE rowid = person_rec.rowid;
        --
      END IF;
      --

    ELSIF l_pos_back_to_back  then -- 3194314
         -- this is a back-to-back with Employee/Cwk

      IF person_rec.effective_end_date = hr_general.end_of_time THEN

         -- it should restore the EX_EMP record instead of removing it
         hr_utility.set_location(l_proc,405);
         --
         UPDATE per_people_f
            SET npw_number = null,
                effective_start_date = p_date_start,  -- in case DT updates exist
                current_npw_flag = null,
                per_information7 = 'INCL'
         WHERE  rowid = person_rec.rowid;

        --
      ELSE -- #1998140
        --
        hr_utility.set_location(l_proc,406);
        --
        DELETE FROM per_people_f
        WHERE rowid = person_rec.rowid;
        --
      END IF;
      --
      -- << 3194314

    ELSE
      --
      hr_utility.set_location(l_proc,410);
      --
      DELETE FROM per_people_f
      WHERE rowid = person_rec.rowid;
      --
    END IF;
    --
    hr_utility.set_location(l_proc,420);
    --
    IF SQL%NOTFOUND THEN
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','cancel_placement');
      hr_utility.set_message_token('STEP',13);
      hr_utility.raise_error;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,430);
  --
  IF NOT l_person_rec_found THEN
    --
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','cancel_placement');
    hr_utility.set_message_token('STEP',14);
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc,440);
  --
  if NOT l_pos_back_to_back then -- 3194314 this should not get executed if b2b emp/cwk

   FOR new_person_rec IN csr_new_person LOOP

    --
    hr_utility.set_location(l_proc,450);
    --
    l_new_person_found := TRUE;
    --
    IF NOT l_pop_back_to_back THEN
      --
      hr_utility.set_location(l_proc,460);
      --
      UPDATE per_people_f
      SET    effective_end_date = l_end_of_time
      WHERE  rowid = new_person_rec.rowid;
      --
    END IF;
    --
    hr_utility.set_location(l_proc,470);
    --
    IF sql%ROWCOUNT <1 then
      --
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','cancel_placement');
      hr_utility.set_message_token('STEP',15);
      hr_utility.raise_error;
      --
    END IF;
    --
   END LOOP;
  end if; -- << 3194314

  --
  hr_utility.set_location(l_proc,480);
  --
  IF NOT l_new_person_found THEN
    --
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','cancel_placement');
    hr_utility.set_message_token('STEP',16);
    hr_utility.raise_error;
    --
  END IF;
  --
  -- If there are no back to back records for
  -- period of placements or period of service then
  -- cancel the current CWK placement record
  --
  IF NOT l_pop_back_to_back AND
     NOT l_pos_back_to_back THEN
    --
    hr_utility.set_location(l_proc,490);
    --
    hr_per_type_usage_internal.cancel_person_type_usage
      (p_effective_date  	  => l_date_start
	     ,p_person_id 		       => p_person_id
	     ,p_system_person_type => 'CWK');
  --

      --Added for the bug 6460093
    --This finds out any system person type of OTHER records
    --which is end dated while creating a placement
    --and updates the end date to end of time while
    --cancelling the placement

      upd_person_type_usage_end_date(c_effective_start_date-1
                                   ,p_person_id
                                   ,p_system_person_type => 'OTHER');

    --Change for the bug 6460093 ends here

  -- If there are back to back records for period of service
  -- then delete the current CWK record from per_person_type_usages_f
  -- table.
  --
 -- bug fix 6992346
--  If there are back to back records for period of service
-- and period of placements then
 elsif NOT l_pop_back_to_back AND l_pos_back_to_back THEN
     hr_utility.set_location(l_proc,491);
     hr_utility.set_location('l_date_start '||l_date_start,491);
         --
    hr_per_type_usage_internal.cancel_person_type_usage
      (p_effective_date  	  => l_date_start
	     ,p_person_id 		       => p_person_id
	     ,p_system_person_type => 'CWK');


   ELSIF l_pos_back_to_back and l_pop_back_to_back THEN
    --ELSIF l_pos_back_to_back  THEN
    --
    hr_utility.set_location(l_proc,500);
    --
    OPEN csr_get_ptu_details;
    FETCH csr_get_ptu_details INTO l_person_type_usage_id,
                                   l_object_version_number;
    --
    IF csr_get_ptu_details%FOUND THEN
      --
      hr_utility.set_location(l_proc,510);
      --
      hr_per_type_usage_internal.delete_person_type_usage
        (p_validate              => FALSE
        ,p_person_type_usage_id  => l_person_type_usage_id
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => hr_api.g_zap
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date);
      --
    END IF;
    --
  END IF;
    -- end of fix 6992346
  --
  per_cancel_hire_or_apl_pkg.update_person_list(p_person_id => p_person_id);
  --
  for asg_sec_rec in csr_asg_sec loop
    --
    hr_utility.set_location(l_proc,300);
    -- do some security maintenance.
    -- reset the security access(per_person_list) for this assignment
    hr_security_internal.add_to_person_list(
                         p_effective_date => asg_sec_rec.effective_start_date
                        ,p_assignment_id  => asg_sec_rec.assignment_id);
    --
  end loop;
  --
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END do_cancel_placement;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION return_legislation_code
  (p_person_id  IN NUMBER ) RETURN VARCHAR2 IS
  --
  -- Declare cursor
  --
  CURSOR csr_leg_code IS
    SELECT pbg.legislation_code
      FROM per_business_groups pbg
         , per_people_f per
     WHERE per.person_id = p_person_id
       AND pbg.business_group_id = per.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  VARCHAR2(150);
  l_proc              VARCHAR2(72)  :=  g_package||'return_legislation_code';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'person_id'
    ,p_argument_value     => p_person_id);
  --
  OPEN  csr_leg_code;
  FETCH csr_leg_code INTO l_legislation_code;
  --
  IF csr_leg_code%notfound THEN
    --
    -- The primary key is invalid therefore we must error
    --
    CLOSE csr_leg_code;
    --
    fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc,20);
  --
  CLOSE csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 999);
  --
  RETURN l_legislation_code;
  --
END return_legislation_code;
--
END per_cancel_hire_or_apl_pkg;

/
