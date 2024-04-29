--------------------------------------------------------
--  DDL for Package Body BEN_CUSTOM_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CUSTOM_FORMULA" as
/* $Header: bencustf.pkb 120.0 2005/05/28 03:55:51 appldev noship $ */
--
/*
This package is to be used to deliver custom formula examples.
see bencustf.sql for delivering formula functions.

Function overview
*****************
contact_valid
-------------
  This function allows formula to test validity of
  contact types. I.E. Do I have a spouse who is over
  25 years old. If so if she causes a boundary event
  then create a temporal event.
*/
--
g_package varchar2(30) := 'ben_custom_formula.';
--
function get_age_change_life_event
  (p_business_group_id in number,
   p_effective_date    in date) return number is
  --
  cursor c1 is
    select ler.ler_id
    from   ben_ler_f ler
    where  ler.business_group_id = p_business_group_id
    and    ler.typ_cd = 'DRVDAGE'
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date;
  --
  l_ler_id number;
  l_proc varchar2(80) := g_package||'get_age_change_life_event';
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  open c1;
    --
    fetch c1 into l_ler_id;
    --
  close c1;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
  return l_ler_id;
  --
end get_age_change_life_event;
--
function get_person_id
  (p_assignment_id  in number,
   p_effective_date in date) return number is
  --
  l_person_id number;
  --
  cursor c1 is
    select paf.person_id
    from   per_all_assignments_f paf
    where  paf.assignment_id = p_assignment_id
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
  --
  l_proc varchar2(80) := g_package||'get_person_id';
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  hr_utility.set_location('Assignment ID :'||p_assignment_id,10);
  hr_utility.set_location('Effective Date :'||p_effective_date,10);
  --
  open c1;
    --
    fetch c1 into l_person_id;
    --
  close c1;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
  hr_utility.set_location('Person ID :'||l_person_id,10);
  return l_person_id;
  --
end get_person_id;
--
function get_spouses_age
  (p_person_id      in number,
   p_contact_type   in varchar2,
   p_effective_date in date) return date is
  --
  cursor c_per_spouse is
    select per.date_of_birth
      from per_contact_relationships ctr,
           per_all_people_f per
     where ctr.person_id = p_person_id
       and per.person_id = ctr.contact_person_id
       and ctr.personal_flag = 'Y'
       and ctr.contact_type = 'S'
       and p_effective_date
           between per.effective_start_date
           and     per.effective_end_date;
  --
  l_date_of_birth date;
  --
  l_proc varchar2(80) := g_package||'get_spouses_age';
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  hr_utility.set_location('p_contact_type :'||p_contact_type,10);
  hr_utility.set_location('p_effective_date :'||p_effective_date,10);
  hr_utility.set_location('p_person_id :'||p_person_id,10);
  --
  if p_contact_type = 'PS' then
    --
    open c_per_spouse;
      --
      fetch c_per_spouse into l_date_of_birth;
      --
    close c_per_spouse;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  hr_utility.set_location('dob :'||l_date_of_birth,10);
  --
  return l_date_of_birth;
  --
end get_spouses_age;
--
function contact_valid
  (p_assignment_id      in number, -- Context
   p_effective_date     in date, -- Context
   p_business_group_id  in number, -- Context
   p_pgm_id             in number, -- Context
   p_pl_typ_id          in number, -- Context
   p_pl_id              in number, -- Context
   p_opt_id             in number, -- Context
   p_contact_type       in varchar2,
   p_min_age_val        in number,
   p_max_age_val        in number,
   p_age_det_cd         in varchar2, -- Add extra variables that may be needed
   p_age_det_rl         in number, -- Add extra variables that may be needed
   p_age_uom            in varchar2, -- Add extra variables that may be needed
   p_rndg_cd            in varchar2, -- Add extra variables that may be needed
   p_rndg_rl            in number, -- Add extra variables that may be needed
   p_create_tmprl_event in varchar2 default 'N') return varchar2 is
  --
  l_proc                  varchar2(80) := g_package||'contact_valid';
  l_person_id             number;
  l_dob                   date;
  l_age                   number;
  l_ler_id                number;
  l_ptnl_ler_for_per_id   number;
  l_object_version_number number;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- We only support contact types that we support through the derived age
  -- factor form (BENFCTRS).
  --
  if p_contact_type not in ('IA','P','PC1',
                            'PD1','PCO','PDO',
                            'PS','PCY','PDY') then
    --
    -- Person is not valid
    --
    return 'N';
    --
  end if;
  --
  -- Get the person_id first
  --
  l_person_id := get_person_id(p_assignment_id  => p_assignment_id,
                               p_effective_date => p_effective_date);
  --
  hr_utility.set_location('Person ID is '||l_person_id,10);
  --
  -- Get the spouses date of birth
  --
  l_dob := get_spouses_age(p_person_id      => l_person_id,
                           p_contact_type   => p_contact_type,
                           p_effective_date => p_effective_date);
  --
  if l_dob is null then
    --
    hr_utility.set_location('Spouses Age is null',10);
    return 'N';
    --
  end if;
  --
  -- Determine what date we are going to use in this case assume effective date
  -- and calculate the persons age
  --
  l_age := months_between(p_effective_date,l_dob) / 12;
  --
  -- Now lets assume if the person we are trying to validate has an age that
  -- falls out of the range then we should create a life event.
  --
  if p_create_tmprl_event = 'Y' and
     (l_age < nvl(p_min_age_val,l_age) or
     l_age >= nvl(p_max_age_val,l_age+1)) then
    --
    -- Create a temporal life event of age changed for the contact we are
    -- processing.
    --
    l_ler_id := get_age_change_life_event
                  (p_business_group_id => p_business_group_id,
                   p_effective_date    => p_effective_date);
    --
    ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
      (p_validate                 => false,
       p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
       p_lf_evt_ocrd_dt           => p_effective_date,
       p_ptnl_ler_for_per_stat_cd => 'DTCTD',
       p_ler_id                   => l_ler_id,
       p_person_id                => l_person_id,
       p_business_group_id        => p_business_group_id,
       p_object_version_number    => l_object_version_number,
       p_effective_date           => p_effective_date,
       p_program_application_id   => fnd_global.prog_appl_id,
       p_program_id               => fnd_global.conc_program_id,
       p_request_id               => fnd_global.conc_request_id,
       p_program_update_date      => p_effective_date,
       p_ntfn_dt                  => trunc(p_effective_date),
       p_dtctd_dt                 => p_effective_date);
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
  return 'Y';
  --
end contact_valid;
--
end ben_custom_formula;

/
